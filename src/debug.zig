const std = @import("std");
const builtin = @import("builtin");
const debug = std.debug;

pub const is_set = builtin.mode == .Debug;

pub fn assert(ok: bool, comptime format: []const u8, args: anytype) void {
    if (!ok) {
        if (is_set) {
            debug.panic(format, args);
        } else {
            unreachable;
        }
    }
}
