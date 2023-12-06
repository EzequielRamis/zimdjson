const std = @import("std");
const builtin = @import("builtin");
const shared = @import("shared.zig");
const vector = shared.vector;
const vector_size = shared.vector_size;
const mask = shared.mask;

const Allocator = std.mem.Allocator;

pub const Indexer = struct {
    const ln_table: vector = std.simd.repeat(vector_size, [_]u8{ 16, 0, 0, 0, 0, 0, 0, 0, 0, 8, 10, 4, 1, 12, 0, 0 });
    const hn_table: vector = std.simd.repeat(vector_size, [_]u8{ 8, 0, 17, 2, 0, 4, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0 });
    const unconditional_extractions = @as(usize, (8.0 / 64.0) * @as(comptime_float, vector_size));

    indexes: std.ArrayList(usize),
    buffer: vector = [_]u8{' '} ** vector_size,
    extractions: [unconditional_extractions]usize = undefined,
    base: usize,
    was_inside_string: mask,
    previous_evn_slash: u1,
    previous_odd_slash: u1,

    pub fn init(allocator: Allocator) Indexer {
        return Indexer{
            .indexes = std.ArrayList(usize).init(allocator),
            .base = 0,
            .was_inside_string = 0,
            .previous_evn_slash = 0,
            .previous_odd_slash = 0,
        };
    }

    pub fn deinit(self: *Indexer) void {
        self.indexes.deinit();
    }

    pub fn identify(self: *Indexer, vec: vector) mask {
        const quotes_mask = maskStructuralQuotes(self, vec);
        const quoted_ranges = identifyQuotedRanges(@bitCast(vec == shared.quote), quotes_mask) ^ self.was_inside_string;
        self.was_inside_string = @bitCast(@as(std.meta.Int(std.builtin.Signedness.signed, vector_size), @bitCast(quoted_ranges)) >> (vector_size - 1));

        const low_nibbles = vec & @as(vector, @splat(0xF));
        const high_nibbles = vec >> @as(vector, @splat(4));
        const low_lookup_values = shared.lookupTable(ln_table, low_nibbles);
        const high_lookup_values = shared.lookupTable(hn_table, high_nibbles);
        const desired_values = low_lookup_values & high_lookup_values;
        const whitespace_chars = shared.anyBitsSet(desired_values, @as(vector, @splat(0b11000)));
        var structural_chars = shared.anyBitsSet(desired_values, @as(vector, @splat(0b111)));

        structural_chars &= ~quoted_ranges;
        structural_chars |= quotes_mask;

        var pseudo_structural_chars = structural_chars | whitespace_chars;
        pseudo_structural_chars <<= 1;
        pseudo_structural_chars &= ~whitespace_chars & ~quoted_ranges;

        structural_chars |= pseudo_structural_chars;
        structural_chars &= ~(quotes_mask & ~quoted_ranges);

        return structural_chars;
    }

    pub fn extract(self: *Indexer, chunk: usize, bitset: mask) Allocator.Error!void {
        const cnt = @popCount(bitset);
        const next_base = self.base + cnt;
        var s = bitset;
        while (s != 0) {
            for (&self.extractions) |*ext| {
                const trailing_zeroes = @ctz(s);
                ext.* = chunk + trailing_zeroes;
                s &= (s -| 1);
            }
            try self.indexes.insertSlice(self.base, &self.extractions);
            self.base += unconditional_extractions;
        }
        self.base = next_base;
        self.indexes.shrinkRetainingCapacity(next_base);
    }

    fn maskStructuralQuotes(self: *Indexer, vec: vector) mask {
        const backs: mask = @bitCast(vec == shared.slash);
        const quotes: mask = @bitCast(vec == shared.quote);
        const starts = backs & ~(backs << 1);
        const evn_starts = starts & shared.evn_mask;
        const odd_starts = starts & shared.odd_mask;

        const evn_start_carries_with_overflow = @addWithOverflow(backs, evn_starts);
        const odd_start_carries_with_overflow = @addWithOverflow(backs, odd_starts);
        const evn_carries = (evn_start_carries_with_overflow[0] + self.previous_evn_slash) & ~backs;
        const odd_carries = (odd_start_carries_with_overflow[0] + self.previous_odd_slash) & ~backs;
        self.previous_evn_slash = evn_start_carries_with_overflow[1];
        self.previous_odd_slash = odd_start_carries_with_overflow[1];

        const odd1_ending_backs = evn_carries & shared.odd_mask;
        const odd2_ending_backs = odd_carries & shared.evn_mask;
        const odd_length_ends = odd1_ending_backs | odd2_ending_backs;
        const structural_quotes = quotes & ~odd_length_ends;
        return structural_quotes;
    }

    fn identifyQuotedRanges(quotes_mask: mask, structural_mask: mask) mask {
        switch (builtin.cpu.arch) {
            .x86_64 => {
                const range = @as(@Vector(16, u8), @bitCast(std.simd.repeat(128 / vector_size, [_]mask{quotes_mask & structural_mask})));
                const ones = @as(@Vector(16, u8), @bitCast(std.simd.repeat(128, [_]u1{1})));
                if (vector_size == 64) {
                    return asm (
                        \\pclmulqdq $0, %[ones], %[range]
                        \\movq %[range], %[ret]
                        : [ret] "=r" (-> mask),
                        : [ones] "x" (ones),
                          [range] "x" (range),
                    );
                } else {
                    return asm (
                        \\pclmulqdq $0, %[ones], %[range]
                        \\movd %[range], %[ret]
                        : [ret] "=r" (-> mask),
                        : [ones] "x" (ones),
                          [range] "x" (range),
                    );
                }
            },
            else => return @as(mask, @bitCast(std.simd.prefixScan(std.builtin.ReduceOp.Xor, 1, @as(shared.vector_mask, @bitCast(quotes_mask))))),
        }
    }
};
