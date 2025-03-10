const std = @import("std");
const types = @import("../../types.zig");
const tokens = @import("../../tokens.zig");
const common = @import("../../common.zig");
const number_common = @import("common.zig");
const eisel_lemire = @import("eisel_lemire.zig");
const digit_comp = @import("digit_comp.zig");
const Error = types.ParseError;
const Number = types.Number;
const max_digits = number_common.max_digits;

pub inline fn parse(comptime Expected: ?types.NumberType, src: [*]const u8) Error!Number {
    @setEvalBranchQuota(5000);
    const is_negative = src[0] == '-';
    if (Expected == .unsigned and is_negative) return error.InvalidNumberLiteral;

    var mantissa_10: u64 = 0;

    const integer_ptr = src + @intFromBool(is_negative);
    var integer_len: usize = undefined;

    var decimal_ptr: [*]const u8 = undefined;
    var decimal_len: usize = 0;

    var exponent_10: i64 = 0;
    var is_float = false;
    var many_digits = false;

    parse_remainding_digits: {
        parse_significant_digits: {
            inline for (0..max_digits - 1) |i| {
                const int_char = integer_ptr[i];
                if (parseDigit(int_char)) |digit| {
                    @branchHint(.likely);
                    mantissa_10 = mantissa_10 *% 10 +% digit;
                } else {
                    if (i == 0) return error.IncorrectType; // there is no digits
                    if (i > 1 and integer_ptr[0] == '0') return error.InvalidNumberLiteral; // there is a leading zero

                    if (common.tables.is_structural_or_whitespace_negated[int_char]) {
                        if (Expected == null or Expected == .double) { // there can be a decimal point
                            decimal_ptr = integer_ptr + i;
                            integer_len = i;
                            if (int_char == '.') {
                                is_float = true;
                                decimal_ptr += 1;
                                if (i == 1 and integer_ptr[0] == '0') {
                                    var significant_ptr = decimal_ptr;
                                    while (significant_ptr[0] == '0') {
                                        significant_ptr += 1;
                                        decimal_len += 1;
                                    }
                                    if (number_common.isEightDigits(significant_ptr)) {
                                        mantissa_10 = mantissa_10 *% 100000000 +% number_common.parseEightDigits(significant_ptr);
                                        if (number_common.isEightDigits(significant_ptr[8..])) {
                                            mantissa_10 = mantissa_10 *% 100000000 +% number_common.parseEightDigits(significant_ptr[8..]);
                                            inline for (16..max_digits - 1) |j| {
                                                const dec_char = significant_ptr[j];
                                                if (parseDigit(dec_char)) |digit| {
                                                    @branchHint(.likely);
                                                    mantissa_10 = mantissa_10 *% 10 +% digit;
                                                } else {
                                                    if (j == 0 and decimal_len == 0) return error.InvalidNumberLiteral;
                                                    decimal_len += j;
                                                    break :parse_remainding_digits;
                                                }
                                            }
                                        } else {
                                            inline for (8..max_digits - 1) |j| {
                                                const dec_char = significant_ptr[j];
                                                if (parseDigit(dec_char)) |digit| {
                                                    @branchHint(.likely);
                                                    mantissa_10 = mantissa_10 *% 10 +% digit;
                                                } else {
                                                    if (j == 0 and decimal_len == 0) return error.InvalidNumberLiteral;
                                                    decimal_len += j;
                                                    break :parse_remainding_digits;
                                                }
                                            }
                                        }
                                    } else {
                                        inline for (0..max_digits - 1) |j| {
                                            const dec_char = significant_ptr[j];
                                            if (parseDigit(dec_char)) |digit| {
                                                @branchHint(.likely);
                                                mantissa_10 = mantissa_10 *% 10 +% digit;
                                            } else {
                                                if (j == 0 and decimal_len == 0) return error.InvalidNumberLiteral;
                                                decimal_len += j;
                                                break :parse_remainding_digits;
                                            }
                                        }
                                    }
                                    decimal_len += max_digits - 1;
                                    if (parseDigit(significant_ptr[max_digits - 1])) |_| {
                                        many_digits = true;
                                        decimal_len += 1;
                                        exponent_10 += 1;
                                        break :parse_significant_digits;
                                    }
                                } else {
                                    if (8 <= max_digits - 1 - i and number_common.isEightDigits(decimal_ptr)) {
                                        mantissa_10 = mantissa_10 *% 100000000 +% number_common.parseEightDigits(decimal_ptr);
                                        if (16 <= max_digits - 1 - i and number_common.isEightDigits(decimal_ptr[8..])) {
                                            mantissa_10 = mantissa_10 *% 100000000 +% number_common.parseEightDigits(decimal_ptr[8..]);
                                            inline for (16..max_digits - 1 - i) |j| {
                                                const dec_char = decimal_ptr[j];
                                                if (parseDigit(dec_char)) |digit| {
                                                    @branchHint(.likely);
                                                    mantissa_10 = mantissa_10 *% 10 +% digit;
                                                } else {
                                                    if (j == 0) return error.InvalidNumberLiteral;
                                                    decimal_len += j;
                                                    break :parse_remainding_digits;
                                                }
                                            }
                                        } else {
                                            inline for (8..max_digits - 1 - i) |j| {
                                                const dec_char = decimal_ptr[j];
                                                if (parseDigit(dec_char)) |digit| {
                                                    @branchHint(.likely);
                                                    mantissa_10 = mantissa_10 *% 10 +% digit;
                                                } else {
                                                    if (j == 0) return error.InvalidNumberLiteral;
                                                    decimal_len += j;
                                                    break :parse_remainding_digits;
                                                }
                                            }
                                        }
                                    } else {
                                        inline for (0..max_digits - 1 - i) |j| {
                                            const dec_char = decimal_ptr[j];
                                            if (parseDigit(dec_char)) |digit| {
                                                @branchHint(.likely);
                                                mantissa_10 = mantissa_10 *% 10 +% digit;
                                            } else {
                                                if (j == 0) return error.InvalidNumberLiteral;
                                                decimal_len += j;
                                                break :parse_remainding_digits;
                                            }
                                        }
                                    }
                                    decimal_len += max_digits - 1 - i;
                                    if (parseDigit(decimal_ptr[max_digits - 1 - i])) |_| {
                                        many_digits = true;
                                        decimal_len += 1;
                                        exponent_10 += 1;
                                        break :parse_significant_digits;
                                    }
                                }
                                break :parse_remainding_digits;
                            } else {
                                break :parse_remainding_digits;
                            }
                        } else { // there is an invalid suffix
                            return error.InvalidNumberLiteral;
                        }
                    }

                    // it is an integer of 18 digits or less
                    if (Expected == null or Expected == .signed) {
                        const n: i64 = @intCast(mantissa_10);
                        return .{ .signed = if (is_negative) -n else n };
                    } else {
                        return .{ .unsigned = mantissa_10 };
                    }
                }
            }
            // at this point, there are 19 parsed digits
            if (integer_ptr[0] == '0') return error.InvalidNumberLiteral; // there is a leading zero
            if (Expected != null and Expected != .double) {
                // remainder: there are 19 parsed digits and zero or more unparsed
                if (Expected == .signed) {
                    // trying to parse the 20th digit if it exists
                    if (parseDigit(integer_ptr[max_digits - 1])) |digit| {
                        if (common.tables.is_structural_or_whitespace_negated[integer_ptr[max_digits]]) return error.InvalidNumberLiteral;
                        if (is_negative) return error.NumberOutOfRange;
                        const maybe_mant_1 = @mulWithOverflow(mantissa_10, 10);
                        const maybe_mant_2 = @addWithOverflow(maybe_mant_1[0], digit);
                        if (@bitCast(maybe_mant_1[1] | maybe_mant_2[1])) return error.NumberOutOfRange;
                        mantissa_10 = maybe_mant_2[0];
                        return .{ .unsigned = mantissa_10 };
                    }

                    if (common.tables.is_structural_or_whitespace_negated[integer_ptr[max_digits - 1]]) return error.InvalidNumberLiteral;
                    if (is_negative) {
                        if (mantissa_10 > @as(u64, std.math.maxInt(i64)) + 1) return error.NumberOutOfRange;
                        const signed: i64 = @intCast(mantissa_10);
                        return .{ .signed = -signed };
                    } else {
                        if (mantissa_10 > std.math.maxInt(i64)) return .{ .unsigned = mantissa_10 };
                        return .{ .signed = @intCast(mantissa_10) };
                    }
                } else {
                    // trying to parse the 20th digit if it exists
                    if (parseDigit(integer_ptr[max_digits - 1])) |digit| {
                        if (common.tables.is_structural_or_whitespace_negated[integer_ptr[max_digits]]) return error.InvalidNumberLiteral;
                        const maybe_mant_1 = @mulWithOverflow(mantissa_10, 10);
                        const maybe_mant_2 = @addWithOverflow(maybe_mant_1[0], digit);
                        if (@bitCast(maybe_mant_1[1] | maybe_mant_2[1])) return error.NumberOutOfRange;
                        mantissa_10 = maybe_mant_2[0];
                        return .{ .unsigned = mantissa_10 };
                    }
                    if (common.tables.is_structural_or_whitespace_negated[integer_ptr[max_digits - 1]]) return error.InvalidNumberLiteral;
                    return .{ .unsigned = mantissa_10 };
                }
            }
            integer_len = max_digits - 1;
            while (number_common.isEightDigits(integer_ptr[integer_len..])) {
                integer_len += 8;
                exponent_10 += 8;
            }
            while (parseDigit(integer_ptr[integer_len])) |_| {
                integer_len += 1;
                exponent_10 += 1;
            }
            decimal_ptr = integer_ptr + integer_len;
            if (decimal_ptr[0] == '.') {
                is_float = true;
                // a decimal digit must be taken into account
                if (parseDigit(decimal_ptr[1])) |_| {
                    many_digits = true;
                    decimal_ptr += 1;
                    decimal_len = 1;
                    exponent_10 += 1;
                    // but there can be more decimal digits
                    break :parse_significant_digits;
                } else {
                    return error.InvalidNumberLiteral;
                }
                break :parse_significant_digits;
            } else {
                many_digits = integer_len > max_digits - 1;
                break :parse_remainding_digits;
            }
        }
        while (number_common.isEightDigits(decimal_ptr[decimal_len..])) {
            decimal_len += 8;
            exponent_10 += 8;
        }
        while (parseDigit(decimal_ptr[decimal_len])) |_| {
            decimal_len += 1;
            exponent_10 += 1;
        }
    }

    var exponent_ptr = decimal_ptr + decimal_len;
    exponent_10 -= @intCast(decimal_len);

    if (exponent_ptr[0] | 0x20 == 'e') {
        is_float = true;
        exponent_ptr += 1;
        try parseExponent(&exponent_ptr, &exponent_10);
    }

    if (common.tables.is_structural_or_whitespace_negated[exponent_ptr[0]]) {
        return error.InvalidNumberLiteral;
    }

    fits_as_integer: {
        if (Expected == null and !is_float) {
            // remainder: there are 19 parsed digits and zero or more unparsed
            if (integer_len > max_digits) break :fits_as_integer;
            // trying to parse the 20th digit if it exists
            if (parseDigit(integer_ptr[max_digits - 1])) |digit| {
                if (is_negative) break :fits_as_integer;
                const maybe_mant_1 = @mulWithOverflow(mantissa_10, 10);
                const maybe_mant_2 = @addWithOverflow(maybe_mant_1[0], digit);
                if (@bitCast(maybe_mant_1[1] | maybe_mant_2[1])) break :fits_as_integer;
                mantissa_10 = maybe_mant_2[0];
                return .{ .unsigned = mantissa_10 };
            }

            if (is_negative) {
                if (mantissa_10 > @as(u64, std.math.maxInt(i64)) + 1) break :fits_as_integer;
                const signed: i64 = @intCast(mantissa_10);
                return .{ .signed = -signed };
            } else {
                if (mantissa_10 > std.math.maxInt(i64)) return .{ .unsigned = mantissa_10 };
                return .{ .signed = @intCast(mantissa_10) };
            }
        }
    }
    {
        @setFloatMode(.strict);

        const fast_min_exp = -22;
        const fast_max_exp = 22;
        const fast_max_man = 2 << number_common.man_bits;

        if (fast_min_exp <= exponent_10 and
            exponent_10 <= fast_max_exp and
            mantissa_10 <= fast_max_man and
            !many_digits)
        {
            var answer: f64 = @floatFromInt(mantissa_10);
            if (exponent_10 < 0)
                answer /= power_of_ten[@intCast(-exponent_10)]
            else
                answer *= power_of_ten[@intCast(exponent_10)];
            return .{ .double = if (is_negative) -answer else answer };
        }

        var bf = eisel_lemire.compute(mantissa_10, exponent_10);
        if (many_digits and bf.e >= 0) {
            if (!bf.eql(eisel_lemire.compute(mantissa_10 + 1, exponent_10))) {
                bf = eisel_lemire.computeError(mantissa_10, exponent_10);
            }
        }
        if (bf.e < 0) {
            @branchHint(.unlikely);
            digit_comp.compute(.{
                .integer = integer_ptr[0..integer_len],
                .decimal = decimal_ptr[0..decimal_len],
                .exponent = exponent_10,
                .mantissa = mantissa_10,
                .negative = is_negative,
            }, &bf);
        }

        if (bf.e == number_common.inf_exp) return error.NumberOutOfRange;

        return .{ .double = bf.toFloat(is_negative) };
    }
}

const power_of_ten: [23]f64 = brk: {
    @setEvalBranchQuota(10000);
    var res: [23]f64 = undefined;
    for (&res, 0..) |*r, i| {
        r.* = std.math.pow(f64, 10, i);
    }
    break :brk res;
};

inline fn parseDigit(char: u8) ?u8 {
    const digit = char -% '0';
    return if (digit < 10) digit else null;
}

inline fn parseExponent(ptr: *[*]const u8, exp: *i64) Error!void {
    const is_negative = ptr.*[0] == '-';
    ptr.* += @intFromBool(is_negative or ptr.*[0] == '+');

    const start_exp = @intFromPtr(ptr.*);

    var exp_number: u64 = 0;
    while (parseDigit(ptr.*[0])) |d| {
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
