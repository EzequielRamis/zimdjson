const std = @import("std");
const zimdjson = @import("zimdjson");
const dom = zimdjson.dom;
const Reader = zimdjson.io.Reader(.{});
const Parser = dom.Parser(.{});

var depth: usize = 0;

fn printDepth() void {
    std.debug.print("\n", .{});
    for (0..depth) |_| {
        std.debug.print("  ", .{});
    }
}

fn walk(v: Parser.Visitor) !void {
    const any = try v.getAny();
    switch (any) {
        .object => |c| {
            std.debug.print("{{", .{});
            depth += 1;
            var it = c.iterator();
            while (it.next()) |field| {
                printDepth();
                std.debug.print("{s}: ", .{field.key});
                try walk(field.value);
            }
            depth -= 1;
            if (c.getSize() != 0) printDepth();
            std.debug.print("}}", .{});
        },
        .array => |c| {
            std.debug.print("[", .{});
            depth += 1;
            var it = c.iterator();
            while (it.next()) |value| {
                printDepth();
                try walk(value);
            }
            depth -= 1;
            if (c.getSize() != 0) printDepth();
            std.debug.print("]", .{});
        },
        .string => |s| std.debug.print("\"{s}\"", .{s}),
        .unsigned => |u| std.debug.print("{}", .{u}),
        .signed => |i| std.debug.print("{}", .{i}),
        .float => |f| std.debug.print("{}", .{f}),
        .bool => |b| std.debug.print("{}", .{b}),
        .null => std.debug.print("null", .{}),
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
