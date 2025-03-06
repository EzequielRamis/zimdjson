const std = @import("std");
const zimdjson = @import("zimdjson");
const Parser = zimdjson.dom.parserFromFile(.{ .stream = .default });

var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
const allocator = gpa.allocator();

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
            var it = c.iterator();
            while (it.next()) |field| : (size += 1) {
                try printDepth();
                try w.print("{s}: ", .{field.key});
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
            var it = c.iterator();
            while (it.next()) |value| : (size += 1) {
                try printDepth();
                try walk(value);
            }
            depth -= 1;
            if (size != 0) try printDepth();
            try w.writeByte(']');
        },
        .string => |value| try w.print("\"{s}\"", .{value}),
        .number => |value| switch (value) {
            inline else => |n| try w.print("{}", .{n}),
        },
        .bool => |value| try w.print("{}", .{value}),
        .null => try w.print("null", .{}),
    }
}

pub fn main() !void {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len == 1) return;

    var parser = Parser.init;
    defer parser.deinit(allocator);

    const file = try std.fs.openFileAbsolute(args[1], .{});
    const json = try parser.parse(allocator, file.reader());
    try walk(json);
    try buf.flush();
}
