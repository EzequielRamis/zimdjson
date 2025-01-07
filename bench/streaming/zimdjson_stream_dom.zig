const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var file: std.fs.File = undefined;
var path: []const u8 = undefined;
var parser = zimdjson.dom.Parser(.{ .stream = .default }).init(allocator);

pub fn init(_path: []const u8) !void {
    path = _path;
}

pub fn prerun() !void {}

pub fn run() !void {
    file = try std.fs.openFileAbsolute(path, .{});
    _ = try parser.load(file);
}

pub fn postrun() !void {
    file.close();
}

pub fn deinit() void {
    parser.deinit();
}

pub fn memusage() usize {
    return traced.total;
}
