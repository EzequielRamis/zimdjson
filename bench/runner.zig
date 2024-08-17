//! Benchmarking tool from https://github.com/andrewrk/poop
//
// The MIT License (Expat)
//
// Copyright (c) Poop Contributors
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

const std = @import("std");
const builtin = @import("builtin");
const PERF = std.os.linux.PERF;
const fd_t = std.posix.fd_t;
const pid_t = std.os.pid_t;
const assert = std.debug.assert;
const MAX_SAMPLES = 10000;

const benchmarks = @import("benchmarks").tuple;

const PerfMeasurement = struct {
    name: []const u8,
    config: PERF.COUNT.HW,
};

const perf_measurements = [_]PerfMeasurement{
    .{ .name = "cpu_cycles", .config = PERF.COUNT.HW.CPU_CYCLES },
    .{ .name = "instructions", .config = PERF.COUNT.HW.INSTRUCTIONS },
    .{ .name = "cache_references", .config = PERF.COUNT.HW.CACHE_REFERENCES },
    .{ .name = "cache_misses", .config = PERF.COUNT.HW.CACHE_MISSES },
    .{ .name = "branch_misses", .config = PERF.COUNT.HW.BRANCH_MISSES },
};

const Events = struct {
    init: *const fn ([]u8) void,
    prerun: *const fn () void,
    run: *const fn () void,
    postrun: *const fn () void,
    deinit: *const fn () void,
    memusage: *const fn () usize,
};

const Command = struct {
    name: []const u8,
    measurements: Measurements,
    sample_count: usize,
    events: Events,

    const Measurements = struct {
        throughput: Measurement,
        wall_time: Measurement,
        mem_required: Measurement,
        cpu_cycles: Measurement,
        instructions: Measurement,
        cache_references: Measurement,
        cache_misses: Measurement,
        branch_misses: Measurement,
    };
};

const Sample = struct {
    throughput: u64,
    wall_time: u64,
    mem_required: u64,
    cpu_cycles: u64,
    instructions: u64,
    cache_references: u64,
    cache_misses: u64,
    branch_misses: u64,

    pub fn lessThanContext(comptime field: []const u8) type {
        return struct {
            fn lessThan(
                _: void,
                lhs: Sample,
                rhs: Sample,
            ) bool {
                return @field(lhs, field) < @field(rhs, field);
            }
        };
    }
};

const ColorMode = enum {
    auto,
    never,
    ansi,
};

