const std = @import("std");
const zimdjson = @import("zimdjson");
const tracy = @import("tracy");
const dom = zimdjson.dom;
const ondemand = zimdjson.ondemand;

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;
    const args = init.minimal.args;

    const path = args[1];

    var parser = dom.parserFromFile(.default).init(gpa);
    defer parser.deinit();

    const file = try std.Io.Dir.openFileAbsolute(io, path, .{});
    defer file.close(io);

    try parser.ensureTotalCapacity((try file.stat(io)).size);

    _ = try parser.parseAssumeCapacity(file.reader());
}
