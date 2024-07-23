const std = @import("std");
const builtin = @import("builtin");
const meta = std.meta;
const simd = std.simd;

const SIGNED = std.builtin.Signedness.signed;
const UNSIGNED = std.builtin.Signedness.unsigned;

pub const vector = @Vector(Vector.LEN_BYTES, u8);
pub const array = [Vector.LEN_BYTES]u8;

pub const Number = union(enum) {
    unsigned: u64,
    signed: i64,
    float: f64,
};

pub const Error = error{
    MaxDepth,
    MaxCapacity,
    Empty,
    Encoding,
    InvalidArray,
    InvalidObject,
    TrailingContent,
    StringUnclosed,
    StringEscaping,
    NumberLiteral,
    NumberOverflow,
    NonValue,
    IncorrectType,
    IndexOutOfBounds,
    UnknownField,
    MissingField,
    DuplicateField,
};

pub const Vector = struct {
    const Self = @This();

    pub const LEN_BYTES = simd.suggestVectorLength(u8) orelse @compileError("SIMD unsupported on this target.");
    pub const LEN_WORDS = LEN_BYTES / 2;
    pub const LEN_DORDS = LEN_BYTES / 4;
    pub const LEN_MASKS = LEN_BYTES / 8;

    pub const ZER: vector = @splat(0);
    pub const ONE: vector = @splat(255);
    pub const SLASH: vector = @splat('\\');
    pub const QUOTE: vector = @splat('"');

    const FormatTag = enum { bytes, words, dords, masks, packs };

    const Format = union(FormatTag) {
        bytes: @Vector(LEN_BYTES, u8),
        words: @Vector(LEN_WORDS, u16),
        dords: @Vector(LEN_DORDS, u32),
        masks: @Vector(LEN_MASKS, u64),
        packs: @Vector(8, PackedElem),
    };

    const ArrFormat = union(FormatTag) {
        bytes: *const [LEN_BYTES]u8,
        words: *const [LEN_WORDS]u16,
        dords: *const [LEN_DORDS]u32,
        masks: *const [LEN_MASKS]u64,
        packs: *const [8]PackedElem,
    };

    pub const PackedElem = meta.Int(UNSIGNED, LEN_BYTES);
    pub const Packed = @Vector(8, PackedElem);
    pub const Masks = @Vector(LEN_MASKS, u64);
    pub const LAST_MASK = LEN_MASKS - 1;

    v: *const [LEN_BYTES]u8,

    pub fn from(v: anytype) Self {
        return .{ .v = @bitCast(v) };
    }

    pub fn fromPtr(v: anytype) Self {
        return .{ .v = @ptrCast(v) };
    }

    pub fn to(self: Self, comptime f: FormatTag) meta.fieldInfo(Format, f).type {
        return @bitCast(self.v.*);
    }

    pub fn format(self: Self, comptime f: FormatTag) meta.fieldInfo(ArrFormat, f).type {
        return @ptrCast(self.v);
    }

    pub fn first(self: Self, comptime f: FormatTag) @typeInfo(meta.fieldInfo(Format, f).type).type {
        return self.format(f)[0];
    }

    pub fn last(self: Self, comptime f: FormatTag) @typeInfo(meta.fieldInfo(Format, f).type).type {
        const len = @typeInfo(self.format(f)).len;
        return self.format(f)[len - 1];
    }
};

pub const umask = usize;
pub const imask = isize;

pub const Mask = struct {
    const Self = @This();

    pub const COMPUTED_VECTORS = 64 / Vector.LEN_BYTES;
    pub const LEN_BITS = 64;
    pub const LAST_BIT = 64 - 1;
    pub const LAST_BYTE = 64 - 8;
    pub const LAST_WORD = 64 - 16;
    pub const LAST_DORD = 64 - 32;
    pub const ZER: umask = 0;
    pub const ONE: umask = @bitCast(@as(imask, -1));

    pub fn allSet(m: umask) bool {
        return @as(imask, @bitCast(m)) == -1;
    }

    pub fn allUnset(m: umask) bool {
        return m == 0;
    }
};

pub fn Predicate(comptime f: Vector.FormatTag) type {
    const L = switch (f) {
        .bytes => Vector.LEN_BYTES,
        .words => Vector.LEN_WORDS,
        .dords => Vector.LEN_DORDS,
        .masks => Vector.LEN_MASKS,
        .packs => 8,
    };

    const E = switch (f) {
        .bytes => 8,
        .words => 16,
        .dords => 32,
        .masks => 64,
        .packs => Vector.LEN_BYTES,
    };

    const V = @Vector(L, bool);

    return struct {
        v: V,

        pub fn from(v: V) @This() {
            return .{ .v = v };
        }

        pub fn pack(self: @This()) meta.Int(UNSIGNED, L) {
            return @bitCast(self.v);
        }

        pub fn unpack(self: @This()) meta.fieldInfo(Vector.Format, f).type {
            return @as(@Vector(L, meta.Int(UNSIGNED, E)), @bitCast(@as(
                @Vector(L, meta.Int(SIGNED, E)),
                @intCast(@as(
                    @Vector(L, i1),
                    @bitCast(
                        @as(@Vector(L, u1), @intFromBool(self.v)),
                    ),
                )),
            )));
        }
    };
}
