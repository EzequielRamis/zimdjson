const std = @import("std");
const common = @import("../../common.zig");
const number = @import("common.zig");
const types = @import("../../types.zig");
const tokens = @import("../../tokens.zig");
const TokenOptions = tokens.Options;
const TokenIterator = tokens.Iterator;
const TokenPhase = tokens.Phase;
const ParseError = types.ParseError;
const max_digits = number.max_digits;

const FromStringOptions = struct {
    can_be_float: bool = true,
    can_be_signed: bool = true,
};

pub fn FromString(comptime sopt: FromStringOptions) type {
    return struct {
        integer: []const u8,
        decimal: []const u8,
        mantissa: u64,
        exponent: i64,
        negative: bool,
        is_float: bool,

        pub fn parse(
            comptime topt: TokenOptions,
            comptime phase: TokenPhase,
            src: *TokenIterator(topt),
        ) ParseError!FromString(sopt) {
            const is_negative = src.ptr[0] == '-';
            if (is_negative and !sopt.can_be_signed) return error.InvalidNumber;

            _ = src.consume(@intFromBool(is_negative), phase);
            const start_integers = src.ptr;
            const first_digit = src.ptr[0];

            var mantissa_10: u64 = 0;
            var exponent_10: i64 = 0;
            var integer_count: usize = 0;
            var decimal_count: usize = 0;
            var is_float = false;

            var integer_slice: []const u8 = src.ptr[0..0];
            var decimal_slice: []const u8 = src.ptr[0..0];

            if (first_digit != '0') {
                while (parseDigit(topt, src)) |d| {
                    mantissa_10 = mantissa_10 * 10 + d;
                    _ = src.consume(1, phase);
                    if (phase == .bounded) integer_count += 1;
                }
                if (phase != .bounded) integer_count = @intFromPtr(src.ptr) - @intFromPtr(start_integers);
                if (integer_count == 0) return error.InvalidNumber;
                integer_slice.ptr = start_integers;
                integer_slice.len = integer_count;

                if (src.ptr[0] == '.') {
                    _ = src.consume(1, phase);
                    const start_decimals = src.ptr;
                    const parsed_decimal_count = parseDecimal(topt, phase, src, &mantissa_10);
                    decimal_count = if (phase == .bounded)
                        decimal_count + parsed_decimal_count
                    else
                        @intFromPtr(src.ptr) - @intFromPtr(start_decimals);

                    if (decimal_count == 0) return error.InvalidNumber;
                    is_float = true;
                    decimal_slice.ptr = start_decimals;
                    decimal_slice.len = decimal_count;
                    exponent_10 -= @intCast(decimal_slice.len);
                }
            } else if (sopt.can_be_float and src.ptr[1] == '.') {
                _ = src.consume(2, phase);
                const start_decimals = src.ptr;
                const parsed_decimal_count = parseDecimal(topt, phase, src, &mantissa_10);
                decimal_count = if (phase == .bounded)
                    decimal_count + parsed_decimal_count
                else
                    @intFromPtr(src.ptr) - @intFromPtr(start_decimals);

                if (decimal_count == 0) return error.InvalidNumber;
                is_float = true;
                decimal_slice.ptr = start_decimals;
                decimal_slice.len = decimal_count;
                if (decimal_count >= max_digits) {
                    for (decimal_slice) |d| {
                        if (d != '0') break;
                        decimal_slice = decimal_slice[1..];
                    }
                }
                exponent_10 -= @intCast(decimal_slice.len);
            } else _ = src.consume(1, phase);

            if (sopt.can_be_float and src.ptr[0] | 0x20 == 'e') {
                is_float = true;
                _ = src.consume(1, phase);
                try parseExponent(topt, phase, src, &exponent_10);
            }

            if (common.Tables.is_structural_or_whitespace_negated[src.ptr[0]]) return error.InvalidNumber;

            return .{
                .mantissa = mantissa_10,
                .exponent = exponent_10,
                .integer = integer_slice,
                .decimal = decimal_slice,
                .is_float = is_float,
                .negative = is_negative,
            };
        }

        fn parseDigit(comptime topt: TokenOptions, src: *TokenIterator(topt)) ?u8 {
            const digit = src.ptr[0] -% '0';
            return if (digit < 10) digit else null;
        }

        fn parseDecimal(
            comptime topt: TokenOptions,
            comptime phase: TokenPhase,
            src: *TokenIterator(topt),
            man: *u64,
        ) usize {
            var count: usize = 0;
            while (number.isEightDigits(src.ptr[0..8])) {
                man.* = man.* * 100000000 + number.parseEightDigits(src.ptr[0..8]);
                _ = src.consume(8, phase);
                count += 8;
            }

            while (parseDigit(topt, src)) |d| {
                man.* = man.* * 10 + d;
                _ = src.consume(1, phase);
                count += 1;
            }
            return count;
        }

        fn parseExponent(
            comptime topt: TokenOptions,
            comptime phase: TokenPhase,
            src: *TokenIterator(topt),
            exp: *i64,
        ) ParseError!void {
            const is_negative = src.ptr[0] == '-';
            _ = src.consume(@intFromBool(is_negative or src.ptr[0] == '+'), phase);

            const start_exp = @intFromPtr(src.ptr);

            var exp_number: u64 = 0;
            while (parseDigit(topt, src)) |d| {
                if (exp_number < 0x10000000) {
                    exp_number = exp_number * 10 + d;
                }
                _ = src.consume(1, phase);
            }

            if (start_exp == @intFromPtr(src.ptr)) return error.InvalidNumber;

            var exp_signed: i64 = @intCast(exp_number);
            if (is_negative) exp_signed = -exp_signed;
            exp.* += exp_signed;
        }
    };
}
