const std = @import("std");
const builtin = @import("builtin");
const debug = std.debug;
const runtime_safety = builtin.mode == .Debug;

pub fn assert(ok: bool) void {
    if (runtime_safety) debug.assert(ok);
}

pub fn assert2(ok: bool, comptime format: []const u8, args: anytype) void {
    if (runtime_safety) if (!ok) debug.panic(format, args);
}
