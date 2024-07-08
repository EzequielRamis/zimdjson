const std = @import("std");
const common = @import("common.zig");

pub fn compute(mantissa: u64, exponent: i64, negative: bool) ?f64 {
    const min_exp = -22;
    const max_exp = 22;
    const max_man = 2 << std.math.floatMantissaBits(f64);

    if (mantissa <= max_man and
        min_exp <= exponent and
        exponent <= max_exp)
    {
        var answer: f64 = @floatFromInt(mantissa);
        if (exponent < 0)
            answer /= power_of_ten[-exponent]
        else
            answer *= power_of_ten[exponent];
        return if (negative) -answer else answer;
    }
    return null;
}

const power_of_ten: [23]f64 = brk: {
    var res: [23]f64 = undefined;
    for (&res, 0..) |*r, i| {
        r.* = std.math.pow(f64, 10, i);
    }
    break :brk res;
};
