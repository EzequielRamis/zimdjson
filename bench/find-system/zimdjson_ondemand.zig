const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

const find_id = 168814437556;
const expected = "16 Persei";

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var file: std.Io.File = undefined;
var path: []const u8 = undefined;
var parser = zimdjson.ondemand.FullParser(.default).init;
var result: []const u8 = undefined;

pub fn init(_: std.Io, _path: []const u8) !void {
    path = _path;
}

pub fn prerun(_: std.Io) !void {}

pub fn run(io: std.Io) !void {
    file = try std.Io.Dir.openFileAbsolute(io, path, .{});
    try parser.expectDocumentSize(allocator, (try file.stat(io)).size);
    var reader = file.reader(io, &.{});
    const doc = try parser.parseFromReader(io, allocator, &reader.interface);
    var systems = (try doc.asArray()).iterator();
    while (try systems.next()) |s| {
        if (try s.at("id64").asUnsigned() == find_id) {
            result = try s.at("name").asString();
            return;
        }
    }
    @panic("system not found");
}

pub fn postrun(io: std.Io) !void {
    if (!std.mem.eql(u8, expected, result)) {
        @panic("system name unequal to expected");
    }
    file.close(io);
}

pub fn deinit(io: std.Io) void {
    parser.deinit(io, allocator);
}

pub fn memusage() usize {
    return traced.total;
}
