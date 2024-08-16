const std = @import("std");
const zimdjson = @import("zimdjson");

var arena: std.heap.ArenaAllocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var file: zimdjson.io.Reader(.{}).slice = undefined;
var parser: zimdjson.ondemand.Parser(.{}) = undefined;
const allocator = arena.allocator();

export fn zimdjson__load(ptr: [*c]const u8, len: usize) void {
    file = zimdjson.io.Reader(.{}).readFileAlloc(allocator, ptr[0..len]) catch @panic("file not found");
}

export fn zimdjson__init() void {
    parser = zimdjson.ondemand.Parser(.{}).init(allocator);
}

export fn zimdjson__prerun() void {}

export fn zimdjson__run() void {
    _ = parser.parse(file) catch unreachable;
}

export fn zimdjson__postrun() void {}

export fn zimdjson__deinit() void {
    arena.deinit();
}
