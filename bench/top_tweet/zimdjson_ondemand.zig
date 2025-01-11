const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");
const Parser = zimdjson.dom.Parser(.{});

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
var parser = zimdjson.ondemand.Parser(.default).init(allocator);
var result: TopTweet = undefined;

pub fn init(_path: []const u8) !void {
    path = _path;
}

pub fn prerun() !void {}

pub fn run() !void {
    result.retweet_count = -1;

    file = try std.fs.openFileAbsolute(path, .{});
    const doc = try parser.load(file);
    const tweet = try doc.at("statuses").getArray();
    var it = tweet.iterator();
    while (try it.next()) |t| : (try t.skip()) {
        const text = try t.at("text").getString();
        const screen_name = try t.at("user").at("screen_name").getString();
        std.debug.print("text: {s}\n", .{text});
        const retweet_count = try t.at("retweet_count").getSigned();
        std.debug.print("retweet_count: {}\n", .{retweet_count});
        if (retweet_count <= max_retweet_count and retweet_count >= result.retweet_count) {
            result = .{
                .retweet_count = retweet_count,
                .text = text,
                .screen_name = screen_name,
            };
        }
    }
}

pub fn postrun() !void {
    file.close();
}

pub fn deinit() void {
    if (!(std.mem.eql(u8, result.text, expected.text) and
        std.mem.eql(u8, result.screen_name, expected.screen_name) and
        result.retweet_count == expected.retweet_count))
    {
        @panic("top tweet text unequal to expected");
    }
    parser.deinit();
}

pub fn memusage() usize {
    return traced.total;
}
