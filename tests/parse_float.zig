const std = @import("std");
const OnDemand = @import("zimdjson").OnDemand;
const PARSE_NUMBER_FXX = @embedFile("parse_number_fxx");

test "lemire-fast-float" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var parser = OnDemand.Parser.init(allocator);
    defer parser.deinit();
    const buf = try allocator.alloc(u8, 2048);
    defer allocator.free(buf);
    const path = PARSE_NUMBER_FXX ++ "/data/lemire-fast-float.txt";
    const file = try std.fs.cwd().openFile(path, .{});
    var reader = file.reader();
    std.debug.print("\n", .{});
    var i: usize = 1;
    while (reader.readUntilDelimiterOrEof(buf, '\n') catch return) |line| : (i += 1) {
        const expected = line[4 + 8 + 2 ..][0..16];
        var actual_buf: [16]u8 = undefined;
        const str = line[4 + 8 + 16 + 3 ..];
        var on_demand = try parser.parse(str);
        if (on_demand.getFloat()) |float| {
            const actual = try std.fmt.bufPrint(&actual_buf, "{X:0>16}", .{@as(u64, @bitCast(float))});
            std.debug.print("expected: {s} actual: {s}", .{ expected, actual });
            std.debug.print(" parsed number {:0>3}: {s}\n", .{ i, str });
            try std.testing.expectEqualStrings(expected, actual);
        } else |err| switch (err) {
            error.NumberOutOfRange => {
                std.debug.print("expected: {s}                         ", .{expected});
                std.debug.print(" parsed number {:0>3}: {s}\n", .{ i, str });
                return err;
            },
            else => {
                std.debug.print("                                   ignoring invalid", .{});
                std.debug.print(" parsed number {:0>3}: {s}\n", .{ i, str });
            },
        }
    }
}
