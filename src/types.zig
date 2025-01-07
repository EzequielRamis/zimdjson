const std = @import("std");
const builtin = @import("builtin");
const meta = std.meta;
const simd = std.simd;
const arch = builtin.cpu.arch;

const signed = std.builtin.Signedness.signed;
const unsigned = std.builtin.Signedness.unsigned;

pub const vector = @Vector(Vector.bytes_len, u8);

pub fn Aligned(comptime aligned: bool) type {
    return struct {
        pub const alignment = if (aligned) Vector.bytes_len else @alignOf(u8);
        pub const slice = []align(alignment) const u8;
        pub const chunk = *align(alignment) const [Mask.bits_len]u8;
        pub const vector = *align(alignment) const [Vector.bytes_len]u8;
    };
}

pub const vectors = [Mask.computed_vectors]vector;

pub const masks_per_iter = if (arch.isX86()) 2 else 1;
pub const block_len = Mask.bits_len * masks_per_iter;
pub const block = [block_len]u8;

const NumberTag = enum(u8) {
    unsigned = 'u',
    signed = 'i',
    float = 'd',
};

pub const Number = union(NumberTag) {
    unsigned: u64,
    signed: i64,
    float: f64,
};

pub const Error = error{
    Empty,
    ExceededDepth,
    ExceededCapacity,
    StreamError,
    StreamRead,
    StreamChunkOverflow,
    FoundControlCharacter,
    InvalidEncoding,
    InvalidEscape,
    InvalidUnicodeCodePoint,
    InvalidNumberLiteral,
    ExpectedValue,
    ExpectedColon,
    ExpectedStringEnd,
    ExpectedKey,
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
    pub const bytes_len = simd.suggestVectorLength(u8) orelse @compileError("No SIMD features available");

    pub const zer: vector = @splat(0);
    pub const one: vector = @splat(255);
    pub const slash: vector = @splat('\\');
    pub const quote: vector = @splat('"');
};

pub const umask = u64;
pub const imask = i64;

pub const Mask = struct {
    pub const computed_vectors = 64 / Vector.bytes_len;
    pub const bits_len = 64;
    pub const last_bit = 64 - 1;

    pub const zer: umask = 0;
    pub const one: umask = @bitCast(@as(imask, -1));

    pub inline fn allSet(m: umask) bool {
        return @as(imask, @bitCast(m)) == -1;
    }

    pub inline fn allUnset(m: umask) bool {
        return m == 0;
    }
};

pub const Predicate = struct {
    const L = Vector.bytes_len;
    const E = 8;

    const predicate = @Vector(L, bool);
    const @"packed" = meta.Int(unsigned, L);
    const unpacked = vector;

    pub inline fn pack(p: predicate) @"packed" {
        return @bitCast(p);
    }

    pub inline fn unpack(p: predicate) unpacked {
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
