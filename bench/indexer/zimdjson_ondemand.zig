const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var json: zimdjson.io.Reader(.{}).slice = undefined;
var parser = zimdjson.ondemand.Parser(.{}).init(allocator);

pub fn init(path: []const u8) void {
    json = zimdjson.io.Reader(.{}).readFileAlloc(allocator, path) catch @panic("file not found");
}

pub fn prerun() void {}

pub fn run() void {
    _ = parser.parse(json) catch unreachable;
}

pub fn postrun() void {}

pub fn deinit() void {
    allocator.free(json);
    parser.deinit();
}

pub fn memusage() usize {
    return traced.total;
}
