const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var json: []u8 = undefined;
var size: usize = 0;
var parser = zimdjson.dom.parserFromSlice(.{ .assume_padding = true }).init(allocator);

pub fn init(path: []const u8) !void {
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    size = (try file.stat()).size;
    json = try allocator.alloc(u8, size + zimdjson.recommended_padding);
    @memset(json[size..], ' ');
    _ = try file.readAll(json[0..size]);
}

pub fn prerun() !void {}

pub fn run() !void {
    _ = try parser.parse(json[0..size]);
}

pub fn postrun() !void {}

pub fn deinit() void {
    parser.deinit();
    allocator.free(json);
}

pub fn memusage() usize {
    return traced.total;
}
