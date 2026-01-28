const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");

const TopFactions = struct {
    id: u64,
    name: []const u8,
    factions_count: usize,
};

const expected = TopFactions{
    .id = 4207021134570,
    .name = "Tigurd",
    .factions_count = 33,
};

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var file: std.Io.File = undefined;
var path: []const u8 = undefined;
var parser = zimdjson.ondemand.StreamParser(.default).init;
var result: TopFactions = undefined;

pub fn init(_: std.Io, _path: []const u8) !void {
    path = _path;
}

pub fn prerun(_: std.Io) !void {}

pub fn run(io: std.Io) !void {
    result.factions_count = 0;

    file = try std.Io.Dir.openFileAbsolute(io, path, .{});
    try parser.expectDocumentSize(allocator, (try file.stat(io)).size);
    var reader = file.reader(io, &.{});
    const doc = try parser.parseFromReader(io, allocator, &reader.interface);
    var systems = (try doc.asArray()).iterator();
    while (try systems.next()) |system| {
        const id = try system.at("id64").asUnsigned();
        const name = try system.at("name").asString();
        const factions = system.at("factions");
        if (factions.err) |err| if (err == error.MissingField) continue else return err;
        var arr = (try factions.asArray()).iterator();
        var factions_count: usize = 0;
        while (try arr.next()) |_| factions_count += 1;
        if (factions_count >= result.factions_count) {
            result = .{
                .id = id,
                .name = name,
                .factions_count = factions_count,
            };
        }
    }
}

pub fn postrun(io: std.Io) !void {
    if (!(result.id == expected.id and
        std.mem.eql(u8, result.name, expected.name) and
        result.factions_count == expected.factions_count))
    {
        @panic("top factions unequal to expected");
    }
    file.close(io);
}

pub fn deinit(io: std.Io) void {
    parser.deinit(io, allocator);
}

pub fn memusage() usize {
    return traced.total;
}
