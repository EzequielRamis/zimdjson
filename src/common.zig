const std = @import("std");
const builtin = @import("builtin");
const simd = std.simd;
const testing = std.testing;

pub const DEFAULT_MAX_DEPTH = 1024;
pub const DEFAULT_MAX_CAPACITY = 2 ** 32;

pub const Tables = struct {
    pub const is_structural: [256]bool = init: {
        var res: [256]bool = undefined;
        for (0..res.len) |i| {
            res[i] = switch (i) {
                '{', '}', ':', '[', ']', ',' => true,
                else => false,
            };
        }
        break :init res;
    };

    pub const is_whitespace: [256]bool = init: {
        var res: [256]bool = undefined;
        for (0..res.len) |i| {
            res[i] = switch (i) {
                0x20, 0x0a, 0x09, 0x0d => true,
                else => false,
            };
        }
        break :init res;
    };

    pub const is_structural_or_whitespace: [256]bool = init: {
        var res: [256]bool = undefined;
        for (0..res.len) |i| {
            res[i] = is_structural[i] or is_whitespace[i];
        }
        break :init res;
    };

    pub const is_structural_or_whitespace_negated: [256]bool = init: {
        var res: [256]bool = undefined;
        for (0..res.len) |i| {
            res[i] = !is_structural_or_whitespace[i];
        }
        break :init res;
    };

    pub const is_scalar: [256]bool = init: {
        var res: [256]bool = undefined;
        for (0..res.len) |i| {
            switch (i) {
                't', 'f', 'n', '"', '-', '0'...'9' => res[i] = true,
                else => res[i] = false,
            }
        }
        break :init res;
    };

    pub const is_not_scalar: [256]bool = init: {
        var res: [256]bool = undefined;
        for (0..res.len) |i| {
            res[i] = !is_scalar[i];
        }
        break :init res;
    };
};

pub fn intFromSlice(comptime T: type, str: []const u8) *align(1) T {
    return @as(*align(1) T, @ptrCast(@constCast(str)));
}
