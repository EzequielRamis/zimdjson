const std = @import("std");
const zimdjson = @import("zimdjson");
const dom = zimdjson.dom;
const Reader = zimdjson.io.Reader(.{});
const Parser = dom.Parser(.{});

var depth: usize = 0;

fn printDepth() void {
    for (0..depth) |_| {
        std.debug.print("  ", .{});
    }
}

fn walk(v: Parser.Visitor) !void {
    printDepth();
    const any = try v.getAny();
    switch (any) {
        .object => |c| {
            std.debug.print("object\n", .{});
            depth += 1;
            defer depth -= 1;
            var it = c.iterator();
            while (it.next()) |field| {
                printDepth();
                std.debug.print("field: {s}\n", .{field.key});
                try walk(field.value);
            }
        },
        .array => |c| {
            std.debug.print("array\n", .{});
            depth += 1;
            defer depth -= 1;
            var it = c.iterator();
            while (it.next()) |value| {
                try walk(value);
            }
        },
        .string => |s| std.debug.print("string: {s}\n", .{s}),
        .unsigned => |u| std.debug.print("unsigned: {}\n", .{u}),
        .signed => |i| std.debug.print("signed: {}\n", .{i}),
        .float => |f| std.debug.print("float: {}\n", .{f}),
        .bool => |b| std.debug.print("bool: {}\n", .{b}),
        .null => std.debug.print("null\n", .{}),
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
