const std = @import("std");
const builtin = @import("builtin");
const simd = std.simd;
const testing = std.testing;

pub const Tables = struct {
    pub const is_structural_or_whitespace: [256]bool = init: {
        var res: [256]bool = undefined;
        for (0..res.len) |i| {
            switch (i) {
                // structural characters
                0x7b, 0x7d, 0x3a, 0x5b, 0x5d, 0x2c => res[i] = true,
                // whitespace characters
                0x20, 0x0a, 0x09, 0x0d => res[i] = true,
                else => res[i] = false,
            }
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

    pub const escape_map: [256]?u8 = init: {
        var res: [256]?u8 = undefined;
        for (0..res.len) |i| {
            switch (i) {
                '"' => res[i] = 0x22,
                '\\' => res[i] = 0x5c,
                '/' => res[i] = 0x2f,
                'b' => res[i] = 0x08,
                'f' => res[i] = 0x0c,
                'n' => res[i] = 0x0a,
                'r' => res[i] = 0x0d,
                't' => res[i] = 0x09,
                else => res[i] = null,
            }
        }
        break :init res;
    };

    pub const digit_map: [256]?u8 = init: {
        var res: [256]?u8 = undefined;
        for (0..res.len) |i| {
            switch (i) {
                '0' => res[i] = 0,
                '1' => res[i] = 1,
                '2' => res[i] = 2,
                '3' => res[i] = 3,
                '4' => res[i] = 4,
                '5' => res[i] = 5,
                '6' => res[i] = 6,
                '7' => res[i] = 7,
                '8' => res[i] = 8,
                '9' => res[i] = 9,
                else => res[i] = null,
            }
        }
        break :init res;
    };

    pub const hex_digit_map: [256]u8 = init: {
        var res: [256]u8 = undefined;
        for (0..res.len) |i| {
            switch (i) {
                '0' => res[i] = 0,
                '1' => res[i] = 1,
                '2' => res[i] = 2,
                '3' => res[i] = 3,
                '4' => res[i] = 4,
                '5' => res[i] = 5,
                '6' => res[i] = 6,
                '7' => res[i] = 7,
                '8' => res[i] = 8,
                '9' => res[i] = 9,
                'a', 'A' => res[i] = 10,
                'b', 'B' => res[i] = 11,
                'c', 'C' => res[i] = 12,
                'd', 'D' => res[i] = 13,
                'e', 'E' => res[i] = 14,
                'f', 'F' => res[i] = 15,
                else => res[i] = 0xFF,
            }
        }
        break :init res;
    };
};

pub fn intFromSlice(comptime T: type, str: []const u8) *align(1) T {
    return @as(*align(1) T, @ptrCast(@constCast(str)));
}
