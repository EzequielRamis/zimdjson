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

const benchmarks = @import("benchmarks");

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
    init: *const fn (std.Io, []u8) anyerror!void,
    prerun: *const fn (std.Io) anyerror!void,
    run: *const fn (std.Io) anyerror!void,
    postrun: *const fn (std.Io) anyerror!void,
    deinit: *const fn (std.Io) void,
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
        mem_allocated: Measurement,
        cpu_cycles: Measurement,
        instructions: Measurement,
        cache_references: Measurement,
        cache_misses: Measurement,
        branch_misses: Measurement,
    };
};

const Sample = struct {
    throughput: i96,
    wall_time: i96,
    mem_allocated: i96,
    cpu_cycles: i96,
    instructions: i96,
    cache_references: i96,
    cache_misses: i96,
    branch_misses: i96,

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

pub fn main(init: std.process.Init) !void {
    var arena_instance = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_instance.deinit();
    const arena = arena_instance.allocator();

    const stdout = std.Io.File.stdout();
    var stdout_buf: [1024]u8 = undefined;
    var stdout_w = stdout.writer(init.io, &stdout_buf);

    var commands: [benchmarks.wrappers.len]Command = undefined;
    const max_nano_seconds: i96 = std.time.ns_per_s * 10;
    const color: ColorMode = .auto;

    var args_it = init.minimal.args.iterate();
    _ = args_it.next();
    const path = try init.arena.allocator().dupe(u8, args_it.next().?);

    const file = try std.Io.Dir.openFileAbsolute(init.io, path, .{});
    const file_stat = try file.stat(init.io);
    const file_size = file_stat.size;

    inline for (&commands, benchmarks.wrappers, 0..) |*c, b, i| {
        // wrap functions
        const deinit_fn = if (@typeInfo(@TypeOf(b.deinit)).@"fn".params.len == 0)
            struct {
                fn f(_: std.Io) void {
                    b.deinit();
                }
            }.f
        else
            b.deinit;

        c.* = .{
            .name = benchmarks.names[i],
            .measurements = undefined,
            .sample_count = undefined,
            .events = .{
                .init = b.init,
                .prerun = b.prerun,
                .run = b.run,
                .postrun = b.postrun,
                .deinit = deinit_fn,
                .memusage = b.memusage,
            },
        };
    }

    var bar = try progress.ProgressBar.init(init.io, arena, stdout);

    const terminal_mode: std.Io.Terminal.Mode = switch (color) {
        .auto => try std.Io.Terminal.Mode.detect(init.io, stdout, blk: {
            const no_color = init.environ_map.get("NO_COLOR") orelse break :blk false;
            if (no_color.len > 0) break :blk true else break :blk false;
        }, blk: {
            const clicolor_force = init.environ_map.get("CLICOLOR_FORCE") orelse break :blk false;
            if (clicolor_force.len > 0) break :blk true else break :blk false;
        }),
        .never => .no_color,
        .ansi => .escape_codes,
    };
    const terminal: std.Io.Terminal = .{ .mode = terminal_mode, .writer = &stdout_w.interface };

    try stdout_w.interface.writeAll("Benchmarking JSON Document ");
    try terminal.setColor(.bold);
    try stdout_w.interface.writeAll(std.fs.path.basename(path));
    try terminal.setColor(.reset);
    try stdout_w.interface.writeAll(" of size ");
    try terminal.setColor(.bold);
    try printUnit(&stdout_w.interface, @floatFromInt(file_size), .bytes, 0, false, false);
    try stdout_w.interface.writeAll("\n");
    try terminal.setColor(.reset);

    var perf_fds = [1]fd_t{-1} ** perf_measurements.len;
    var perf_ids = [1]u64{0} ** perf_measurements.len;
    defer for (&perf_fds) |*perf_fd| {
        _ = std.os.linux.close(perf_fd.*);
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

    var start_time = std.Io.Timestamp.now(init.io, .real);

    for (&commands, 1..) |*command, i| {
        const min_samples = 3;

        try @call(.never_inline, command.events.init, .{ init.io, path });
        defer @call(.never_inline, command.events.deinit, .{init.io});

        const first_start = start_time.untilNow(init.io, .real);
        var sample_index: usize = 0;
        var mem_allocated: u64 = 0;
        while ((sample_index < min_samples or
            (start_time.untilNow(init.io, .real).toNanoseconds() - first_start.toNanoseconds()) < max_nano_seconds) and
            sample_index < samples_buf.len) : (sample_index += 1)
        {
            if (terminal.mode != .no_color) try bar.render();

            try @call(.never_inline, command.events.prerun, .{init.io});

            _ = std.os.linux.ioctl(perf_fds[0], PERF.EVENT_IOC.RESET, PERF.IOC_FLAG_GROUP);
            _ = std.os.linux.ioctl(perf_fds[0], PERF.EVENT_IOC.ENABLE, PERF.IOC_FLAG_GROUP);

            const before_call_time = std.Io.Timestamp.now(init.io, .real);

            try @call(.never_inline, command.events.run, .{init.io});

            const end = before_call_time.untilNow(init.io, .real);

            _ = std.os.linux.ioctl(perf_fds[0], PERF.EVENT_IOC.DISABLE, PERF.IOC_FLAG_GROUP);

            if (sample_index == 0) mem_allocated = command.events.memusage() -| file_size;

            try @call(.never_inline, command.events.postrun, .{init.io});

            const format = readPerfFd(perf_fds[0]);

            const elapsed_ns = end.toNanoseconds();

            samples_buf[sample_index] = .{
                .throughput = if (elapsed_ns > 0) @divFloor(file_size * 1000_000_000, elapsed_ns) else 0,
                .wall_time = elapsed_ns,
                .mem_allocated = mem_allocated,
                .cpu_cycles = format.values[0].value,
                .instructions = format.values[1].value,
                .cache_references = format.values[2].value,
                .cache_misses = format.values[3].value,
                .branch_misses = format.values[4].value,
            };

            if (terminal.mode != .no_color) {
                bar.estimate = est_total: {
                    const cur_samples: i96 = sample_index + 1;
                    const ns_per_sample = @divFloor(start_time.toNanoseconds() - first_start.toNanoseconds(), cur_samples);
                    const estimate = std.math.divCeil(i96, max_nano_seconds, ns_per_sample) catch unreachable;
                    break :est_total @intCast(@min(MAX_SAMPLES, @max(cur_samples, estimate, min_samples)));
                };
                bar.current += 1;
            }
        }

        if (terminal.mode != .no_color) {
            // reset bar for next command
            try bar.clear();
            bar.current = 0;
            bar.estimate = 1;
        }

        const all_samples = samples_buf[0..sample_index];

        command.measurements = .{
            .throughput = Measurement.compute(all_samples, "throughput", .throughput),
            .wall_time = Measurement.compute(all_samples, "wall_time", .nanoseconds),
            .mem_allocated = Measurement.compute(all_samples, "mem_allocated", .bytes),
            .cpu_cycles = Measurement.compute(all_samples, "cpu_cycles", .count),
            .instructions = Measurement.compute(all_samples, "instructions", .count),
            .cache_references = Measurement.compute(all_samples, "cache_references", .count),
            .cache_misses = Measurement.compute(all_samples, "cache_misses", .count),
            .branch_misses = Measurement.compute(all_samples, "branch_misses", .count),
        };
        command.sample_count = all_samples.len;

        {
            try terminal.setColor(.bold);
            try stdout_w.interface.print("Benchmark {d}", .{i});
            try terminal.setColor(.dim);
            try stdout_w.interface.print(" ({d} runs)", .{command.sample_count});
            try terminal.setColor(.reset);
            try stdout_w.interface.writeAll(":");
            try stdout_w.interface.print(" {s} ", .{command.name});
            try stdout_w.interface.writeAll("\n");

            try terminal.setColor(.bold);
            try stdout_w.interface.writeAll("  measurement");
            for (0..25 - "  measurement".len) |_| try stdout_w.interface.writeByte(' ');
            try terminal.setColor(.bright_green);
            try stdout_w.interface.writeAll("mean");
            try terminal.setColor(.reset);
            try terminal.setColor(.bold);
            try stdout_w.interface.writeAll(" ± ");
            try terminal.setColor(.green);
            try stdout_w.interface.writeAll("σ");
            try terminal.setColor(.reset);

            try terminal.setColor(.bold);
            for (0..14) |_| try stdout_w.interface.writeByte(' ');
            try terminal.setColor(.cyan);
            try stdout_w.interface.writeAll("min");
            try terminal.setColor(.reset);
            try terminal.setColor(.bold);
            try stdout_w.interface.writeAll(" … ");
            try terminal.setColor(.magenta);
            try stdout_w.interface.writeAll("max");
            try terminal.setColor(.reset);

            try terminal.setColor(.bold);
            for (0..20 - "  outliers".len) |_| try stdout_w.interface.writeByte(' ');
            try terminal.setColor(.bright_yellow);
            try stdout_w.interface.writeAll("outliers");
            try terminal.setColor(.reset);

            if (commands.len >= 2) {
                try terminal.setColor(.bold);
                for (0..9) |_| try stdout_w.interface.writeByte(' ');
                try stdout_w.interface.writeAll("delta");
                try terminal.setColor(.reset);
            }

            try stdout_w.interface.writeAll("\n");

            inline for (@typeInfo(Command.Measurements).@"struct".fields) |field| {
                const measurement = @field(command.measurements, field.name);
                const first_measurement = if (i == 1)
                    null
                else
                    @field(commands[0].measurements, field.name);
                try printMeasurement(terminal, &stdout_w.interface, measurement, field.name, first_measurement, commands.len);
            }

            try stdout_w.flush(); // 💩
        }
    }

    try stdout_w.interface.writeAll("\n");
    try stdout_w.flush(); // 💩

    var results_dir_buf: [256]u8 = undefined;
    const results_dir = try std.fmt.bufPrint(&results_dir_buf, "bench/{s}/results", .{benchmarks.suite});

    var results_filepath_buf: [256]u8 = undefined;
    const results_filepath = try std.fmt.bufPrint(&results_filepath_buf, "bench/{s}/results/{s}.json", .{
        benchmarks.suite,
        std.fs.path.stem(path),
    });

    std.Io.Dir.cwd().createDir(init.io, results_dir, .default_dir) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };

    const results_file = try std.Io.Dir.cwd().createFile(init.io, results_filepath, .{
        .truncate = true,
    });
    defer results_file.close(init.io);
    const Results = [commands.len]struct {
        name: []const u8,
        measurements: Command.Measurements,
        sample_count: usize,
    };
    var results: Results = undefined;
    for (&results, &commands) |*result, command| {
        result.* = .{
            .name = command.name,
            .measurements = command.measurements,
            .sample_count = command.sample_count,
        };
    }
    const fmt = std.json.fmt(results, .{ .whitespace = .indent_2 });

    var writer = std.Io.Writer.Allocating.init(init.arena.allocator());
    try fmt.format(&writer.writer);
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
    q1: i96,
    median: i96,
    q3: i96,
    min: i96,
    max: i96,
    mean: f64,
    std_dev: f64,
    outlier_count: i96,
    sample_count: i96,
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
        var total: i96 = 0;
        var min: i96 = std.math.maxInt(i96);
        var max: i96 = 0;
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
        var outlier_count: i96 = 0;
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
    terminal: std.Io.Terminal,
    w: *std.Io.Writer,
    m: Measurement,
    name: []const u8,
    first_m: ?Measurement,
    command_count: usize,
) !void {
    try w.print("  {s}", .{name});

    var buf: [200]u8 = undefined;
    var fbs: std.Io.Writer = .fixed(&buf);
    var count: usize = 0;

    const color_enabled = terminal.mode != .no_color;
    const spaces = 32 - ("  (mean  ):".len + name.len + 2);
    for (0..spaces) |_| try w.writeByte(' ');
    if (m.unit != .throughput) for (0..2) |_| try w.writeByte(' ');
    try terminal.setColor(.bright_green);
    try printUnit(&fbs, m.mean, m.unit, m.std_dev, color_enabled, true);
    try w.writeAll(fbs.buffered());
    count += fbs.consumeAll();
    try terminal.setColor(.reset);
    try w.writeAll(" ± ");
    try terminal.setColor(.green);
    try printUnit(&fbs, m.std_dev, m.unit, 0, color_enabled, true);
    try w.writeAll(fbs.buffered());
    count += fbs.consumeAll();
    try terminal.setColor(.reset);

    for (0..66 - ("  measurement      ".len + count + 3)) |_| try w.writeByte(' ');
    count = 0;

    try terminal.setColor(.cyan);
    try printUnit(&fbs, @floatFromInt(m.min), m.unit, m.std_dev, color_enabled, true);
    try w.writeAll(fbs.buffered());
    count += fbs.consumeAll();
    try terminal.setColor(.reset);
    try w.writeAll(" … ");
    try terminal.setColor(.magenta);
    try printUnit(&fbs, @floatFromInt(m.max), m.unit, m.std_dev, color_enabled, true);
    try w.writeAll(fbs.buffered());
    count += fbs.consumeAll();
    try terminal.setColor(.reset);

    for (0..46 - (count + 1)) |_| try w.writeByte(' ');
    if (m.unit == .throughput) for (0..2) |_| try w.writeByte(' ');
    count = 0;

    const outlier_percent = @as(f64, @floatFromInt(m.outlier_count)) / @as(f64, @floatFromInt(m.sample_count)) * 100;
    if (outlier_percent >= 10)
        try terminal.setColor(.yellow)
    else
        try terminal.setColor(.dim);
    try fbs.print("{d: >4.0} ({d: >2.0}%)", .{ m.outlier_count, outlier_percent });
    try w.writeAll(fbs.buffered());
    count += fbs.consumeAll();
    try terminal.setColor(.reset);

    for (0..19 - (count + 1)) |_| try w.writeByte(' ');

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
                        try terminal.setColor(.bright_red);
                    } else {
                        try terminal.setColor(.dim);
                        try w.writeAll("  ");
                    }
                    try w.writeAll("-");
                } else {
                    if (is_sig) {
                        try terminal.setColor(.bright_yellow);
                        try w.writeAll("⚡");
                        try terminal.setColor(.bright_green);
                    } else {
                        try terminal.setColor(.dim);
                        try w.writeAll("  ");
                    }
                    try w.writeAll("+");
                }
            } else if (m.mean > f.mean) {
                if (is_sig) {
                    try w.writeAll("💩");
                    try terminal.setColor(.bright_red);
                } else {
                    try terminal.setColor(.dim);
                    try w.writeAll("  ");
                }
                try w.writeAll("+");
            } else {
                if (is_sig) {
                    try terminal.setColor(.bright_yellow);
                    try w.writeAll("⚡");
                    try terminal.setColor(.bright_green);
                } else {
                    try terminal.setColor(.dim);
                    try w.writeAll("  ");
                }
                try w.writeAll("-");
            }
            try fbs.print("{d: >5.1}% ± {d: >4.1}%", .{ @abs(diff_mean_percent), half });
            try w.writeAll(fbs.buffered());
            count += fbs.consumeAll();
        } else {
            try terminal.setColor(.dim);
            try w.writeAll("0%");
        }
    }

    try terminal.setColor(.reset);
    try w.writeAll("\n");
}

