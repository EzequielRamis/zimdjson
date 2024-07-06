const std = @import("std");
const types = @import("../../types.zig");
const tokens = @import("../../tokens.zig");
const clinger = @import("clinger.zig");
const eisel_lemire = @import("eisel_lemire.zig");
const digit_comp = @import("digit_comp.zig");
const FromString = @import("from_string.zig").FromString;
const TokenOptions = tokens.Options;
const TokenIterator = tokens.Iterator;
const TokenPhase = tokens.Phase;
const ParseError = types.ParseError;

const Number = union(enum) {
    unsigned: u64,
    signed: i64,
    float: f64,
};

pub fn Parser(comptime opt: TokenOptions) type {
    return struct {
        pub fn parse(comptime phase: TokenPhase, src: *TokenIterator(opt)) ParseError!Number {
            const parsed_number = try FromString(.{}).parse(opt, phase, src);
            if (parsed_number.is_float) return .{
                .float = computeFloat(parsed_number),
            };

            const digit_count = parsed_number.integer.len;
            const negative = parsed_number.negative;
            const integer = parsed_number.mantissa;
            const longest_digit_count = if (negative) 19 else 20;
            if (digit_count < longest_digit_count) {
                if (std.math.cast(i64, integer)) |i| {
                    return .{ .signed = if (negative) -i else i };
                }
                return .{ .unsigned = integer };
            }
            if (digit_count == longest_digit_count) {
                if (negative) {
                    return .{ .signed = -std.math.cast(i64, integer) orelse return error.InvalidNumber };
                }
                if (parsed_number.integer[0] != '1' or integer <= std.math.maxInt(i64)) return error.InvalidNumber;
                return .{ .unsigned = integer };
            }
            return error.InvalidNumber;
        }

        pub fn parseSigned(comptime phase: TokenPhase, src: *TokenIterator(opt)) ParseError!i64 {
            const parsed_number = try FromString(.{ .can_be_float = false }).parse(opt, phase, src);

            const digit_count = parsed_number.integer.len;
            const negative = parsed_number.negative;
            const integer = parsed_number.mantissa;

            const longest_digit_count = 19;
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

            const longest_digit_count = 20;
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

fn computeFloat(parsed_number: FromString(.{})) f64 {
    @setFloatMode(.strict);

    const mantissa = parsed_number.mantissa;
    const exponent = parsed_number.exponent;
    const negative = parsed_number.negative;

    const digits_count = parsed_number.integer.len + parsed_number.decimal.len;

    if (digits_count <= 19) if (clinger.compute(mantissa, exponent, negative)) |f| return f;

    if (eisel_lemire.compute(mantissa, exponent, negative)) |f| {
        if (digits_count <= 19) return f;
        if (eisel_lemire.compute(mantissa + 1, exponent, negative)) |f2| {
            if (f == f2) return f;
        }
    }

    return digit_comp.compute(parsed_number);
}
