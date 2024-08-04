const std = @import("std");
const builtin = @import("builtin");
const tracy = @import("tracy");
const debug = @import("debug");
const common = @import("common.zig");
const types = @import("types.zig");
const intr = @import("intrinsics.zig");
const unicode = @import("unicode.zig");
const Reader = @import("Reader.zig");
const ArrayList = std.ArrayList;
const simd = std.simd;
const vector = types.vector;
const Vector = types.Vector;
const umask = types.umask;
const imask = types.imask;
const assert = debug.assert;
const cpu = builtin.cpu;
const Mask = types.Mask;
const Pred = types.Predicate;

const Error = types.Error;
const Allocator = std.mem.Allocator;
const Self = @This();

debug: if (debug.is_set) Debug else void = if (debug.is_set) .{} else {},

prev_scalar: umask = 0,
prev_inside_string: umask = 0,
next_is_escaped: umask = 0,
unescaped_error: umask = 0,
reader: Reader,
indexes: ArrayList(u32),
utf8_checker: unicode.Checker,

pub fn init(allocator: Allocator) Self {
    return Self{
        .reader = Reader.init(),
        .indexes = ArrayList(u32).init(allocator),
        .utf8_checker = unicode.Checker.init(),
    };
}

pub fn deinit(self: *Self) void {
    self.indexes.deinit();
}

pub fn index(self: *Self, document: []const u8) !void {
    self.reader.read(document);
    const tracer = tracy.traceNamed(@src(), "Indexer.index");
    defer tracer.end();
    try self.indexes.ensureTotalCapacity(self.reader.document.len);
    self.indexes.shrinkRetainingCapacity(0);

    var i = self.reader.index;
    while (self.reader.next()) |block| : (i = self.reader.index) {
        self.step(block, i);
    }
    if (self.reader.last()) |block| {
        self.step(block, i);
    }
    if (self.unescaped_error != 0) return error.FoundControlCharacter;
    if (!self.utf8_checker.succeeded()) return error.InvalidEncoding;
    if (self.prev_inside_string != 0) return error.ExpectedStringEnd;
    if (self.indexes.items.len == 0) return error.Empty;
}

inline fn step(self: *Self, block: *const Reader.block, i: u32) void {
    switch (Reader.MASKS_PER_ITER) {
        1 => {
            const chunk = block[0..Mask.LEN_BITS];
            const tokens = self.identify(chunk);
            self.utf8_checker.check(chunk);
            self.extract(tokens, i);
        },
        2 => {
            const chunk1 = block[0..Mask.LEN_BITS];
            const chunk2 = block[Mask.LEN_BITS..][0..Mask.LEN_BITS];
            const tokens1 = self.identify(chunk1);
            const tokens2 = self.identify(chunk2);
            self.utf8_checker.check(chunk1);
            self.utf8_checker.check(chunk2);
            self.extract(tokens1, i);
            self.extract(tokens2, i + Mask.LEN_BITS);
        },
        else => unreachable,
    }
}

inline fn identify(self: *Self, block: *const [Mask.LEN_BITS]u8) umask {
    // const tracer = tracy.traceNamed(@src(), "Indexer.identify");
    // defer tracer.end();

    const vec: vector = block[0..Vector.LEN_BYTES].*;
    var quotes: umask = Pred(.bytes).pack(vec == Vector.QUOTE);
    var backslash: umask = Pred(.bytes).pack(vec == Vector.SLASH);
    var unescaped: umask = Pred(.bytes).pack(vec < @as(vector, @splat(0x20)));

    inline for (1..Mask.COMPUTED_VECTORS) |i| {
        const offset = i * Vector.LEN_BYTES;
        const _vec: vector = block[offset..][0..Vector.LEN_BYTES].*;
        const q = Pred(.bytes).pack(_vec == Vector.QUOTE);
        const b = Pred(.bytes).pack(_vec == Vector.SLASH);
        const u = Pred(.bytes).pack(_vec < @as(vector, @splat(0x20)));
        quotes |= @as(umask, q) << @truncate(offset);
        backslash |= @as(umask, b) << @truncate(offset);
        unescaped |= @as(umask, u) << @truncate(offset);
    }

    const unescaped_quotes = quotes & ~self.escapedChars(backslash);
    const clmul_ranges = intr.clmul(unescaped_quotes);
    const inside_string = self.prev_inside_string;
    const quoted_ranges = clmul_ranges ^ inside_string;

    const sw = structuralAndWhitespace(block);
    const structural = sw.structural;
    const whitespace = sw.whitespace;

    const struct_white = structural | whitespace;
    const scalar = ~struct_white;

    const nonquote_scalar = scalar & ~unescaped_quotes;
    const follows_nonquote_scalar = nonquote_scalar << 1 | self.prev_scalar;

    const string_tail = quoted_ranges ^ quotes;
    const potential_scalar_start = scalar & ~follows_nonquote_scalar;
    const potential_structural_start = structural | potential_scalar_start;
    const structural_start = potential_structural_start & ~string_tail;

    self.prev_inside_string = @bitCast(@as(imask, @bitCast(quoted_ranges)) >> Mask.LAST_BIT);
    self.prev_scalar = scalar >> Mask.LAST_BIT;
    self.unescaped_error |= unescaped & quoted_ranges;

    defer if (debug.is_set) self.debug.expectIdentified(block, structural_start);
    return structural_start;
}