fn printNum3SigFigs(w: *std.Io.Writer, num: f64, comptime whitespace: bool) !void {
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

fn printUnit(w: *std.Io.Writer, x: f64, unit: Measurement.Unit, std_dev: f64, color_enabled: bool, comptime whitespace_enabled: bool) !void {
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
pub fn getStatScore95(df: ?i96) f64 {
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

        allocator: std.mem.Allocator,
        io: std.Io,
        spinner: Spinner,
        current: i96,
        estimate: i96,
        stdout: std.Io.File,
        buf: std.Io.Writer.Allocating,
        last_rendered: std.Io.Timestamp,

        pub fn init(io: std.Io, allocator: std.mem.Allocator, stdout: std.Io.File) !Self {
            const width = getScreenWidth(stdout.handle);
            const buf: std.Io.Writer.Allocating = try .initCapacity(allocator, width + WIDTH_PADDING);
            return Self{
                .io = io,
                .allocator = allocator,
                .spinner = Spinner.init(),
                .last_rendered = std.Io.Timestamp.now(io, .real),
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
            const now = std.Io.Timestamp.now(self.io, .real);

            if (self.last_rendered.durationTo(now).toNanoseconds() < 50 * std.time.ns_per_ms) {
                return;
            }
            try self.clear();
            self.last_rendered = now;
            const width = getScreenWidth(self.stdout.handle);
            if (width + WIDTH_PADDING > self.buf.writer.buffer.len) {
                try self.buf.ensureTotalCapacity(width + WIDTH_PADDING);
            }
            const bar_width = width - Spinner.frame1.len - " 10000 runs ".len - " 100% ".len;
            const prog_len = @divFloor((bar_width * 2) * self.current, self.estimate);
            const full_bars_len: usize = @intCast(@divFloor(prog_len, 2));

            try self.buf.writer.print("{s}{s}{s} {d: >5} runs ", .{ EscapeCodes.cyan, self.spinner.get(), EscapeCodes.reset, self.current });
            self.spinner.next();

            try self.buf.writer.print("{s}", .{EscapeCodes.pink}); // pink
            for (0..full_bars_len) |_| {
                try self.buf.writer.print(bar, .{});
            }
            if (@mod(prog_len, 2) == 1) {
                try self.buf.writer.print(half_bar_left, .{});
            }
            try self.buf.writer.print("{s}{s}", .{ EscapeCodes.white, EscapeCodes.dim }); // white
            if (@mod(prog_len, 2) == 0) {
                try self.buf.writer.print(half_bar_right, .{});
            }
            if (full_bars_len < bar_width) {
                if (@mod(prog_len, 2) == 0) {
                    try self.buf.writer.print(half_bar_right, .{});
                }
                for (0..(bar_width - full_bars_len - 1)) |_| {
                    try self.buf.writer.print(bar, .{});
                }
            }
            try self.buf.writer.print("{s}", .{EscapeCodes.reset}); // reset
            try self.buf.writer.print(" {d: >3.0}% ", .{
                @as(f64, @floatFromInt(self.current)) * 100 / @as(f64, @floatFromInt(self.estimate)),
            });
            var stdout_writer = self.stdout.writer(self.io, &.{});
            try stdout_writer.interface.writeAll(self.buf.written());
        }

        pub fn clear(self: *Self) !void {
            var writer = self.stdout.writer(self.io, &.{});
            try writer.interface.writeAll(EscapeCodes.erase_line); // clear and reset line
            self.buf.clearRetainingCapacity();
            try writer.interface.flush();
        }
    };
};
