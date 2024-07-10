const std = @import("std");
const common = @import("common.zig");
const types = @import("../../types.zig");
const BigInt = @import("BigInt.zig");
const FromString = @import("from_string.zig").FromString;
const Limb = BigInt.Limb;
const BiasedFp = common.BiasedFp;
const assert = std.debug.assert;

pub fn compute(parsed_number: FromString(.{}), _bf: BiasedFp) BiasedFp {
    @setCold(true);

    const sci_exp = scientificExponent(parsed_number);

    var bigman = BigInt.init();
    const digits = parseBigMantissa(&bigman, parsed_number);

    const exp: i32 = sci_exp + 1 - digits;
    if (exp >= 0) {
        return positiveDigitComp(&bigman, @intCast(exp));
    } else {
        var bf = _bf;
        bf.e -= BiasedFp.invalid_bias;
        return negativeDigitComp(&bigman, exp, bf);
    }
}

fn positiveDigitComp(bigman: *BigInt, exp: u32) BiasedFp {
    assert(if (bigman.pow10(exp)) true else |_| false);

    const high = bigman.high64();

    var answer: BiasedFp = .{
        .m = high.bits,
        .e = bigman.bitsLen() - 64 + BiasedFp.bias,
    };

    round(&answer, positiveRound1, .{ .truncated = high.truncated });

    return answer;
}

fn negativeDigitComp(real_digits: *BigInt, real_exp: i32, bf: BiasedFp) BiasedFp {
    var bf2 = bf;
    round(&bf2, negativeRound1, {});
    const b2 = bf2.toFloat(false);
    const theor = toExtendedHalfway(b2);
    var theor_digits = BigInt.from(theor.m);
    const theor_exp = theor.e;

    const pow2_exp = theor_exp - real_exp;
    const pow5_exp: u32 = @intCast(-real_exp);
    if (pow5_exp != 0) {
        assert(if (theor_digits.pow5(pow5_exp)) true else |_| false);
    }
    if (pow2_exp > 0) {
        assert(if (theor_digits.pow2(@intCast(pow2_exp))) true else |_| false);
    } else if (pow2_exp < 0) {
        assert(if (real_digits.pow2(@intCast(-pow2_exp))) true else |_| false);
    }

    const order = real_digits.order(theor_digits);
    var answer = bf;
    round(&answer, negativeRound2, .{ .order = order });
    return answer;
}

fn toExtendedHalfway(value: f64) BiasedFp {
    var bf = toExtended(value);
    bf.m <<= 1;
    bf.m += 1;
    bf.e -= 1;
    return bf;
}

fn toExtended(value: f64) BiasedFp {
    const mask_exp = 0x7FF0000000000000;
    const mask_man = 0x000FFFFFFFFFFFFF;
    const mask_hid = 0x0010000000000000;

    const bits: u64 = @bitCast(value);

    var bf: BiasedFp = undefined;

    if (bits & mask_exp == 0) {
        bf.e = 1 - BiasedFp.bias;
        bf.m = bits & mask_man;
    } else {
        bf.e = @bitCast(@as(u32, @intCast((bits & mask_exp) >> std.math.floatExponentBits(f64))));
        bf.e -= BiasedFp.bias;
        bf.m = (bits & mask_man) | mask_hid;
    }

    return bf;
}

fn positiveRound1(bf: *BiasedFp, shift: u32, args: anytype) void {
    roundNearestTieEven(bf, shift, positiveRound2, args);
}

fn positiveRound2(is_odd: bool, is_halfway: bool, is_above: bool, args: anytype) bool {
    return is_above or (is_halfway and args.truncated) or (is_odd and is_halfway);
}

fn negativeRound1(bf: *BiasedFp, shift: u32, _: anytype) void {
    roundDown(bf, shift);
}

fn roundDown(bf: *BiasedFp, shift: u32) void {
    if (shift == 64) {
        bf.m = 0;
    } else {
        bf.m >>= @intCast(shift);
    }
    bf.e += @intCast(shift);
}

fn negativeRound2(bf: *BiasedFp, shift: u32, args: anytype) void {
    roundNearestTieEven(bf, shift, negativeRound3, args);
}

fn negativeRound3(is_odd: bool, _: bool, _: bool, args: anytype) bool {
    return switch (args.order) {
        .gt => true,
        .lt => false,
        else => is_odd,
    };
}

