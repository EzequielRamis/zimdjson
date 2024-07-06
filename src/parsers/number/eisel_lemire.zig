const std = @import("std");
const assert = std.debug.assert;

pub fn compute(mantissa: u64, exponent: i64, negative: bool) ?f64 {
    if (mantissa == 0 or exponent < -342) return if (negative) -0.0 else 0.0;
    if (exponent > 308) return null;
    const lz: u64 = @clz(mantissa);
    const w = @as(u64, 1 << lz) * mantissa;
    const z = (power_of_five_u128[exponent] * w) / (1 << 64);
    var m: u54 = @truncate(z);
    const u = z / (2 << 127);
    const p = ((217706 * exponent) / (1 << 16)) + 63 - lz + u;
    if (p <= -1022 - 64) return if (negative) -0.0 else 0.0;
    if (p <= -1022) {
        const s = -1022 - p + 1;
        m = m / (1 << s);
        if (m % 2 == 1) m += 1;
        m /= 2;
        const answer = @as(f64, @floatFromInt(m * (1 << p))) * std.math.pow(f64, 2, -52);
        return if (negative) -answer else answer;
    }
    if (z % (1 << 64) <= 1 and
        m % 2 == 1 and
        (m / 2) % 2 == 0 and
        -4 <= exponent and
        exponent <= 23)
    {
        // round to even
    }
    if (m % 2 == 1) m += 1;
    m /= 2;
    if (m == (1 << 53)) {
        m /= 2;
        p += 1;
    }
    if (p > 1023) return null;
    const answer = @as(f64, @floatFromInt(m * (1 << p))) * std.math.pow(f64, 2, -52);
    return if (negative) -answer else answer;
}

const U128 = struct {
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
    const index = 2 * (q + 342);
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

// "Number Parsing at a Gigabyte per Second", Figure 5 (https://arxiv.org/pdf/2101.11408#figure.caption.21)
const power_of_five_u128: [342 + 309]u128 = brk: {
    @setEvalBranchQuota(1000000);
    var res1: [315]u128 = undefined;
    for (&res1, 0..) |*r, _q| {
        const q = -342 + @as(comptime_int, _q);
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
    var res3: [309]u128 = undefined;
    for (&res3, 0..) |*r, q| {
        var power5 = std.math.pow(u2048, 5, q);
        while (power5 < 1 << 127) power5 *= 2;
        while (power5 >= 1 << 128) power5 /= 2;
        r.* = power5;
    }
    break :brk res1 ++ res2 ++ res3;
};

const power_of_five_u64: *const [power_of_five_u128.len * 2]u64 = @ptrCast(&power_of_five_u128);
