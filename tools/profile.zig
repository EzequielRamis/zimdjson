const std = @import("std");
const zimdjson = @import("zimdjson");
const tracy = @import("tracy");
const dom = zimdjson.dom;
const ondemand = zimdjson.ondemand;
const Reader = zimdjson.io.Reader(.{});

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const args = try std.process.argsAlloc(arena.allocator());
    defer std.process.argsFree(arena.allocator(), args);

    if (args.len == 1) return;

    var tracy_alloc = tracy.tracyAllocator(std.heap.c_allocator);
    const allocator = tracy_alloc.allocator();

    const path = args[1];
    var parser = dom.Parser(.{ .length_hint = 1024 * 1024 * 1024 * 2 }).init(allocator);
    // var parser = ondemand.Parser(.{}).init(allocator);
    defer parser.deinit();

    // const rand = std.crypto.random;
    while (true) {
        // const index = rand.uintLessThan(u8, 100);
        _ = try parser.parse(path);
        // const created_at = try document.at(index).at("reportedOn").getString();
        // tracy.messageCopy(created_at);
    }
}
