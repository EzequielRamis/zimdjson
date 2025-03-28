const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var file: std.fs.File = undefined;
var path: []const u8 = undefined;
var parser = zimdjson.dom.FullParser(.default).init;
var result = std.ArrayList(u64).init(allocator);

pub fn init(_path: []const u8) !void {
    path = _path;
}

pub fn prerun() !void {
    result.clearRetainingCapacity();
}

pub fn run() !void {
    file = try std.fs.openFileAbsolute(path, .{});
    try parser.expectDocumentSize(allocator, (try file.stat()).size);
    const doc = try parser.parseFromReader(allocator, file.reader().any());
    var statuses = (try doc.at("statuses").asArray()).iterator();
    while (statuses.next()) |tweet| {
        try result.append(try tweet.at("user").at("id").asUnsigned());
        const retweet = tweet.at("retweeted_status");
        if (retweet.err) |err| if (err == error.MissingField) continue else return err;
        try result.append(try retweet.at("user").at("id").asUnsigned());
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
