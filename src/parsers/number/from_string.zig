const std = @import("std");
const builtin = @import("builtin");
const common = @import("../common.zig");
const types = @import("../../types.zig");
const intr = @import("../intrinsics.zig");
const tokens = @import("../../tokens.zig");
const TokenOptions = tokens.Options;
const TokenIterator = tokens.Iterator;
const TokenPhase = tokens.Phase;
const ParseError = types.ParseError;
const cpu = builtin.cpu;
const intFromSlice = common.intFromSlice;

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
                    mantissa_10 = mantissa_10 *% 10 +% d;
                    _ = src.consume(1, phase);
                    if (phase == .bounded) integer_count += 1;
                }
                if (phase != .bounded) integer_count = @intFromPtr(src.ptr) - @intFromPtr(start_integers);
                if (integer_count == 0) return error.InvalidNumber;
                integer_slice = start_integers[0..decimal_count];

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
                    decimal_slice = start_decimals[0..decimal_count];
                    exponent_10 -%= @intCast(decimal_slice.len);
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
                decimal_slice = start_decimals[0..decimal_count];
                if (decimal_count > 19) {
                    for (decimal_slice) |d| {
                        if (d != '0') break;
                        decimal_slice = decimal_slice[1..];
                    }
                }
                exponent_10 -%= @intCast(decimal_slice.len);
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
            const digit = src.ptr[0] - '0';
            return if (digit < 10) digit else null;
        }

        fn parseDecimal(
            comptime topt: TokenOptions,
            comptime phase: TokenPhase,
            src: *TokenIterator(topt),
            man: *u64,
        ) usize {
            var count = 0;
            while (isMadeOfEightDigits(src)) {
                man.* = man.* *% 100000000 +% parseEightDigits(src);
                _ = src.consume(8, phase);
                count += 8;
            }

            while (parseDigit(src)) |d| {
                man.* = man.* *% 10 +% d;
                _ = src.consume(1, phase);
                count += 1;
            }
            return count;
        }

        fn isMadeOfEightDigits(comptime topt: TokenOptions, src: *TokenIterator(topt)) bool {
            const val = intFromSlice(u64, src.ptr[0..8]);
            return (((val & 0xF0F0F0F0F0F0F0F0) |
                (((val + 0x0606060606060606) & 0xF0F0F0F0F0F0F0F0) >> 4)) ==
                0x3333333333333333);
        }

        fn parseEightDigits(comptime topt: TokenOptions, src: *TokenIterator(topt)) u32 {
            if (cpu.arch.isX86()) {
                const ascii0: @Vector(16, u8) = @splat('0');
                const mul_1_10 = std.simd.repeat(16, [_]u8{ 10, 1 });
                const mul_1_100 = std.simd.repeat(8, [_]u16{ 100, 1 });
                const mul_1_10000 = std.simd.repeat(8, [_]u16{ 10000, 1 });
                const input = @as(@Vector(16, u8), src.ptr[0..16]) - ascii0;
                const t1 = intr.mulSaturatingAdd(input, mul_1_10);
                const t2 = intr.mulWrappingAdd(t1, mul_1_100);
                const t3 = intr.pack(t2, t2);
                const t4 = intr.mulWrappingAdd(t3, mul_1_10000);
                return t4[0];
            } else {
                // https://johnnylee-sde.github.io/Fast-numeric-string-to-int
                var sum = intFromSlice(u64, src.ptr[0..8]);
                sum = (sum & 0x0F0F0F0F0F0F0F0F) * 2561 >> 8;
                sum = (sum & 0x00FF00FF00FF00FF) * 6553601 >> 16;
                sum = (sum & 0x0000FFFF0000FFFF) * 42949672960001 >> 32;
                return @intCast(sum);
            }
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
            while (parseDigit(src)) |d| {
                if (exp_number < 0x10000000) {
                    exp_number = exp_number *% 10 +% d;
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
