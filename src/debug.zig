const std = @import("std");
const builtin = @import("builtin");
const build_options = @import("build_options");
const debug = std.debug;

pub const is_set = build_options.enable_debug;

pub fn assert(ok: bool, comptime format: []const u8, args: anytype) void {
    if (!ok) {
        if (is_set) {
            debug.panic(format, args);
        } else {
            unreachable;
        }
    }
}
