const std = @import("std");
const builtin = @import("builtin");
const simd = std.simd;
const cpu = builtin.cpu;
const testing = std.testing;

pub const vector_size = simd.suggestVectorSize(u8) orelse @compileError("SIMD features not supported at current target");
pub const vector = @Vector(vector_size, u8);
pub const mask = std.meta.Int(std.builtin.Signedness.unsigned, vector_size);
pub const vector_mask = @Vector(vector_size, bool);

pub const zer_mask: mask = 0;
pub const one_mask: mask = @bitCast(simd.repeat(vector_size, [_]u1{1}));
pub const evn_mask: mask = @bitCast(simd.repeat(vector_size, [_]u1{ 1, 0 }));
pub const odd_mask: mask = @bitCast(simd.repeat(vector_size, [_]u1{ 0, 1 }));

pub const zer_vector: vector_mask = @bitCast(zer_mask);
pub const one_vector: vector_mask = @bitCast(one_mask);

pub const quote: vector = @splat('"');
pub const slash: vector = @splat('\\');

pub fn lookupTable(table: vector, nibbles: vector) vector {
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

pub fn anyBitsSet(vec: vector, bits: vector) mask {
    return ~@as(mask, @bitCast(bitsNotSet(vec & bits)));
}

pub fn bitsNotSet(vec: vector) vector_mask {
    return @select(bool, vec == @as(vector, @splat(0)), one_vector, zer_vector);
}

pub fn reverseMask(input: mask) mask {
    return @bitCast(simd.reverseOrder(@as(vector_mask, @bitCast(input))));
}

pub fn partialChunk(len: usize) usize {
    return ((len -| 1) / vector_size) * vector_size;
}
