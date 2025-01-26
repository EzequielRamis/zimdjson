const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var json: []u8 = undefined;
var parser = zimdjson.ondemand.parserFromSlice(.{ .assume_padding = true }).init(allocator);

pub fn init(path: []const u8) !void {
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    json = try allocator.alloc(u8, (try file.stat()).size + zimdjson.recommended_padding);
    _ = try file.readAll(json);
}

pub fn prerun() !void {}

pub fn run() !void {
    _ = try parser.parse(json);
}

pub fn postrun() !void {}

pub fn deinit() void {
    parser.deinit();
    allocator.free(json);
}

pub fn memusage() usize {
    return traced.total;
}
