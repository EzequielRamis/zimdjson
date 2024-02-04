const std = @import("std");
const builtin = @import("builtin");
const shared = @import("shared.zig");
const cpu = builtin.cpu;
const Reader = @import("reader.zig");

const simd = std.simd;
const vector = shared.vector;
const vectors = shared.vectors;
const vector_size = shared.vector_size;
const register_size = shared.register_size;
const ratio = shared.register_vector_ratio;
const vector_mask = shared.vector_mask;
const vectorized_mask = shared.vectorized_mask;
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

pub fn index(self: *Self) !void {
    var iter = try self.indexes.addManyAsSlice(self.reader.document.len);
    // var timer = try std.time.Timer.start();
    var i = self.reader.index;
    while (self.reader.next()) |block| : (i = self.reader.index) {
        const scanned = Scanner.from(block);

        const tokens = identify(scanned);
        self.extract(tokens, i, &iter);

        prev_scanned = scanned;
        prev_scalar = @truncate(prev_scanned.scalar() >> (register_size - 1));
    }
    // std.debug.print("Stage 1: {}\n", .{timer.lap()});
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

    prev_inside_string = @bitCast(@as(shared.imask, @bitCast(quoted_ranges)) >> register_size - 1);

    return structural;
}

const indexes_bitmap: [256][8]usize = res: {
    @setEvalBranchQuota(5000);
    var res: [256][8]usize = [_][8]usize{[_]usize{~@as(usize, 0)} ** 8} ** 256;
    for (0..256) |i| {
        var bitset = (std.bit_set.IntegerBitSet(8){ .mask = i }).iterator(.{});
        var j = 0;
        while (bitset.next()) |b| : (j += 1) {
            res[i][j] = b + 1;
        }
    }
    break :res res;
};

pub fn extract(_: *Self, tokens: mask, i: usize, dst: *[]usize) void {
    var s = tokens;
    while (s != 0) {
        const tz = @ctz(s);
        dst.*[0] = i + tz;
        dst.* = dst.*[1..];
        s &= s - 1;
    }
}

// pub fn extract(_: *Self, tokens: masks, _: usize, dst: []usize) usize {
//     var pop_count: usize = 0;
//     inline for (0..vector_register_ratio) |t| {
//         pop_count += @popCount(tokens[t]);
//     }
//     const store = dst[0..vector_register_ratio];
//     store.* = tokens;
//     return pop_count;
// }

fn escapedChars(backs: mask) mask {
    const starts = backs & ~(backs << 1);

    const first_backslash = starts & 1;
    const evn_starts = starts & shared.evn_mask;
    const evn_yields = @addWithOverflow(backs, evn_starts);
    const evn_carries = (evn_yields[0] - (prev_odd_carry & first_backslash)) & ~backs;

    const odd_starts = starts & shared.odd_mask;
    const odd_yields = @addWithOverflow(backs, odd_starts);
    const odd_carries = (odd_yields[0] + prev_odd_carry) & ~backs;

    const is_all_backslash = @intFromBool(@as(shared.imask, @bitCast(backs)) == -1);
    prev_odd_carry = (is_all_backslash & prev_odd_carry) | odd_yields[1];

    const odd1_ending_backs = evn_carries & shared.odd_mask;
    const odd2_ending_backs = odd_carries & shared.evn_mask;
    const odd_length_ends = odd1_ending_backs | odd2_ending_backs;
    return odd_length_ends;
}

fn clmul(quotes_mask: mask) mask {
    switch (builtin.cpu.arch) {
        .x86_64 => {
            const range: @Vector(16, u8) = @bitCast(
                simd.repeat(128 / register_size, [_]mask{quotes_mask}),
            );
            const ones: @Vector(16, u8) = @bitCast(simd.repeat(128, [_]u1{1}));
            return asm (
                \\vpclmulqdq $0, %[ones], %[range], %[ret]
                : [ret] "=v" (-> mask),
                : [ones] "v" (ones),
                  [range] "v" (range),
            );
        },
        else => {
            const prefix_xor = simd.prefixScan(
                std.builtin.ReduceOp.Xor,
                1,
                @as(vectorized_mask, @bitCast(quotes_mask)),
            );
            return @as(mask, @bitCast(prefix_xor));
        },
    }
}

const Scanner = struct {
    whitespace: mask,
    structural: mask,
    backslash: mask,
    quotes: mask,

    pub fn from(block: *const Reader.block) @This() {
        var mask_whitespace: mask = 0;
        var mask_structural: mask = 0;
        var mask_backslash: mask = 0;
        var mask_quotes: mask = 0;
        for (0..ratio) |i| {
            const offset = i * vector_size;
            const vec: vector = block[offset..][0..vector_size].*;
            const low_nibbles = vec & @as(vector, @splat(0xF));
            const high_nibbles = vec >> @as(vector, @splat(4));
            const low_lookup_values = lut(ln_table, low_nibbles);
            const high_lookup_values = lut(hn_table, high_nibbles);
            const desired_values = low_lookup_values & high_lookup_values;
            const whitespace: vector_mask = @bitCast(desired_values & @as(vector, @splat(0b11000)) != shared.zer_vector);
            const structural: vector_mask = @bitCast(desired_values & @as(vector, @splat(0b111)) != shared.zer_vector);
            const backslash: vector_mask = @bitCast(vec == shared.slash);
            const quotes: vector_mask = @bitCast(vec == shared.quote);
            mask_whitespace |= @as(mask, whitespace) << @truncate(offset);
            mask_structural |= @as(mask, structural) << @truncate(offset);
            mask_backslash |= @as(mask, backslash) << @truncate(offset);
            mask_quotes |= @as(mask, quotes) << @truncate(offset);
        }
        return .{
            .whitespace = mask_whitespace,
            .structural = mask_structural,
            .backslash = mask_backslash,
            .quotes = mask_quotes,
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
            return asm (
                \\vpshufb %[nibbles], %[table], %[ret]
                : [ret] "=v" (-> vector),
                : [table] "v" (table),
                  [nibbles] "v" (nibbles),
            );
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
