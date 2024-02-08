const std = @import("std");
const builtin = @import("builtin");
const Reader = @import("reader.zig");
const types = @import("types.zig");
const cpu = builtin.cpu;
const simd = std.simd;
const vector = types.vector;
const Vector = types.Vector;
const umask = types.umask;
const imask = types.imask;
const Mask = types.Mask;
const Pred = types.Predicate;

const Allocator = std.mem.Allocator;
const Self = @This();

const ln_table: vector = simd.repeat(Vector.LEN_BYTES, [_]u8{ 16, 0, 0, 0, 0, 0, 0, 0, 0, 8, 10, 4, 1, 12, 0, 0 });
const hn_table: vector = simd.repeat(Vector.LEN_BYTES, [_]u8{ 8, 0, 17, 2, 0, 4, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0 });
const whitespace_table: vector = @splat(0b11000);
const structural_table: vector = @splat(0b00111);
const evn_mask: umask = @bitCast(simd.repeat(Mask.LEN_BITS, [_]u1{ 1, 0 }));
const odd_mask: umask = @bitCast(simd.repeat(Mask.LEN_BITS, [_]u1{ 0, 1 }));

var prev_scalar: umask = 0;
var prev_inside_string: umask = 0;
var next_is_escaped: umask = 0;

reader: Reader,
indexes: std.ArrayList(u32),

pub fn init(allocator: Allocator, document: []const u8) Self {
    return Self{
        .reader = Reader.init(document),
        .indexes = std.ArrayList(u32).init(allocator),
    };
}

pub fn deinit(self: *Self) void {
    self.indexes.deinit();
}

pub fn index(self: *Self) !void {
    var iter = try self.indexes.addManyAsSlice(self.reader.document.len);
    var iter_count: usize = 0;
    var i = self.reader.index;
    while (self.reader.next()) |block| : (i = self.reader.index) {
        const scanned = Scanner.from(block);
        const tokens = identify(scanned);
        iter_count += extract(tokens, i, &iter);
    }
    if (self.reader.last()) |block| {
        const scanned = Scanner.from(block);
        const tokens = identify(scanned);
        iter_count += extract(tokens, i, &iter);
    }
    self.indexes.shrinkAndFree(iter_count);
}

fn identify(sc: Scanner) umask {
    const unescaped_quotes = sc.quotes & ~escapedChars(sc.backslash);
    const invert_ranges: umask = @bitCast(@as(imask, @bitCast(prev_inside_string)) >> Mask.LAST_BIT);
    const quoted_ranges = clmul(unescaped_quotes) ^ invert_ranges;
    const struct_white = sc.structural | sc.whitespace;
    const scalar = ~struct_white;

    const nonquote_scalar = scalar & ~unescaped_quotes;
    const follows_nonquote_scalar = nonquote_scalar << 1 | prev_scalar;

    const string_tail = quoted_ranges ^ sc.quotes;
    const potential_scalar_start = scalar & ~follows_nonquote_scalar;
    const potential_structural_start = sc.structural | potential_scalar_start;
    const structural_start = potential_structural_start & ~string_tail;

    prev_inside_string = quoted_ranges;
    prev_scalar = scalar >> Mask.LAST_BIT;

    return structural_start;
}

const indexes_bitmap: [256][8]u32 = res: {
    @setEvalBranchQuota(5000);
    var res: [256][8]u32 = [_][8]u32{[_]u32{@as(u32, 0)} ** 8} ** 256;
    for (0..256) |i| {
        var bitset = (std.bit_set.IntegerBitSet(8){ .mask = i }).iterator(.{});
        var j = 0;
        while (bitset.next()) |b| : (j += 1) {
            res[i][j] = b;
        }
    }
    break :res res;
};

// fn extract(tokens: umask, i: usize, dst: *[]u32) usize {
//     var pop_count: usize = 0;
//     var s = tokens;
//     inline for (0..8) |r| {
//         const tokens_byte = s & 0xFF;
//         const pop = @popCount(tokens_byte);
//         pop_count += pop;
//         var indexes = indexes_bitmap[tokens_byte];
//         for (&indexes) |*idx| {
//             idx.* +%= @truncate(i);
//             idx.* +%= @truncate(r * 8);
//         }
//         @memcpy(dst.*[0..8], &indexes);
//         dst.* = dst.*[pop..];
//         s >>= 8;
//     }
//     return pop_count;
// }

