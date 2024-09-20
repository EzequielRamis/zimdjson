const std = @import("std");
const common = @import("../../common.zig");
const number = @import("common.zig");
const types = @import("../../types.zig");
const tokens = @import("../../tokens.zig");
const TokenOptions = tokens.Options;
const TokenIterator = tokens.Iterator;
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

        pub inline fn parse(src: [*]const u8) Error!FromString(sopt) {
            var ptr = src;
            const is_negative = ptr[0] == '-';
            if (is_negative and !sopt.can_be_signed) {
                return error.InvalidNumberLiteral;
            }

            ptr += @intFromBool(is_negative);
            const first_digit = ptr[0];

            var mantissa_10: u64 = 0;
            var exponent_10: i64 = 0;
            var is_float = false;

            var integer_ptr: [*]const u8 = ptr;
            var decimal_ptr: [*]const u8 = ptr;
            var integer_len: u32 = 0;
            var decimal_len: u32 = 0;

            while (parseDigit(ptr)) |d| {
                mantissa_10 = mantissa_10 *% 10 +% d;
                ptr += 1;
            }
            integer_len = @intCast(@intFromPtr(ptr) - @intFromPtr(integer_ptr));
            if ((first_digit == '0' and integer_len > 1) or integer_len == 0) {
                return error.InvalidNumberLiteral;
            }

            if (sopt.can_be_float) {
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
            }

            if (common.tables.is_structural_or_whitespace_negated[ptr[0]]) {
                return error.InvalidNumberLiteral;
            }

            return .{
                .mantissa = mantissa_10,
                .exponent = exponent_10,
                .integer = integer_ptr[0..integer_len],
                .decimal = decimal_ptr[0..decimal_len],
                .negative = is_negative,
                .is_float = is_float,
            };
        }

        inline fn parseDigit(ptr: [*]const u8) ?u8 {
            const digit = ptr[0] -% '0';
            return if (digit < 10) digit else null;
        }

        inline fn parseDecimal(ptr: *[*]const u8, man: *u64) void {
            while (number.isEightDigits(ptr.*[0..8].*)) {
                man.* = man.* *% 100000000 +% number.parseEightDigits(ptr.*[0..8].*);
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
    };
}
