const std = @import("std");
const zimdjson = @import("zimdjson");
const Parser = zimdjson.ondemand.StreamParser(.default);

var depth: usize = 0;

fn printDepth(w: *std.Io.Writer) !void {
    try w.writeByte('\n');
    try w.splatByteAll(' ', depth * 2);
}

fn walk(w: *std.Io.Writer, v: Parser.Value) !void {
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
                try walk(w, field.value);
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
                try walk(w, value);
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
    const args = try init.minimal.args.toSlice(init.arena.allocator());

    if (args.len == 1) return;

    var parser = Parser.init;
    defer parser.deinit(init.gpa);

    const file = try std.Io.Dir.openFileAbsolute(init.io, args[1], .{});
    defer file.close(init.io);

    var read_buf: [8192]u8 = undefined;
    var file_reader = file.reader(init.io, &read_buf);

    var write_buf: [8192]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &write_buf);

    const json = try parser.parseFromReader(init.gpa, &file_reader.interface);
    try walk(&stdout_writer.interface, json.asValue());
    try stdout_writer.interface.flush();
}
