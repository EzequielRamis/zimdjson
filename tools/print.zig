const std = @import("std");
const zimdjson = @import("zimdjson");
const dom = zimdjson.dom;
const Reader = zimdjson.io.Reader(.{});
const Parser = dom.Parser(.{});

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
            while (it.next()) |field| {
                try printDepth();
                try stdout.print("{s}: ", .{field.key});
                try walk(field.value);
            }
            depth -= 1;
            if (c.getSize() != 0) try printDepth();
            try stdout.writeByte('}');
        },
        .array => |c| {
            try stdout.writeByte('[');
            depth += 1;
            var it = c.iterator();
            while (it.next()) |value| {
                try printDepth();
                try walk(value);
            }
            depth -= 1;
            if (c.getSize() != 0) try printDepth();
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
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const args = try std.process.argsAlloc(arena.allocator());
    defer std.process.argsFree(arena.allocator(), args);

    if (args.len == 1) return;

    const allocator = arena.allocator();

    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();

    const json = try parser.parse(args[1]);
    try walk(json);
}