pub fn main() !void {
    var arena_instance = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_instance.deinit();
    const arena = arena_instance.allocator();

    const stdout = std.io.getStdOut();
    var stdout_bw = std.io.bufferedWriter(stdout.writer());
    const stdout_w = stdout_bw.writer();

    var commands: [benchmarks.len]Command = undefined;
    const max_nano_seconds: u64 = std.time.ns_per_s * 10;
    const color: ColorMode = .auto;

    const args = try std.process.argsAlloc(arena);
    const path = args[1];

    const file = try std.fs.openFileAbsolute(path, .{});
    const file_stat = try file.stat();
    const file_size = file_stat.size;

    inline for (&commands, benchmarks) |*c, b| {
        c.* = .{
            .name = b.name,
            .measurements = undefined,
            .sample_count = undefined,
            .events = .{
                .init = b.init,
                .prerun = b.prerun,
                .run = b.run,
                .postrun = b.postrun,
                .deinit = b.deinit,
                .memusage = b.memusage,
            },
        };
    }

    var bar = try progress.ProgressBar.init(arena, stdout);

    const tty_conf: std.io.tty.Config = switch (color) {
        .auto => std.io.tty.detectConfig(stdout),
        .never => .no_color,
        .ansi => .escape_codes,
    };

    var perf_fds = [1]fd_t{-1} ** perf_measurements.len;
    var perf_ids = [1]u64{0} ** perf_measurements.len;
    defer for (&perf_fds) |*perf_fd| {
        std.posix.close(perf_fd.*);
    };

    const PERF_EVENT_IOC_ID = 536_880_135;
    for (perf_measurements, &perf_fds, &perf_ids) |measurement, *perf_fd, *perf_id| {
        var attr: std.os.linux.perf_event_attr = .{
            .type = PERF.TYPE.HARDWARE,
            .config = @intFromEnum(measurement.config),
            .flags = .{
                .disabled = true,
                .exclude_kernel = true,
                .exclude_hv = true,
                .inherit = true,
            },
            .read_format = (1 << 2) | (1 << 3),
        };
        perf_fd.* = std.posix.perf_event_open(&attr, 0, -1, perf_fds[0], 0) catch |err| {
            std.debug.panic("unable to open perf event: {s}\n", .{@errorName(err)});
        };
        if (std.os.linux.ioctl(perf_fd.*, PERF_EVENT_IOC_ID, @intFromPtr(perf_id)) == -1) @panic("ioctl(PERF.EVENT_IOC.ID)");
    }

    var samples_buf: [MAX_SAMPLES]Sample = undefined;

    var timer = std.time.Timer.start() catch @panic("need timer to work");

    for (&commands, 1..) |*command, i| {
        const min_samples = 3;

        command.events.init(path);
        defer command.events.deinit();

        const first_start = timer.read();
        var sample_index: usize = 0;
        while ((sample_index < min_samples or
            (timer.read() - first_start) < max_nano_seconds) and
            sample_index < samples_buf.len) : (sample_index += 1)
        {
            if (tty_conf != .no_color) try bar.render();

            command.events.prerun();

            _ = std.os.linux.ioctl(perf_fds[0], PERF.EVENT_IOC.RESET, PERF.IOC_FLAG_GROUP);
            _ = std.os.linux.ioctl(perf_fds[0], PERF.EVENT_IOC.ENABLE, PERF.IOC_FLAG_GROUP);

            const start = timer.read();

            command.events.run();

            const end = timer.read();

            _ = std.os.linux.ioctl(perf_fds[0], PERF.EVENT_IOC.DISABLE, PERF.IOC_FLAG_GROUP);

            const mem_required = command.events.memusage() -| file_size;

            command.events.postrun();

            const format = readPerfFd(perf_fds[0]);

            samples_buf[sample_index] = .{
                .throughput = file_size * 1000_000_000 / (end - start),
                .wall_time = end - start,
                .mem_required = mem_required,
                .cpu_cycles = format.values[0].value,
                .instructions = format.values[1].value,
                .cache_references = format.values[2].value,
                .cache_misses = format.values[3].value,
                .branch_misses = format.values[4].value,
            };

            if (tty_conf != .no_color) {
                bar.estimate = est_total: {
                    const cur_samples: u64 = sample_index + 1;
                    const ns_per_sample = (timer.read() - first_start) / cur_samples;
                    const estimate = std.math.divCeil(u64, max_nano_seconds, ns_per_sample) catch unreachable;
                    break :est_total @intCast(@min(MAX_SAMPLES, @max(cur_samples, estimate, min_samples)));
                };
                bar.current += 1;
            }
        }

        if (tty_conf != .no_color) {
            // reset bar for next command
            try bar.clear();
            bar.current = 0;
            bar.estimate = 1;
        }

        const all_samples = samples_buf[0..sample_index];

        command.measurements = .{
            .throughput = Measurement.compute(all_samples, "throughput", .throughput),
            .wall_time = Measurement.compute(all_samples, "wall_time", .nanoseconds),
            .mem_required = Measurement.compute(all_samples, "mem_required", .bytes),
            .cpu_cycles = Measurement.compute(all_samples, "cpu_cycles", .count),
            .instructions = Measurement.compute(all_samples, "instructions", .count),
            .cache_references = Measurement.compute(all_samples, "cache_references", .count),
            .cache_misses = Measurement.compute(all_samples, "cache_misses", .count),
            .branch_misses = Measurement.compute(all_samples, "branch_misses", .count),
        };
        command.sample_count = all_samples.len;

        {
            try tty_conf.setColor(stdout_w, .bold);
            try stdout_w.print("Benchmark {d}", .{i});
            try tty_conf.setColor(stdout_w, .dim);
            try stdout_w.print(" ({d} runs, size of json: ", .{command.sample_count});
            try printUnit(stdout_w, @floatFromInt(file_size), .bytes, 0, false, false);
            try stdout_w.print(")", .{});
            try tty_conf.setColor(stdout_w, .reset);
            try stdout_w.writeAll(":");
            try stdout_w.print(" {s} ", .{command.name});
            try stdout_w.writeAll("\n");

            try tty_conf.setColor(stdout_w, .bold);
            try stdout_w.writeAll("  measurement");
            try stdout_w.writeByteNTimes(' ', 25 - "  measurement".len);
            try tty_conf.setColor(stdout_w, .bright_green);
            try stdout_w.writeAll("mean");
            try tty_conf.setColor(stdout_w, .reset);
            try tty_conf.setColor(stdout_w, .bold);
            try stdout_w.writeAll(" ± ");
            try tty_conf.setColor(stdout_w, .green);
            try stdout_w.writeAll("σ");
            try tty_conf.setColor(stdout_w, .reset);

            try tty_conf.setColor(stdout_w, .bold);
            try stdout_w.writeByteNTimes(' ', 14);
            try tty_conf.setColor(stdout_w, .cyan);
            try stdout_w.writeAll("min");
            try tty_conf.setColor(stdout_w, .reset);
            try tty_conf.setColor(stdout_w, .bold);
            try stdout_w.writeAll(" … ");
            try tty_conf.setColor(stdout_w, .magenta);
            try stdout_w.writeAll("max");
            try tty_conf.setColor(stdout_w, .reset);

            try tty_conf.setColor(stdout_w, .bold);
            try stdout_w.writeByteNTimes(' ', 20 - " outliers".len);
            try tty_conf.setColor(stdout_w, .bright_yellow);
            try stdout_w.writeAll("outliers");
            try tty_conf.setColor(stdout_w, .reset);

            if (commands.len >= 2) {
                try tty_conf.setColor(stdout_w, .bold);
                try stdout_w.writeByteNTimes(' ', 9);
                try stdout_w.writeAll("delta");
                try tty_conf.setColor(stdout_w, .reset);
            }

            try stdout_w.writeAll("\n");

            inline for (@typeInfo(Command.Measurements).Struct.fields) |field| {
                const measurement = @field(command.measurements, field.name);
                const first_measurement = if (i == 1)
                    null
                else
                    @field(commands[0].measurements, field.name);
                try printMeasurement(tty_conf, stdout_w, measurement, field.name, first_measurement, commands.len);
            }

            try stdout_bw.flush(); // 💩
        }
    }

    try stdout_bw.flush(); // 💩
}

