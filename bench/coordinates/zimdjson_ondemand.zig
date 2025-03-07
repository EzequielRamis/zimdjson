const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

const Point = struct {
    x: f64,
    y: f64,
    z: f64,
};

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var file: std.fs.File = undefined;
var path: []const u8 = undefined;
var parser = zimdjson.ondemand.parserFromFile(.default).init;
var result = std.ArrayList(Point).init(allocator);

pub fn init(_path: []const u8) !void {
    path = _path;
}

pub fn prerun() !void {
    result.clearRetainingCapacity();
}

pub fn run() !void {
    file = try std.fs.openFileAbsolute(path, .{});
    try parser.ensureTotalCapacity(allocator, (try file.stat()).size);
    const doc = try parser.parse(allocator, file.reader());
    const systems = try doc.asArray();
    while (try systems.next()) |sys| {
        const coords = try sys.at("coords").asObject();
        try result.append(.{
            .x = try coords.at("x").asFloat(),
            .y = try coords.at("y").asFloat(),
            .z = try coords.at("z").asFloat(),
        });
    }
}

pub fn postrun() !void {
    file.close();
}

pub fn deinit() void {
    parser.deinit(allocator);
}

pub fn memusage() usize {
    return traced.total;
}
