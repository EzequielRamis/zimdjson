const std = @import("std");
const builtin = @import("builtin");
const shared = @import("shared.zig");
const cpu = builtin.cpu;
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

var prev_scanned: Scanner = .{ .whitespace = 0, .structural = 0, .backslash = 0, .quotes = 0 };
var prev_odd_carry: u1 = 0;
var prev_scalar: u1 = 0;
var prev_inside_string: mask = 0;

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
        const scanned = Scanner.from(block.value);

        const tokens = identify(scanned);
        try self.extract(tokens, block.index);

        prev_scanned = scanned;
        prev_scalar = @truncate(prev_scanned.scalar() >> (vector_size - 1));
    }
}

pub fn identify(sc: Scanner) mask {
    const unescaped_quotes = sc.quotes & ~escapedChars(sc.backslash);
    const quoted_ranges = clmul(unescaped_quotes) ^ prev_inside_string;
    var structural = sc.structural;

    structural &= ~quoted_ranges;
    structural |= unescaped_quotes;

    var pseudo_structural_chars = structural | sc.whitespace;
    pseudo_structural_chars <<= 1;
    pseudo_structural_chars |= ~prev_scalar & sc.scalar();
    pseudo_structural_chars &= ~sc.whitespace & ~quoted_ranges;

    structural |= pseudo_structural_chars;
    structural &= ~(unescaped_quotes & ~quoted_ranges);

    prev_inside_string = @bitCast(@as(shared.signed_mask, @bitCast(quoted_ranges)) >> (vector_size - 1));

    return structural;
}

pub fn extract(self: *Self, tokens: mask, i: usize) Allocator.Error!void {
    var s = tokens;
    while (s != 0) {
        const tz = @ctz(s);
        try self.indexes.append(i + tz);
        s &= (s - 1);
    }
}

fn escapedChars(backs: mask) mask {
    const starts = backs & ~(backs << 1);

    const first_backslash = starts & 1;
    const evn_starts = starts & shared.evn_mask;
    const evn_yields = @addWithOverflow(backs, evn_starts);
    const evn_carries = (evn_yields[0] - (prev_odd_carry & first_backslash)) & ~backs;

    const odd_starts = starts & shared.odd_mask;
    const odd_yields = @addWithOverflow(backs, odd_starts);
    const odd_carries = (odd_yields[0] + prev_odd_carry) & ~backs;

    const is_all_backslash = @intFromBool(@as(shared.signed_mask, @bitCast(backs)) == -1);
    prev_odd_carry = (is_all_backslash & prev_odd_carry) | odd_yields[1];

    const odd1_ending_backs = evn_carries & shared.odd_mask;
    const odd2_ending_backs = odd_carries & shared.evn_mask;
    const odd_length_ends = odd1_ending_backs | odd2_ending_backs;
    return odd_length_ends;
}

fn clmul(quotes_mask: mask) mask {
    switch (builtin.cpu.arch) {
        .x86_64 => {
            const range: @Vector(16, u8) = @bitCast(simd.repeat(128 / vector_size, [_]mask{quotes_mask}));
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

const Scanner = struct {
    whitespace: mask,
    structural: mask,
    backslash: mask,
    quotes: mask,

    pub fn from(vec: vector) @This() {
        const low_nibbles = vec & @as(vector, @splat(0xF));
        const high_nibbles = vec >> @as(vector, @splat(4));
        const low_lookup_values = lut(ln_table, low_nibbles);
        const high_lookup_values = lut(hn_table, high_nibbles);
        const desired_values = low_lookup_values & high_lookup_values;
        const whitespace = anyBitSet(desired_values & @as(vector, @splat(0b11000)));
        const structural = anyBitSet(desired_values & @as(vector, @splat(0b111)));
        return .{
            .whitespace = whitespace,
            .structural = structural,
            .backslash = @bitCast(vec == shared.slash),
            .quotes = @bitCast(vec == shared.quote),
        };
    }

    pub fn scalar(self: @This()) mask {
        return ~(self.structural | self.whitespace);
    }
};

fn lut(table: vector, nibbles: vector) vector {
    // TODO:
    // [] arm
    // [] aarch64
    // [] ppc
    // [] mips
    // [] riscv
    // [] wasm
    switch (cpu.arch) {
        .x86_64 => {
            if (vector_size >= 32) {
                return asm volatile (
                    \\vpshufb %[nibbles], %[table], %[ret]
                    : [ret] "=x" (-> vector),
                    : [table] "x" (table),
                      [nibbles] "x" (nibbles),
                );
            } else {
                return asm volatile (
                    \\pshufb %[nibbles], %[table], %[ret]
                    : [ret] "=x" (-> vector),
                    : [table] "x" (table),
                      [nibbles] "x" (nibbles),
                );
            }
        },
        else => {
            @compileLog("Table lookup instruction not supported on this target.");
            var fallback: vector = [_]u8{0} ** vector_size;
            for (0..vector_size) |i| {
                const n = nibbles[i];
                if (n < vector_size) {
                    fallback[i] = table[n];
                }
            }
            return fallback;
        },
    }
}

fn anyBitSet(vec: vector) mask {
    return ~@as(mask, @bitCast(vec == shared.zer_vector));
}
