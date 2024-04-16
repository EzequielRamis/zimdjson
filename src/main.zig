const std = @import("std");
const Dom = @import("Dom.zig");

const Allocator = std.mem.Allocator;

pub fn main() !void {
    // var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    // const gpa = general_purpose_allocator.allocator();
    const malloc = std.heap.c_allocator;
    const args = try std.process.argsAlloc(malloc);
    defer std.process.argsFree(malloc, args);

    var parser = Dom.Parser.init(malloc);
    _ = try parser.load(args[1]);
}
