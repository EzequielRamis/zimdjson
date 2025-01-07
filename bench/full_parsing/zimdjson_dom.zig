const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var json: []const u8 = undefined;
var parser = zimdjson.dom.Parser(.{}).init(allocator);

pub fn init(path: []const u8) !void {
    const file = try std.fs.openFileAbsolute(path, .{});
    json = try file.readToEndAlloc(allocator, std.math.maxInt(u32));
}

pub fn prerun() !void {}

pub fn run() !void {
    _ = try parser.parse(json);
}

pub fn postrun() !void {}

pub fn deinit() void {
    parser.deinit();
    std.heap.c_allocator.free(json);
}

pub fn memusage() usize {
    return traced.total;
}