inline fn structuralAndWhitespace(block: *const [Mask.LEN_BITS]u8) struct {
    structural: umask,
    whitespace: umask,
} {
    if (cpu.arch.isX86()) {
        const whitespace_table = simd.repeat(Vector.LEN_BYTES, [_]u8{ ' ', 100, 100, 100, 17, 100, 113, 2, 100, '\t', '\n', 112, 100, '\r', 100, 100 });
        const structural_table = simd.repeat(Vector.LEN_BYTES, [_]u8{
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, ':', '{', // : = 3A, [ = 5B, { = 7B
            ',', '}', 0, 0, // , = 2C, ] = 5D, } = 7D
        });
        const vec: vector = block[0..Vector.LEN_BYTES].*;

        var whitespace: umask = Pred(.bytes).pack(vec == intr.lookupTable(whitespace_table, vec));
        inline for (1..Mask.COMPUTED_VECTORS) |i| {
            const offset = i * Vector.LEN_BYTES;
            const _vec: vector = block[offset..][0..Vector.LEN_BYTES].*;
            const w: umask = Pred(.bytes).pack(_vec == intr.lookupTable(whitespace_table, _vec));
            whitespace |= w << @truncate(offset);
        }

        var structural: umask = Pred(.bytes).pack(vec | @as(vector, @splat(0x20)) == intr.lookupTable(structural_table, vec));
        inline for (1..Mask.COMPUTED_VECTORS) |i| {
            const offset = i * Vector.LEN_BYTES;
            const _vec: vector = block[offset..][0..Vector.LEN_BYTES].*;
            const s: umask = Pred(.bytes).pack(_vec | @as(vector, @splat(0x20)) == intr.lookupTable(structural_table, _vec));
            structural |= s << @truncate(offset);
        }

        return .{ .structural = structural, .whitespace = whitespace };
    } else {
        const ln_table: vector = simd.repeat(Vector.LEN_BYTES, [_]u8{ 16, 0, 0, 0, 0, 0, 0, 0, 0, 8, 10, 4, 1, 12, 0, 0 });
        const hn_table: vector = simd.repeat(Vector.LEN_BYTES, [_]u8{ 8, 0, 17, 2, 0, 4, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0 });
        const whitespace_table: vector = @splat(0b11000);
        const structural_table: vector = @splat(0b00111);
        const vec: vector = block[0..Vector.LEN_BYTES].*;
        const low_nibbles = vec & @as(vector, @splat(0xF));
        const high_nibbles = vec >> @as(vector, @splat(4));
        const low_lookup_values = intr.lookupTable(ln_table, low_nibbles);
        const high_lookup_values = intr.lookupTable(hn_table, high_nibbles);
        const desired_values = low_lookup_values & high_lookup_values;
        var whitespace: umask = ~Pred(.bytes).pack(desired_values & whitespace_table == Vector.ZER);
        var structural: umask = ~Pred(.bytes).pack(desired_values & structural_table == Vector.ZER);
        inline for (1..Mask.COMPUTED_VECTORS) |i| {
            const offset = i * Vector.LEN_BYTES;
            const _vec: vector = block[offset..][0..Vector.LEN_BYTES].*;
            const _low_nibbles = _vec & @as(vector, @splat(0xF));
            const _high_nibbles = _vec >> @as(vector, @splat(4));
            const _low_lookup_values = intr.lookupTable(ln_table, _low_nibbles);
            const _high_lookup_values = intr.lookupTable(hn_table, _high_nibbles);
            const _desired_values = _low_lookup_values & _high_lookup_values;
            const w: umask = ~Pred(.bytes).pack(_desired_values & whitespace_table == Vector.ZER);
            const s: umask = ~Pred(.bytes).pack(_desired_values & structural_table == Vector.ZER);
            whitespace |= w << @truncate(offset);
            structural |= s << @truncate(offset);
        }
        return .{ .structural = structural, .whitespace = whitespace };
    }
}

