const std = @import("std");
const common = @import("common.zig");
const assert = std.debug.assert;
const BiasedFp = common.BiasedFp;
const min_pow10 = common.min_pow10;
const max_pow10 = common.max_pow10;
const min_exp = common.min_exp;
const min_even_exp = common.min_even_exp;
const max_even_exp = common.max_even_exp;
const inf_exp = common.inf_exp;
const man_bits = common.man_bits;

pub fn computeError(mantissa: u64, exponent: i64) BiasedFp {
    const lz: u6 = @intCast(@clz(mantissa));
    const w = mantissa << @intCast(lz);
    const q = exponent;
    const product = productApproximation(man_bits, w, q);
    return computeErrorScaled(product.high, q, lz);
}

pub fn compute(mantissa: u64, exponent: i64) BiasedFp {
    var answer: BiasedFp = undefined;
    if (mantissa == 0 or exponent < min_pow10) {
        answer.e = 0;
        answer.m = 0;
        return answer;
    }
    if (exponent > max_pow10) {
        answer.e = inf_exp;
        answer.m = 0;
        return answer;
    }
    const lz: u6 = @intCast(@clz(mantissa));
    const w = mantissa << lz;
    const q = exponent;
    const product = productApproximation(man_bits, w, q);
    const upperbit: u1 = @intCast(product.high >> 63);
    answer.m = product.high >> (64 - man_bits - 3 + @as(u6, upperbit));
    answer.e = power(@intCast(q)) + upperbit - lz - min_exp;
    if (answer.e <= 0) {
        if (-answer.e + 1 >= 64) {
            answer.e = 0;
            answer.m = 0;
            return answer;
        }
        answer.m >>= @intCast(-answer.e + 1);
        answer.m += (answer.m & 1); // round up
        answer.m >>= 1;
        answer.e = if (answer.m < 1 << man_bits) 0 else 1;
        return answer;
    }
    if ((product.low <= 1) and (q >= min_even_exp) and (q <= max_even_exp) and
        ((answer.m & 3) == 1))
    {
        if ((answer.m << (64 - man_bits - 3 + @as(u6, upperbit))) == product.high) {
            answer.m &= ~@as(u64, 1);
        }
    }

    answer.m += (answer.m & 1); // round up
    answer.m >>= 1;
    if (answer.m >= 2 << man_bits) {
        answer.m = 1 << man_bits;
        answer.e += 1;
    }

    answer.m &= ~(@as(u64, 1) << man_bits);
    if (answer.e >= inf_exp) {
        answer.e = inf_exp;
        answer.m = 0;
    }
    return answer;
}

fn power(q: i32) i32 {
    return (((152170 + 65536) * q) >> 16) + 63;
}

const U128 = packed struct {
    low: u64,
    high: u64,

    pub fn from(n: u128) U128 {
        return @bitCast(n);
    }

    pub fn mul(a: u64, b: u64) U128 {
        return U128.from(std.math.mulWide(u64, a, b));
    }
};

fn productApproximation(comptime precision: comptime_int, w: u64, q: i64) U128 {
    comptime assert(precision > 0 and precision <= 64);
    const index: usize = 2 * @as(usize, @intCast(q - min_pow10));
    var first_product = U128.mul(w, power_of_five_u64[index]);
    const precision_mask: u64 = if (precision < 64)
        @as(u64, 0xFFFFFFFFFFFFFFFF) >> precision
    else
        0xFFFFFFFFFFFFFFFF;
    if (first_product.high & precision_mask == precision_mask) {
        const second_product = U128.mul(w, power_of_five_u64[index + 1]);
        first_product.low += second_product.high;
        if (second_product.high > first_product.low) {
            first_product.high += 1;
        }
    }
    return first_product;
}

fn computeErrorScaled(w: u64, q: i64, lz: u8) BiasedFp {
    const hilz = ~@as(u1, @intCast(w >> 63));
    return .{
        .m = w << hilz,
        .e = power(@intCast(q)) + BiasedFp.bias - hilz - lz - 62 + BiasedFp.invalid_bias,
    };
}

// "Number Parsing at a Gigabyte per Second", Figure 5 (https://arxiv.org/pdf/2101.11408#figure.caption.21)
const power_of_five_u128: [-min_pow10 + max_pow10 + 1]u128 = brk: {
    @setEvalBranchQuota(1000000);
    var res1: [315]u128 = undefined;
    for (&res1, 0..) |*r, _q| {
        const q = min_pow10 + @as(comptime_int, _q);
        const power5 = std.math.pow(u2048, 5, -q);
        var z = 0;
        while (1 << z < power5) z += 1;
        const b = 2 * z + 2 * 64;
        var c = std.math.pow(u2048, 2, b) / power5 + 1;
        while (c >= 1 << 128) c /= 2;
        r.* = c;
    }
    var res2: [27]u128 = undefined;
    for (&res2, 0..) |*r, _q| {
        const q = -27 + @as(comptime_int, _q);
        const power5 = std.math.pow(u2048, 5, -q);
        var z = 0;
        while (1 << z < power5) z += 1;
        const b = z + 127;
        const c = std.math.pow(u2048, 2, b) / power5 + 1;
        r.* = c;
    }
    var res3: [max_pow10 + 1]u128 = undefined;
    for (&res3, 0..) |*r, q| {
        var power5 = std.math.pow(u2048, 5, q);
        while (power5 < 1 << 127) power5 *= 2;
        while (power5 >= 1 << 128) power5 /= 2;
        r.* = power5;
    }
    break :brk res1 ++ res2 ++ res3;
};

const power_of_five_u64: *const [power_of_five_u128.len * 2]u64 = @ptrCast(&power_of_five_u128);
