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

pub fn lookupTable(table: vector, nibbles: vector) vector {
    switch (cpu.arch) {
        .x86_64 => {
            return asm (
                \\vpshufb %[nibbles], %[table], %[ret]
                : [ret] "=v" (-> vector),
                : [table] "v" (table),
                  [nibbles] "v" (nibbles),
            );
        },
        else => unreachable,
    }
}

pub fn pack(vec1: @Vector(4, i32), vec2: @Vector(4, i32)) @Vector(8, u16) {
    switch (cpu.arch) {
        .x86_64 => {
            return asm (
                \\vpackusdw %[vec1], %[vec2], %[ret]
                : [ret] "=v" (-> @Vector(8, u16)),
                : [vec1] "v" (vec1),
                  [vec2] "v" (vec2),
            );
        },
        else => unreachable,
    }
}

pub fn mulSaturatingAdd(vec1: @Vector(16, u8), vec2: @Vector(16, u8)) @Vector(8, u16) {
    switch (builtin.cpu.arch) {
        .x86_64 => {
            return asm (
                \\vpmaddubsw %[vec1], %[vec2], %[ret]
                : [ret] "=v" (-> @Vector(8, u16)),
                : [vec1] "v" (vec1),
                  [vec2] "v" (vec2),
            );
        },
        else => unreachable,
    }
}

pub fn mulWrappingAdd(vec1: @Vector(8, i16), vec2: @Vector(8, i16)) @Vector(4, i32) {
    switch (builtin.cpu.arch) {
        .x86_64 => {
            return asm (
                \\vpmaddwd %[vec1], %[vec2], %[ret]
                : [ret] "=v" (-> @Vector(4, i32)),
                : [vec1] "v" (vec1),
                  [vec2] "v" (vec2),
            );
        },
        else => unreachable,
    }
}
