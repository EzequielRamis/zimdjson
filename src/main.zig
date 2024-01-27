const std = @import("std");
const builtin = @import("builtin");
const shared = @import("shared.zig");
const Indexer = @import("indexer.zig");
const Prefixes = @import("prefixes.zig");
const TapeBuilder = @import("builder.zig");
const simd = std.simd;
const cpu = builtin.cpu;
const testing = std.testing;
const vector = shared.vector;
const vector_size = shared.vector_size;
const mask = shared.mask;

const Allocator = std.mem.Allocator;

pub fn fromSlice(allocator: Allocator, document: []const u8) !void {
    // stage 1
    var timer = try std.time.Timer.start();
    var indexer = Indexer.init(allocator, document);
    defer indexer.deinit();
    try indexer.index();
    std.debug.print("Stage 1: {}\n", .{timer.lap()});

    const prefixes = Prefixes.init(indexer);

    // stage 2
    var tape = TapeBuilder.init(allocator, prefixes);
    defer tape.deinit();

    try tape.build();
    std.debug.print("Stage 2: {}\n", .{timer.lap()});
}

pub fn fromFile(allocator: Allocator, path: []const u8) !void {
    const file = try std.fs.cwd().openFile(path, .{});
    const len = (try file.metadata()).size();

    const buffer = try allocator.alloc(u8, len);
    defer allocator.free(buffer);

    _ = try file.read(buffer);
    try fromSlice(allocator, buffer);
}

pub fn main() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = general_purpose_allocator.allocator();
    const args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, args);

    try fromFile(gpa, args[1]);
}
