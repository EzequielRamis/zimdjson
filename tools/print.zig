const std = @import("std");
const zimdjson = @import("zimdjson");
const ondemand = zimdjson.ondemand;
const Reader = zimdjson.io.Reader(.{});
const Parser = ondemand.Parser(.{ .stream = .default });

const stdout = std.io.getStdOut().writer();

var depth: usize = 0;

fn printDepth() !void {
    try stdout.writeByte('\n');
    try stdout.writeBytesNTimes("  ", depth);
}

fn walk(visitor: Parser.Visitor) !void {
    const any = try visitor.getAny();
    switch (any) {
        .object => |c| {
            try stdout.writeByte('{');
            depth += 1;
            var it = c.iterator();
            var size: usize = 0;
            while (try it.next()) |field| : (size += 1) {
                try printDepth();
                try stdout.print("{s}: ", .{field.key});
                try walk(field.value);
            }
            depth -= 1;
            if (size != 0) try printDepth();
            try stdout.writeByte('}');
        },
        .array => |c| {
            try stdout.writeByte('[');
            depth += 1;
            var it = c.iterator();
            var size: usize = 0;
            while (try it.next()) |value| : (size += 1) {
                try printDepth();
                try walk(value);
            }
            depth -= 1;
            if (size != 0) try printDepth();
            try stdout.writeByte(']');
        },
        .string => |value| try stdout.print("\"{s}\"", .{value}),
        .unsigned => |value| try stdout.print("{}", .{value}),
        .signed => |value| try stdout.print("{}", .{value}),
        .float => |value| try stdout.print("{}", .{value}),
        .bool => |value| try stdout.print("{}", .{value}),
        .null => try stdout.print("null", .{}),
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
    const json = try parser.load(file);
    try walk(json);
}
