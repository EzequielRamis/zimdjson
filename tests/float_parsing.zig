const std = @import("std");
const builtin = @import("builtin");
const ondemand = @import("zimdjson").ondemand;
const parse_number_data = @import("parse_number_fxx");
const data_path = parse_number_data.path;

fn testFrom(comptime set: []const u8) !void {
    // std.debug.print("START:   {s}\n", .{set});
    const path = data_path ++ "/data/" ++ set ++ ".txt";
    const allocator = std.testing.allocator;
    var parser = ondemand.FullParser(.default).init;
    defer parser.deinit(std.testing.io, allocator);
    const buf = try allocator.alloc(u8, 2048);
    defer allocator.free(buf);
    const file = try std.Io.Dir.cwd().openFile(std.testing.io, path, .{});
    var reader = file.reader(std.testing.io, buf);
    var i: usize = 1;
    while (parse(&reader.interface, '\n')) |line| : (i += 1) {
        const expected = line[4 + 8 + 2 ..][0..16];
        var actual_buf: [16]u8 = undefined;
        const str = line[4 + 8 + 16 + 3 ..];
        // std.debug.print("TEST {:0>6}: {s} -> {s}\n", .{ i, str, expected });
        var document = try parser.parseFromSlice(allocator, str);
        const float = document.asDouble() catch |err| switch (err) {
            error.NumberOutOfRange => std.math.inf(f64),
            error.InvalidNumberLiteral, error.IncorrectType => {
                // std.debug.print("ignoring invalid number {:0>6}: {s}\n", .{ i, str });
                continue;
            },
            else => return err,
        };
        const actual = try std.fmt.bufPrint(&actual_buf, "{X:0>16}", .{@as(u64, @bitCast(float))});
        std.testing.expectEqualStrings(expected, actual) catch {
            std.debug.print("FAIL: {} {s}\n", .{ i, str });
            @breakpoint();
        };
    }
    // std.debug.print("END:     {s}\n\n", .{set});
}

fn parse(r: *std.Io.Reader, delimiter: u8) ?[]u8 {
    const zig_version = builtin.zig_version;
    // https://github.com/ziglang/zig/issues/25597#issuecomment-3410445340
    if (zig_version.major == 0 and zig_version.minor == 15 and zig_version.patch == 1) {
        return std.Io.Reader.takeDelimiterExclusive(r, delimiter) catch null;
    } else {
        return std.Io.Reader.takeDelimiter(r, delimiter) catch null;
    }
}

test "exhaustive-float16" {
    try testFrom("exhaustive-float16");
}

test "freetype-2-7" {
    try testFrom("freetype-2-7");
}

test "google-double-conversion" {
    try testFrom("google-double-conversion");
}

test "google-wuffs" {
    try testFrom("google-wuffs");
}

test "ibm-fpgen" {
    try testFrom("ibm-fpgen");
}

test "lemire-fast-double-parser" {
    try testFrom("lemire-fast-double-parser");
}

test "lemire-fast-float" {
    try testFrom("lemire-fast-float");
}

test "more-test-cases" {
    try testFrom("more-test-cases");
}

test "remyoudompheng-fptest-0" {
    try testFrom("remyoudompheng-fptest-0");
}

test "remyoudompheng-fptest-1" {
    try testFrom("remyoudompheng-fptest-1");
}

test "remyoudompheng-fptest-2" {
    try testFrom("remyoudompheng-fptest-2");
}

test "remyoudompheng-fptest-3" {
    try testFrom("remyoudompheng-fptest-3");
}

test "tencent-rapidjson" {
    try testFrom("tencent-rapidjson");
}

test "ulfjack-ryu" {
    try testFrom("ulfjack-ryu");
}
