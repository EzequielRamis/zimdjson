const std = @import("std");
const zimdjson = @import("zimdjson");
const dom = zimdjson.dom;
const Reader = zimdjson.io.Reader(.{});
const Parser = dom.Parser(.{});

const stdout = std.io.getStdOut().writer();

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
    empty_object_count: usize,
    empty_array_count: usize,
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
            if (c.getSize() == 0) stats.empty_object_count += 1;
        },
        .array => |c| {
            stats.array_count += 1;
            stats.token_count += @max(1, c.getSize());
            var it = c.iterator();
            while (it.next()) |value| try walk(value);
            if (c.getSize() == 0) stats.empty_array_count += 1;
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

    try stdout.print(
        \\Total bytes                : {[json_size]}
        \\Tokens                     : {[token_count]}
        \\Objects                    : {[object_count]}
        \\Arrays                     : {[array_count]}
        \\Keys                       : {[key_count]}
        \\Strings                    : {[string_count]}
        \\Unsigned integers          : {[unsigned_count]}
        \\Signed integers            : {[signed_count]}
        \\Floats                     : {[float_count]}
        \\True atoms                 : {[true_count]}
        \\False atoms                : {[false_count]}
        \\Null atoms                 : {[null_count]}
        \\Empty objects              : {[empty_object_count]}
        \\Empty arrays               : {[empty_array_count]}
        \\
    , stats);

    try stdout.print(
        \\Tokens/total bytes         : {d:.3}%
        \\
    , .{@as(f64, @floatFromInt(stats.token_count)) /
        @as(f64, @floatFromInt(stats.json_size)) * 100});

    const tape_words = stats.object_count * 2 +
        stats.array_count * 2 +
        (stats.float_count + stats.unsigned_count + stats.signed_count) * 2 +
        stats.true_count + stats.false_count + stats.null_count + stats.string_count;
    const tape_size = tape_words * 8;
    try stdout.print(
        \\Tape words                 : {}
        \\Tape byte size             : {}
        \\Tape byte size/total bytes : {d:.3}%
        \\
    , .{
        tape_words, tape_size,
        @as(f64, @floatFromInt(tape_size)) /
            @as(f64, @floatFromInt(stats.json_size)) * 100,
    });
}
