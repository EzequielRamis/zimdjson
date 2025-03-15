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

var file: std.fs.File = undefined;
var path: []const u8 = undefined;
var parser = zimdjson.ondemand.StreamParser(.default).init;
var result: TopFactions = undefined;

pub fn init(_path: []const u8) !void {
    path = _path;
}

pub fn prerun() !void {}

pub fn run() !void {
    result.factions_count = 0;

    file = try std.fs.openFileAbsolute(path, .{});
    try parser.expectDocumentSize(allocator, (try file.stat()).size);
    const doc = try parser.parseFromReader(allocator, file.reader().any());
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

pub fn postrun() !void {
    if (!(result.id == expected.id and
        std.mem.eql(u8, result.name, expected.name) and
        result.factions_count == expected.factions_count))
    {
        @panic("top factions unequal to expected");
    }
    file.close();
}

pub fn deinit() void {
    parser.deinit(allocator);
}

pub fn memusage() usize {
    return traced.total;
}