inline fn escapedChars(self: *Self, backs: umask) umask {
    if (backs == 0) {
        const escaped = self.next_is_escaped;
        self.next_is_escaped = 0;
        return escaped;
    }
    const odd_mask: umask = @bitCast(simd.repeat(Mask.LEN_BITS, [_]u1{ 0, 1 }));
    const potential_escape = backs & ~self.next_is_escaped;
    const maybe_escaped = potential_escape << 1;
    const maybe_escaped_and_odd_bits = maybe_escaped | odd_mask;
    const even_series_codes_and_odd_bits = maybe_escaped_and_odd_bits -% potential_escape;
    const escape_and_terminal_code = even_series_codes_and_odd_bits ^ odd_mask;
    const escaped = escape_and_terminal_code ^ (backs | self.next_is_escaped);
    const escape = escape_and_terminal_code & backs;
    self.next_is_escaped = escape >> Mask.LAST_BIT;
    return escaped;
}

inline fn extract(self: *Self, tokens: umask, i: u32) void {
    const pop_count = @popCount(tokens);
    const new_len = self.indexes.items.len + pop_count;
    var ptr = self.indexes.items[self.indexes.items.len..].ptr;
    var s = tokens;
    while (s != 0) : (ptr += 8) {
        inline for (0..8) |j| {
            const tz = @ctz(s);
            ptr[j] = i + tz;
            s &= s -% 1;
        }
    }
    self.indexes.items.len = new_len;
}

const Debug = struct {
    prev_scalar: bool = false,
    prev_inside_string: bool = false,
    next_is_escaped: bool = false,

    pub fn expectIdentified(self: *Debug, block: *const [Mask.LEN_BITS]u8, actual: umask) void {

        // Structural chars
        var expected_structural: umask = 0;
        for (block, 0..) |c, i| {
            if (common.Tables.is_structural[c]) {
                expected_structural |= @as(umask, 1) << @truncate(i);
            }
        }

        // Scalars
        for (block, 0..) |c, i| {
            if (i == 0) {
                if (!self.prev_scalar and common.Tables.is_structural_or_whitespace_negated[c]) {
                    expected_structural |= @as(umask, 1) << @truncate(i);
                }
                continue;
            }
            const prev = block[i - 1];
            if ((prev == '"' or common.Tables.is_structural_or_whitespace[prev]) and !common.Tables.is_whitespace[c]) {
                expected_structural |= @as(umask, 1) << @truncate(i);
                continue;
            }
        }
        self.prev_scalar = common.Tables.is_structural_or_whitespace_negated[block[block.len - 1]];

        // Escaped chars
        var expected_escaped: umask = 0;
        for (block, 0..) |c, i| {
            if (self.next_is_escaped) {
                expected_escaped |= @as(umask, 1) << @truncate(i);
                self.next_is_escaped = false;
                continue;
            }
            if (c == '\\') {
                self.next_is_escaped = true;
            }
        }

        // Filter inside strings
        var expected_string_ranges: umask = 0;
        for (block, 0..) |c, i| {
            if (self.prev_inside_string) {
                expected_string_ranges |= @as(umask, 1) << @truncate(i);
            }
            if (c == '"' and @as(u1, @truncate(expected_escaped >> @truncate(i))) == 0) {
                self.prev_inside_string = !self.prev_inside_string;
            }
        }
        const expected = expected_structural & ~expected_string_ranges;

        var printable_block: [Mask.LEN_BITS]u8 = undefined;
        @memcpy(&printable_block, block);
        for (&printable_block) |*c| {
            if (common.Tables.is_whitespace[c.*] and c.* != ' ') {
                c.* = '~';
            }
        }
        debug.assert(
            expected == actual,
            \\Misindexed block
            \\
            \\Block:    '{s}'
            \\Actual:   '{b:0>64}'
            \\Expected: '{b:0>64}'
            \\
        ,
            .{
                printable_block,
                @as(umask, @bitCast(std.simd.reverseOrder(@as(@Vector(64, u1), @bitCast(actual))))),
                @as(umask, @bitCast(std.simd.reverseOrder(@as(@Vector(64, u1), @bitCast(expected))))),
            },
        );
    }
};
