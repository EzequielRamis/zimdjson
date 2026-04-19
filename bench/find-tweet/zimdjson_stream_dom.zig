const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

const find_id = 505874901689851904;
const expected = "RT @shiawaseomamori: 一に止まると書いて、正しいという意味だなんて、この年になるまで知りませんでした。 人は生きていると、前へ前へという気持ちばかり急いて、どんどん大切なものを置き去りにしていくものでしょう。本当に正しいことというのは、一番初めの場所にあるの…";

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var file: std.Io.File = undefined;
var path: []const u8 = undefined;
var parser = zimdjson.dom.StreamParser(.default).init;
var result: []const u8 = undefined;

pub fn init(_: std.Io, _path: []const u8) !void {
    path = _path;
}

pub fn prerun(_: std.Io) !void {}

pub fn run(io: std.Io) !void {
    file = try std.Io.Dir.openFileAbsolute(io, path, .{});
    try parser.expectDocumentSize(allocator, (try file.stat(io)).size);
    var reader = file.reader(io, &.{});
    const doc = try parser.parseFromReader(io, allocator, &reader.interface);
    var tweet = (try doc.at("statuses").asArray()).iterator();
    while (tweet.next()) |t| {
        if (try t.at("id").asUnsigned() == find_id) {
            result = try t.at("text").asString();
            return;
        }
    }
    @panic("tweet not found");
}

pub fn postrun(io: std.Io) !void {
    if (!std.mem.eql(u8, expected, result)) {
        @panic("tweet text unequal to expected");
    }
    file.close(io);
}

pub fn deinit(io: std.Io) void {
    parser.deinit(io, allocator);
}

pub fn memusage() usize {
    return traced.total;
}
