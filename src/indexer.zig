const std = @import("std");
const builtin = @import("builtin");
const shared = @import("shared.zig");
const cpu = builtin.cpu;
const Reader = @import("reader.zig");
// const bench = @import("bench.zig");

const simd = std.simd;
const vector = shared.vector;
const vectors = shared.vectors;
const vector_size = shared.vector_size;
const register_size = shared.register_size;
const vector_count = shared.register_vector_ratio;
const register_count = shared.vector_register_ratio;
const vector_mask = shared.vector_mask;
const vectorized_mask = shared.vectorized_mask;
const vector_register_ratio = shared.vector_register_ratio;
const mask = shared.mask;
const masks = shared.masks;
const imasks = shared.imasks;
const vectorizePredicate = shared.vectorizePredicate;

const Allocator = std.mem.Allocator;
const Self = @This();

const ln_table: vector = simd.repeat(vector_size, [_]u8{ 16, 0, 0, 0, 0, 0, 0, 0, 0, 8, 10, 4, 1, 12, 0, 0 });
const hn_table: vector = simd.repeat(vector_size, [_]u8{ 8, 0, 17, 2, 0, 4, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0 });

var prev_scanned: Scanner = std.mem.zeroInit(Scanner, .{});
var prev_inside_string: u8 = 0;
var prev_odd_carry: u1 = 0;
var prev_scalar: u1 = 0;

reader: Reader,
indexes: std.ArrayListAligned(usize, vector_size),

pub fn init(allocator: Allocator, document: []const u8) Self {
    return Self{
        .reader = Reader.init(document),
        .indexes = std.ArrayListAligned(usize, vector_size).init(allocator),
    };
}

pub fn deinit(self: *Self) void {
    self.indexes.deinit();
}

pub fn index(self: *Self) !void {
    var i = self.reader.index;
    // var nanoseconds: usize = 0;
    var iter = try self.indexes.addManyAsSlice(self.reader.document.len);
    var iter_count: usize = 0;
    // var timer = try std.time.Timer.start();
    // var nano: usize = 0;
    // bench.start();
    while (self.reader.next()) |block| : (i = self.reader.index) {
        // std.debug.print("NEXT: {}\n", .{bench.lap().cpu_cycles});
        // bench.reset();
        const scanned = Scanner.from(block);
        // std.debug.print("SCAN: {}\n", .{bench.lap().cpu_cycles});
        // bench.reset();

        const tokens = identify(scanned);
        // std.debug.print("IDEN: {}\n", .{bench.lap().cpu_cycles});
        // bench.reset();
        // nano += timer.lap();
        iter_count += self.extract(@bitCast(tokens), i, &iter);
        // std.debug.print("EXTR: {}\n", .{bench.lap().cpu_cycles});
        // bench.reset();
        // iter_count += added;
        // iter = iter[vector_size..];

        prev_scanned = scanned;
        prev_scalar = @truncate(prev_scanned.scalar()[vector_size - 1] >> 7);
    }
    self.indexes.shrinkAndFree(iter_count);
    // std.debug.print("NANO: {}\n", .{nano});
}

