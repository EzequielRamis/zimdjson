const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");
const Parser = zimdjson.dom.Parser(.{});

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var json: zimdjson.io.Reader(.{}).slice = undefined;
var parser = Parser.init(allocator);
var result = std.ArrayList(u64).init(allocator);

pub fn init(path: []const u8) !void {
    json = try zimdjson.io.Reader(.{}).readFileAlloc(allocator, path);
}

pub fn prerun() !void {}

pub fn run() !void {
    // Walk the document, parsing as we go
    const doc = try parser.parse(json);
    const statuses = try doc.at("statuses").getArray();
    var it = statuses.iterator();
    while (it.next()) |tweet| {
        // We believe that all statuses have a matching
        // user, and we are willing to throw when they do not.
        try result.append(try tweet.at("user").at("id").getUnsigned());
        // Not all tweets have a "retweeted_status", but when they do
        // we want to go and find the user within.
        const retweet = tweet.at("retweeted_status");
        if (retweet.err) |err| if (err == error.MissingField) continue;
        try result.append(try retweet.at("user").at("id").getUnsigned());
    }
}

pub fn postrun() !void {}

pub fn deinit() void {
    allocator.free(json);
    parser.deinit();
}

pub fn memusage() usize {
    return traced.total;
}
