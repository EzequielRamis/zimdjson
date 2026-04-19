const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var file: std.Io.File = undefined;
var path: []const u8 = undefined;
var parser = zimdjson.dom.StreamParser(.default).init;

pub fn init(_: std.Io, _path: []const u8) !void {
    path = _path;
}

pub fn prerun(_: std.Io) !void {}

pub fn run(io: std.Io) !void {
    file = try std.Io.Dir.openFileAbsolute(io, path, .{});
    try parser.expectDocumentSize(allocator, (try file.stat(io)).size);
    var reader = file.reader(io, &.{});
    _ = try parser.parseFromReader(io, allocator, &reader.interface);
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
