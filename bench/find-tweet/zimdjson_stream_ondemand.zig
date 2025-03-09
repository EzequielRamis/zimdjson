const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

const find_id = 505874901689851904;
const expected = "RT @shiawaseomamori: 一に止まると書いて、正しいという意味だなんて、この年になるまで知りませんでした。 人は生きていると、前へ前へという気持ちばかり急いて、どんどん大切なものを置き去りにしていくものでしょう。本当に正しいことというのは、一番初めの場所にあるの…";

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var file: std.fs.File = undefined;
var path: []const u8 = undefined;
var parser = zimdjson.ondemand.parserFromFile(.{ .stream = .default }).init;
var result: []const u8 = undefined;

pub fn init(_path: []const u8) !void {
    path = _path;
}

pub fn prerun() !void {}

pub fn run() !void {
    file = try std.fs.openFileAbsolute(path, .{});
    try parser.ensureTotalCapacity(allocator, (try file.stat()).size);
    const doc = try parser.parse(allocator, file.reader());
    var tweet = (try doc.at("statuses").asArray()).iterator();
    while (try tweet.next()) |t| {
        if (try t.at("id").asUnsigned() == find_id) {
            result = try t.at("text").asString().get();
            return;
        }
    }
    @panic("tweet not found");
}

pub fn postrun() !void {
    if (!std.mem.eql(u8, expected, result)) {
        @panic("tweet text unequal to expected");
    }
    file.close();
}

pub fn deinit() void {
    parser.deinit(allocator);
}

pub fn memusage() usize {
    return traced.total;
}
