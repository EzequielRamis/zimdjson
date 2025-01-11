const std = @import("std");
const types = @import("../../types.zig");
const tokens = @import("../../tokens.zig");
const common = @import("../../common.zig");
const number_common = @import("common.zig");
const eisel_lemire = @import("eisel_lemire.zig");
const digit_comp = @import("digit_comp.zig");
const Error = types.Error;
const Number = types.Number;
const max_digits = number_common.max_digits;

pub const Parser = struct {
    pub inline fn parse(src: [*]const u8) Error!Number {
        const is_negative = src[0] == '-';
        var ptr = src + @intFromBool(is_negative);

        var mantissa_10: u64 = 0;

        const integer_ptr: [*]const u8 = ptr;
        while (parseDigit(ptr)) |d| {
            mantissa_10 = mantissa_10 *% 10 +% d;
            ptr += 1;
        }
        const integer_len: usize = @intFromPtr(ptr) - @intFromPtr(integer_ptr);
        if (integer_len == 0) return error.ExpectedValue;
        if (integer_ptr[0] == '0' and integer_len > 1) return error.InvalidNumberLiteral;

        var exponent_10: i64 = 0;
        var is_float = false;
        var decimal_ptr: [*]const u8 = undefined;
        var decimal_len: usize = 0;
        if (ptr[0] == '.') {
            ptr += 1;
            decimal_ptr = ptr;
            parseDecimal(&ptr, &mantissa_10);
            decimal_len = @intCast(@intFromPtr(ptr) - @intFromPtr(decimal_ptr));

            if (decimal_len == 0) {
                return error.InvalidNumberLiteral;
            }
            is_float = true;
            exponent_10 -= @intCast(decimal_len);
        }

        if (ptr[0] | 0x20 == 'e') {
            is_float = true;
            ptr += 1;
            try parseExponent(&ptr, &exponent_10);
        }

        if (common.tables.is_structural_or_whitespace_negated[ptr[0]]) {
            return error.InvalidNumberLiteral;
        }

        if (is_float) {
            return .{ .float = try computeFloat(.{
                .integer = integer_ptr[0..integer_len],
                .decimal = decimal_ptr[0..decimal_len],
                .mantissa = mantissa_10,
                .exponent = exponent_10,
                .negative = is_negative,
            }) };
        }

        const longest_digit_count: u32 = if (is_negative) max_digits - 1 else max_digits;
        if (integer_len < longest_digit_count) {
            if (std.math.cast(i64, mantissa_10)) |i| {
                return .{ .signed = if (is_negative) -i else i };
            }
            return .{ .unsigned = mantissa_10 };
        }
        if (integer_len == longest_digit_count) {
            if (is_negative) {
                return .{ .signed = -(std.math.cast(i64, mantissa_10) orelse return error.NumberOutOfRange) };
            }
            const max_int: u64 = std.math.maxInt(i64);
            if (integer_ptr[0] != '1' or mantissa_10 <= max_int) return error.NumberOutOfRange;
            return .{ .unsigned = mantissa_10 };
        }
        return error.NumberOutOfRange;
    }

    pub inline fn parseSigned(src: [*]const u8) Error!i64 {
        const is_negative = src[0] == '-';
        var ptr = src + @intFromBool(is_negative);

        var mantissa_10: u64 = 0;

        const integer_ptr: [*]const u8 = ptr;
        while (parseDigit(ptr)) |d| {
            mantissa_10 = mantissa_10 *% 10 +% d;
            ptr += 1;
        }
        const integer_len: usize = @intFromPtr(ptr) - @intFromPtr(integer_ptr);
        if (integer_len == 0) return error.ExpectedValue;
        if (integer_ptr[0] == '0' and integer_len > 1) return error.InvalidNumberLiteral;

        if (common.tables.is_structural_or_whitespace_negated[ptr[0]]) {
            return error.InvalidNumberLiteral;
        }

        const longest_digit_count = max_digits - 1;
        if (integer_len <= longest_digit_count) {
            if (mantissa_10 > std.math.maxInt(i64) + @as(u64, @intFromBool(is_negative))) return error.NumberOutOfRange;

            const i: i64 = @intCast(mantissa_10);
            return if (is_negative) -i else i;
        }
        return error.NumberOutOfRange;
    }

    pub inline fn parseUnsigned(src: [*]const u8) Error!u64 {
        const is_negative = src[0] == '-';
        if (is_negative) return error.InvalidNumberLiteral;
        var ptr = src + @intFromBool(is_negative);

        var mantissa_10: u64 = 0;

        const integer_ptr: [*]const u8 = ptr;
        while (parseDigit(ptr)) |d| {
            mantissa_10 = mantissa_10 *% 10 +% d;
            ptr += 1;
        }
        const integer_len: usize = @intFromPtr(ptr) - @intFromPtr(integer_ptr);
        if (integer_len == 0) return error.ExpectedValue;
        if (integer_ptr[0] == '0' and integer_len > 1) return error.InvalidNumberLiteral;

        if (common.tables.is_structural_or_whitespace_negated[ptr[0]]) {
            return error.InvalidNumberLiteral;
        }

        const longest_digit_count = max_digits;
        if (integer_len < longest_digit_count) {
            return mantissa_10;
        }
        if (integer_len == longest_digit_count) {
            if (integer_ptr[0] != '1' or
                mantissa_10 <= std.math.maxInt(i64)) return error.NumberOutOfRange;
            return mantissa_10;
        }
        return error.NumberOutOfRange;
    }

    pub inline fn parseFloat(src: [*]const u8) Error!f64 {
        const is_negative = src[0] == '-';
        var ptr = src + @intFromBool(is_negative);

        var mantissa_10: u64 = 0;

        const integer_ptr: [*]const u8 = ptr;
        while (parseDigit(ptr)) |d| {
            mantissa_10 = mantissa_10 *% 10 +% d;
            ptr += 1;
        }
        const integer_len: usize = @intFromPtr(ptr) - @intFromPtr(integer_ptr);
        if (integer_len == 0) {
            return error.ExpectedValue;
        }
        if (integer_ptr[0] == '0' and integer_len > 1) {
            return error.InvalidNumberLiteral;
        }

        var exponent_10: i64 = 0;
        var decimal_ptr: [*]const u8 = undefined;
        var decimal_len: usize = 0;
        if (ptr[0] == '.') {
            ptr += 1;
            decimal_ptr = ptr;
            parseDecimal(&ptr, &mantissa_10);
            decimal_len = @intCast(@intFromPtr(ptr) - @intFromPtr(decimal_ptr));

            if (decimal_len == 0) {
                return error.InvalidNumberLiteral;
            }
            exponent_10 -= @intCast(decimal_len);
        }

        if (ptr[0] | 0x20 == 'e') {
            ptr += 1;
            try parseExponent(&ptr, &exponent_10);
        }

        if (common.tables.is_structural_or_whitespace_negated[ptr[0]]) {
            return error.InvalidNumberLiteral;
        }

        return computeFloat(.{
            .integer = integer_ptr[0..integer_len],
            .decimal = decimal_ptr[0..decimal_len],
            .mantissa = mantissa_10,
            .exponent = exponent_10,
            .negative = is_negative,
        });
    }
};

