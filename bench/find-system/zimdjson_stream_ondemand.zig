const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

const find_id = 168814437556;
const expected = "16 Persei";

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var file: std.fs.File = undefined;
var path: []const u8 = undefined;
var parser = zimdjson.ondemand.parserFromFile(.{ .stream = .default }).init;
var result: []const u8 = undefined;

pub fn init(_path: []const u8) !void {
    path = _path;
}

pub fn prerun() !void {}

pub fn run() !void {
    file = try std.fs.openFileAbsolute(path, .{});
    try parser.ensureTotalCapacity(allocator, (try file.stat()).size);
    const doc = try parser.parse(allocator, file.reader());
    const systems = try doc.asArray();
    while (try systems.next()) |s| {
        if (try s.at("id64").asUnsigned() == find_id) {
            result = try s.at("name").asString().get();
            return;
        }
    }
    @panic("system not found");
}

pub fn postrun() !void {
    if (!std.mem.eql(u8, expected, result)) {
        @panic("system name unequal to expected");
    }
    file.close();
}

pub fn deinit() void {
    parser.deinit(allocator);
}

pub fn memusage() usize {
    return traced.total;
}
