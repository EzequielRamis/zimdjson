const std = @import("std");
const types = @import("../../types.zig");
const tokens = @import("../../tokens.zig");
const common = @import("common.zig");
const eisel_lemire = @import("eisel_lemire.zig");
const digit_comp = @import("digit_comp.zig");
const FromString = @import("from_string.zig").FromString;
const TokenOptions = tokens.Options;
const TokenIterator = tokens.Iterator;
const TokenPhase = tokens.Phase;
const Error = types.Error;
const Number = types.Number;
const max_digits = common.max_digits;

pub fn Parser(comptime opt: TokenOptions) type {
    return struct {
        pub fn parse(comptime phase: TokenPhase, src: *TokenIterator(opt)) Error!Number {
            var parsed_number = try FromString(.{}).parse(opt, phase, src);
            if (parsed_number.is_float) return .{
                .float = try computeFloat(&parsed_number),
            };

            const digit_count = parsed_number.integer.len;
            const negative = parsed_number.negative;
            const integer = parsed_number.mantissa;
            const longest_digit_count: u32 = if (negative) max_digits - 1 else max_digits;
            if (digit_count < longest_digit_count) {
                if (std.math.cast(i64, integer)) |i| {
                    return .{ .signed = if (negative) -i else i };
                }
                return .{ .unsigned = integer };
            }
            if (digit_count == longest_digit_count) {
                if (negative) {
                    return .{ .signed = -(std.math.cast(i64, integer) orelse return error.NumberOutOfRange) };
                }
                const max_int: u64 = std.math.maxInt(i64);
                if (parsed_number.integer[0] != '1' or integer <= max_int) return error.NumberOutOfRange;
                return .{ .unsigned = integer };
            }
            return error.NumberOutOfRange;
        }

        pub fn parseSigned(comptime phase: TokenPhase, src: *TokenIterator(opt)) Error!i64 {
            const parsed_number = try FromString(.{ .can_be_float = false }).parse(opt, phase, src);

            const digit_count = parsed_number.integer.len;
            const negative = parsed_number.negative;
            const integer = parsed_number.mantissa;

            const longest_digit_count = max_digits - 1;
            if (digit_count <= longest_digit_count) {
                if (integer > std.math.maxInt(i64) + @intFromBool(negative)) return error.NumberOutOfRange;

                const i: i64 = @intCast(integer);
                return if (negative) -i else i;
            }

            return error.NumberOutOfRange;
        }

        pub fn parseUnsigned(comptime phase: TokenPhase, src: *TokenIterator(opt)) Error!u64 {
            const parsed_number = try FromString(.{
                .can_be_float = false,
                .can_be_signed = false,
            }).parse(opt, phase, src);

            const digit_count = parsed_number.integer.len;
            const integer = parsed_number.mantissa;

            const longest_digit_count = max_digits;
            if (digit_count < longest_digit_count) return integer;
            if (digit_count == longest_digit_count) {
                if (parsed_number.integer[0] != '1' or
                    integer <= std.math.maxInt(i64)) return error.NumberOutOfRange;
                return integer;
            }

            return error.NumberOutOfRange;
        }

        pub fn parseFloat(comptime phase: TokenPhase, src: *TokenIterator(opt)) Error!f64 {
            var parsed_number = try FromString(.{}).parse(opt, phase, src);
            return computeFloat(&parsed_number);
        }
    };
}

inline fn computeFloat(number: *FromString(.{})) Error!f64 {
    @setFloatMode(.strict);

    var many_digits = false;
    if (number.integer.len + number.decimal.len >= max_digits) {
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
    const fast_max_man = 2 << common.man_bits;

    if (!many_digits and
        fast_min_exp <= number.exponent and
        number.exponent <= fast_max_exp and
        number.mantissa <= fast_max_man)
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
    if (bf.e < 0) digit_comp.compute(number.*, &bf);

    if (bf.e == common.inf_exp) return error.NumberOutOfRange;

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
