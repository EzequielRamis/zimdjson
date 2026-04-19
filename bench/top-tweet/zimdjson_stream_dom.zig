const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");
const Parser = zimdjson.dom.StreamParser(.default);

const TopTweet = struct {
    text: []const u8,
    screen_name: []const u8,
    retweet_count: i64,
};

const expected = TopTweet{
    .text = "RT @shiawaseomamori: 一に止まると書いて、正しいという意味だなんて、この年になるまで知りませんでした。 人は生きていると、前へ前へという気持ちばかり急いて、どんどん大切なものを置き去りにしていくものでしょう。本当に正しいことというのは、一番初めの場所にあるの…",
    .screen_name = "anime_toshiden1",
    .retweet_count = 58,
};

const max_retweet_count = 60;

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var file: std.Io.File = undefined;
var path: []const u8 = undefined;
var parser = Parser.init;
var result: TopTweet = undefined;

pub fn init(_: std.Io, _path: []const u8) !void {
    path = _path;
}

pub fn prerun(_: std.Io) !void {}

pub fn run(io: std.Io) !void {
    result.retweet_count = -1;
    var top_tweet: Parser.Value = undefined;

    file = try std.Io.Dir.openFileAbsolute(io, path, .{});
    try parser.expectDocumentSize(allocator, (try file.stat(io)).size);
    var reader = file.reader(io, &.{});
    const doc = try parser.parseFromReader(io, allocator, &reader.interface);
    var tweet = (try doc.at("statuses").asArray()).iterator();
    while (tweet.next()) |t| {
        const retweet_count = try t.at("retweet_count").asSigned();
        if (retweet_count <= max_retweet_count and retweet_count >= result.retweet_count) {
            result.retweet_count = retweet_count;
            top_tweet = t;
        }
    }

    result.text = try top_tweet.at("text").asString();
    result.screen_name = try top_tweet.at("user").at("screen_name").asString();
}

pub fn postrun(io: std.Io) !void {
    if (!(std.mem.eql(u8, result.text, expected.text) and
        std.mem.eql(u8, result.screen_name, expected.screen_name) and
        result.retweet_count == expected.retweet_count))
    {
        @panic("top tweet text unequal to expected");
    }
    file.close(io);
}

pub fn deinit(io: std.Io) void {
    parser.deinit(io, allocator);
}

pub fn memusage() usize {
    return traced.total;
}
