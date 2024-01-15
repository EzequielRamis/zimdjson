const std = @import("std");
const builtin = @import("builtin");
const shared = @import("shared.zig");
const Indexer = @import("indexer.zig").Indexer;
const builder = @import("builder.zig");
const simd = std.simd;
const cpu = builtin.cpu;
const testing = std.testing;
const vector = shared.vector;
const vector_size = shared.vector_size;

pub fn fromSlice(input: []const u8) !void {
    // stage 1
    var indexer = Indexer.init(std.heap.page_allocator);
    defer indexer.deinit();

    var i: usize = 0;
    while (i < shared.partialChunk(input.len)) : (i += vector_size) {
        const chunk: vector = input[i..][0..vector_size].*;
        const structural_chars = indexer.identify(chunk);
        try indexer.extract(i, structural_chars);
    }
    var eof_chunk = [_]u8{' '} ** vector_size;
    const sub_chunk = eof_chunk[0..(input.len - i)];
    @memcpy(sub_chunk, input[i..input.len]);
    const structural_chars = indexer.identify(eof_chunk);
    try indexer.extract(i, structural_chars);

    // stage 2
    var tape = builder.Tape.init(std.heap.page_allocator, input, indexer.indexes);
    try tape.build();
    defer tape.deinit();
}

pub fn fromFile(path: []const u8) !void {
    const file = try std.fs.cwd().openFile(path, .{});
    const len = (try file.metadata()).size();

    const buffer = try std.heap.page_allocator.alloc(u8, len);
    defer std.heap.page_allocator.free(buffer);

    _ = try file.read(buffer);
    try fromSlice(buffer);
}

pub fn main() !void {
    try fromFile("tests/foo.json");
}