fn parseCmd(list: *std.ArrayList([]const u8), cmd: []const u8) !void {
    var it = std.mem.tokenizeScalar(u8, cmd, ' ');
    while (it.next()) |s| try list.append(s);
}

const Format = extern struct {
    const Value = extern struct {
        value: u64,
        id: u64,
    };
    len: u64,
    values: [perf_measurements.len]Value,
};

fn readPerfFd(fd: fd_t) Format {
    var result: Format = undefined;
    const n = std.posix.read(fd, std.mem.asBytes(&result)) catch |err| {
        std.debug.panic("unable to read perf fd: {s}\n", .{@errorName(err)});
    };
    assert(n == @sizeOf(Format));
    assert(result.len == perf_measurements.len);
    return result;
}

const Measurement = struct {
    q1: u64,
    median: u64,
    q3: u64,
    min: u64,
    max: u64,
    mean: f64,
    std_dev: f64,
    outlier_count: u64,
    sample_count: u64,
    unit: Unit,

    const Unit = enum {
        nanoseconds,
        bytes,
        count,
        throughput, // 1byte/ns == 1GB/s
    };

    fn compute(samples: []Sample, comptime field: []const u8, unit: Unit) Measurement {
        std.mem.sort(Sample, samples, {}, Sample.lessThanContext(field).lessThan);
        // Compute stats
        var total: u64 = 0;
        var min: u64 = std.math.maxInt(u64);
        var max: u64 = 0;
        for (samples) |s| {
            const v = @field(s, field);
            total += v;
            if (v < min) min = v;
            if (v > max) max = v;
        }
        const mean = @as(f64, @floatFromInt(total)) / @as(f64, @floatFromInt(samples.len));
        var std_dev: f64 = 0;
        for (samples) |s| {
            const v = @field(s, field);
            const delta: f64 = @as(f64, @floatFromInt(v)) - mean;
            std_dev += delta * delta;
        }
        if (samples.len > 1) {
            std_dev /= @floatFromInt(samples.len - 1);
            std_dev = @sqrt(std_dev);
        }

        const q1 = @field(samples[samples.len / 4], field);
        const q3 = if (samples.len < 4) @field(samples[samples.len - 1], field) else @field(samples[samples.len - samples.len / 4], field);
        // Tukey's Fences outliers
        var outlier_count: u64 = 0;
        const iqr: f64 = @floatFromInt(q3 - q1);
        const low_fence = @as(f64, @floatFromInt(q1)) - 1.5 * iqr;
        const high_fence = @as(f64, @floatFromInt(q3)) + 1.5 * iqr;
        for (samples) |s| {
            const v: f64 = @floatFromInt(@field(s, field));
            if (v < low_fence or v > high_fence) outlier_count += 1;
        }
        return .{
            .q1 = q1,
            .median = @field(samples[samples.len / 2], field),
            .q3 = q3,
            .mean = mean,
            .min = min,
            .max = max,
            .std_dev = std_dev,
            .outlier_count = outlier_count,
            .sample_count = samples.len,
            .unit = unit,
        };
    }
};

