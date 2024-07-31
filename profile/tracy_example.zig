const std = @import("std");
const zimdjson = @import("zimdjson");
const tracy = @import("tracy");
const DOM = zimdjson.DOM;

pub fn main() !void {
    var tracy_alloc = tracy.tracyAllocator(std.heap.c_allocator);
    const allocator = tracy_alloc.allocator();

    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();

    const rand = std.crypto.random;
    const path = "../simdjson-data/jsonexamples/twitter.json";
    while (true) {
        const index = rand.uintLessThan(u8, 100);
        const document = try parser.load(path);
        const created_at = try document.at("statuses").at(index).at("created_at").getString();
        tracy.messageCopy(created_at);
    }
}
