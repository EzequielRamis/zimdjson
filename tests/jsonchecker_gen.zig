const std = @import("std");
const SIMDJSON_DATA = @embedFile("simdjson-data");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const args = try std.process.argsAlloc(alloc);
    const output_file_path = args[1];
    var output_file = std.fs.createFileAbsolute(output_file_path, .{}) catch |err| {
        fatal("unable to open '{s}': {s}", .{ output_file_path, @errorName(err) });
    };
    defer output_file.close();

    var checker_zig_content = std.ArrayList(u8).init(alloc);
    defer checker_zig_content.deinit();

    var strings = std.ArrayList(u8).init(alloc);
    defer strings.deinit();
    var files = std.ArrayList([]const u8).init(alloc);
    defer files.deinit();

    try checker_zig_content.appendSlice(
        \\//! This file is auto-generated with `zig build test-jsonchecker`
        \\const std = @import("std");
        \\const DOM = @import("zimdjson").DOM;
        \\const SIMDJSON_DATA = @embedFile("simdjson-data");
        \\
        \\
    );

    const checker_path = SIMDJSON_DATA ++ "/jsonchecker";
    var checker_dir = try std.fs.openDirAbsolute(checker_path, .{ .iterate = true });
    defer checker_dir.close();

    var checker_it = checker_dir.iterate();
    while (try checker_it.next()) |file| {
        if (file.kind == .file and std.mem.endsWith(u8, file.name, ".json")) {
            try strings.append(@truncate(file.name.len));
            try strings.appendSlice(file.name);
        }
    }
    const minefield_path = SIMDJSON_DATA ++ "/jsonchecker/minefield";
    var minefield_dir = try std.fs.openDirAbsolute(minefield_path, .{ .iterate = true });
    defer minefield_dir.close();

    var minefield_it = minefield_dir.iterate();
    while (try minefield_it.next()) |file| {
        if (file.kind == .file and std.mem.endsWith(u8, file.name, ".json")) {
            try strings.append(@truncate(file.name.len));
            try strings.appendSlice(file.name);
        }
    }
    var i: usize = 0;
    while (i < strings.items.len) {
        const len = strings.items[i];
        const str = strings.items[i + 1 ..][0..len];
        try files.append(str);
        i += len + 1;
    }
    std.sort.insertion([]const u8, files.items, {}, lessThanSlice);
    for (files.items) |file| {
        const is_pass = std.mem.startsWith(u8, file, "pass") or std.mem.startsWith(u8, file, "y_");
        const is_excluded = std.mem.endsWith(u8, file, "EXCLUDE.json") or std.mem.startsWith(u8, file, "i_");
        const is_minefield = std.mem.startsWith(u8, file, "y_") or std.mem.startsWith(u8, file, "n_");
        const identifier = file[0 .. file.len - 5];
        if (!is_excluded) {
            try checker_zig_content.appendSlice("test \"");
            try checker_zig_content.appendSlice(identifier);
            try checker_zig_content.appendSlice("\"{\n");
            try checker_zig_content.appendSlice(
                \\  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
                \\  const allocator = gpa.allocator();
                \\  var parser = DOM.Parser.init(allocator);
                \\  defer parser.deinit();
                \\
            );
            if (is_pass) {
                try checker_zig_content.appendSlice("  _ = try parser.load(SIMDJSON_DATA ++ \"/jsonchecker/");
                if (is_minefield) try checker_zig_content.appendSlice("minefield/");
                try checker_zig_content.appendSlice(file);
                try checker_zig_content.appendSlice(
                    \\");
                );
            } else {
                try checker_zig_content.appendSlice("  _ = parser.load(SIMDJSON_DATA ++ \"/jsonchecker/");
                if (is_minefield) try checker_zig_content.appendSlice("minefield/");
                try checker_zig_content.appendSlice(file);
                try checker_zig_content.appendSlice(
                    \\") catch return;
                    \\  return error.MustHaveFailed;
                );
            }
            try checker_zig_content.appendSlice("\n}\n\n");
        }
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
