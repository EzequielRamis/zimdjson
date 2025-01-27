const std = @import("std");
const zimdjson = @import("zimdjson");
const Parser = zimdjson.ondemand.parserFromFile(.{ .stream = .default });

var buf = std.io.bufferedWriter(std.io.getStdOut().writer());
var w = buf.writer();
var string_buf: [zimdjson.ondemand.default_stream_chunk_length]u8 = undefined;

var depth: usize = 0;

fn printDepth() !void {
    try w.writeByte('\n');
    try w.writeBytesNTimes("  ", depth);
}

fn walk(v: Parser.Value) !void {
    const any = try v.asAny();
    switch (any) {
        .object => |c| {
            try w.writeByte('{');
            depth += 1;
            var size: usize = 0;
            while (try c.next()) |field| : (size += 1) {
                try printDepth();
                try w.print("{s}: ", .{try field.key.write(&string_buf)});
                try walk(field.value);
            }
            depth -= 1;
            if (size != 0) try printDepth();
            try w.writeByte('}');
        },
        .array => |c| {
            try w.writeByte('[');
            depth += 1;
            var size: usize = 0;
            while (try c.next()) |value| : (size += 1) {
                try printDepth();
                try walk(value);
            }
            depth -= 1;
            if (size != 0) try printDepth();
            try w.writeByte(']');
        },
        .string => |value| try w.print("\"{s}\"", .{try value.write(&string_buf)}),
        .number => |value| switch (value) {
            inline else => |n| try w.print("{}", .{n}),
        },
        .bool => |value| try w.print("{}", .{value}),
        .null => try w.print("null", .{}),
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();
    const args = try std.process.argsAlloc(gpa.allocator());
    defer std.process.argsFree(gpa.allocator(), args);

    if (args.len == 1) return;

    // const allocator = arena.allocator();

    var parser = Parser.init(gpa.allocator());
    defer parser.deinit();

    const file = try std.fs.openFileAbsolute(args[1], .{});
    const json = try parser.parse(file.reader());
    try walk(json.asValue());
    try buf.flush();
}
