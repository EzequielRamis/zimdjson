const std = @import("std");
const zimdjson = @import("zimdjson");
const tracy = @import("tracy");
const DOM = zimdjson.DOM;
const OnDemand = zimdjson.OnDemand;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const args = try std.process.argsAlloc(arena.allocator());
    defer std.process.argsFree(arena.allocator(), args);

    var tracy_alloc = tracy.tracyAllocator(std.heap.c_allocator);
    const allocator = tracy_alloc.allocator();

    var parser = DOM.Parser.init(allocator);
    // var parser = OnDemand.Parser.init(allocator);

    defer parser.deinit();

    while (true) {
        const document = try parser.load(args[1]);
        _ = document;
    }
}
