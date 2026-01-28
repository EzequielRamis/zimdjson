const std = @import("std");
const data_info = @import("simdjson-data");

pub fn main(init: std.process.Init) !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const alloc = gpa.allocator();

    var args_it = init.minimal.args.iterate();
    _ = args_it.next();

    const output_file_path = args_it.next().?;

    var output_file = std.Io.Dir.createFileAbsolute(init.io, output_file_path, .{}) catch |err| {
        fatal("unable to open '{s}': {s}", .{ output_file_path, @errorName(err) });
    };
    defer output_file.close(init.io);

    var checker_zig_content = std.ArrayList(u8).empty;
    defer checker_zig_content.deinit(alloc);

    var strings = std.ArrayList(u8).empty;
    defer strings.deinit(alloc);
    var files = std.ArrayList([]const u8).empty;
    defer files.deinit(alloc);

    try checker_zig_content.appendSlice(alloc,
        \\//! This file is auto-generated with `zig build tests/generate`
        \\
        \\const std = @import("std");
        \\const zimdjson = @import("zimdjson");
        \\const Parser = zimdjson.dom.StreamParser(.default);
        \\const data_path = @import("simdjson-data").path;
        \\
        \\
    );

    const adversarial_path = data_info.path ++ "/jsonchecker/adversarial/issue150";
    var adversarial_dir = try std.Io.Dir.openDirAbsolute(init.io, adversarial_path, .{ .iterate = true });
    defer adversarial_dir.close(init.io);

    var adversarial_it = adversarial_dir.iterate();
    while (try adversarial_it.next(init.io)) |file| {
        if (file.kind == .file and std.mem.endsWith(u8, file.name, ".json")) {
            try strings.append(alloc, @truncate(file.name.len));
            try strings.appendSlice(alloc, file.name);
        }
    }

    var i: usize = 0;
    while (i < strings.items.len) {
        const len = strings.items[i];
        const str = strings.items[i + 1 ..][0..len];
        try files.append(alloc, str);
        i += len + 1;
    }
    std.sort.insertion([]const u8, files.items, {}, lessThanSlice);

    for (files.items) |file| {
        const identifier = file[0 .. file.len - 5];
        var buf: [1024]u8 = undefined;
        try checker_zig_content.appendSlice(alloc, try std.fmt.bufPrint(&buf,
            \\test "{[id]s}" {{
            \\    const allocator = std.testing.allocator;
            \\    var parser = Parser.init;
            \\    defer parser.deinit(std.testing.io, allocator);
            \\    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonchecker/adversarial/issue150/{[path]s}", .{{}});
            \\    defer file.close(std.testing.io);
            \\    var reader = file.reader(std.testing.io, &.{{}});
            \\    _ = parser.parseFromReader(std.testing.io, allocator, &reader.interface) catch return;
            \\    return error.MustHaveFailed;
            \\}}
            \\
            \\
        , .{ .id = identifier, .path = file }));
    }

    var writer = output_file.writer(init.io, &.{});
    try writer.interface.writeAll(checker_zig_content.items);
    return std.process.cleanExit(init.io);
}

fn lessThanSlice(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.lessThan(u8, lhs, rhs);
}

fn fatal(comptime format: []const u8, args: anytype) noreturn {
    std.debug.print(format, args);
    std.process.exit(1);
}
