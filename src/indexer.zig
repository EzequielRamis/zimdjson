const std = @import("std");
const builtin = @import("builtin");
const shared = @import("shared.zig");
const Reader = @import("reader.zig");

const simd = std.simd;
const vector = shared.vector;
const vector_size = shared.vector_size;
const vector_mask = shared.vector_mask;
const mask = shared.mask;

const Allocator = std.mem.Allocator;
const Self = @This();

const ln_table: vector = simd.repeat(vector_size, [_]u8{ 16, 0, 0, 0, 0, 0, 0, 0, 0, 8, 10, 4, 1, 12, 0, 0 });
const hn_table: vector = simd.repeat(vector_size, [_]u8{ 8, 0, 17, 2, 0, 4, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0 });
var previous_evn_slash: u1 = 0;
var previous_odd_slash: u1 = 0;
var last_was_struct_or_white: u1 = 0;
var was_inside_string: mask = 0;

reader: Reader,
indexes: std.ArrayList(usize),

pub fn init(allocator: Allocator, document: []const u8) Self {
    return Self{
        .reader = Reader.init(document),
        .indexes = std.ArrayList(usize).init(allocator),
    };
}

pub fn deinit(self: *Self) void {
    self.indexes.deinit();
}

pub fn index(self: *Self) Allocator.Error!void {
    while (self.reader.next()) |block| {
        const structural_mask = self.identify(block.value);
        try self.extract(block.index, structural_mask);
    }
}

pub fn identify(self: *Self, vec: vector) mask {
    const quotes_mask = maskStructuralQuotes(self, vec);
    const quoted_ranges = identifyQuotedRanges(@bitCast(vec == shared.quote), quotes_mask) ^ was_inside_string;
    const signed_quoted_ranges: std.meta.Int(std.builtin.Signedness.signed, vector_size) = @bitCast(quoted_ranges);

    const low_nibbles = vec & @as(vector, @splat(0xF));
    const high_nibbles = vec >> @as(vector, @splat(4));
    const low_lookup_values = shared.lut(ln_table, low_nibbles);
    const high_lookup_values = shared.lut(hn_table, high_nibbles);
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

    structural_chars |= 1 & ~was_inside_string & last_was_struct_or_white & ~whitespace_chars;

    was_inside_string = @bitCast(signed_quoted_ranges >> (vector_size - 1));
    last_was_struct_or_white = @intFromBool(shared.Tables.is_structural_or_whitespace[vec[vector_size - 1]]);

    return structural_chars;
}

pub fn extract(self: *Self, i: usize, bitset: mask) Allocator.Error!void {
    var s = bitset;
    while (s != 0) {
        const tz = @ctz(s);
        try self.indexes.append(i + tz);
        s &= (s - 1);
    }
}

fn maskStructuralQuotes(_: *Self, vec: vector) mask {
    const backs: mask = @bitCast(vec == shared.slash);
    const quotes: mask = @bitCast(vec == shared.quote);
    const starts = backs & ~(backs << 1);
    const evn_starts = starts & shared.evn_mask;
    const odd_starts = starts & shared.odd_mask;

    const evn_start_carries_with_overflow = @addWithOverflow(backs, evn_starts);
    const odd_start_carries_with_overflow = @addWithOverflow(backs, odd_starts);
    const evn_carries = (evn_start_carries_with_overflow[0] + previous_evn_slash) & ~backs;
    const odd_carries = (odd_start_carries_with_overflow[0] + previous_odd_slash) & ~backs;
    previous_evn_slash = evn_start_carries_with_overflow[1];
    previous_odd_slash = odd_start_carries_with_overflow[1];

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
