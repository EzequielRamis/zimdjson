const std = @import("std");
const zimdjson = @import("zimdjson");

var arena: std.heap.ArenaAllocator = undefined;
var file: zimdjson.io.Reader(.{}).slice = undefined;
var parser: zimdjson.dom.Parser(.{}) = undefined;

export fn zimdjson_dom__init() void {
    arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    file = zimdjson.io.Reader(.{}).readFileAlloc(
        allocator,
        std.fs.cwd(),
        "../simdjson-data/jsonexamples/twitter.json",
    ) catch unreachable;
    // parser = zimdjson.dom.Parser(.{}).init(allocator);
}
export fn zimdjson_dom__prerun() void {
    parser = zimdjson.dom.Parser(.{}).init(arena.allocator());
}

export fn zimdjson_dom__run() void {
    const document = parser.parse(file) catch unreachable;
    const i = std.crypto.random.uintLessThan(u8, 100);
    _ = document.at("statuses").at(i).at("created_at").getString() catch unreachable;
}

export fn zimdjson_dom__postrun() void {}
export fn zimdjson_dom__deinit() void {
    arena.allocator().free(file);
    parser.deinit();
}
