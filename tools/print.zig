const std = @import("std");
const zimdjson = @import("zimdjson");
const Parser = zimdjson.ondemand.StreamParser(.default);

var depth: usize = 0;

fn printDepth(w: *std.Io.Writer) !void {
    try w.writeByte('\n');
    for (0..depth) |_| try w.writeAll("  ");
}

fn walk(v: Parser.Value, w: *std.Io.Writer) !void {
    const any = try v.asAny();
    switch (any) {
        .object => |c| {
            try w.writeByte('{');
            depth += 1;
            var size: usize = 0;
            var it = c.iterator();
            while (try it.next()) |field| : (size += 1) {
                try printDepth(w);
                try w.print("{s}: ", .{try field.key.getTemporal()});
                try walk(field.value, w);
            }
            depth -= 1;
            if (size != 0) try printDepth(w);
            try w.writeByte('}');
        },
        .array => |c| {
            try w.writeByte('[');
            depth += 1;
            var size: usize = 0;
            var it = c.iterator();
            while (try it.next()) |value| : (size += 1) {
                try printDepth(w);
                try walk(value, w);
            }
            depth -= 1;
            if (size != 0) try printDepth(w);
            try w.writeByte(']');
        },
        .string => |value| try w.print("\"{s}\"", .{try value.getTemporal()}),
        .number => |value| switch (value) {
            inline else => |n| try w.print("{}", .{n}),
        },
        .bool => |value| try w.print("{}", .{value}),
        .null => try w.print("null", .{}),
    }
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const args = init.minimal.args;
    const gpa = init.gpa;

    var it = args.iterate();
    _ = it.next(); // argv[0]
    if (it.next()) |path| {
        var parser = Parser.init;
        defer parser.deinit(io, gpa);

        const file = try std.Io.Dir.cwd().openFile(io, path, .{});
        defer file.close(io);

        var read_buf: [4096]u8 = undefined;
        var reader = file.reader(io, &read_buf);
        const json = try parser.parseFromReader(io, gpa, &reader.interface);

        var write_buf: [4096]u8 = undefined;
        var writer = std.Io.File.stdout().writer(io, &write_buf);

        try walk(json.asValue(), &writer.interface);
        try writer.flush();
    }
}
