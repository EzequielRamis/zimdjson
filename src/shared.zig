const std = @import("std");
const builtin = @import("builtin");
const simd = std.simd;
const cpu = builtin.cpu;
const testing = std.testing;

pub const vector_size = simd.suggestVectorLength(u8) orelse @compileError("SIMD features not supported at current target");
pub const vector = @Vector(vector_size, u8);
pub const mask = std.meta.Int(std.builtin.Signedness.unsigned, vector_size);
pub const vector_mask = @Vector(vector_size, bool);

pub const zer_mask: mask = 0;
pub const one_mask: mask = @bitCast(simd.repeat(vector_size, [_]u1{1}));
pub const evn_mask: mask = @bitCast(simd.repeat(vector_size, [_]u1{ 1, 0 }));
pub const odd_mask: mask = @bitCast(simd.repeat(vector_size, [_]u1{ 0, 1 }));

pub const zer_vector: vector_mask = @bitCast(zer_mask);
pub const one_vector: vector_mask = @bitCast(one_mask);

pub const quote: vector = @splat('"');
pub const slash: vector = @splat('\\');

pub fn lookupTable(table: vector, nibbles: vector) vector {
    // TODO:
    // [] arm
    // [] aarch64
    // [] ppc
    // [] mips
    // [] riscv
    // [] wasm
    switch (cpu.arch) {
        .x86_64 => {
            if (vector_size >= 32) {
                return asm volatile (
                    \\vpshufb %[nibbles], %[table], %[ret]
                    : [ret] "=x" (-> vector),
                    : [table] "x" (table),
                      [nibbles] "x" (nibbles),
                );
            } else {
                return asm volatile (
                    \\pshufb %[nibbles], %[table], %[ret]
                    : [ret] "=x" (-> vector),
                    : [table] "x" (table),
                      [nibbles] "x" (nibbles),
                );
            }
        },
        else => @compileError("Table lookup not implemented for this target"),
    }
}

pub fn anyBitsSet(vec: vector, bits: vector) mask {
    return ~@as(mask, @bitCast(bitsNotSet(vec & bits)));
}

pub fn bitsNotSet(vec: vector) vector_mask {
    return @select(bool, vec == @as(vector, @splat(0)), one_vector, zer_vector);
}

pub fn reverseMask(input: mask) mask {
    return @bitCast(simd.reverseOrder(@as(vector_mask, @bitCast(input))));
}

pub fn partialChunk(len: usize) usize {
    return ((len -| 1) / vector_size) * vector_size;
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
