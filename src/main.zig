const std = @import("std");
const builtin = @import("builtin");
const simd = std.simd;
const cpu = builtin.cpu;
const testing = std.testing;

// TODO:
// Stage 1:
// [X] Identification of the quoted substrings
// [X] Vectorized Classification
// [ ] Identification of White-Space and Pseudo-Structural Characters
// [ ] Index Extraction
// [ ] Character-Encoding Validation
// Stage 2:
// [ ] Number Parsing
// [ ] String Validation and Normalization

const vector_size = simd.suggestVectorSize(u8) orelse @compileError("SIMD features not supported at current target");
const vector = @Vector(vector_size, u8);
const mask = std.meta.Int(std.builtin.Signedness.unsigned, vector_size);
const vector_mask = @Vector(vector_size, bool);

const zer_mask: mask = 0;
const one_mask: mask = @bitCast(simd.repeat(vector_size, [_]u1{1}));
const evn_mask: mask = @bitCast(simd.repeat(vector_size, [_]u1{ 1, 0 }));
const odd_mask: mask = @bitCast(simd.repeat(vector_size, [_]u1{ 0, 1 }));

const zer_vector: vector_mask = @bitCast(zer_mask);
const one_vector: vector_mask = @bitCast(one_mask);

const quote: vector = @splat('"');
const slash: vector = @splat('\\');

const ln_table: vector = simd.repeat(vector_size, [_]u8{ 16, 0, 0, 0, 0, 0, 0, 0, 0, 8, 10, 4, 1, 12, 0, 0 });
const hn_table: vector = simd.repeat(vector_size, [_]u8{ 8, 0, 17, 2, 0, 4, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0 });

fn reverseMask(input: mask) mask {
    return @bitCast(simd.reverseOrder(@as(vector_mask, @bitCast(input))));
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

        std.debug.print("{s}\n", .{buffer});
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
        else => @compileError("Table lookup not implemented for this target"),
    }
}

fn anyBitsSet(vec: vector, bits: vector) mask {
    return ~@as(mask, @bitCast(bitsNotSet(vec & bits)));
}

fn bitsNotSet(vec: vector) vector_mask {
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
    switch (cpu.arch) {
        .x86_64 => {
            const range = @as(@Vector(16, u8), @bitCast(simd.repeat(128 / vector_size, [_]mask{quotes_mask & structural_mask})));
            const ones = @as(@Vector(16, u8), @bitCast(simd.repeat(128, [_]u1{1})));
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
        else => return @as(mask, @bitCast(simd.prefixScan(builtin.ReduceOp.Xor, 1, @as(vector_mask, @bitCast(quotes_mask))))),
    }
}

test "basic add functionality" {
    try fromSlice(
        \\{ "\\\"Nam[{": [ 116,"\\\\" , 234, "true", false ], "t":"\\\"" }
    );
    try testing.expect(10 == 10);
}
