const std = @import("std");
const simdjson_data = @embedFile("simdjson-data");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const args = try std.process.argsAlloc(alloc);
    const output_file_path = args[1];
    var output_file = std.fs.createFileAbsolute(output_file_path, .{}) catch |err| {
        fatal("unable to open '{s}': {s}", .{ output_file_path, @errorName(err) });
    };
    defer output_file.close();

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
        \\const simdjson_data = @embedFile("simdjson-data");
        \\
        \\
    );

    const adversarial_path = simdjson_data ++ "/jsonchecker/adversarial/issue150";
    var adversarial_dir = try std.fs.openDirAbsolute(adversarial_path, .{ .iterate = true });
    defer adversarial_dir.close();

    var adversarial_it = adversarial_dir.iterate();
    while (try adversarial_it.next()) |file| {
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
            \\    defer parser.deinit(allocator);
            \\    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/{[path]s}", .{{}});
            \\    defer file.close();
            \\    var reader = file.reader(&.{{}});
            \\    _ = parser.parseFromReader(allocator, &reader.interface) catch return;
            \\    return error.MustHaveFailed;
            \\}}
            \\
            \\
        , .{ .id = identifier, .path = file }));
    }

    try output_file.writeAll(checker_zig_content.items);
    return std.process.cleanExit();
}

fn lessThanSlice(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.lessThan(u8, lhs, rhs);
}

fn fatal(comptime format: []const u8, args: anytype) noreturn {
    std.debug.print(format, args);
    std.process.exit(1);
}
