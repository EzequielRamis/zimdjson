const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");
const Parser = zimdjson.dom.parserFromFile(.{ .stream = .default });

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

var file: std.fs.File = undefined;
var path: []const u8 = undefined;
var parser = Parser.init;
var result: TopTweet = undefined;

pub fn init(_path: []const u8) !void {
    path = _path;
}

pub fn prerun() !void {}

pub fn run() !void {
    result.retweet_count = -1;
    var top_tweet: Parser.Value = undefined;

    file = try std.fs.openFileAbsolute(path, .{});
    try parser.ensureTotalCapacity(allocator, (try file.stat()).size);
    const doc = try parser.parse(allocator, file.reader());
    const tweet = try doc.at("statuses").asArray();
    var it = tweet.iterator();
    while (it.next()) |t| {
        const retweet_count = try t.at("retweet_count").asSigned();
        if (retweet_count <= max_retweet_count and retweet_count >= result.retweet_count) {
            result.retweet_count = retweet_count;
            top_tweet = t;
        }
    }

    result.text = try top_tweet.at("text").asString();
    result.screen_name = try top_tweet.at("user").at("screen_name").asString();
}

pub fn postrun() !void {
    if (!(std.mem.eql(u8, result.text, expected.text) and
        std.mem.eql(u8, result.screen_name, expected.screen_name) and
        result.retweet_count == expected.retweet_count))
    {
        @panic("top tweet text unequal to expected");
    }
    file.close();
}

pub fn deinit() void {
    parser.deinit(allocator);
}

pub fn memusage() usize {
    return traced.total;
}
