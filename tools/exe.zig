const std = @import("std");
const zimdjson = @import("zimdjson");
const tracy = @import("tracy");
const dom = zimdjson.dom;
const ondemand = zimdjson.ondemand;

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());

    const path = args[1];

    var parser = dom.FullParser(.default).init;
    defer parser.deinit(init.gpa);

    const file = try std.Io.Dir.openFileAbsolute(init.io, path, .{});
    defer file.close(init.io);

    var read_buf: [8192]u8 = undefined;
    var file_reader = file.reader(init.io, &read_buf);

    _ = try parser.parseFromReader(init.gpa, &file_reader.interface);
}
