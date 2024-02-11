const std = @import("std");
const builtin = @import("builtin");
const types = @import("types.zig");
const cpu = builtin.cpu;
const simd = std.simd;
const umask = types.umask;
const vector = types.vector;
const Vector = types.Vector;

pub fn clmul(quotes_mask: umask) umask {
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

pub fn lut(table: vector, nibbles: vector) vector {
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
