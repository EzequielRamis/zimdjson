const std = @import("std");
const OnDemand = @import("zimdjson").OnDemand;
const PARSE_NUMBER_FXX = @embedFile("parse_number_fxx");

fn testFrom(comptime set: []const u8) !void {
    std.debug.print("START:   {s}\n", .{set});
    const path = PARSE_NUMBER_FXX ++ "/data/" ++ set ++ ".txt";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var parser = OnDemand.Parser.init(allocator);
    defer parser.deinit();
    const buf = try allocator.alloc(u8, 2048);
    defer allocator.free(buf);
    const file = try std.fs.cwd().openFile(path, .{});
    var reader = file.reader();
    var i: usize = 1;
    while (reader.readUntilDelimiterOrEof(buf, '\n') catch return) |line| : (i += 1) {
        const expected = line[4 + 8 + 2 ..][0..16];
        var actual_buf: [16]u8 = undefined;
        const str = line[4 + 8 + 16 + 3 ..];
        var on_demand = try parser.parse(str);
        const float = on_demand.getFloat() catch |err| switch (err) {
            error.NumberOutOfRange => std.math.inf(f64),
            else => {
                std.debug.print("ignoring invalid number {:0>4}: {s}\n", .{ i, str });
                // std.debug.print("                                   ignoring invalid", .{});
                // std.debug.print(" parsed number {:0>3}: {s}\n", .{ i, str });
                continue;
            },
        };
        const actual = try std.fmt.bufPrint(&actual_buf, "{X:0>16}", .{@as(u64, @bitCast(float))});
        // std.debug.print("expected: {s} actual: {s}", .{ expected, actual });
        // std.debug.print(" parsed number {:0>3}: {s}\n", .{ i, str });
        try std.testing.expectEqualStrings(expected, actual);
    }
    std.debug.print("END:     {s}\n\n", .{set});
}

// test "exhaustive-float16" {
//     try testFrom("exhaustive-float16"); // ❌
// }

// test "freetype-2-7" {
//     try testFrom("freetype-2-7"); // ✅
// }

// test "google-double-conversion" {
//     try testFrom("google-double-conversion"); // ❌
// }

// test "google-wuffs" {
//     try testFrom("google-wuffs"); // ❌
// }

// test "ibm-fpgen" {
//     try testFrom("ibm-fpgen"); // ❌
// }

// test "lemire-fast-double-parser" {
//     try testFrom("lemire-fast-double-parser"); // ✅
// }

// test "lemire-fast-float" {
//     try testFrom("lemire-fast-float"); // ✅
// }

// test "more-test-cases" {
//     try testFrom("more-test-cases"); // ✅
// }

// test "remyoudompheng-fptest-0" {
//     try testFrom("remyoudompheng-fptest-0"); // ✅
// }

// test "remyoudompheng-fptest-1" {
//     try testFrom("remyoudompheng-fptest-1"); // ✅
// }

// test "remyoudompheng-fptest-2" {
//     try testFrom("remyoudompheng-fptest-2"); // ✅
// }

// test "remyoudompheng-fptest-3" {
//     try testFrom("remyoudompheng-fptest-3"); // ✅
// }

// test "tencent-rapidjson" {
//     try testFrom("tencent-rapidjson"); // ❌
// }

// test "ulfjack-ryu" {
//     try testFrom("ulfjack-ryu"); // ❌
// }
