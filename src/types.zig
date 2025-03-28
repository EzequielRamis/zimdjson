const std = @import("std");
const builtin = @import("builtin");
const meta = std.meta;
const simd = std.simd;
const arch = builtin.cpu.arch;
const assert = std.debug.assert;
const Allocator = std.mem.Allocator;

const signed = std.builtin.Signedness.signed;
const unsigned = std.builtin.Signedness.unsigned;

pub const vector = @Vector(Vector.bytes_len, u8);
pub const vectors = [Mask.computed_vectors]vector;

pub const masks_per_iter = if (arch.isX86()) 2 else 1;
pub const block_len = Mask.bits_len * masks_per_iter;

pub fn Aligned(comptime aligned: bool) type {
    return struct {
        /// Depending on the processor, aligned SIMD vector instructions may provide higher
        /// performance (benchmarking is recommended). To enforce the use of these instructions,
        /// the input must be properly aligned.
        pub const alignment = if (aligned) Vector.bytes_len else @alignOf(u8);
        pub const slice = []align(alignment) const u8;
        pub const vector = *align(alignment) const @Vector(Vector.bytes_len, u8);
        pub const vectors = [Mask.computed_vectors]@This().vector;
        pub const chunk = *align(alignment) const [Mask.bits_len]u8;
        pub const block = *align(alignment) const [block_len]u8;
    };
}

pub const Format = enum {
    json,
};

pub const NumberType = enum(u8) {
    unsigned = 'u',
    signed = 'i',
    double = 'd',
};

/// Represents a valid JSON number.
pub const Number = union(NumberType) {
    /// The number is tagged as `.unsigned` if it fits in a `u64` but *not* in a `i64`.
    unsigned: u64,
    /// The number is tagged as `.signed` if it fits in a `i64`.
    signed: i64,
    /// The number is tagged as `.double` if it has a decimal point or an exponent.
    double: f64,

    /// Cast a number to a different type. If the number doesn't fit in, or can't be
    /// perfectly represented by, the new type, it will be converted to the closest
    /// possible representation.
    pub fn lossyCast(self: Number, comptime T: type) T {
        return switch (self) {
            inline else => |n| std.math.lossyCast(T, n),
        };
    }

    /// Cast an integer to a different integer type. If the number doesn't fit, return
    /// `null`.
    pub fn cast(self: Number, comptime T: type) ?T {
        assert(self != .double); // must pass an integer
        return switch (self) {
            .double => unreachable,
            inline else => |n| std.math.cast(T, n),
        };
    }
};

pub const ValueType = enum {
    null,
    bool,
    number,
    string,
    object,
    array,
};

pub const ReaderError = error{
    /// A generic error occurred while reading from the provided reader. If you want to know
    /// which specific error occurred, you can "recover" it using the following pattern:
    ///
    /// ```zig
    /// const document = parser.parseFromReader(allocator, file.reader().any()) catch |err| switch (err) {
    ///    error.AnyReader => return parser.recoverReaderError(@TypeOf(file.reader())),
    ///    else => |e| return e,
    /// };
    ///
    /// const array = document.asArray() catch |err| switch (err) {
    ///    error.AnyReader => return parser.recoverReaderError(@TypeOf(file.reader())),
    ///    else => |e| return e,
    /// };
    /// ```
    AnyReader,
};

pub const ParseError = error{
    /// The document exceeds the user-specified depth limitation.
    ExceededDepth,
    /// The parser can not support a document that big.
    ExceededCapacity,
    /// The parser can not recognize escape sequence.
    InvalidEscape,
    /// The parser can not decode the Unicode code point.
    InvalidUnicodeCodePoint,
    /// Found a non-numerical character in the number.
    InvalidNumberLiteral,
    /// Expected a colon after key in object.
    ExpectedColon,
    /// Expected a string typed key in object.
    ExpectedKey,
    /// Expected a comma or a closing bracket in array.
    ExpectedArrayCommaOrEnd,
    /// Expected a comma or a closing brace in object.
    ExpectedObjectCommaOrEnd,
    /// The array ends early.
    IncompleteArray,
    /// The object ends early.
    IncompleteObject,
    /// The number does not fit in the target type.
    NumberOutOfRange,
    /// The array index is too large.
    IndexOutOfBounds,
    /// An unexpected trailing content in document.
    TrailingContent,
    /// The value has a different type than user expected.
    IncorrectType,
    /// The field is not found in object.
    MissingField,
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
    pub const odd: umask = 0xAAAA_AAAA_AAAA_AAAA;

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

pub fn BoundedArrayList(comptime T: type, comptime initial_max_capacity: usize) type {
    const Error = ParseError || Allocator.Error;

    return struct {
        const Self = @This();

        max_capacity: usize,
        list: std.ArrayListUnmanaged(T),

        pub const empty = Self{
            .list = .empty,
            .max_capacity = initial_max_capacity,
        };

        pub fn deinit(self: *Self, allocator: Allocator) void {
            self.list.deinit(allocator);
        }

        pub inline fn ensureUnusedCapacity(
            self: *Self,
            allocator: Allocator,
            additional_count: usize,
        ) Error!void {
            if (self.list.items.len + additional_count > self.max_capacity) return error.ExceededCapacity;
            try self.list.ensureUnusedCapacity(allocator, additional_count);
        }

        pub inline fn ensureTotalCapacity(
            self: *Self,
            allocator: Allocator,
            new_capacity: usize,
        ) Error!void {
            if (new_capacity > self.max_capacity) return error.ExceededCapacity;
            try self.list.ensureTotalCapacity(allocator, new_capacity);
        }

        pub inline fn appendAssumeCapacity(self: *Self, item: T) void {
            self.list.appendAssumeCapacity(item);
        }

        pub inline fn appendSliceAssumeCapacity(self: *Self, _items: []const T) void {
            self.list.appendSliceAssumeCapacity(_items);
        }

        pub inline fn items(self: Self) []T {
            return self.list.items;
        }
    };
}

pub fn StringBuffer(comptime initial_max_capacity: usize) type {
    return struct {
        const Self = @This();

        allocator: Allocator,
        strings: BoundedArrayList(u8, initial_max_capacity),

        pub const init: Self = .{
            .allocator = undefined,
            .strings = .empty,
        };

        pub fn ensureTotalCapacity(self: *Self, new_capacity: usize) !void {
            return self.strings.ensureTotalCapacity(self.allocator, new_capacity + Vector.bytes_len);
        }

        pub fn ensureUnusedCapacity(self: *Self, additional_count: usize) !void {
            return self.strings.ensureUnusedCapacity(self.allocator, additional_count);
        }

        pub fn saveIndex(self: Self) usize {
            return self.strings.items().len;
        }

        pub fn loadIndex(self: *Self, index: usize) void {
            self.strings.list.items.len = index;
        }

        pub fn peek(self: Self) [*]u8 {
            return self.strings.items()[self.strings.items().len..].ptr;
        }

        pub fn advance(self: *Self, count: usize) void {
            self.strings.list.items.len += count;
        }

        pub fn reset(self: *Self) void {
            self.strings.list.clearRetainingCapacity();
        }

        pub fn deinit(self: *Self) void {
            self.strings.deinit(self.allocator);
        }
    };
}
