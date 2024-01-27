const std = @import("std");
const builtin = @import("builtin");
const simd = std.simd;
const testing = std.testing;

pub const vector_size = simd.suggestVectorLength(u8) orelse fallback: {
    @compileLog("SIMD not supported on this target.");
    break :fallback 1;
};

pub const register_size = builtin.target.ptrBitWidth();
pub const register_vector_ratio = register_size / @min(register_size, vector_size);

pub const mask = usize;
pub const signed_mask = isize;
pub const vector = @Vector(vector_size, u8);
pub const vector_mask = std.meta.Int(std.builtin.Signedness.unsigned, vector_size);
pub const vectorized_mask = @Vector(vector_size, u1);

pub const vectors = [register_vector_ratio]vector;

pub const zer_mask: mask = 0;
pub const one_mask: mask = @bitCast(@as(isize, -1));
pub const evn_mask: mask = @bitCast(simd.repeat(register_size, [_]u1{ 1, 0 }));
pub const odd_mask: mask = @bitCast(simd.repeat(register_size, [_]u1{ 0, 1 }));

pub const zer_vector_mask: vectorized_mask = @bitCast(zer_mask);
pub const one_vector_mask: vectorized_mask = @bitCast(one_mask);

pub const zer_vector: vector = @splat(0);
pub const one_vector: vector = ~zer_vector;
pub const quote: vector = @splat('"');
pub const slash: vector = @splat('\\');

pub fn reverseMask(input: mask) mask {
    return @bitCast(simd.reverseOrder(@as(vectorized_mask, @bitCast(input))));
}

pub const TapeError = error{
    TrueAtom,
    FalseAtom,
    NullAtom,
    String,
    Number,
    NonValue,
    Empty,
    Colon,
    NonTerminatedString,
    ObjectBegin,
    ArrayBegin,
    MissingValue,
    MissingKey,
    MissingComma,
    InvalidEscape,
    InvalidNumber,
};

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

    pub const hex_digit_map: [256]?u8 = init: {
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
                'a', 'A' => res[i] = 10,
                'b', 'B' => res[i] = 11,
                'c', 'C' => res[i] = 12,
                'd', 'D' => res[i] = 13,
                'e', 'E' => res[i] = 14,
                'f', 'F' => res[i] = 15,
                else => res[i] = null,
            }
        }
        break :init res;
    };
};

pub const ElementTag = enum {
    true_atom,
    false_atom,
    null_atom,

    signed,
    unsigned,
    float,

    string_key,
    string_value,

    object_begin,
    object_end,

    array_begin,
    array_end,

    root,
};

pub const Element = union(ElementTag) {
    true_atom: void,
    false_atom: void,
    null_atom: void,

    signed: i64,
    unsigned: u64,
    float: f64,

    string_key: [:0]const u8,
    string_value: [:0]const u8,

    object_begin: usize,
    object_end: usize,

    array_begin: usize,
    array_end: usize,

    root: usize,
};

pub fn intFromSlice(comptime T: type, str: []const u8) T {
    return @as(*align(1) T, @ptrCast(@constCast(str))).*;
}
