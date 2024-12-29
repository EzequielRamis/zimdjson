const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var json: []const u8 = undefined;
var parser = zimdjson.dom.Parser(.{
    .chunk_length = 1024 * 16 * 1,
    .length_hint = 1024 * 1024 * 1024 * 1,
}).init(allocator);

pub fn init(path: []const u8) !void {
    json = path;
}

pub fn prerun() !void {}

pub fn run() !void {
    _ = try parser.parse(json);
}

pub fn postrun() !void {}

pub fn deinit() void {
    parser.deinit();
}

pub fn memusage() usize {
    return traced.total;
}
