const std = @import("std");
const common = @import("../../common.zig");
const number = @import("common.zig");
const types = @import("../../types.zig");
const tokens = @import("../../tokens.zig");
const TokenOptions = tokens.Options;
const TokenIterator = tokens.Iterator;
const TokenPhase = tokens.Phase;
const Error = types.Error;
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
        ) Error!FromString(sopt) {
            const is_negative = src.ptr[0] == '-';
            if (is_negative and !sopt.can_be_signed) return error.NumberLiteral;

            _ = src.consume(@intFromBool(is_negative), phase);
            const first_digit = src.ptr[0];

            var mantissa_10: u64 = 0;
            var exponent_10: i64 = 0;
            var is_float = false;

            var integer_ptr: [*]const u8 = src.ptr;
            var decimal_ptr: [*]const u8 = src.ptr;
            var integer_len: usize = 0;
            var decimal_len: usize = 0;

            while (parseDigit(topt, src)) |d| {
                mantissa_10 = mantissa_10 *% 10 +% d;
                _ = src.consume(1, phase);
                if (phase == .bounded) integer_len += 1;
            }
            if (phase != .bounded) integer_len = @intFromPtr(src.ptr) - @intFromPtr(integer_ptr);
            if ((first_digit == '0' and integer_len > 1) or integer_len == 0) return error.NumberLiteral;

            if (sopt.can_be_float) {
                if (src.ptr[0] == '.') {
                    _ = src.consume(1, phase);
                    decimal_ptr = src.ptr;
                    const parsed_decimal_len = parseDecimal(topt, phase, src, &mantissa_10);
                    decimal_len = if (phase == .bounded)
                        decimal_len + parsed_decimal_len
                    else
                        @intFromPtr(src.ptr) - @intFromPtr(decimal_ptr);

                    if (decimal_len == 0) return error.NumberLiteral;
                    is_float = true;
                    exponent_10 -= @intCast(decimal_len);
                }

                if (src.ptr[0] | 0x20 == 'e') {
                    is_float = true;
                    _ = src.consume(1, phase);
                    try parseExponent(topt, phase, src, &exponent_10);
                }
            }

            if (common.Tables.is_structural_or_whitespace_negated[src.ptr[0]]) return error.NumberLiteral;

            return .{
                .mantissa = mantissa_10,
                .exponent = exponent_10,
                .integer = integer_ptr[0..integer_len],
                .decimal = decimal_ptr[0..decimal_len],
                .negative = is_negative,
                .is_float = is_float,
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
            var len: usize = 0;
            while (number.isEightDigits(src.ptr[0..8])) {
                man.* = man.* *% 100000000 +% number.parseEightDigits(src.ptr[0..8]);
                _ = src.consume(8, phase);
                len += 8;
            }

            while (parseDigit(topt, src)) |d| {
                man.* = man.* *% 10 +% d;
                _ = src.consume(1, phase);
                len += 1;
            }
            return len;
        }

        fn parseExponent(
            comptime topt: TokenOptions,
            comptime phase: TokenPhase,
            src: *TokenIterator(topt),
            exp: *i64,
        ) Error!void {
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

            if (start_exp == @intFromPtr(src.ptr)) return error.NumberLiteral;

            var exp_signed: i64 = @intCast(exp_number);
            if (is_negative) exp_signed = -exp_signed;
            exp.* += exp_signed;
        }
    };
}