fn printMeasurement(
    tty_conf: std.io.tty.Config,
    w: anytype,
    m: Measurement,
    name: []const u8,
    first_m: ?Measurement,
    command_count: usize,
) !void {
    try w.print("  {s}", .{name});

    var buf: [200]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);
    var count: usize = 0;

    const color_enabled = tty_conf != .no_color;
    const spaces = 32 - ("  (mean  ):".len + name.len + 2);
    try w.writeByteNTimes(' ', spaces);
    if (m.unit != .throughput) try w.writeByteNTimes(' ', 2);
    try tty_conf.setColor(w, .bright_green);
    try printUnit(fbs.writer(), m.mean, m.unit, m.std_dev, color_enabled, true);
    try w.writeAll(fbs.getWritten());
    count += fbs.pos;
    fbs.pos = 0;
    try tty_conf.setColor(w, .reset);
    try w.writeAll(" ± ");
    try tty_conf.setColor(w, .green);
    try printUnit(fbs.writer(), m.std_dev, m.unit, 0, color_enabled, true);
    try w.writeAll(fbs.getWritten());
    count += fbs.pos;
    fbs.pos = 0;
    try tty_conf.setColor(w, .reset);

    try w.writeByteNTimes(' ', 66 - ("  measurement      ".len + count + 3));
    count = 0;

    try tty_conf.setColor(w, .cyan);
    try printUnit(fbs.writer(), @floatFromInt(m.min), m.unit, m.std_dev, color_enabled, true);
    try w.writeAll(fbs.getWritten());
    count += fbs.pos;
    fbs.pos = 0;
    try tty_conf.setColor(w, .reset);
    try w.writeAll(" … ");
    try tty_conf.setColor(w, .magenta);
    try printUnit(fbs.writer(), @floatFromInt(m.max), m.unit, m.std_dev, color_enabled, true);
    try w.writeAll(fbs.getWritten());
    count += fbs.pos;
    fbs.pos = 0;
    try tty_conf.setColor(w, .reset);

    try w.writeByteNTimes(' ', 46 - (count + 1));
    if (m.unit == .throughput) try w.writeByteNTimes(' ', 2);
    count = 0;

    const outlier_percent = @as(f64, @floatFromInt(m.outlier_count)) / @as(f64, @floatFromInt(m.sample_count)) * 100;
    if (outlier_percent >= 10)
        try tty_conf.setColor(w, .yellow)
    else
        try tty_conf.setColor(w, .dim);
    try fbs.writer().print("{d: >4.0} ({d: >2.0}%)", .{ m.outlier_count, outlier_percent });
    try w.writeAll(fbs.getWritten());
    count += fbs.pos;
    fbs.pos = 0;
    try tty_conf.setColor(w, .reset);

    try w.writeByteNTimes(' ', 19 - (count + 1));

    // ratio
    if (command_count > 1) {
        if (first_m) |f| {
            const half = blk: {
                const z = getStatScore95(m.sample_count + f.sample_count - 2);
                const n1: f64 = @floatFromInt(m.sample_count);
                const n2: f64 = @floatFromInt(f.sample_count);
                const normer = std.math.sqrt(1.0 / n1 + 1.0 / n2);
                const numer1 = (n1 - 1) * (m.std_dev * m.std_dev);
                const numer2 = (n2 - 1) * (f.std_dev * f.std_dev);
                const df = n1 + n2 - 2;
                const sp = std.math.sqrt((numer1 + numer2) / df);
                break :blk (z * sp * normer) * 100 / f.mean;
            };
            const diff_mean_percent = (m.mean - f.mean) * 100 / f.mean;
            // significant only if full interval is beyond abs 1% with the same sign
            const is_sig = blk: {
                if (diff_mean_percent >= 1 and (diff_mean_percent - half) >= 1) {
                    break :blk true;
                } else if (diff_mean_percent <= -1 and (diff_mean_percent + half) <= -1) {
                    break :blk true;
                } else {
                    break :blk false;
                }
            };
            if (m.unit == .throughput) {
                if (m.mean <= f.mean) {
                    if (is_sig) {
                        try w.writeAll("💩");
                        try tty_conf.setColor(w, .bright_red);
                    } else {
                        try tty_conf.setColor(w, .dim);
                        try w.writeAll("  ");
                    }
                    try w.writeAll("-");
                } else {
                    if (is_sig) {
                        try tty_conf.setColor(w, .bright_yellow);
                        try w.writeAll("⚡");
                        try tty_conf.setColor(w, .bright_green);
                    } else {
                        try tty_conf.setColor(w, .dim);
                        try w.writeAll("  ");
                    }
                    try w.writeAll("+");
                }
            } else if (m.mean > f.mean) {
                if (is_sig) {
                    try w.writeAll("💩");
                    try tty_conf.setColor(w, .bright_red);
                } else {
                    try tty_conf.setColor(w, .dim);
                    try w.writeAll("  ");
                }
                try w.writeAll("+");
            } else {
                if (is_sig) {
                    try tty_conf.setColor(w, .bright_yellow);
                    try w.writeAll("⚡");
                    try tty_conf.setColor(w, .bright_green);
                } else {
                    try tty_conf.setColor(w, .dim);
                    try w.writeAll("  ");
                }
                try w.writeAll("-");
            }
            try fbs.writer().print("{d: >5.1}% ± {d: >4.1}%", .{ @abs(diff_mean_percent), half });
            try w.writeAll(fbs.getWritten());
            count += fbs.pos;
            fbs.pos = 0;
        } else {
            try tty_conf.setColor(w, .dim);
            try w.writeAll("0%");
        }
    }

    try tty_conf.setColor(w, .reset);
    try w.writeAll("\n");
}

