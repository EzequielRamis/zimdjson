const std = @import("std");
const SIMDJSON_DATA = @embedFile("simdjson-data");

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const args = try std.process.argsAlloc(arena);
    const output_file_path = args[1];
    var output_file = std.fs.createFileAbsolute(output_file_path, .{}) catch |err| {
        fatal("unable to open '{s}': {s}", .{ output_file_path, @errorName(err) });
    };
    defer output_file.close();

    var checker_zig_content = std.ArrayList(u8).init(arena);
    defer checker_zig_content.deinit();

    try checker_zig_content.appendSlice(
        \\//! This file is auto-generated with `zig build test-jsonchecker`
        \\const std = @import("std");
        \\const Dom = @import("zimdjson").Dom;
        \\
        \\
    );
    const checker_path = SIMDJSON_DATA ++ "/jsonchecker";
    const checker_dir = try std.fs.openDirAbsolute(checker_path, .{ .iterate = true });
    var checker_it = checker_dir.iterate();
    while (try checker_it.next()) |file| {
        if (file.kind == .file) {
            const ext = file.name[file.name.len - 5 ..];
            if (std.mem.eql(u8, ext, ".json")) {
                const is_pass = std.mem.eql(u8, file.name[0..4], "pass");
                const identifier = file.name[0 .. file.name.len - 5];
                try checker_zig_content.appendSlice("test \"");
                try checker_zig_content.appendSlice(identifier);
                try checker_zig_content.appendSlice("\"{\n");
                try checker_zig_content.appendSlice(
                    \\  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
                    \\  const allocator = gpa.allocator();
                    \\  var parser = Dom.Parser.init(allocator);
                    \\  defer parser.deinit();
                );
                if (is_pass) {
                    try checker_zig_content.appendSlice("  _ = try parser.load(\"");
                    try checker_zig_content.appendSlice(checker_path);
                    try checker_zig_content.appendSlice("/");
                    try checker_zig_content.appendSlice(file.name);
                    try checker_zig_content.appendSlice(
                        \\");
                    );
                } else {
                    try checker_zig_content.appendSlice("  _ = parser.load(\"");
                    try checker_zig_content.appendSlice(checker_path);
                    try checker_zig_content.appendSlice("/");
                    try checker_zig_content.appendSlice(file.name);
                    try checker_zig_content.appendSlice(
                        \\") catch return;
                        \\  return error.MustHaveFailed;
                    );
                }
                try checker_zig_content.appendSlice("\n}\n\n");
            }
        }
    }

    try output_file.writeAll(checker_zig_content.items);
    return std.process.cleanExit();
}

fn fatal(comptime format: []const u8, args: anytype) noreturn {
    std.debug.print(format, args);
    std.process.exit(1);
}
