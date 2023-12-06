const std = @import("std");
const builtin = @import("builtin");
const shared = @import("shared.zig");
const Indexer = @import("indexer.zig").Indexer;
const simd = std.simd;
const cpu = builtin.cpu;
const testing = std.testing;
const vector = shared.vector;
const vector_size = shared.vector_size;

pub fn fromSlice(input: []const u8) !void {
    var indexer = Indexer.init(std.heap.page_allocator);
    defer indexer.deinit();
    var i: usize = 0;
    std.debug.print("{}, {}\n", .{ input.len, shared.partialChunk(input.len) });
    while (i < shared.partialChunk(input.len)) : (i += vector_size) {
        const chunk: vector = input[i..][0..vector_size].*;
        const structural_chars = indexer.identify(chunk);
        std.debug.print("{s}\n", .{input[i..][0..vector_size].*});
        std.debug.print("{b:0>32}\n", .{shared.reverseMask(structural_chars)});
        try indexer.extract(i, structural_chars);
    }
    var eof_chunk = [_]u8{' '} ** vector_size;
    var sub_chunk = eof_chunk[0..(input.len - i)];
    @memcpy(sub_chunk, input[i..input.len]);
    const structural_chars = indexer.identify(eof_chunk);
    std.debug.print("{s}\n", .{eof_chunk});
    std.debug.print("{b:0>32}\n", .{shared.reverseMask(structural_chars)});
    try indexer.extract(i, structural_chars);

    for (indexer.indexes.items) |item| {
        std.debug.print("{} ", .{item});
    }
    std.debug.print("\n", .{});
}

pub fn fromFile(path: []const u8) !void {
    const file = try std.fs.cwd().openFile(path, .{});
    const len = (try file.metadata()).size();
    var buffer: [vector_size]u8 = undefined;

    var indexer = Indexer.init(std.heap.page_allocator);
    defer indexer.deinit();

    var i: usize = 0;
    std.debug.print("{}, {}\n", .{ len, shared.partialChunk(len) });
    while (i < shared.partialChunk(len)) : (i += vector_size) {
        _ = try file.read(&buffer);
        const chunk: vector = buffer;
        const structural_chars = indexer.identify(chunk);
        std.debug.print("{s}\n", .{buffer});
        std.debug.print("{b:0>32}\n", .{shared.reverseMask(structural_chars)});
        try indexer.extract(i, structural_chars);
    }
    _ = try file.read(&buffer);
    var eof_chunk = [_]u8{' '} ** vector_size;
    var sub_chunk = eof_chunk[0..(len - i)];
    @memcpy(sub_chunk, buffer[0..(len - i)]);
    const structural_chars = indexer.identify(eof_chunk);
    std.debug.print("{s}\n", .{eof_chunk});
    std.debug.print("{b:0>32}\n", .{shared.reverseMask(structural_chars)});
    try indexer.extract(i, structural_chars);

    for (indexer.indexes.items) |item| {
        std.debug.print("{} ", .{item});
    }
    std.debug.print("\n", .{});
}

pub fn main() !void {
    try fromSlice(
        \\{ "\\\"Nam[{": [116, "\\\\", 234, "true", false], "t": "\\\"" }
    );
    // try fromFile("tests/foo.json");
}