fn printNum3SigFigs(w: anytype, num: f64, comptime whitespace: bool) !void {
    if (num >= 1000 or num == 0) {
        const fmt = if (whitespace) "{d: >4.0}" else "{d:.0}";
        try w.print(fmt, .{num});
        // TODO Do we need special handling here since it overruns 3 sig figs?
    } else if (num >= 100) {
        const fmt = if (whitespace) "{d: >4.0}" else "{d:.0}";
        try w.print(fmt, .{num});
    } else if (num >= 10) {
        const fmt = if (whitespace) "{d: >3.1}" else "{d:.1}";
        try w.print(fmt, .{num});
    } else {
        const fmt = if (whitespace) "{d: >3.2}" else "{d:.2}";
        try w.print(fmt, .{num});
    }
}

fn printUnit(w: anytype, x: f64, unit: Measurement.Unit, std_dev: f64, color_enabled: bool, comptime whitespace_enabled: bool) !void {
    _ = std_dev; // TODO something useful with this
    const num = x;
    var val: f64 = 0;
    const color: []const u8 = progress.EscapeCodes.dim ++ progress.EscapeCodes.white;
    const right_pad = if (whitespace_enabled) " " else "";
    var ustr: []const u8 = "  ";
    if (num >= 1000_000_000_000) {
        val = num / 1000_000_000_000;
        ustr = switch (unit) {
            .count => "T" ++ right_pad,
            .nanoseconds => "ks",
            .bytes => "TB",
            .throughput => "TB/s", // unreachable
        };
    } else if (num >= 1000_000_000) {
        val = num / 1000_000_000;
        ustr = switch (unit) {
            .count => "G" ++ right_pad,
            .nanoseconds => "s" ++ right_pad,
            .bytes => "GB",
            .throughput => "GB/s",
        };
    } else if (num >= 1000_000) {
        val = num / 1000_000;
        ustr = switch (unit) {
            .count => "M" ++ right_pad,
            .nanoseconds => "ms",
            .bytes => "MB",
            .throughput => "MB/s",
        };
    } else if (num >= 1000) {
        val = num / 1000;
        ustr = switch (unit) {
            .count => "K" ++ right_pad,
            .nanoseconds => "us",
            .bytes => "KB",
            .throughput => "KB/s",
        };
    } else {
        val = num;
        ustr = switch (unit) {
            .count => " " ++ right_pad,
            .nanoseconds => "ns",
            .bytes => "B" ++ right_pad,
            .throughput => "B/s", // unreachable
        };
    }
    try printNum3SigFigs(w, val, whitespace_enabled);
    if (color_enabled) {
        try w.print("{s}{s}{s}", .{ color, ustr, progress.EscapeCodes.reset });
    } else {
        try w.writeAll(ustr);
    }
}

