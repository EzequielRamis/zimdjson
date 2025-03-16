const std = @import("std");
const zimdjson = @import("zimdjson");
const tracy = @import("tracy");
const Parser = zimdjson.ondemand.FullParser(.default);

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const args = try std.process.argsAlloc(arena.allocator());
    defer std.process.argsFree(arena.allocator(), args);

    if (args.len == 1) return;

    var tracy_alloc = tracy.tracyAllocator(std.heap.c_allocator);
    const allocator = tracy_alloc.allocator();

    const path = args[1];

    var parser = Parser.init;
    defer parser.deinit(allocator);

    // const rand = std.crypto.random;
    while (true) {
        var tracer = tracy.traceNamed(@src(), "parser");
        defer tracer.end();
        const file = try std.fs.openFileAbsolute(path, .{});
        defer file.close();
        // const index = rand.uintLessThan(u8, 100);
        _ = try parser.parseFromReader(allocator, file.reader().any());
        // const created_at = try document.at(index).at("reportedOn").getString();
        // tracy.messageCopy(created_at);
    }
}