pub fn identify(sc: Scanner) vector {
    const unescaped_quotes = sc.quotes & ~escapedChars(sc.backslash);
    const quoted_ranges = parallelPrefixXor(unescaped_quotes) ^ @as(vector, @splat(prev_inside_string));
    var structural = sc.structural;

    structural &= ~quoted_ranges;
    structural |= unescaped_quotes;

    var pseudo_structural_chars_masks: masks = @bitCast(structural | sc.whitespace);
    pseudo_structural_chars_masks <<= @as(masks, @splat(1));
    var pseudo_structural_chars: vector = @bitCast(pseudo_structural_chars_masks);
    pseudo_structural_chars[0] |= ~prev_scalar & sc.scalar()[vector_size - 1] >> 7;
    pseudo_structural_chars &= ~sc.whitespace & ~quoted_ranges;

    structural |= pseudo_structural_chars;
    structural &= ~(unescaped_quotes & ~quoted_ranges);

    prev_inside_string = @bitCast(@as(i8, @intCast(
        @as(i1, @bitCast(
            @as(u1, @truncate(quoted_ranges[vector_size - 1] >> 7)),
        )),
    )));

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

pub fn extract(_: *Self, tokens: masks, i: usize, dst: *[]usize) usize {
    var pop_count: usize = 0;
    inline for (0..vector_register_ratio) |t| {
        var s = tokens[t];
        pop_count += @popCount(s);
        while (s != 0) {
            const tz = @ctz(s);
            dst.*[0] = i + tz;
            dst.* = dst.*[1..];
            s &= s - 1;
        }
    }
    return pop_count;
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

const overflow_shuffles: @Vector(vector_register_ratio, i32) = res: {
    switch (vector_register_ratio) {
        2 => break :res [2]i32{ 1, -1 },
        4 => break :res [4]i32{ 1, 2, 3, -1 },
        8 => break :res [8]i32{ 1, 2, 3, 4, 5, 6, 7, -1 },
        else => unreachable,
    }
};

fn escapedChars(backs_: vector) vector {
    const backs: masks = @bitCast(backs_);
    const ones: masks = @splat(1);
    const starts = backs & ~(backs << ones);

    const first_backslash = starts & ones;
    const evn_starts = starts & shared.evn_vector;
    const evn_yields = backs +% evn_starts;
    var evn_overflows = @as(masks, @intCast(@intFromBool(evn_yields < backs)));
    evn_overflows = @shuffle(mask, evn_overflows, @as(masks, @splat(0)), overflow_shuffles);
    evn_overflows[0] |= prev_odd_carry;
    const evn_carries = (evn_yields - (evn_overflows & first_backslash)) & ~backs;

    const odd_starts = starts & shared.odd_vector;
    const odd_yields = backs +% odd_starts;
    var odd_overflows = @as(masks, @intCast(@intFromBool(odd_yields < backs)));
    const next_odd_carry = odd_overflows[vector_register_ratio - 1];
    odd_overflows = @shuffle(mask, odd_overflows, @as(masks, @splat(0)), overflow_shuffles);
    odd_overflows[0] |= prev_odd_carry;
    const odd_carries = (odd_yields + odd_overflows) & ~backs;

    const is_all_backslash = @intFromBool(~@as(
        std.meta.Int(std.builtin.Signedness.unsigned, vector_register_ratio),
        @bitCast(~backs == @as(masks, @splat(0))),
    ) == 0);
    prev_odd_carry = (is_all_backslash & prev_odd_carry) | @as(u1, @truncate(next_odd_carry >> (register_size - 1)));

    const odd1_ending_backs = evn_carries & shared.odd_vector;
    const odd2_ending_backs = odd_carries & shared.evn_vector;
    const odd_length_ends = odd1_ending_backs | odd2_ending_backs;
    return @bitCast(odd_length_ends);
}

const prefix_xor_levels = std.math.log2(vector_register_ratio);
const prefix_xor_shuffles: [prefix_xor_levels]@Vector(vector_register_ratio * 2, i32) = res: {
    switch (prefix_xor_levels) {
        3 => break :res [3]@Vector(vector_register_ratio * 2, i32){
            [_]i32{ -1, -1, 1, 1, 3, 3, 5, 5, 7, 7, 9, 9, 11, 11, 13, 13 },
            [_]i32{ -1, -1, -1, -1, 3, 3, 3, 3, -1, -1, -1, -1, 11, 11, 11, 11 },
            [_]i32{ -1, -1, -1, -1, -1, -1, -1, -1, 7, 7, 7, 7, 7, 7, 7, 7 },
        },
        2 => break :res [2]@Vector(vector_register_ratio * 2, i32){
            [_]i32{ -1, -1, 1, 1, 3, 3, 5, 5 },
            [_]i32{ -1, -1, -1, -1, 3, 3, 3, 3 },
        },
        1 => break :res [1]@Vector(vector_register_ratio * 2, i32){
            [_]i32{ -1, -1, 1, 1 },
        },
        else => unreachable,
    }
};

// https://www.tldraw.com/r/Cug-swPLJUhvC91XlSz3Z?viewport=1919,-342,3959,1847&page=page:page
fn parallelPrefixXor(vec: vector) vector {
    var res: masks = @bitCast(vec);
    inline for (0..vector_register_ratio) |i| {
        res[i] = clmul(res[i]);
    }
    inline for (0..prefix_xor_levels) |i| {
        const inside_string = vectorizePredicate(@Vector(vector_size / 4, u32), @as(
            @Vector(vector_size / 4, i32),
            @bitCast(res),
        ) < @as(@Vector(vector_size / 4, i32), @splat(0)));
        const must_invert = @shuffle(
            u32,
            inside_string,
            @as(@Vector(vector_size / 4, u32), @splat(0)),
            prefix_xor_shuffles[i],
        );
        res ^= @bitCast(must_invert);
    }
    return @bitCast(res);
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
    whitespace: vector align(vector_size),
    structural: vector align(vector_size),
    backslash: vector align(vector_size),
    quotes: vector align(vector_size),

    pub fn from(block: *const Reader.block) @This() {
        const vector_masks = @Vector(8, vector_mask);

        var mask_whitespace: vector_masks = @splat(0);
        var mask_structural: vector_masks = @splat(0);
        var mask_backslash: vector_masks = @splat(0);
        var mask_quotes: vector_masks = @splat(0);
        inline for (0..8) |i| {
            const offset = i * vector_size;
            const vec: vector = block[offset..][0..vector_size].*;
            const low_nibbles = vec & @as(vector, @splat(0xF));
            const high_nibbles = vec >> @as(vector, @splat(4));
            const low_lookup_values = lut(ln_table, low_nibbles);
            const high_lookup_values = lut(hn_table, high_nibbles);
            const desired_values = low_lookup_values & high_lookup_values;
            const whitespace: vector_mask = @bitCast(
                desired_values & @as(
                    vector,
                    @splat(0b11000),
                ) != shared.zer_vector,
            );
            const structural: vector_mask = @bitCast(
                desired_values & @as(vector, @splat(0b111)) != shared.zer_vector,
            );
            const backslash: vector_mask = @bitCast(vec == shared.slash);
            const quotes: vector_mask = @bitCast(vec == shared.quote);
            mask_whitespace[i] = whitespace;
            mask_structural[i] = structural;
            mask_backslash[i] = backslash;
            mask_quotes[i] = quotes;
        }
        return .{
            .whitespace = @as(vector, @bitCast(mask_whitespace)),
            .structural = @as(vector, @bitCast(mask_structural)),
            .backslash = @as(vector, @bitCast(mask_backslash)),
            .quotes = @as(vector, @bitCast(mask_quotes)),
        };
    }

    pub fn scalar(self: @This()) vector {
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
