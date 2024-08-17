const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var traced = TracedAllocator{ .wrapped = gpa.allocator() };
var file: zimdjson.io.Reader(.{}).slice = undefined;
var parser: zimdjson.ondemand.Parser(.{}) = undefined;
const allocator = traced.allocator();

export fn zimdjson__init(ptr: [*c]const u8, len: usize) void {
    file = zimdjson.io.Reader(.{}).readFileAlloc(allocator, ptr[0..len]) catch @panic("file not found");
    parser = zimdjson.ondemand.Parser(.{}).init(allocator);
}

export fn zimdjson__prerun() void {}

export fn zimdjson__run() void {
    _ = parser.parse(file) catch unreachable;
}

export fn zimdjson__postrun() void {}

export fn zimdjson__deinit() void {
    allocator.free(file);
    parser.deinit();
}

export fn zimdjson__memusage() usize {
    return traced.total;
}