inline fn computeFloat(_number: number_common.FromString) Error!f64 {
    @setFloatMode(.strict);
    var number = _number;

    var many_digits = false;
    if (number.integer.len + number.decimal.len >= max_digits) {
        @branchHint(.unlikely);
        if (number.integer[0] == '0') {
            while (number.decimal.len > 0 and number.decimal[0] == '0') {
                number.decimal = number.decimal[1..];
            }
            if (number.decimal.len >= max_digits) {
                many_digits = true;
                number.mantissa = 0;
                const truncated_decimal_len = @min(number.decimal.len, max_digits - 1);
                for (number.decimal[0..truncated_decimal_len]) |d| {
                    number.mantissa = number.mantissa * 10 + (d - '0');
                }
                number.exponent += @intCast(number.decimal.len - truncated_decimal_len);
            }
        } else {
            many_digits = true;
            number.mantissa = 0;
            const truncated_integer_len = @min(number.integer.len, max_digits - 1);
            for (number.integer[0..truncated_integer_len]) |i| {
                number.mantissa = number.mantissa * 10 + (i - '0');
            }
            number.exponent += @intCast(number.integer.len - truncated_integer_len);
            const truncated_decimal_len = @min(number.decimal.len, max_digits - 1 - truncated_integer_len);
            for (number.decimal[0..truncated_decimal_len]) |d| {
                number.mantissa = number.mantissa * 10 + (d - '0');
            }
            number.exponent += @intCast(number.decimal.len - truncated_decimal_len);
        }
    }

    const fast_min_exp = -22;
    const fast_max_exp = 22;
    const fast_max_man = 2 << number_common.man_bits;

    if (fast_min_exp <= number.exponent and
        number.exponent <= fast_max_exp and
        number.mantissa <= fast_max_man and
        !many_digits)
    {
        var answer: f64 = @floatFromInt(number.mantissa);
        if (number.exponent < 0)
            answer /= power_of_ten[@intCast(-number.exponent)]
        else
            answer *= power_of_ten[@intCast(number.exponent)];
        return if (number.negative) -answer else answer;
    }

    var bf = eisel_lemire.compute(number.mantissa, number.exponent);
    if (many_digits and bf.e >= 0) {
        if (!bf.eql(eisel_lemire.compute(number.mantissa + 1, number.exponent))) {
            bf = eisel_lemire.computeError(number.mantissa, number.exponent);
        }
    }
    if (bf.e < 0) {
        @branchHint(.unlikely);
        digit_comp.compute(number, &bf);
    }

    if (bf.e == number_common.inf_exp) return error.NumberOutOfRange;

    return bf.toFloat(number.negative);
}

const power_of_ten: [23]f64 = brk: {
    @setEvalBranchQuota(10000);
    var res: [23]f64 = undefined;
    for (&res, 0..) |*r, i| {
        r.* = std.math.pow(f64, 10, i);
    }
    break :brk res;
};

inline fn parseDigit(ptr: [*]const u8) ?u8 {
    const digit = ptr[0] -% '0';
    return if (digit < 10) digit else null;
}

inline fn parseDecimal(ptr: *[*]const u8, man: *u64) void {
    while (number_common.isEightDigits(ptr.*[0..8].*)) {
        man.* = man.* *% 100000000 +% number_common.parseEightDigits(ptr.*);
        ptr.* += 8;
    }

    while (parseDigit(ptr.*)) |d| {
        man.* = man.* *% 10 +% d;
        ptr.* += 1;
    }
}

inline fn parseExponent(ptr: *[*]const u8, exp: *i64) Error!void {
    const is_negative = ptr.*[0] == '-';
    ptr.* += @intFromBool(is_negative or ptr.*[0] == '+');

    const start_exp = @intFromPtr(ptr.*);

    var exp_number: u64 = 0;
    while (parseDigit(ptr.*)) |d| {
        if (exp_number < 0x10000000) {
            exp_number = exp_number * 10 + d;
        }
        ptr.* += 1;
    }

    if (start_exp == @intFromPtr(ptr.*)) {
        return error.InvalidNumberLiteral;
    }

    var exp_signed: i64 = @intCast(exp_number);
    if (is_negative) exp_signed = -exp_signed;
    exp.* += exp_signed;
}
