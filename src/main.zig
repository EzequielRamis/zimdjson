const std = @import("std");
const builtin = @import("builtin");
const shared = @import("shared.zig");
const types = @import("types.zig");
const Indexer = @import("indexer.zig");
const Prefixes = @import("prefixes.zig");
const TapeBuilder = @import("builder.zig");
const simd = std.simd;
const cpu = builtin.cpu;
const testing = std.testing;

const Allocator = std.mem.Allocator;

pub fn fromSlice(allocator: Allocator, document: []const u8) !void {
    // stage 1
    var indexer = Indexer.init(allocator, document);
    defer indexer.deinit();
    try indexer.index();

    // const prefixes = Prefixes.init(indexer);

    // // stage 2
    // var tape = TapeBuilder.init(allocator, prefixes);
    // defer tape.deinit();

    // try tape.build();
}

pub fn fromFile(allocator: Allocator, path: []const u8) !void {
    const file = try std.fs.cwd().openFile(path, .{});
    const len = (try file.metadata()).size();

    const buffer = try allocator.alignedAlloc(u8, types.Vector.LEN_BYTES, len);
    defer allocator.free(buffer);

    _ = try file.read(buffer);
    try fromSlice(allocator, buffer);
}

pub fn main() !void {
    // var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    // const gpa = general_purpose_allocator.allocator();
    const malloc = std.heap.c_allocator;
    const args = try std.process.argsAlloc(malloc);
    defer std.process.argsFree(malloc, args);

    try fromFile(malloc, args[1]);
}