fn extract(tokens: umask, i: usize, dst: *[]u32) usize {
    const pop_count = @popCount(tokens);
    var slice = dst.*;
    var s = tokens;
    while (s != 0) {
        inline for (0..8) |_| {
            const tz = @ctz(s);
            slice[0] = @as(u32, @truncate(i)) + tz;
            slice = slice[1..];
            s &= s -% 1;
        }
    }
    dst.* = dst.*[pop_count..];
    return pop_count;
}

fn escapedChars(backs: umask) umask {
    if (backs == 0) {
        const escaped = next_is_escaped;
        next_is_escaped = 0;
        return escaped;
    }
    const potential_escape = backs & ~next_is_escaped;
    const maybe_escaped = potential_escape << 1;
    const maybe_escaped_and_odd_bits = maybe_escaped | odd_mask;
    const even_series_codes_and_odd_bits = maybe_escaped_and_odd_bits -% potential_escape;
    const escape_and_terminal_code = even_series_codes_and_odd_bits ^ odd_mask;
    const escaped = escape_and_terminal_code ^ (backs | next_is_escaped);
    const escape = escape_and_terminal_code & backs;
    next_is_escaped = escape >> Mask.LAST_BIT;
    return escaped;
}

fn clmul(quotes_mask: umask) umask {
    switch (builtin.cpu.arch) {
        .x86_64 => {
            const ones: @Vector(16, u8) = @bitCast(simd.repeat(128, [_]u1{1}));
            return asm (
                \\vpclmulqdq $0, %[ones], %[quotes], %[ret]
                : [ret] "=v" (-> umask),
                : [ones] "v" (ones),
                  [quotes] "v" (quotes_mask),
            );
        },
        else => unreachable,
    }
}

const Scanner = struct {
    whitespace: umask,
    structural: umask,
    backslash: umask,
    quotes: umask,

    pub fn from(block: *const Reader.block) @This() {
        var mask_whitespace: umask = 0;
        var mask_structural: umask = 0;
        var mask_backslash: umask = 0;
        var mask_quotes: umask = 0;

        for (0..Mask.COMPUTED_VECTORS) |i| {
            const offset = i * Vector.LEN_BYTES;
            const vec = Vector.from(block[offset..][0..Vector.LEN_BYTES]).to(.bytes);
            const low_nibbles = vec & @as(vector, @splat(0xF));
            const high_nibbles = vec >> @as(vector, @splat(4));
            const low_lookup_values = lut(ln_table, low_nibbles);
            const high_lookup_values = lut(hn_table, high_nibbles);
            const desired_values = low_lookup_values & high_lookup_values;
            const whitespace = ~Pred(.bytes).from(desired_values & whitespace_table == Vector.ZER).pack();
            const structural = ~Pred(.bytes).from(desired_values & structural_table == Vector.ZER).pack();
            const backslash = Pred(.bytes).from(vec == Vector.SLASH).pack();
            const quotes = Pred(.bytes).from(vec == Vector.QUOTE).pack();
            mask_whitespace |= @as(umask, whitespace) << @truncate(offset);
            mask_structural |= @as(umask, structural) << @truncate(offset);
            mask_backslash |= @as(umask, backslash) << @truncate(offset);
            mask_quotes |= @as(umask, quotes) << @truncate(offset);
        }
        return .{
            .whitespace = mask_whitespace,
            .structural = mask_structural,
            .backslash = mask_backslash,
            .quotes = mask_quotes,
        };
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
            var fallback: vector = @splat(0);
            for (0..Vector.LEN_BYTES) |i| {
                const n = nibbles[i];
                if (n < Vector.LEN_BYTES) {
                    fallback[i] = table[n];
                }
            }
            return fallback;
        },
    }
}
