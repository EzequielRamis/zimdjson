const std = @import("std");
const zimdjson = @import("zimdjson");
const dom = zimdjson.dom;
const Reader = zimdjson.io.Reader(.{});
const Parser = dom.Parser(.{});

const stdout = std.io.getStdOut().writer();

var depth: usize = 0;

fn printDepth() !void {
    try stdout.print("\n", .{});
    for (0..depth) |_| {
        try stdout.print("  ", .{});
    }
}

fn walk(v: Parser.Visitor) !void {
    const any = try v.getAny();
    switch (any) {
        .object => |c| {
            try stdout.print("{{", .{});
            depth += 1;
            var it = c.iterator();
            while (it.next()) |field| {
                try printDepth();
                try stdout.print("{s}: ", .{field.key});
                try walk(field.value);
            }
            depth -= 1;
            if (c.getSize() != 0) try printDepth();
            try stdout.print("}}", .{});
        },
        .array => |c| {
            try stdout.print("[", .{});
            depth += 1;
            var it = c.iterator();
            while (it.next()) |value| {
                try printDepth();
                try walk(value);
            }
            depth -= 1;
            if (c.getSize() != 0) try printDepth();
            try stdout.print("]", .{});
        },
        .string => |s| try stdout.print("\"{s}\"", .{s}),
        .unsigned => |u| try stdout.print("{}", .{u}),
        .signed => |i| try stdout.print("{}", .{i}),
        .float => |f| try stdout.print("{}", .{f}),
        .bool => |b| try stdout.print("{}", .{b}),
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

    const file = try Reader.readFileAlloc(allocator, args[1]);
    defer allocator.free(file);

    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();

    const json = try parser.parse(file);
    try walk(json);
}
