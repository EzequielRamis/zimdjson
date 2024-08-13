const std = @import("std");
const zimdjson = @import("zimdjson");

var arena: std.heap.ArenaAllocator = undefined;
var file: zimdjson.io.Reader(.{}).slice = undefined;
var parser: zimdjson.ondemand.Parser(.{}) = undefined;

export fn zimdjson_ondemand__init() void {
    arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    file = zimdjson.io.Reader(.{}).readFileAlloc(
        allocator,
        std.fs.cwd(),
        "../simdjson-data/jsonexamples/twitter.json",
    ) catch unreachable;
    parser = zimdjson.ondemand.Parser(.{}).init(allocator);
}
export fn zimdjson_ondemand__prerun() void {}

export fn zimdjson_ondemand__run() void {
    const document = parser.parse(file) catch unreachable;
    const i = std.crypto.random.uintLessThan(u8, 100);
    _ = document.at("statuses").at(i).at("created_at").getString() catch unreachable;
}

export fn zimdjson_ondemand__postrun() void {}

export fn zimdjson_ondemand__deinit() void {
    arena.allocator().free(file);
    parser.deinit();
}
