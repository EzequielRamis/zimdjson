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
var parser = zimdjson.ondemand.Parser(.{ .stream = .default }).init(allocator);
var result = std.ArrayList(Point).init(allocator);

pub fn init(_path: []const u8) !void {
    path = _path;
}

pub fn prerun() !void {
    result.clearRetainingCapacity();
}

pub fn run() !void {
    const doc = try parser.parseFromFile(path);
    const systems = try doc.asArray();
    while (try systems.next()) |sys| {
        const point = try sys.at("coords").asObject();
        try result.append(.{
            .x = try point.at("x").asFloat(),
            .y = try point.at("y").asFloat(),
            .z = try point.at("z").asFloat(),
        });
    }
}

pub fn postrun() !void {}

pub fn deinit() void {
    parser.deinit();
}

pub fn memusage() usize {
    return traced.total;
}
