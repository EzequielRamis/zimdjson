const std = @import("std");
const zimdjson = @import("zimdjson");
const dom = zimdjson.dom;
const Reader = zimdjson.io.Reader(.{});
const Parser = dom.Parser(.{});

const Stats = struct {
    json_size: usize,
    token_count: usize,
    object_count: usize,
    key_count: usize,
    array_count: usize,
    string_count: usize,
    unsigned_count: usize,
    signed_count: usize,
    float_count: usize,
    true_count: usize,
    false_count: usize,
    null_count: usize,
};

var stats = std.mem.zeroes(Stats);

fn walk(v: Parser.Visitor) !void {
    stats.token_count += 1;
    const any = try v.getAny();
    switch (any) {
        .object => |c| {
            stats.object_count += 1;
            stats.token_count += @max(1, 3 * c.getSize());
            stats.key_count += c.getSize();
            var it = c.iterator();
            while (it.next()) |field| try walk(field.value);
        },
        .array => |c| {
            stats.array_count += 1;
            stats.token_count += @max(1, c.getSize());
            var it = c.iterator();
            while (it.next()) |value| try walk(value);
        },
        .string => stats.string_count += 1,
        .unsigned => stats.unsigned_count += 1,
        .signed => stats.signed_count += 1,
        .float => stats.float_count += 1,
        .bool => |b| {
            if (b) stats.true_count += 1 else stats.false_count += 1;
        },
        .null => stats.null_count += 1,
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const args = try std.process.argsAlloc(arena.allocator());
    defer std.process.argsFree(arena.allocator(), args);

    if (args.len == 1) return;

    const allocator = arena.allocator();

    const file = try Reader.readFileAlloc(allocator, args[1]);
    defer allocator.free(file);

    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();

    stats.json_size = file.len;
    const json = try parser.parse(file);
    try walk(json);

    std.debug.print(
        \\Number of total bytes      : {[json_size]}
        \\Number of tokens           : {[token_count]}
        \\Number of objects          : {[object_count]}
        \\Number of arrays           : {[array_count]}
        \\Number of keys             : {[key_count]}
        \\Number of strings          : {[string_count]}
        \\Number of unsigned integers: {[unsigned_count]}
        \\Number of signed integers  : {[signed_count]}
        \\Number of floats           : {[float_count]}
        \\Number of true atoms       : {[true_count]}
        \\Number of false atoms      : {[false_count]}
        \\Number of null atoms       : {[null_count]}
        \\
    , stats);

    std.debug.print(
        \\Tokens/total bytes         : {d:.3}%
        \\
    , .{@as(f64, @floatFromInt(stats.token_count)) / @as(f64, @floatFromInt(stats.json_size)) * 100});
}
