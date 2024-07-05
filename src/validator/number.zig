const std = @import("std");
const builtin = @import("builtin");
const common = @import("../common.zig");
const types = @import("../types.zig");
const intr = @import("../intrinsics.zig");
const tokens = @import("../tokens.zig");
const debug = @import("../debug.zig");
const BigInt = @import("../BigInt.zig");
const TokenOptions = tokens.Options;
const TokenIterator = tokens.Iterator;
const TokenPhase = tokens.Phase;
const ArrayList = std.ArrayList;
const ParseError = types.ParseError;
const cpu = builtin.cpu;
const intFromSlice = common.intFromSlice;
const assert = std.debug.assert;

const Number = union(enum) {
    unsigned: u64,
    signed: i64,
    float: f64,
};

const NumberParsingOptions = struct {
    can_be_float: bool = true,
    can_be_signed: bool = true,
};

pub fn Parser(comptime opt: TokenOptions) type {
    return struct {
        pub fn parse(comptime phase: TokenPhase, src: *TokenIterator(opt)) ParseError!Number {
            const parsed_number = try ParsedNumberString(.{}).parse(opt, phase, src);
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
            const parsed_number = try ParsedNumberString(.{ .can_be_float = false }).parse(opt, phase, src);

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
            const parsed_number = try ParsedNumberString(.{
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
            const parsed_number = try ParsedNumberString(.{}).parse(opt, phase, src);
            return computeFloat(parsed_number);
        }
    };
}

fn ParsedNumberString(comptime nopt: NumberParsingOptions) type {
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
        ) ParseError!ParsedNumberString(nopt) {
            const is_negative = src.ptr[0] == '-';
            if (is_negative and !nopt.can_be_signed) return error.InvalidNumber;

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
            } else if (nopt.can_be_float and src.ptr[1] == '.') {
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

            if (nopt.can_be_float and src.ptr[0] | 0x20 == 'e') {
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

fn computeFloat(parsed_number: ParsedNumberString(.{})) f64 {
    @setFloatMode(.strict);

    const mantissa = parsed_number.mantissa;
    const exponent = parsed_number.exponent;
    const negative = parsed_number.negative;

    const digits_count = parsed_number.integer.len + parsed_number.decimal.len;

    if (digits_count <= 19) if (computeClinger(mantissa, exponent, negative)) |f| return f;

    if (computeEiselLemire(mantissa, exponent, negative)) |f| {
        if (digits_count <= 19) return f;
        if (computeEiselLemire(mantissa + 1, exponent, negative)) |f2| {
            if (f == f2) return f;
        }
    }

    return computeBigInt(parsed_number);
}

fn computeClinger(mantissa: u64, exponent: i64, negative: bool) ?f64 {
    const min_exponent = -22;
    const max_exponent = 22;
    const max_mantissa = 2 << std.math.floatMantissaBits(f64);

    if (mantissa <= max_mantissa and
        min_exponent <= exponent and
        exponent <= max_exponent)
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

const U128 = struct {
    low: u64,
    high: u64,

    pub fn from(n: u128) U128 {
        const ptr = @as([2]u64, @ptrCast(&n));
        return .{ .low = ptr[0], .high = ptr[1] };
    }

    pub fn mul(a: u64, b: u64) U128 {
        const r: u128 = @as(u128, a) * b;
        return U128.from(r);
    }
};

fn productApproximation(comptime precision: comptime_int, w: u64, q: i64) U128 {
    comptime assert(precision > 0 and precision <= 64);
    const index = 2 * (q + 342);
    var first_product = U128.mul(w, power_of_five_u64[index]);
    const precision_mask: u64 = if (precision < 64)
        @as(u64, 0xFFFFFFFFFFFFFFFF) >> precision
    else
        0xFFFFFFFFFFFFFFFF;
    if (first_product.high & precision_mask == precision_mask) {
        const second_product = U128.mul(w, power_of_five_u64[index + 1]);
        first_product.low += second_product.high;
        if (second_product.high > first_product.low) {
            first_product.high += 1;
        }
    }
    return first_product;
}

fn computeEiselLemire(mantissa: u64, exponent: i64, negative: bool) ?f64 {
    if (mantissa == 0 or exponent < -342) return if (negative) -0.0 else 0.0;
    if (exponent > 308) return null;
    const lz: u64 = @clz(mantissa);
    const w = @as(u64, 1 << lz) * mantissa;
    const z = (power_of_five_u128[exponent] * w) / (1 << 64);
    var m: u54 = @truncate(z);
    const u = z / (2 << 127);
    const p = ((217706 * exponent) / (1 << 16)) + 63 - lz + u;
    if (p <= -1022 - 64) return if (negative) -0.0 else 0.0;
    if (p <= -1022) {
        const s = -1022 - p + 1;
        m = m / (1 << s);
        if (m % 2 == 1) m += 1;
        m /= 2;
        const answer = @as(f64, @floatFromInt(m * (1 << p))) * std.math.pow(f64, 2, -52);
        return if (negative) -answer else answer;
    }
    if (z % (1 << 64) <= 1 and
        m % 2 == 1 and
        (m / 2) % 2 == 0 and
        -4 <= exponent and
        exponent <= 23)
    {
        // round to even
    }
    if (m % 2 == 1) m += 1;
    m /= 2;
    if (m == (1 << 53)) {
        m /= 2;
        p += 1;
    }
    if (p > 1023) return null;
    const answer = @as(f64, @floatFromInt(m * (1 << p))) * std.math.pow(f64, 2, -52);
    return if (negative) -answer else answer;
}

// https://github.com/Alexhuszagh/rust-lexical/blob/main/lexical-parse-float/docs/Algorithm.md
// https://github.com/fastfloat/fast_float/pull/96
fn computeBigInt(parsed_number: ParsedNumberString(.{})) f64 {
    @setCold(true);

    const sci_exp = scientificExponent(parsed_number);

    const limbs_len = std.math.log2_int_ceil(usize, std.math.pow(comptime_int, 10, 0x300 + 342)) / @typeInfo(BigLimb).Int.bits;
    var buffer: [limbs_len]BigLimb = undefined;
    const bigint = Mutable.init(&buffer, 0);

    const digits = setBigIntMantissa(bigint, parsed_number);

    const exp: i32 = sci_exp +% 1 -% digits;
    if (exp >= 0) {} else {}
}

fn scientificExponent(parsed_number: ParsedNumberString(.{})) i32 {
    var man = parsed_number.mantissa;
    var exp: i32 = @truncate(parsed_number.exponent);
    while (man >= 10000) {
        man /= 10000;
        exp += 4;
    }
    while (man >= 100) {
        man /= 100;
        exp += 2;
    }
    while (man >= 10) {
        man /= 10;
        exp += 1;
    }
    return exp;
}

fn parseBigMantissa(bigint: *BigInt, number: ParsedNumberString(.{})) void {
    const max_digits = 0x300 + 1;
    const step = 19;
    var counter: usize = 0;
    var digits: i32 = 0;
    var value: BigInt.Limb = 0;

    for (number.integer) |p| {}
}

const power_of_ten: [23]f64 = brk: {
    var res: [23]f64 = undefined;
    for (&res, 0..) |*r, i| {
        r.* = std.math.pow(f64, 10, i);
    }
    break :brk res;
};

// "Number Parsing at a Gigabyte per Second", Figure 5 (https://arxiv.org/pdf/2101.11408#figure.caption.21)
const power_of_five_u128: [342 + 309]u128 = brk: {
    @setEvalBranchQuota(1000000);
    var res1: [315]u128 = undefined;
    for (&res1, 0..) |*r, _q| {
        const q = -342 + @as(comptime_int, _q);
        const power5 = std.math.pow(u2048, 5, -q);
        var z = 0;
        while (1 << z < power5) z += 1;
        const b = 2 * z + 2 * 64;
        var c = std.math.pow(u2048, 2, b) / power5 + 1;
        while (c >= 1 << 128) c /= 2;
        r.* = c;
    }
    var res2: [27]u128 = undefined;
    for (&res2, 0..) |*r, _q| {
        const q = -27 + @as(comptime_int, _q);
        const power5 = std.math.pow(u2048, 5, -q);
        var z = 0;
        while (1 << z < power5) z += 1;
        const b = z + 127;
        const c = std.math.pow(u2048, 2, b) / power5 + 1;
        r.* = c;
    }
    var res3: [309]u128 = undefined;
    for (&res3, 0..) |*r, q| {
        var power5 = std.math.pow(u2048, 5, q);
        while (power5 < 1 << 127) power5 *= 2;
        while (power5 >= 1 << 128) power5 /= 2;
        r.* = power5;
    }
    break :brk res1 ++ res2 ++ res3;
};

const power_of_five_u64: *const [power_of_five_u128.len * 2]u64 = @ptrCast(&power_of_five_u128);
