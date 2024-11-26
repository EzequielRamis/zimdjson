const std = @import("std");
const builtin = @import("builtin");
// const tracy = @import("tracy");
// const debug = @import("debug");
const common = @import("common.zig");
const types = @import("types.zig");
const intr = @import("intrinsics.zig");
const unicode = @import("unicode.zig");
const reader = @import("reader.zig");
const simd = std.simd;
const vector = types.vector;
const Vector = types.Vector;
const umask = types.umask;
const imask = types.imask;
const assert = std.debug.assert;
const cpu = builtin.cpu;
const Mask = types.Mask;
const Predicate = types.Predicate;

const Error = types.Error;
const Allocator = std.mem.Allocator;

const Options = struct {
    aligned: bool,
};

pub fn Indexer(comptime options: Options) type {
    return struct {
        const Aligned = types.Aligned(options.aligned);

        const Self = @This();
        const Indexes = std.ArrayList(u32);
        const Reader = reader.Reader(.{ .aligned = options.aligned });
        const Checker = unicode.Checker(.{ .aligned = options.aligned });

        // debug: if (debug.is_set) Debug else void = if (debug.is_set) .{} else {},

        prev_structural: umask = undefined,
        prev_scalar: umask = undefined,
        prev_inside_string: umask = undefined,
        next_is_escaped: umask = undefined,
        unescaped_error: umask = undefined,
        reader: Reader = .{},
        utf8_checker: Checker = .{},
        indexes: Indexes,

        pub fn init(allocator: Allocator) Self {
            return Self{
                .indexes = Indexes.init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.indexes.deinit();
        }

        pub fn index(self: *Self, document: Aligned.slice) !void {
            self.reader.read(document);
            // const tracer = tracy.traceNamed(@src(), "Indexer.index");
            // defer tracer.end();

            try self.indexes.ensureTotalCapacity(self.reader.document.len + 1);
            self.indexes.shrinkRetainingCapacity(0);
            self.prev_structural = 0;
            self.prev_scalar = 0;
            self.prev_inside_string = 0;
            self.next_is_escaped = 0;
            self.unescaped_error = 0;
            self.utf8_checker = .{};

            while (self.reader.next()) |block| {
                self.step(block, self.reader.index -% Reader.BLOCK_SIZE);
            }
            if (self.reader.last()) |block| {
                self.step(block, self.reader.index -% Reader.BLOCK_SIZE);
            }
            self.extract(self.prev_structural, self.reader.index -% Mask.len_bits);
            if (self.unescaped_error != 0) return error.FoundControlCharacter;
            if (!self.utf8_checker.succeeded()) return error.InvalidEncoding;
            if (self.prev_inside_string != 0) return error.ExpectedStringEnd;
            if (self.indexes.items.len == 0) return error.Empty;
        }

        inline fn step(self: *Self, block: Reader.Block, i: u32) void {
            inline for (0..Reader.MASKS_PER_ITER) |m| {
                const offset = @as(comptime_int, m) * Mask.len_bits;
                const chunk: Aligned.chunk = @alignCast(block[offset..][0..Mask.len_bits]);
                var vecs: types.vectors = undefined;
                inline for (0..Mask.computed_vectors) |j| {
                    vecs[j] = @as(Aligned.vector, @alignCast(chunk[j * Vector.len_bytes ..][0..Vector.len_bytes])).*;
                }
                const tokens = self.identify(vecs);
                self.next(vecs, tokens, i + offset);
            }
        }

        inline fn identify(self: *Self, vecs: types.vectors) JsonBlock {
            const vec = vecs[0];
            var quotes: umask = Predicate.pack(vec == Vector.quote);
            var backslash: umask = Predicate.pack(vec == Vector.slash);
            inline for (1..Mask.computed_vectors) |i| {
                const offset = i * Vector.len_bytes;
                const _vec = vecs[i];
                const q = Predicate.pack(_vec == Vector.quote);
                const b = Predicate.pack(_vec == Vector.slash);
                quotes |= @as(umask, q) << @truncate(offset);
                backslash |= @as(umask, b) << @truncate(offset);
            }

            const unescaped_quotes = quotes & ~self.escapedChars(backslash);
            const clmul_ranges = intr.clmul(unescaped_quotes);
            const inside_string = clmul_ranges ^ self.prev_inside_string;
            self.prev_inside_string = @bitCast(@as(imask, @bitCast(inside_string)) >> Mask.last_bit);
            const strings = StringBlock{
                .in_string = inside_string,
                .quotes = unescaped_quotes,
            };

            const chars = classify(vecs);
            const nonquote_scalar = chars.scalar() & ~strings.quotes;
            const follows_nonquote_scalar = nonquote_scalar << 1 | self.prev_scalar;
            self.prev_scalar = nonquote_scalar >> Mask.last_bit;

            return .{
                .string = strings,
                .chars = chars,
                .follows_potential_nonquote_scalar = follows_nonquote_scalar,
            };
        }

        inline fn classify(vecs: types.vectors) CharsBlock {
            if (cpu.arch.isX86()) {
                const whitespace_table: vector = simd.repeat(Vector.len_bytes, [_]u8{ ' ', 100, 100, 100, 17, 100, 113, 2, 100, '\t', '\n', 112, 100, '\r', 100, 100 });
                const structural_table: vector = simd.repeat(Vector.len_bytes, [_]u8{
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, ':', '{', // : = 3A, [ = 5B, { = 7B
                    ',', '}', 0, 0, // , = 2C, ] = 5D, } = 7D
                });
                const vec = vecs[0];
                var whitespace: umask = Predicate.pack(vec == intr.lookupTable(whitespace_table, vec));
                var structural: umask = Predicate.pack(vec | @as(vector, @splat(0x20)) == intr.lookupTable(structural_table, vec));
                inline for (1..Mask.computed_vectors) |i| {
                    const offset = i * Vector.len_bytes;
                    const _vec = vecs[i];
                    const w: umask = Predicate.pack(_vec == intr.lookupTable(whitespace_table, _vec));
                    const s: umask = Predicate.pack(_vec | @as(vector, @splat(0x20)) == intr.lookupTable(structural_table, _vec));
                    whitespace |= w << @truncate(offset);
                    structural |= s << @truncate(offset);
                }

                return .{ .structural = structural, .whitespace = whitespace };
            } else {
                const ln_table: vector = simd.repeat(Vector.len_bytes, [_]u8{ 16, 0, 0, 0, 0, 0, 0, 0, 0, 8, 10, 4, 1, 12, 0, 0 });
                const hn_table: vector = simd.repeat(Vector.len_bytes, [_]u8{ 8, 0, 17, 2, 0, 4, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0 });
                const whitespace_table: vector = @splat(0b11000);
                const structural_table: vector = @splat(0b00111);
                const vec = vecs[0];
                const low_nibbles = vec & @as(vector, @splat(0xF));
                const high_nibbles = vec >> @as(vector, @splat(4));
                const low_lookup_values = intr.lookupTable(ln_table, low_nibbles);
                const high_lookup_values = intr.lookupTable(hn_table, high_nibbles);
                const desired_values = low_lookup_values & high_lookup_values;
                var whitespace: umask = ~Predicate.pack(desired_values & whitespace_table == Vector.zer);
                var structural: umask = ~Predicate.pack(desired_values & structural_table == Vector.zer);
                inline for (1..Mask.computed_vectors) |i| {
                    const offset = i * Vector.len_bytes;
                    const _vec = vecs[i];
                    const _low_nibbles = _vec & @as(vector, @splat(0xF));
                    const _high_nibbles = _vec >> @as(vector, @splat(4));
                    const _low_lookup_values = intr.lookupTable(ln_table, _low_nibbles);
                    const _high_lookup_values = intr.lookupTable(hn_table, _high_nibbles);
                    const _desired_values = _low_lookup_values & _high_lookup_values;
                    const w: umask = ~Predicate.pack(_desired_values & whitespace_table == Vector.zer);
                    const s: umask = ~Predicate.pack(_desired_values & structural_table == Vector.zer);
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
            const odd_mask: umask = @bitCast(simd.repeat(Mask.len_bits, [_]u1{ 0, 1 }));
            const potential_escape = backs & ~self.next_is_escaped;
            const maybe_escaped = potential_escape << 1;
            const maybe_escaped_and_odd_bits = maybe_escaped | odd_mask;
            const even_series_codes_and_odd_bits = maybe_escaped_and_odd_bits -% potential_escape;
            const escape_and_terminal_code = even_series_codes_and_odd_bits ^ odd_mask;
            const escaped = escape_and_terminal_code ^ (backs | self.next_is_escaped);
            const escape = escape_and_terminal_code & backs;
            self.next_is_escaped = escape >> Mask.last_bit;
            return escaped;
        }

        inline fn next(self: *Self, vecs: types.vectors, block: JsonBlock, i: u32) void {
            const vec = vecs[0];
            var unescaped: umask = Predicate.pack(vec <= @as(vector, @splat(0x1F)));
            inline for (1..Mask.computed_vectors) |j| {
                const offset = j * Vector.len_bytes;
                const _vec = vecs[j];
                const u = Predicate.pack(_vec <= @as(vector, @splat(0x1F)));
                unescaped |= @as(umask, u) << @truncate(offset);
            }
            self.utf8_checker.check(vecs);
            self.extract(self.prev_structural, i -% Mask.len_bits);
            self.prev_structural = block.structuralStart();
            self.unescaped_error |= block.nonQuoteInsideString(unescaped);
            // if (debug.is_set) self.debug.expectIdentified(vecs, self.prev_structural);
        }

        inline fn extract(self: *Self, tokens: umask, i: u32) void {
            const steps = 4;
            const steps_until = 24;
            const pop_count: u32 = @popCount(tokens);
            const ixs = self.indexes.items[self.indexes.items.len..].ptr;
            self.indexes.items.len += pop_count;
            var s = if (cpu.arch.isARM()) @bitReverse(tokens) else tokens;
            inline for (0..steps_until / steps) |u| {
                if (u * steps < pop_count) {
                    @branchHint(.unlikely);
                    inline for (0..steps) |j| {
                        if (cpu.arch.isARM()) {
                            const lz: u32 = @clz(s);
                            ixs[j + u * steps] = i + lz;
                            s ^= std.math.shr(umask, 1 << 63, lz);
                        } else {
                            const tz: u32 = @ctz(s);
                            ixs[j + u * steps] = i + tz;
                            s &= s -% 1;
                        }
                    }
                }
            }
            if (steps_until < pop_count) {
                @branchHint(.unlikely);
                for (steps_until..pop_count) |j| {
                    if (cpu.arch.isARM()) {
                        const lz: u32 = @clz(s);
                        ixs[j] = i + lz;
                        s ^= std.math.shr(umask, 1 << 63, lz);
                    } else {
                        const tz: u32 = @ctz(s);
                        ixs[j] = i + tz;
                        s &= s -% 1;
                    }
                }
            }
        }
    };
}

const JsonBlock = struct {
    string: StringBlock,
    chars: CharsBlock,
    follows_potential_nonquote_scalar: umask,

    pub inline fn structuralStart(self: JsonBlock) umask {
        return self.potentialStructuralStart() & ~self.string.stringTail();
    }

    pub inline fn whitespace(self: JsonBlock) umask {
        return self.nonQuoteOutsideString(self.chars.whitespace);
    }

    pub inline fn nonQuoteInsideString(self: JsonBlock, mask: umask) umask {
        return self.string.nonQuoteInsideString(mask);
    }

    pub inline fn nonQuoteOutsideString(self: JsonBlock, mask: umask) umask {
        return self.string.nonQuoteOutsideString(mask);
    }

    inline fn potentialStructuralStart(self: JsonBlock) umask {
        return self.chars.structural | self.potentialScalarStart();
    }

    inline fn potentialScalarStart(self: JsonBlock) umask {
        return self.chars.scalar() & ~self.follows_potential_nonquote_scalar;
    }
};

const StringBlock = struct {
    quotes: umask,
    in_string: umask,

    pub inline fn stringContent(self: StringBlock) umask {
        return self.in_string & ~self.quotes;
    }

    pub inline fn nonQuoteInsideString(self: StringBlock, mask: umask) umask {
        return mask & self.in_string;
    }

    pub inline fn nonQuoteOutsideString(self: StringBlock, mask: umask) umask {
        return mask & ~self.in_string;
    }

    pub inline fn stringTail(self: StringBlock) umask {
        return self.in_string ^ self.quotes;
    }
};

const CharsBlock = struct {
    whitespace: umask,
    structural: umask,

    pub inline fn scalar(self: CharsBlock) umask {
        return ~(self.structural | self.whitespace);
    }
};

const Debug = struct {
    loc: u32 = 0,
    prev_scalar: bool = false,
    prev_inside_string: bool = false,
    next_is_escaped: bool = false,

    fn isX86Relaxed(c: u8) bool {
        return if (cpu.arch.isX86()) c == 26 or c == 255 else true;
    }

    pub fn expectIdentified(self: *Debug, vecs: types.vectors, actual: umask) void {
        const chunk: [Mask.len_bits]u8 = @bitCast(vecs);

        // Structural chars
        var expected_structural: umask = 0;
        for (chunk, 0..) |c, i| {
            if (common.tables.is_structural[c] or isX86Relaxed(c)) {
                expected_structural |= @as(umask, 1) << @truncate(i);
            }
        }

        // Scalars
        for (chunk, 0..) |c, i| {
            if (i == 0) {
                if (!self.prev_scalar and !(common.tables.is_structural_or_whitespace[c] or isX86Relaxed(c))) {
                    expected_structural |= @as(umask, 1) << @truncate(i);
                }
                continue;
            }
            const prev = chunk[i - 1];
            if ((prev == '"' or common.tables.is_structural_or_whitespace[prev] or isX86Relaxed(prev)) and !common.tables.is_whitespace[c]) {
                expected_structural |= @as(umask, 1) << @truncate(i);
                continue;
            }
        }
        self.prev_scalar = !(common.tables.is_structural_or_whitespace[chunk[chunk.len - 1]] or isX86Relaxed(chunk[chunk.len - 1]));

        // Escaped chars
        var expected_escaped: umask = 0;
        for (chunk, 0..) |c, i| {
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
        for (chunk, 0..) |c, i| {
            if (self.prev_inside_string) {
                expected_string_ranges |= @as(umask, 1) << @truncate(i);
            }
            if (c == '"' and @as(u1, @truncate(expected_escaped >> @truncate(i))) == 0) {
                self.prev_inside_string = !self.prev_inside_string;
            }
        }
        const expected = expected_structural & ~expected_string_ranges;

        for (chunk) |c| {
            if (c == '\n') self.loc += 1;
        }

        var printable_chunk: [Mask.len_bits]u8 = undefined;
        @memcpy(&printable_chunk, &chunk);
        for (&printable_chunk) |*c| {
            if (common.tables.is_whitespace[c.*] and c.* != ' ') {
                c.* = '~';
            }
            if (!(32 <= c.* and c.* < 128)) {
                c.* = '*';
            }
        }
        assert(
            expected == actual,
            \\Misindexed chunk at line {}
            \\
            \\Chunk:    '{s}'
            \\Actual:   '{b:0>64}'
            \\Expected: '{b:0>64}'
            \\
        ,
            .{
                self.loc,
                printable_chunk,
                @as(umask, @bitCast(std.simd.reverseOrder(@as(@Vector(64, u1), @bitCast(actual))))),
                @as(umask, @bitCast(std.simd.reverseOrder(@as(@Vector(64, u1), @bitCast(expected))))),
            },
        );
    }
};
