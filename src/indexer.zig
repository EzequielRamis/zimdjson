const std = @import("std");
const builtin = @import("builtin");
const build_options = @import("build_options");
// const tracy = @import("tracy");
const common = @import("common.zig");
const types = @import("types.zig");
const intr = @import("intrinsics.zig");
const simd = std.simd;
const vector = types.vector;
const Vector = types.Vector;
const umask = types.umask;
const imask = types.imask;
const assert = std.debug.assert;
const cpu = builtin.cpu;
const Mask = types.Mask;
const Predicate = types.Predicate;

pub const Error = error{
    /// Found unescaped characters in string.
    FoundUnescapedChars,
    /// The input is not valid UTF-8.
    InvalidUtf8,
    /// Missing quote at the end.
    ExpectedStringEnd,
    /// No structural element found.
    Empty,
};

const Allocator = std.mem.Allocator;

const Options = struct {
    aligned: bool,
    relative: bool,
};

const debug_indexer = builtin.mode == .Debug and build_options.is_dev_mode;

pub fn Indexer(comptime T: type, comptime options: Options) type {
    return struct {
        const Self = @This();
        const Aligned = types.Aligned(options.aligned);

        debug: if (debug_indexer) Debug else void = if (debug_indexer) .{} else {},

        prev_scalar: umask,
        prev_inside_string: umask,
        prev_offset: if (options.relative) i64 else T,

        next_is_escaped: umask,
        unescaped_error: umask,
        utf8: Utf8 = .init,

        pub const init = std.mem.zeroInit(Self, .{});

        pub inline fn validate(self: Self) Error!void {
            if (self.unescaped_error != 0) return error.FoundUnescapedChars;
            if (!self.utf8.succeeded()) return error.InvalidUtf8;
        }

        pub inline fn validateEof(self: Self) Error!void {
            if (self.prev_inside_string != 0) return error.ExpectedStringEnd;
        }

        pub inline fn index(self: *Self, block: Aligned.block, dest: [*]T) u32 {
            var written: u32 = 0;
            var vectors: [types.masks_per_iter]types.vectors = undefined;
            var blocks: [types.masks_per_iter]JsonBlock = undefined;
            inline for (0..types.masks_per_iter) |m| {
                const offset = @as(comptime_int, m) * Mask.bits_len;
                const chunk: Aligned.chunk = block[offset..][0..Mask.bits_len];
                inline for (0..Mask.computed_vectors) |j| {
                    vectors[m][j] = @as(Aligned.vector, chunk[j * Vector.bytes_len ..][0..Vector.bytes_len]).*;
                }
            }
            inline for (0..types.masks_per_iter) |m| {
                blocks[m] = self.identify(vectors[m]);
            }
            inline for (0..types.masks_per_iter) |m| {
                written += self.next(vectors[m], blocks[m], dest[written..]);
            }
            return written;
        }

        inline fn identify(self: *Self, vecs: types.vectors) JsonBlock {
            const vec = vecs[0];
            var quotes: umask = Predicate.pack(vec == Vector.quote);
            inline for (1..Mask.computed_vectors) |i| {
                const offset = i * Vector.bytes_len;
                const _vec = vecs[i];
                const q = Predicate.pack(_vec == Vector.quote);
                quotes |= @as(umask, q) << @truncate(offset);
            }
            const unescaped_quotes = quotes & ~self.escapedChars(vecs);
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
                const whitespace_table: vector = simd.repeat(Vector.bytes_len, [_]u8{ ' ', 100, 100, 100, 17, 100, 113, 2, 100, '\t', '\n', 112, 100, '\r', 100, 100 });
                const structural_table: vector = simd.repeat(Vector.bytes_len, [_]u8{
                    0, 0, 0, 0,
                    0, 0, 0, 0,
                    0, 0, ':', '{', // : = 3A, [ = 5B, { = 7B
                    ',', '}', 0, 0, // , = 2C, ] = 5D, } = 7D
                });
                const vec = vecs[0];
                var whitespace: umask = Predicate.pack(vec == intr.lookupTable(whitespace_table, vec));
                var structural: umask = Predicate.pack(vec | @as(vector, @splat(0x20)) == intr.lookupTable(structural_table, vec));
                inline for (1..Mask.computed_vectors) |i| {
                    const offset = i * Vector.bytes_len;
                    const _vec = vecs[i];
                    const s: umask = Predicate.pack(_vec | @as(vector, @splat(0x20)) == intr.lookupTable(structural_table, _vec));
                    structural |= s << @truncate(offset);
                }

                inline for (1..Mask.computed_vectors) |i| {
                    const offset = i * Vector.bytes_len;
                    const _vec = vecs[i];
                    const w: umask = Predicate.pack(_vec == intr.lookupTable(whitespace_table, _vec));
                    whitespace |= w << @truncate(offset);
                }
                return .{ .structural = structural, .whitespace = whitespace };
            } else {
                const ln_table: vector = simd.repeat(Vector.bytes_len, [_]u8{ 16, 0, 0, 0, 0, 0, 0, 0, 0, 8, 10, 4, 1, 12, 0, 0 });
                const hn_table: vector = simd.repeat(Vector.bytes_len, [_]u8{ 8, 0, 17, 2, 0, 4, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0 });
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
                    const offset = i * Vector.bytes_len;
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

        inline fn escapedChars(self: *Self, vecs: types.vectors) umask {
            const next_is_escaped = self.next_is_escaped;
            const vec = vecs[0];
            var backslash: umask = Predicate.pack(vec == Vector.slash);
            inline for (1..Mask.computed_vectors) |i| {
                const offset = i * Vector.bytes_len;
                const _vec = vecs[i];
                const b = Predicate.pack(_vec == Vector.slash);
                backslash |= @as(umask, b) << @truncate(offset);
            }
            if (backslash == 0) {
                const escaped = next_is_escaped;
                self.next_is_escaped = 0;
                return escaped;
            }
            const potential_escape = backslash & ~next_is_escaped;
            const maybe_escaped = potential_escape << 1;
            const maybe_escaped_and_odd_bits = maybe_escaped | types.Mask.odd;
            const even_series_codes_and_odd_bits = maybe_escaped_and_odd_bits -% potential_escape;
            const escape_and_terminal_code = even_series_codes_and_odd_bits ^ types.Mask.odd;
            const escaped = escape_and_terminal_code ^ (backslash | next_is_escaped);
            const escape = escape_and_terminal_code & backslash;
            self.next_is_escaped = escape >> Mask.last_bit;
            return escaped;
        }

        inline fn next(self: *Self, vecs: types.vectors, block: JsonBlock, dest: [*]T) u32 {
            const vec = vecs[0];
            var unescaped: umask = Predicate.pack(vec <= @as(vector, @splat(0x1F)));
            inline for (1..Mask.computed_vectors) |j| {
                const offset = j * Vector.bytes_len;
                const _vec = vecs[j];
                const u = Predicate.pack(_vec <= @as(vector, @splat(0x1F)));
                unescaped |= @as(umask, u) << @truncate(offset);
            }
            self.utf8.check(vecs);
            const structurals = block.structuralStart();
            if (debug_indexer) self.debug.expectIdentified(vecs, structurals);
            const written = self.extract(structurals, dest);
            self.unescaped_error |= block.nonQuoteInsideString(unescaped);
            return written;
        }

        const RelativeOffsetBuffer = [Mask.bits_len + 1]u8;
        inline fn extract(self: *Self, tokens: umask, dest: [*]T) u32 {
            const steps = 4;
            const steps_until = 24;
            assert(steps_until < types.Mask.bits_len);

            const pop_count: u8 = @popCount(tokens);
            var mask = if (cpu.arch.isArm()) @bitReverse(tokens) else tokens;

            var offsets: RelativeOffsetBuffer = undefined;
            if (options.relative) offsets[0] = 0;

            const prev_offset = self.prev_offset;

            if (0 < pop_count) {
                inline for (0..steps) |j| self.writeIndexAt(j, &mask, dest, &offsets, prev_offset);
                self.recursiveWrites(1, steps, (steps_until / steps) - 1, pop_count, &mask, dest, &offsets, prev_offset);
                if (steps_until < pop_count) {
                    @branchHint(.unlikely);
                    for (steps_until..pop_count) |j| self.writeIndexAt(j, &mask, dest, &offsets, prev_offset);
                }
                if (options.relative) {
                    dest[0] = @intCast(@as(i64, @intCast(dest[0])) - prev_offset);
                    self.prev_offset = offsets[pop_count];
                }
            }

            if (options.relative) {
                self.prev_offset -= Mask.bits_len;
            } else {
                self.prev_offset +%= Mask.bits_len;
            }
            return pop_count;
        }

        inline fn recursiveWrites(
            self: Self,
            i: comptime_int,
            steps: comptime_int,
            until: comptime_int,
            pop_count: u8,
            mask: *umask,
            dest: [*]T,
            offsets: *RelativeOffsetBuffer,
            prev_offset: anytype,
        ) void {
            if (i * steps < pop_count) {
                @branchHint(.unlikely);
                inline for (0..steps) |j| self.writeIndexAt(j + i * steps, mask, dest, offsets, prev_offset);
                if (i < until) {
                    self.recursiveWrites(
                        i + 1,
                        steps,
                        until,
                        pop_count,
                        mask,
                        dest,
                        offsets,
                        prev_offset,
                    );
                }
            }
        }

        inline fn writeIndexAt(
            _: Self,
            i: usize,
            mask: *umask,
            dest: [*]T,
            offsets: *RelativeOffsetBuffer,
            prev_offset: anytype,
        ) void {
            const offset: if (options.relative) u8 else T =
                if (cpu.arch.isArm())
                    @clz(mask.*)
                else
                    @ctz(mask.*);

            if (options.relative) {
                dest[i] = offset - offsets[i];
                offsets[i + 1] = offset;
            } else {
                dest[i] = offset +% prev_offset;
            }

            if (cpu.arch.isArm()) {
                mask.* ^= std.math.shr(umask, 1 << 63, offset);
            } else {
                mask.* &= mask.* -% 1;
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

const Utf8 = struct {
    const Self = @This();

    err: vector,
    prev_vec: vector,
    prev_incomplete: vector,

    pub const init = std.mem.zeroInit(Self, .{});

    pub inline fn succeeded(self: Self) bool {
        const err = self.err | self.prev_incomplete;
        return simd.prefixScan(.Or, 1, err)[Vector.bytes_len - 1] == 0;
    }

    pub inline fn check(self: *Self, vecs: types.vectors) void {
        if (isASCII(vecs)) {
            @branchHint(.likely);
            self.err |= self.prev_incomplete;
        } else {
            inline for (0..Mask.computed_vectors) |i| {
                const vec = vecs[i];
                self.checkUTF8Bytes(vec);
                self.prev_vec = vec;
                if (i == Mask.computed_vectors - 1) {
                    self.prev_incomplete = isIncomplete(vec);
                }
            }
        }
    }

    inline fn isASCII(vecs: types.vectors) bool {
        var reduced = vecs[0];
        inline for (0..Mask.computed_vectors) |i| {
            reduced |= vecs[i];
        }
        return Predicate.pack(@as(vector, @splat(0x80)) <= reduced) == 0;
    }

    inline fn isIncomplete(vec: vector) vector {
        const max: vector = @splat(255);
        return vec -| max;
    }

    inline fn checkUTF8Bytes(self: *Self, vec: vector) void {
        @setEvalBranchQuota(10000);
        const prev_vec = self.prev_vec;
        const len = Vector.bytes_len;
        const prev1_mask: @Vector(len, i32) = [_]i32{len} ++ ([_]i32{0} ** (len - 1));
        const prev2_mask: @Vector(len, i32) = [_]i32{ len - 1, len } ++ ([_]i32{0} ** (len - 2));
        const prev3_mask: @Vector(len, i32) = [_]i32{ len - 2, len - 1, len } ++ ([_]i32{0} ** (len - 3));
        const shift1_mask = comptime simd.shiftElementsRight(simd.iota(i32, len), 1, 0) - prev1_mask;
        const shift2_mask = comptime simd.shiftElementsRight(simd.iota(i32, len), 2, 0) - prev2_mask;
        const shift3_mask = comptime simd.shiftElementsRight(simd.iota(i32, len), 3, 0) - prev3_mask;
        const prev1 = @shuffle(u8, vec, prev_vec, shift1_mask);

        // zig fmt: off
        // Bit 0 = Too Short (lead byte/ASCII followed by lead byte/ASCII)
        // Bit 1 = Too Long (ASCII followed by continuation)
        // Bit 2 = Overlong 3-byte
        // Bit 4 = Surrogate
        // Bit 5 = Overlong 2-byte
        // Bit 7 = Two Continuations
        const TOO_SHORT      :u8 = 1 << 0; // 11______ 0_______
                                           // 11______ 11______
        const TOO_LONG       :u8 = 1 << 1; // 0_______ 10______
        const OVERLONG_3     :u8 = 1 << 2; // 11100000 100_____
        const SURROGATE      :u8 = 1 << 4; // 11101101 101_____
        const OVERLONG_2     :u8 = 1 << 5; // 1100000_ 10______
        const TWO_CONTS      :u8 = 1 << 7; // 10______ 10______
        const TOO_LARGE      :u8 = 1 << 3; // 11110100 1001____
                                           // 11110100 101_____
                                           // 11110101 1001____
                                           // 11110101 101_____
                                           // 1111011_ 1001____
                                           // 1111011_ 101_____
                                           // 11111___ 1001____
                                           // 11111___ 101_____
        const TOO_LARGE_1000 :u8 = 1 << 6;
                                           // 11110101 1000____
                                           // 1111011_ 1000____
                                           // 11111___ 1000____
        const OVERLONG_4     :u8 = 1 << 6; // 11110000 1000____

        const byte_1_high = intr.lookupTable(simd.repeat(Vector.bytes_len, [_]u8{
            // 0_______ ________ <ASCII in byte 1>
            TOO_LONG, TOO_LONG, TOO_LONG, TOO_LONG,
            TOO_LONG, TOO_LONG, TOO_LONG, TOO_LONG,
            // 10______ ________ <continuation in byte 1>
            TWO_CONTS, TWO_CONTS, TWO_CONTS, TWO_CONTS,
            // 1100____ ________ <two byte lead in byte 1>
            TOO_SHORT | OVERLONG_2,
            // 1101____ ________ <two byte lead in byte 1>
            TOO_SHORT,
            // 1110____ ________ <three byte lead in byte 1>
            TOO_SHORT | OVERLONG_3 | SURROGATE,
            // 1111____ ________ <four+ byte lead in byte 1>
            TOO_SHORT | TOO_LARGE | TOO_LARGE_1000 | OVERLONG_4,
        }), prev1 >> @as(vector, @splat(4)));

        const CARRY = TOO_SHORT | TOO_LONG | TWO_CONTS; // These all have ____ in byte 1 .

        const byte_1_low = intr.lookupTable(simd.repeat(Vector.bytes_len, [_]u8{
            // ____0000 ________
            CARRY | OVERLONG_3 | OVERLONG_2 | OVERLONG_4,
            // ____0001 ________
            CARRY | OVERLONG_2,
            // ____001_ ________
            CARRY,
            CARRY,

            // ____0100 ________
            CARRY | TOO_LARGE,
            // ____0101 ________
            CARRY | TOO_LARGE | TOO_LARGE_1000,
            // ____011_ ________
            CARRY | TOO_LARGE | TOO_LARGE_1000,
            CARRY | TOO_LARGE | TOO_LARGE_1000,

            // ____1___ ________
            CARRY | TOO_LARGE | TOO_LARGE_1000,
            CARRY | TOO_LARGE | TOO_LARGE_1000,
            CARRY | TOO_LARGE | TOO_LARGE_1000,
            CARRY | TOO_LARGE | TOO_LARGE_1000,
            CARRY | TOO_LARGE | TOO_LARGE_1000,
            // ____1101 ________
            CARRY | TOO_LARGE | TOO_LARGE_1000 | SURROGATE,
            CARRY | TOO_LARGE | TOO_LARGE_1000,
            CARRY | TOO_LARGE | TOO_LARGE_1000,
        }), prev1 & @as(vector, @splat(0x0F)));

        const byte_2_high = intr.lookupTable(simd.repeat(Vector.bytes_len, [_]u8{
            // ________ 0_______ <ASCII in byte 2>
            TOO_SHORT, TOO_SHORT, TOO_SHORT, TOO_SHORT,
            TOO_SHORT, TOO_SHORT, TOO_SHORT, TOO_SHORT,

            // ________ 1000____
            TOO_LONG | OVERLONG_2 | TWO_CONTS | OVERLONG_3 | TOO_LARGE_1000 | OVERLONG_4,
            // ________ 1001____
            TOO_LONG | OVERLONG_2 | TWO_CONTS | OVERLONG_3 | TOO_LARGE,
            // ________ 101_____
            TOO_LONG | OVERLONG_2 | TWO_CONTS | SURROGATE  | TOO_LARGE,
            TOO_LONG | OVERLONG_2 | TWO_CONTS | SURROGATE  | TOO_LARGE,

            // ________ 11______
            TOO_SHORT, TOO_SHORT, TOO_SHORT, TOO_SHORT,
        }), vec >> @as(vector, @splat(4)));
        // zig fmt: on

        const special_cases = byte_1_high & byte_1_low & byte_2_high;

        const prev2 = @shuffle(u8, vec, prev_vec, shift2_mask);
        const prev3 = @shuffle(u8, vec, prev_vec, shift3_mask);

        const is_third_byte = prev2 -| @as(vector, @splat(0xE0 - 0x80));
        const is_fourth_byte = prev3 -| @as(vector, @splat(0xF0 - 0x80));

        const must_be_2_3_continuation = is_third_byte | is_fourth_byte;
        const must_be_2_3_80 = must_be_2_3_continuation & @as(vector, @splat(0x80));

        self.err |= must_be_2_3_80 ^ special_cases;
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
        const chunk: [Mask.bits_len]u8 = @bitCast(vecs);

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

        var printable_chunk: [Mask.bits_len]u8 = undefined;
        @memcpy(&printable_chunk, &chunk);
        for (&printable_chunk) |*c| {
            if (common.tables.is_whitespace[c.*] and c.* != ' ') {
                c.* = '~';
            }
            if (!(32 <= c.* and c.* < 128)) {
                c.* = '*';
            }
        }

        if (expected != actual) {
            std.debug.panic(
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
    }
};
