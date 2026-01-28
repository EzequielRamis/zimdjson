const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var file: std.Io.File = undefined;
var path: []const u8 = undefined;
var parser = zimdjson.ondemand.FullParser(.default).init;
var result = std.ArrayList(u64).empty;

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
    var statuses = (try doc.at("statuses").asArray()).iterator();
    while (try statuses.next()) |tweet| {
        try result.append(allocator, try tweet.at("user").at("id").asUnsigned());
        const retweet = tweet.at("retweeted_status");
        if (retweet.err) |err| if (err == error.MissingField) continue else return err;
        try result.append(allocator, try retweet.at("user").at("id").asUnsigned());
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
