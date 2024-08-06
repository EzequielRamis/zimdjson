const std = @import("std");
const builtin = @import("builtin");
const io = @import("io.zig");
const meta = std.meta;
const simd = std.simd;

const signed = std.builtin.Signedness.signed;
const unsigned = std.builtin.Signedness.unsigned;

pub const vector = @Vector(Vector.len_bytes, u8);

pub fn Aligned(comptime aligned: bool) type {
    return struct {
        pub const alignment = if (aligned) Vector.len_bytes else 1;
        pub const slice = []align(alignment) const u8;
        pub const chunk = *align(alignment) const [Mask.len_bits]u8;
        pub const vector = *align(alignment) const [Vector.len_bytes]u8;
    };
}

pub const vectors = [Mask.computed_vectors]vector;

pub const Number = union(enum) {
    unsigned: u64,
    signed: i64,
    float: f64,
};

pub const Error = error{
    Empty,
    ExceededDepth,
    ExceededCapacity,
    FoundControlCharacter,
    InvalidEncoding,
    InvalidEscape,
    InvalidUnicodeCodePoint,
    InvalidNumberLiteral,
    ExpectedValue,
    ExpectedColon,
    ExpectedStringEnd,
    ExpectedKeyAsString,
    ExpectedArrayCommaOrEnd,
    ExpectedObjectCommaOrEnd,
    IncompleteArray,
    IncompleteObject,
    NumberOutOfRange,
    IndexOutOfBounds,
    TrailingContent,
    IncorrectPointer,
    IncorrectType,
    UnknownVariant,
    UnknownField,
    MissingField,
    DuplicateField,
};

pub const Vector = struct {
    pub const len_bytes = simd.suggestVectorLength(u8) orelse @compileError("SIMD unsupported on this target.");

    pub const zer: vector = @splat(0);
    pub const one: vector = @splat(255);
    pub const slash: vector = @splat('\\');
    pub const quote: vector = @splat('"');
};

pub const umask = u64;
pub const imask = i64;

pub const Mask = struct {
    pub const computed_vectors = 64 / Vector.len_bytes;
    pub const len_bits = 64;
    pub const last_bit = 64 - 1;

    pub const zer: umask = 0;
    pub const one: umask = @bitCast(@as(imask, -1));

    pub fn allSet(m: umask) bool {
        return @as(imask, @bitCast(m)) == -1;
    }

    pub fn allUnset(m: umask) bool {
        return m == 0;
    }
};

pub const Predicate = struct {
    const L = Vector.len_bytes;
    const E = 8;

    const predicate = @Vector(L, bool);
    const @"packed" = meta.Int(unsigned, L);
    const unpacked = vector;

    pub fn pack(p: predicate) @"packed" {
        return @bitCast(p);
    }

    pub fn unpack(p: predicate) unpacked {
        return @as(@Vector(L, meta.Int(unsigned, E)), @bitCast(@as(
            @Vector(L, meta.Int(signed, E)),
            @intCast(@as(
                @Vector(L, i1),
                @bitCast(
                    @as(@Vector(L, u1), @intFromBool(p)),
                ),
            )),
        )));
    }
};
