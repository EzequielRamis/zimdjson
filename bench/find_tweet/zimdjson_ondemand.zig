const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

const find_id = 505874901689851904;
const expected = "RT @shiawaseomamori: 一に止まると書いて、正しいという意味だなんて、この年になるまで知りませんでした。 人は生きていると、前へ前へという気持ちばかり急いて、どんどん大切なものを置き去りにしていくものでしょう。本当に正しいことというのは、一番初めの場所にあるの…";

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var json: zimdjson.io.Reader(.{}).slice = undefined;
var parser = zimdjson.ondemand.Parser(.{}).init(allocator);
var result: []const u8 = undefined;

pub fn init(path: []const u8) !void {
    json = try zimdjson.io.Reader(.{}).readFileAlloc(allocator, path);
}

pub fn prerun() !void {}

pub fn run() !void {
    const doc = try parser.parse(json);
    var tweets = try doc.at("statuses").getArray();
    while (try tweets.next()) |t| : (try t.skip()) {
        if (try t.at("id").getUnsigned() == find_id) {
            result = try t.at("text").getString();
            return;
        }
    }
    @panic("tweet not found");
}

pub fn postrun() !void {}

pub fn deinit() void {
    if (!std.mem.eql(u8, expected, result)) {
        @panic("tweet text unequal to expected");
    }
    allocator.free(json);
    parser.deinit();
}

pub fn memusage() usize {
    return traced.total;
}
