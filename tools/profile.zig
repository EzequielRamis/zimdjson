const std = @import("std");
const zimdjson = @import("zimdjson");
const tracy = @import("tracy");
const dom = zimdjson.dom;
const ondemand = zimdjson.ondemand;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const args = try std.process.argsAlloc(arena.allocator());
    defer std.process.argsFree(arena.allocator(), args);

    if (args.len == 1) return;

    var tracy_alloc = tracy.tracyAllocator(std.heap.c_allocator);
    const allocator = tracy_alloc.allocator();

    const path = args[1];
    const temp = try std.fs.openFileAbsolute(path, .{});
    const size = (try temp.stat()).size;
    temp.close();

    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();

    try parser.ensureTotalCapacity(size);

    // const rand = std.crypto.random;
    while (true) {
        const file = try std.fs.openFileAbsolute(path, .{});
        defer file.close();
        // const index = rand.uintLessThan(u8, 100);
        _ = try parser.parseAssumeCapacity(file.reader());
        // const created_at = try document.at(index).at("reportedOn").getString();
        // tracy.messageCopy(created_at);
    }
}
