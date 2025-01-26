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
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    const json = try allocator.alloc(u8, (try file.stat()).size + zimdjson.recommended_padding);
    _ = try file.readAll(json);

    var parser = ondemand.parserFromSlice(.{
        .assume_padding = true,
    }).init(allocator);
    defer parser.deinit();

    // const rand = std.crypto.random;
    while (true) {
        var tracer = tracy.traceNamed(@src(), "parser");
        defer tracer.end();
        // const file = try std.fs.openFileAbsolute(path, .{});
        // defer file.close();
        // const index = rand.uintLessThan(u8, 100);
        _ = try parser.parse(json);
        // const created_at = try document.at(index).at("reportedOn").getString();
        // tracy.messageCopy(created_at);
    }
}
