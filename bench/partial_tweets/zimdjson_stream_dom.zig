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

var file: std.fs.File = undefined;
var path: []const u8 = undefined;
var parser = zimdjson.dom.Parser(.{ .stream = .default }).init(allocator);
var result = std.ArrayList(PartialTweet).init(allocator);

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
        const user = tweet.at("user");
        try result.append(.{
            .created_at = try tweet.at("created_at").getString(),
            .id = try tweet.at("id").getUnsigned(),
            .result = try tweet.at("text").getString(),
            .in_reply_to_status_id = brk: {
                const el = tweet.at("in_reply_to_status_id");
                break :brk if (try el.isNull()) 0 else try el.getUnsigned();
            },
            .user = .{
                .id = try user.at("id").getUnsigned(),
                .screen_name = try user.at("screen_name").getString(),
            },
            .retweet_count = try tweet.at("retweet_count").getUnsigned(),
            .favorite_count = try tweet.at("favorite_count").getUnsigned(),
        });
    }
}

pub fn postrun() !void {}

pub fn deinit() void {
    parser.deinit();
}

pub fn memusage() usize {
    return traced.total;
}
