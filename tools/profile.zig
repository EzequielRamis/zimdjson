const std = @import("std");
const zimdjson = @import("zimdjson");
const tracy = @import("tracy");
const Parser = zimdjson.ondemand.FullParser(.reader_only);

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());

    if (args.len == 1) return;

    var tracy_alloc = tracy.tracyAllocator(init.gpa);
    const allocator = tracy_alloc.allocator();

    const path = args[1];

    var parser = Parser.init;
    defer parser.deinit(allocator);

    // const rand = std.crypto.random;
    while (true) {
        var tracer = tracy.traceNamed(@src(), "parser");
        defer tracer.end();
        const file = try std.Io.Dir.openFileAbsolute(init.io, path, .{});
        defer file.close(init.io);
        var read_buf: [8192]u8 = undefined;
        var file_reader = file.reader(init.io, &read_buf);
        // const index = rand.uintLessThan(u8, 100);
        _ = try parser.parseFromReader(allocator, &file_reader.interface);
        // const created_at = try document.at(index).at("reportedOn").getString();
        // tracy.messageCopy(created_at);
    }
}