// Gets either the T or Z score for 95% confidence.
// If no `df` variable is provided, Z score is provided.
pub fn getStatScore95(df: ?u64) f64 {
    if (df) |dff| {
        const dfv: usize = @intCast(dff);
        if (dfv <= 30) {
            return t_table95_1to30[dfv - 1];
        } else if (dfv <= 120) {
            const idx_10s = @divFloor(dfv, 10);
            return t_table95_10s_10to120[idx_10s - 1];
        }
    }
    return 1.96;
}

const t_table95_1to30 = [_]f64{
    12.706,
    4.303,
    3.182,
    2.776,
    2.571,
    2.447,
    2.365,
    2.306,
    2.262,
    2.228,
    2.201,
    2.179,
    2.16,
    2.145,
    2.131,
    2.12,
    2.11,
    2.101,
    2.093,
    2.086,
    2.08,
    2.074,
    2.069,
    2.064,
    2.06,
    2.056,
    2.052,
    2.045,
    2.048,
    2.042,
};

const t_table95_10s_10to120 = [_]f64{
    2.228,
    2.086,
    2.042,
    2.021,
    2.009,
    2,
    1.994,
    1.99,
    1.987,
    1.984,
    1.982,
    1.98,
};

const progress = struct {
    const Spinner = struct {
        const Self = @This();
        pub const frames = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏";
        pub const frame1 = "⠋";
        pub const frame_count = frames.len / frame1.len;

        frame_idx: usize,

        pub fn init() Self {
            return Self{ .frame_idx = 0 };
        }

        pub fn get(self: *const Self) []const u8 {
            return frames[self.frame_idx * frame1.len ..][0..frame1.len];
        }

        pub fn next(self: *Self) void {
            self.frame_idx = (self.frame_idx + 1) % frame_count;
        }
    };

    const bar = "━";
    const half_bar_left = "╸";
    const half_bar_right = "╺";
    const TIOCGWINSZ: u32 = 0x5413; // https://docs.rs/libc/latest/libc/constant.TIOCGWINSZ.html
    const WIDTH_PADDING: usize = 100;

    const Winsize = extern struct {
        ws_row: c_ushort,
        ws_col: c_ushort,
        ws_xpixel: c_ushort,
        ws_ypixel: c_ushort,
    };

    pub fn getScreenWidth(stdout: std.posix.fd_t) usize {
        var winsize: Winsize = undefined;
        _ = std.os.linux.ioctl(stdout, TIOCGWINSZ, @intFromPtr(&winsize));
        return @intCast(winsize.ws_col);
    }

    pub const EscapeCodes = struct {
        pub const dim = "\x1b[2m";
        pub const pink = "\x1b[38;5;205m";
        pub const white = "\x1b[37m";
        pub const red = "\x1b[31m";
        pub const yellow = "\x1b[33m";
        pub const green = "\x1b[32m";
        pub const magenta = "\x1b[35m";
        pub const cyan = "\x1b[36m";
        pub const reset = "\x1b[0m";
        pub const erase_line = "\x1b[2K\r";
    };

    pub const ProgressBar = struct {
        const Self = @This();

        spinner: Spinner,
        current: u64,
        estimate: u64,
        stdout: std.fs.File,
        buf: std.ArrayList(u8),
        last_rendered: std.time.Instant,

        pub fn init(allocator: std.mem.Allocator, stdout: std.fs.File) !Self {
            const width = getScreenWidth(stdout.handle);
            const buf = try std.ArrayList(u8).initCapacity(allocator, width + WIDTH_PADDING);
            return Self{
                .spinner = Spinner.init(),
                .last_rendered = try std.time.Instant.now(),
                .current = 0,
                .estimate = 1,
                .stdout = stdout,
                .buf = buf,
            };
        }

        pub fn deinit(self: *Self) void {
            self.buf.deinit();
        }

        /// Clears then renders bar if enough time has passed since last render.
        pub fn render(self: *Self) !void {
            const now = try std.time.Instant.now();
            if (now.since(self.last_rendered) < 50 * std.time.ns_per_ms) {
                return;
            }
            try self.clear();
            self.last_rendered = now;
            const width = getScreenWidth(self.stdout.handle);
            if (width + WIDTH_PADDING > self.buf.capacity) {
                try self.buf.resize(width + WIDTH_PADDING);
            }
            var writer = self.buf.writer();
            const bar_width = width - Spinner.frame1.len - " 10000 runs ".len - " 100% ".len;
            const prog_len = (bar_width * 2) * self.current / self.estimate;
            const full_bars_len: usize = @intCast(prog_len / 2);

            try writer.print("{s}{s}{s} {d: >5} runs ", .{ EscapeCodes.cyan, self.spinner.get(), EscapeCodes.reset, self.current });
            self.spinner.next();

            try writer.print("{s}", .{EscapeCodes.pink}); // pink
            for (0..full_bars_len) |_| {
                try writer.print(bar, .{});
            }
            if (prog_len % 2 == 1) {
                try writer.print(half_bar_left, .{});
            }
            try writer.print("{s}{s}", .{ EscapeCodes.white, EscapeCodes.dim }); // white
            if (prog_len % 2 == 0) {
                try writer.print(half_bar_right, .{});
            }
            for (0..(bar_width - full_bars_len - 1)) |_| {
                try writer.print(bar, .{});
            }
            try writer.print("{s}", .{EscapeCodes.reset}); // reset
            try writer.print(" {d: >3.0}% ", .{
                @as(f64, @floatFromInt(self.current)) * 100 / @as(f64, @floatFromInt(self.estimate)),
            });
            try self.stdout.writeAll(self.buf.items[0..self.buf.items.len]);
        }

        pub fn clear(self: *Self) !void {
            try self.stdout.writeAll(EscapeCodes.erase_line); // clear and reset line
            self.buf.clearRetainingCapacity();
        }
    };
};
