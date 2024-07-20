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
const ParseError = types.ParseError;
const max_digits = common.max_digits;

const Number = union(enum) {
    unsigned: u64,
    signed: i64,
    float: f64,
};

pub fn Parser(comptime opt: TokenOptions) type {
    return struct {
        pub const Result = Number;

        pub fn parse(comptime phase: TokenPhase, src: *TokenIterator(opt)) ParseError!Number {
            const parsed_number = try FromString(.{}).parse(opt, phase, src);
            if (parsed_number.is_float) return .{
                .float = try computeFloat(parsed_number),
            };

            const digit_count = parsed_number.integer.len;
            const negative = parsed_number.negative;
            const integer = parsed_number.mantissa;
            const longest_digit_count: usize = if (negative) max_digits - 1 else max_digits;
            if (digit_count < longest_digit_count) {
                if (std.math.cast(i64, integer)) |i| {
                    return .{ .signed = if (negative) -i else i };
                }
                return .{ .unsigned = integer };
            }
            if (digit_count == longest_digit_count) {
                if (negative) {
                    return .{ .signed = -(std.math.cast(i64, integer) orelse return error.InvalidNumber) };
                }
                const max_int: u64 = std.math.maxInt(i64);
                if (parsed_number.integer[0] != '1' or integer <= max_int) return error.InvalidNumber;
                return .{ .unsigned = integer };
            }
            return error.InvalidNumber;
        }

        pub fn parseSigned(comptime phase: TokenPhase, src: *TokenIterator(opt)) ParseError!i64 {
            const parsed_number = try FromString(.{ .can_be_float = false }).parse(opt, phase, src);

            const digit_count = parsed_number.integer.len;
            const negative = parsed_number.negative;
            const integer = parsed_number.mantissa;

            const longest_digit_count = max_digits - 1;
            if (digit_count <= longest_digit_count) {
                if (integer > std.math.maxInt(i64) + @intFromBool(negative)) return error.InvalidNumber;

                const i: i64 = @intCast(integer);
                return if (negative) -i else i;
            }

            return error.InvalidNumber;
        }

        pub fn parseUnsigned(comptime phase: TokenPhase, src: *TokenIterator(opt)) ParseError!u64 {
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
                    integer <= std.math.maxInt(i64)) return error.InvalidNumber;
                return integer;
            }

            return error.InvalidNumber;
        }

        pub fn parseFloat(comptime phase: TokenPhase, src: *TokenIterator(opt)) ParseError!f64 {
            const parsed_number = try FromString(.{}).parse(opt, phase, src);
            return computeFloat(parsed_number);
        }
    };
}

fn computeFloat(parsed_number: FromString(.{})) ParseError!f64 {
    @setFloatMode(.strict);

    var mantissa = parsed_number.mantissa;
    var exponent = parsed_number.exponent;
    var integer = parsed_number.integer;
    var decimal = parsed_number.decimal;

    var many_digits = false;
    if (integer.len + decimal.len >= max_digits) {
        if (integer[0] == '0') {
            while (decimal.len > 0 and decimal[0] == '0') {
                decimal = decimal[1..];
            }
            if (decimal.len >= max_digits) {
                many_digits = true;
                mantissa = 0;
                const truncated_decimal_len = @min(decimal.len, max_digits - 1);
                for (decimal[0..truncated_decimal_len]) |d| {
                    mantissa = mantissa * 10 + (d - '0');
                }
                exponent += @intCast(decimal.len - truncated_decimal_len);
            }
        } else {
            many_digits = true;
            mantissa = 0;
            const truncated_integer_len = @min(integer.len, max_digits - 1);
            for (integer[0..truncated_integer_len]) |i| {
                mantissa = mantissa * 10 + (i - '0');
            }
            exponent += @intCast(integer.len - truncated_integer_len);
            const truncated_decimal_len = @min(decimal.len, max_digits - 1 - truncated_integer_len);
            for (decimal[0..truncated_decimal_len]) |d| {
                mantissa = mantissa * 10 + (d - '0');
            }
            exponent += @intCast(decimal.len - truncated_decimal_len);
        }
    }

    const fast_min_exp = -22;
    const fast_max_exp = 22;
    const fast_max_man = 2 << common.man_bits;

    if (!many_digits and
        fast_min_exp <= exponent and
        exponent <= fast_max_exp and
        mantissa <= fast_max_man)
    {
        var answer: f64 = @floatFromInt(mantissa);
        if (exponent < 0)
            answer /= power_of_ten[@intCast(-exponent)]
        else
            answer *= power_of_ten[@intCast(exponent)];
        return if (parsed_number.negative) -answer else answer;
    }

    var bf = eisel_lemire.compute(mantissa, exponent);
    if (many_digits and bf.e >= 0) {
        if (!bf.eql(eisel_lemire.compute(mantissa + 1, exponent))) {
            bf = eisel_lemire.computeError(mantissa, exponent);
        }
    }
    if (bf.e < 0) bf = digit_comp.compute(parsed_number, bf);

    if (bf.e == common.inf_exp) return error.NumberOutOfRange;

    return bf.toFloat(parsed_number.negative);
}

const power_of_ten: [23]f64 = brk: {
    var res: [23]f64 = undefined;
    for (&res, 0..) |*r, i| {
        r.* = std.math.pow(f64, 10, i);
    }
    break :brk res;
};
