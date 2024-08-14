const std = @import("std");
const zimdjson = @import("zimdjson");

var arena: std.heap.ArenaAllocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var file: zimdjson.io.Reader(.{}).slice = undefined;
var parser: zimdjson.ondemand.Parser(.{}) = undefined;
var i: u32 = undefined;
const allocator = arena.allocator();

export fn zimdjson__init() void {
    parser = zimdjson.ondemand.Parser(.{}).init(allocator);
    file = zimdjson.io.Reader(.{}).readFileAlloc(allocator, std.fs.cwd(), "../simdjson-data/jsonexamples/twitter.json") catch unreachable;
}

export fn zimdjson__prerun() void {
    i = std.crypto.random.uintLessThan(u32, 100);
}

export fn zimdjson__run() void {
    _ = parser.parse(file) catch unreachable;
}

export fn zimdjson__postrun() void {}

export fn zimdjson__deinit() void {
    arena.deinit();
}
