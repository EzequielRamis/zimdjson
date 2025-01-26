const std = @import("std");
const zimdjson = @import("zimdjson");
const tracy = @import("tracy");
const dom = zimdjson.dom;
const ondemand = zimdjson.ondemand;

pub fn main() !void {
    const allocator = std.heap.c_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const path = args[1];

    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();

    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    try parser.ensureTotalCapacity((try file.stat()).size);

    _ = try parser.parseAssumeCapacity(file.reader());
}
