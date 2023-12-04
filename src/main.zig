const std = @import("std");
const builtin = @import("builtin");
const testing = std.testing;

const vector_size = std.simd.suggestVectorSize(u8) orelse @compileError("SIMD features not supported at current target");
const vector = @Vector(vector_size, u8);
const mask = std.meta.Int(std.builtin.Signedness.unsigned, vector_size);

const zer_mask: mask = 0;
const one_mask: mask = @bitCast(std.simd.repeat(vector_size, [_]u1{1}));
const evn_mask: mask = @bitCast(std.simd.repeat(vector_size, [_]u1{ 1, 0 }));
const odd_mask: mask = @bitCast(std.simd.repeat(vector_size, [_]u1{ 0, 1 }));

const evn_vector: @Vector(vector_size, bool) = @bitCast(evn_mask);
const odd_vector: @Vector(vector_size, bool) = @bitCast(odd_mask);
const zer_vector: @Vector(vector_size, bool) = @bitCast(zer_mask);
const one_vector: @Vector(vector_size, bool) = @bitCast(one_mask);

const brack_str: vector = @splat('[');
const brack_end: vector = @splat(']');
const brace_str: vector = @splat('{');
const brace_end: vector = @splat('}');
const comma: vector = @splat(',');
const colon: vector = @splat(':');
const quote: vector = @splat('"');
const slash: vector = @splat('\\');

const ln_table: vector = std.simd.repeat(vector_size, [_]u8{ 16, 0, 0, 0, 0, 0, 0, 0, 0, 8, 10, 4, 1, 12, 0, 0 });
const hn_table: vector = std.simd.repeat(vector_size, [_]u8{ 8, 0, 17, 2, 0, 4, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0 });

fn reverseMask(input: mask) mask {
    return @bitCast(std.simd.reverseOrder(@as(@Vector(vector_size, bool), @bitCast(input))));
}

pub fn fromSlice(input: []const u8) !void {
    std.debug.print("\n", .{});
    var buffer = [_]u8{0} ** vector_size;
    var i: usize = 0;
    while (i < input.len) : (i += vector_size) {
        const slice = input[i..];
        const slice_len = @min(slice.len, vector_size);
        const sub_buffer = buffer[0..slice_len];
        @memcpy(sub_buffer, slice[0..slice_len]);
        const stream: vector = buffer;

        // const quotes_mask = maskStructuralQuotes(stream);
        // anda pero ver de usar el carry-less mul
        // const quoted_strings_mask = @as(mask, @bitCast(std.simd.prefixScan(std.builtin.ReduceOp.Xor, 1, @as(@Vector(vector_size, bool), @bitCast(quotes_mask)))));

        std.debug.print("{s}\n", .{buffer});
        // std.debug.print("{x:0>2}\n", .{stream});
        const low_nibbles = stream & @as(vector, @splat(0xF));
        const high_nibbles = stream >> @as(vector, @splat(4));
        const low_lookup_values = lookupTable(ln_table, low_nibbles);
        const high_lookup_values = lookupTable(hn_table, high_nibbles);
        const desired_values = low_lookup_values & high_lookup_values;
        const structural_chars = anyBitsSet(desired_values, @as(vector, @splat(0b111)));
        std.debug.print("{b:0>32}\n", .{reverseMask(structural_chars)});
        const whitespace_chars = anyBitsSet(desired_values, @as(vector, @splat(0b11000)));
        std.debug.print("{b:0>32}\n", .{reverseMask(whitespace_chars)});
        std.debug.print("{b:0>32}\n", .{reverseMask(identifyQuotedRange(@bitCast(stream == quote), maskStructuralQuotes(stream)))});

        @memset(&buffer, 0);
    }
    std.debug.print("\n", .{});
}

fn lookupTable(table: vector, nibbles: vector) vector {
    return asm volatile (
        \\vpshufb %[nibbles], %[table], %[ret]
        : [ret] "=x" (-> vector),
        : [table] "x" (table),
          [nibbles] "x" (nibbles),
    );
}

fn anyBitsSet(vec: vector, bits: vector) mask {
    return ~@as(mask, @bitCast(bitsNotSet(vec & bits)));
}

fn bitsNotSet(vec: vector) @Vector(vector_size, bool) {
    return @select(bool, vec == @as(vector, @splat(0)), one_vector, zer_vector);
}

fn maskStructuralQuotes(vec: vector) mask {
    const backs: mask = @bitCast(vec == slash);
    const quotes: mask = @bitCast(vec == quote);
    const starts = backs & ~(backs << 1);
    const evn_starts = starts & evn_mask;
    const odd_starts = starts & odd_mask;
    const evn_start_carries = @addWithOverflow(backs, evn_starts)[0];
    const odd_start_carries = @addWithOverflow(backs, odd_starts)[0];
    const evn_carries = evn_start_carries & ~backs;
    const odd_carries = odd_start_carries & ~backs;
    const odd1_ending_backs = evn_carries & odd_mask;
    const odd2_ending_backs = odd_carries & evn_mask;
    const odd_ends = odd1_ending_backs | odd2_ending_backs;
    const structural_quotes = quotes & ~odd_ends;
    return structural_quotes;
}

fn identifyQuotedRange(quotes_mask: mask, structural_mask: mask) mask {
    const q = @as(@Vector(16, u8), @bitCast(std.simd.repeat(128 / vector_size, [_]mask{quotes_mask & structural_mask})));
    const ones = @as(@Vector(16, u8), @bitCast(std.simd.repeat(128, [_]u1{1})));
    return asm (
        \\pclmulqdq $0, %[ones], %[q]
        \\movd %[q], %[ret]
        : [ret] "={eax}" (-> mask),
        : [ones] "x" (ones),
          [q] "x" (q),
    );
}

test "basic add functionality" {
    try fromSlice(
        \\{ "\\\"Nam[{": [ 116,"\\\\" , 234, "true", false ], "t":"\\\"" }
    );
    try testing.expect(10 == 10);
}
