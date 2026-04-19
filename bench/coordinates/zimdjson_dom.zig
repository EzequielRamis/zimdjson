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

var file: std.Io.File = undefined;
var path: []const u8 = undefined;
var parser = zimdjson.dom.FullParser(.default).init;
var result = std.ArrayList(Point).empty;

pub fn init(_: std.Io, _path: []const u8) !void {
    path = _path;
}

pub fn prerun(_: std.Io) !void {
    result.clearRetainingCapacity();
}

pub fn run(io: std.Io) !void {
    file = try std.Io.Dir.openFileAbsolute(io, path, .{});
    try parser.expectDocumentSize(allocator, (try file.stat(io)).size);
    var reader = file.reader(io, &.{});
    const doc = try parser.parseFromReader(io, allocator, &reader.interface);
    var systems = (try doc.asArray()).iterator();
    while (systems.next()) |sys| {
        const coords = try sys.at("coords").asObject();
        try result.append(allocator, .{
            .x = try coords.at("x").asDouble(),
            .y = try coords.at("y").asDouble(),
            .z = try coords.at("z").asDouble(),
        });
    }
}

pub fn postrun(io: std.Io) !void {
    file.close(io);
}

pub fn deinit(io: std.Io) void {
    parser.deinit(io, allocator);
}

pub fn memusage() usize {
    return traced.total;
}
