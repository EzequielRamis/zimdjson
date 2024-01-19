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
const mask = shared.mask;

pub fn fromSlice(document: []const u8) !void {
    // stage 1
    var indexer = Indexer.init(std.heap.page_allocator);
    defer indexer.deinit();

    var i: usize = 0;
    while (i < shared.partialChunk(document.len)) : (i += vector_size) {
        const chunk: vector = document[i..][0..vector_size].*;
        const structural_chars = indexer.identify(chunk);
        try indexer.extract(i, structural_chars);
    }
    var eof_chunk = [_]u8{0} ** vector_size;
    const remainder_len = document.len - i;
    const sub_chunk = eof_chunk[0..remainder_len];
    @memcpy(sub_chunk, document[i..document.len]);
    var structural_chars = indexer.identify(eof_chunk);
    const zero_mask = (@as(mask, 1) << @truncate(remainder_len)) -| 1;
    structural_chars &= zero_mask;
    try indexer.extract(i, structural_chars);

    // stage 2
    var tape = builder.Tape.init(std.heap.page_allocator, document, indexer.indexes);
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
