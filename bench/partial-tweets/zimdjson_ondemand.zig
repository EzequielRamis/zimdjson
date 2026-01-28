const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

const PartialTweet = struct {
    created_at: []const u8,
    id: u64,
    result: []const u8,
    in_reply_to_status_id: u64,
    user: struct {
        id: u64,
        screen_name: []const u8,
    },
    retweet_count: u64,
    favorite_count: u64,
};

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var file: std.Io.File = undefined;
var path: []const u8 = undefined;
var parser = zimdjson.ondemand.FullParser(.default).init;
var result = std.ArrayList(PartialTweet).empty;

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
        try result.append(allocator, .{
            .created_at = try tweet.at("created_at").asString(),
            .id = try tweet.at("id").asUnsigned(),
            .result = try tweet.at("text").asString(),
            .in_reply_to_status_id = try tweet.at("in_reply_to_status_id").asLeaky(?u64, null, .{}) orelse 0,
            .user = brk: {
                const user = tweet.at("user");
                break :brk .{
                    .id = try user.at("id").asUnsigned(),
                    .screen_name = try user.at("screen_name").asString(),
                };
            },
            .retweet_count = try tweet.at("retweet_count").asUnsigned(),
            .favorite_count = try tweet.at("favorite_count").asUnsigned(),
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
