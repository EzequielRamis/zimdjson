const std = @import("std");

const NUM_SAMPLES = 1_000_000;
const MAX_NS = std.time.ns_per_s * 5;

var SAMPLES_BUF: [NUM_SAMPLES]Sample = undefined;
var PERF_FDS = [1]std.os.fd_t{-1} ** PERF_MEASUREMENTS.len;

const PERF_MEASUREMENTS = [_]PerfMeasurement{
    .{ .name = "cpu_cycles", .config = std.os.linux.PERF.COUNT.HW.CPU_CYCLES },
    .{ .name = "instructions", .config = std.os.linux.PERF.COUNT.HW.INSTRUCTIONS },
    .{ .name = "cache_references", .config = std.os.linux.PERF.COUNT.HW.CACHE_REFERENCES },
    .{ .name = "cache_misses", .config = std.os.linux.PERF.COUNT.HW.CACHE_MISSES },
    .{ .name = "branch_misses", .config = std.os.linux.PERF.COUNT.HW.BRANCH_MISSES },
};

const PerfMeasurement = struct {
    name: []const u8,
    config: std.os.linux.PERF.COUNT.HW,
};

const Sample = struct {
    cpu_cycles: u64,
    instructions: u64,
    cache_references: u64,
    cache_misses: u64,
    branch_misses: u64,
};

fn readPerfFd(fd: std.os.fd_t) usize {
    var result: usize = 0;
    const n = std.os.read(fd, std.mem.asBytes(&result)) catch |err| {
        std.debug.panic("unable to read perf fd: {s}\n", .{@errorName(err)});
    };
    std.debug.assert(n == @sizeOf(usize));
    return result;
}

pub fn start() void {
    for (PERF_MEASUREMENTS, 0..) |measurement, i| {
        var attr: std.os.linux.perf_event_attr = .{
            .type = std.os.linux.PERF.TYPE.HARDWARE,
            .config = @intFromEnum(measurement.config),
            .flags = .{
                .disabled = true,
                .exclude_kernel = true,
                .exclude_hv = true,
                .inherit = true,
                .enable_on_exec = true,
            },
        };
        PERF_FDS[i] = std.os.perf_event_open(&attr, 0, -1, PERF_FDS[0], std.os.linux.PERF.FLAG.FD_CLOEXEC) catch |err| {
            std.debug.panic("unable to open perf event: {s}\n", .{@errorName(err)});
        };
    }
    _ = std.os.linux.ioctl(PERF_FDS[0], std.os.linux.PERF.EVENT_IOC.RESET, std.os.linux.PERF.IOC_FLAG_GROUP);
    _ = std.os.linux.ioctl(PERF_FDS[0], std.os.linux.PERF.EVENT_IOC.ENABLE, std.os.linux.PERF.IOC_FLAG_GROUP);
}

pub fn lap() Sample {
    _ = std.os.linux.ioctl(PERF_FDS[0], std.os.linux.PERF.EVENT_IOC.DISABLE, std.os.linux.PERF.IOC_FLAG_GROUP);
    const cpu_cycles = readPerfFd(PERF_FDS[0]);
    const instructions = readPerfFd(PERF_FDS[1]);
    const cache_references = readPerfFd(PERF_FDS[2]);
    const cache_misses = readPerfFd(PERF_FDS[3]);
    const branch_misses = readPerfFd(PERF_FDS[4]);

    return .{
        .cpu_cycles = cpu_cycles,
        .instructions = instructions,
        .cache_references = cache_references,
        .cache_misses = cache_misses,
        .branch_misses = branch_misses,
    };
}

pub fn reset() void {
    for (PERF_MEASUREMENTS, 0..) |_, i| {
        std.os.close(PERF_FDS[i]);
        PERF_FDS[i] = -1;
    }
    start();
}
