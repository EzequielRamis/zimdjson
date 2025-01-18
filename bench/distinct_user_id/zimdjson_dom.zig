const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var file: std.fs.File = undefined;
var path: []const u8 = undefined;
var parser = zimdjson.dom.Parser(.default).init(allocator);
var result = std.ArrayList(u64).init(allocator);

pub fn init(_path: []const u8) !void {
    path = _path;
}

pub fn prerun() !void {
    result.clearRetainingCapacity();
}

pub fn run() !void {
    const doc = try parser.load(path);
    const statuses = try doc.at("statuses").getArray();
    var it = statuses.iterator();
    while (it.next()) |tweet| {
        try result.append(try tweet.at("user").at("id").getUnsigned());
        const retweet = tweet.at("retweeted_status");
        if (retweet.err != error.MissingField) {
            try result.append(try retweet.at("user").at("id").getUnsigned());
        }
    }
}

pub fn postrun() !void {}

pub fn deinit() void {
    parser.deinit();
}

pub fn memusage() usize {
    return traced.total;
}
