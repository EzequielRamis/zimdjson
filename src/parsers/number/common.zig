const std = @import("std");
const builtin = @import("builtin");
const intr = @import("../../intrinsics.zig");
const common = @import("../../common.zig");
const intFromSlice = common.intFromSlice;
const cpu = builtin.cpu;

pub const min_pow10 = -342;
pub const max_pow10 = 308;
pub const min_exp = -1023;
pub const min_even_exp = -4;
pub const max_even_exp = 23;
pub const max_digits = 20;
pub const max_big_digits = 0x300;
pub const inf_exp: i32 = 0x7FF;
pub const man_bits = std.math.floatMantissaBits(f64);

/// A custom 64-bit floating point type, representing `f * 2^e`.
/// e is biased, so it be directly shifted into the exponent bits.
/// Negative exponent indicates an invalid result.
pub const BiasedFp = struct {
    pub const bias = man_bits - min_exp;
    pub const invalid_bias = -0x8000;

    const Self = @This();

    /// The significant digits.
    m: u64,
    /// The biased, binary exponent.
    e: i32,

    pub fn zero() Self {
        return .{ .f = 0, .e = 0 };
    }

    pub fn zeroPow2(e: i32) Self {
        return .{ .f = 0, .e = e };
    }

    pub fn eql(self: Self, other: Self) bool {
        return self.m == other.m and self.e == other.e;
    }

    pub fn toFloat(self: Self, negative: bool) f64 {
        var f = self.m;
        f |= @as(u64, @intCast(self.e)) << std.math.floatMantissaBits(f64);
        f |= @as(u64, @intFromBool(negative)) << 63;
        return @bitCast(f);
    }
};

pub fn isEightDigits(src: *const [8]u8) bool {
    const val = intFromSlice(u64, src).*;
    const a = val +% 0x4646464646464646;
    const b = val -% 0x3030303030303030;
    return (((a | b) & 0x8080808080808080)) == 0;
}

pub fn parseEightDigits(src: *const [8]u8) u32 {
    // if (cpu.arch.isX86()) {
    //     const ascii0: @Vector(16, u8) = @splat('0');
    //     const mul_1_10 = std.simd.repeat(16, [_]u8{ 10, 1 });
    //     const mul_1_100 = std.simd.repeat(8, [_]u16{ 100, 1 });
    //     const mul_1_10000 = std.simd.repeat(8, [_]u16{ 10000, 1 });
    //     const input = std.simd.repeat(16, src.*) - ascii0;
    //     const t1 = intr.mulSaturatingAdd(input, mul_1_10);
    //     const t2 = intr.mulWrappingAdd(t1, mul_1_100);
    //     const t3 = intr.pack(t2, t2);
    //     const t4 = intr.mulWrappingAdd(t3, mul_1_10000);
    //     return t4[0];
    // } else {
    var val = intFromSlice(u64, src).*;
    const mask = 0x000000FF000000FF;
    const mul1 = 0x000F424000000064; // 100 + (1000000ULL << 32)
    const mul2 = 0x0000271000000001; // 1 + (10000ULL << 32)
    val -%= 0x3030303030303030;
    val = (val *% 10) +% (val >> 8); // val = (val * 2561) >> 8;
    val = (((val & mask) *% mul1) +% (((val >> 16) & mask) *% mul2)) >> 32;
    return @intCast(val);
    // }
}