fn scientificExponent(parsed_number: FromString(.{})) i32 {
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

fn parseBigMantissa(bigint: *BigInt, number: FromString(.{})) i32 {
    const max_digits = common.max_big_digits + 1;
    const step = common.max_digits - 1;
    var counter: usize = 0;
    var digits: i32 = 0;
    var value: Limb = 0;

    var int_slice = number.integer;
    while (int_slice.len > 0) {
        while (int_slice.len >= 8 and
            step - counter >= 8 and
            max_digits - digits >= 8)
        {
            value = value * 100000000 + common.parseEightDigits(int_slice[0..8]);
            counter += 8;
            digits += 8;
            int_slice = int_slice[8..];
        }

        while (counter < step and
            int_slice.len > 0 and
            digits < max_digits)
        {
            value = value * 10 + (int_slice[0] - '0');
            counter += 1;
            digits += 1;
            int_slice = int_slice[1..];
        }

        addNative(bigint, power_of_ten[counter], value);
        if (digits == max_digits) {
            var truncated = isTruncated(int_slice);
            if (number.decimal.len > 0) {
                truncated = truncated or isTruncated(number.decimal);
            }
            if (truncated) {
                roundUpBigInt(bigint, &digits);
            }
            return digits;
        } else {
            counter = 0;
            value = 0;
        }
    }

    if (number.decimal.len > 0) {
        var dec_slice = number.decimal;
        if (digits == 0) skipZeroes(&dec_slice);
        while (dec_slice.len > 0) {
            while (dec_slice.len >= 8 and
                step - counter >= 8 and
                max_digits - digits >= 8)
            {
                value = value * 100000000 + common.parseEightDigits(dec_slice[0..8]);
                counter += 8;
                digits += 8;
                dec_slice = dec_slice[8..];
            }

            while (counter < step and
                dec_slice.len > 0 and
                digits < max_digits)
            {
                value = value * 10 + (dec_slice[0] - '0');
                counter += 1;
                digits += 1;
                dec_slice = dec_slice[1..];
            }

            addNative(bigint, power_of_ten[counter], value);
            if (digits == max_digits) {
                const truncated = isTruncated(dec_slice);
                if (truncated) {
                    roundUpBigInt(bigint, &digits);
                }
                return digits;
            } else {
                counter = 0;
                value = 0;
            }
        }
    }

    if (counter != 0) addNative(bigint, power_of_ten[counter], value);
    return digits;
}

fn skipZeroes(slice: *[]const u8) void {
    const zer: types.vector = @splat('0');
    const len = types.Vector.LEN_BYTES;
    while (slice.len >= len) {
        const vec: types.vector = @bitCast(slice.*[0..len].*);
        if (!types.Mask.allSet(types.Predicate(.bytes).from(vec == zer).pack())) break;
        slice.* = slice.*[len..];
    }
    while (slice.len > 0) {
        if (slice.*[0] != '0') return;
        slice.* = slice.*[1..];
    }
}

fn isTruncated(src: []const u8) bool {
    var slice = src;
    const zer: types.vector = @splat('0');
    const len = types.Vector.LEN_BYTES;
    while (slice.len >= len) {
        const vec: types.vector = @bitCast(slice[0..len].*);
        if (!types.Mask.allSet(types.Predicate(.bytes).from(vec == zer).pack())) return true;
        slice = slice[len..];
    }
    for (slice) |p| if (p != '0') return true;
    return false;
}

fn roundUpBigInt(bigint: *BigInt, digits: *i32) void {
    addNative(bigint, 10, 1);
    digits.* += 1;
}

fn addNative(bigint: *BigInt, power: Limb, value: Limb) void {
    bigint.mulScalar(power) catch unreachable;
    bigint.addScalar(value) catch unreachable;
}

const power_of_ten: [20]u64 = brk: {
    var res: [20]u64 = undefined;
    for (&res, 0..) |*r, i| {
        r.* = std.math.pow(u64, 10, i);
    }
    break :brk res;
};

const RoundCallback = fn (*BiasedFp, u32, anytype) void;
const NearestCallback = fn (bool, bool, bool, anytype) bool;

fn round(bf: *BiasedFp, callback: RoundCallback, args: anytype) void {
    const mantissa_bits = std.math.floatMantissaBits(f64);
    const mantissa_shift = BigInt.limb_bits - mantissa_bits - 1;
    if (-bf.e >= mantissa_shift) {
        const shift: u32 = @intCast(-bf.e + 1);
        callback(bf, @min(shift, 64), args);
        bf.e = if (bf.m < 1 << mantissa_bits) 0 else 1;
        return;
    }

    callback(bf, mantissa_shift, args);

    if (bf.m >= 2 << mantissa_bits) {
        bf.m = 1 << mantissa_bits;
        bf.e += 1;
    }

    bf.m &= ~(@as(u64, 1) << mantissa_bits);
    if (bf.e >= common.inf_exp) {
        bf.e = common.inf_exp;
        bf.m = 0;
    }
}

fn roundNearestTieEven(bf: *BiasedFp, shift: u32, callback: NearestCallback, args: anytype) void {
    const mask = if (shift == 64) std.math.maxInt(u64) else (@as(u64, 1) << @intCast(shift)) - 1;
    const halfway = if (shift == 0) 0 else @as(u64, 1) << @intCast(shift - 1);
    const truncated_bits = bf.m & mask;
    const is_above = truncated_bits > halfway;
    const is_halfway = truncated_bits == halfway;

    roundDown(bf, shift);

    const is_odd = (bf.m & 1) == 1;
    bf.m += @intFromBool(callback(is_odd, is_halfway, is_above, args));
}
