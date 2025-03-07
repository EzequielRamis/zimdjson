const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");
const Parser = zimdjson.dom.parserFromFile(.default);

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
var parser = Parser.init;
var result: TopFactions = undefined;

pub fn init(_path: []const u8) !void {
    path = _path;
}

pub fn prerun() !void {}

pub fn run() !void {
    result.factions_count = 0;
    var top_factions: Parser.Value = undefined;

    file = try std.fs.openFileAbsolute(path, .{});
    try parser.ensureTotalCapacity(allocator, (try file.stat()).size);
    const doc = try parser.parse(allocator, file.reader());
    const systems = try doc.asArray();
    var it = systems.iterator();
    while (it.next()) |system| {
        const factions = system.at("factions");
        if (factions.err) |err| if (err == error.MissingField) continue else return err;
        const factions_count = try factions.getSize();
        if (factions_count >= result.factions_count) {
            result.factions_count = factions_count;
            top_factions = system;
        }
    }
    result.id = try top_factions.at("id64").asUnsigned();
    result.name = try top_factions.at("name").asString();
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
