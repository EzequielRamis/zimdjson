const std = @import("std");
const builtin = @import("builtin");
const shared = @import("shared.zig");
const simd = std.simd;
const vector = shared.vector;
const vector_size = shared.vector_size;
const vector_mask = shared.vector_mask;
const mask = shared.mask;

const Allocator = std.mem.Allocator;

pub const Indexer = struct {
    const ln_table: vector = simd.repeat(vector_size, [_]u8{ 16, 0, 0, 0, 0, 0, 0, 0, 0, 8, 10, 4, 1, 12, 0, 0 });
    const hn_table: vector = simd.repeat(vector_size, [_]u8{ 8, 0, 17, 2, 0, 4, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0 });

    indexes: std.ArrayList(usize),
    buffer: vector = [_]u8{' '} ** vector_size,
    was_inside_string: mask = 0,
    previous_evn_slash: u1 = 0,
    previous_odd_slash: u1 = 0,

    pub fn init(allocator: Allocator) Indexer {
        return Indexer{
            .indexes = std.ArrayList(usize).init(allocator),
        };
    }

    pub fn deinit(self: *Indexer) void {
        self.indexes.deinit();
    }

    pub fn identify(self: *Indexer, vec: vector) mask {
        const quotes_mask = maskStructuralQuotes(self, vec);
        const quoted_ranges = identifyQuotedRanges(@bitCast(vec == shared.quote), quotes_mask) ^ self.was_inside_string;
        const signed_quoted_ranges: std.meta.Int(std.builtin.Signedness.signed, vector_size) = @bitCast(quoted_ranges);
        self.was_inside_string = @bitCast(signed_quoted_ranges >> (vector_size - 1));

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

    pub fn extract(self: *Indexer, index: usize, bitset: mask) Allocator.Error!void {
        var s = bitset;
        // NOTE: no encuentro una forma de hacer un loop unrolling, ni siquiera con la keyword inline
        // Además, da lo mismo si copio el body manualmente, el asm es el mismo
        while (s != 0) {
            const tz = @ctz(s);
            try self.indexes.append(index + tz);
            s &= (s -| 1);
        }
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
                const range: @Vector(16, u8) = @bitCast(simd.repeat(128 / vector_size, [_]mask{quotes_mask & structural_mask}));
                const ones: @Vector(16, u8) = @bitCast(simd.repeat(128, [_]u1{1}));
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
            else => {
                const prefix_xor = simd.prefixScan(std.builtin.ReduceOp.Xor, 1, @as(vector_mask, @bitCast(quotes_mask)));
                return @as(mask, @bitCast(prefix_xor));
            },
        }
    }
};
