const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var json: []u8 = undefined;
var size: usize = 0;
var parser = zimdjson.dom.FullParser(.{ .assume_padding = true }).init;

pub fn init(io: std.Io, path: []const u8) !void {
    const file = try std.Io.Dir.openFileAbsolute(io, path, .{});
    defer file.close(io);

    size = (try file.stat(io)).size;
    json = try allocator.alloc(u8, size + zimdjson.padding);
    @memset(json[size..], ' ');
    var reader = file.reader(io, &.{});
    _ = try reader.interface.readSliceShort(json[0..size]);
}

pub fn prerun(_: std.Io) !void {}

pub fn run(_: std.Io) !void {
    _ = try parser.parseFromSlice(allocator, json[0..size]);
}

pub fn postrun(_: std.Io) !void {}

pub fn deinit(io: std.Io) void {
    parser.deinit(io, allocator);
    allocator.free(json);
}

pub fn memusage() usize {
    return traced.total;
}
