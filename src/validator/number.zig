const std = @import("std");
const shared = @import("../shared.zig");
const types = @import("../types.zig");
const math = std.math;
const vector = shared.vector;
const vector_size = shared.vector_size;
const mask = shared.mask;
const ParseError = types.ParseError;
// const parseFloat = @import("./number/parse_float.zig").parseFloat;

const Result = union(enum) {
    signed: i64,
    unsigned: u64,
    float: f64,
};

// pub fn number(src: []const u8) !Result {

//     //
//     // Check for minus sign
//     //
//     const negative: u1 = @intFromBool(src[0] == '-');
//     var p = src[negative..];

//     //
//     // Parse the integer part.
//     //
//     // PERF NOTE: we don't use is_made_of_eight_digits_fast because large integers like 123456789 are rare
//     const start_digits = p;
//     var i: usize = 0;
//     while (parse_digit(p[0], &i)) {
//         p = p[1..];
//     }

//     // If there were no digits, or if the integer starts with 0 and has more than one digit, it's an error.
//     // Optimization note: size_t is expected to be unsigned.
//     const digit_count: u64 = p.ptr - start_digits.ptr;
//     if (digit_count == 0 or ('0' == *start_digits and digit_count > 1)) {
//         return ParseError.InvalidNumber;
//     }

//     //
//     // Handle floats if there is a . or e (or both)
//     //
//     var exponent: i64 = 0;
//     var is_float: bool = false;
//     if ('.' == *p) {
//         is_float = true;
//         p = p[1..];
//         parse_decimal_after_separator(src, p, i, exponent);
//         digit_count = p.len - start_digits; // used later to guard against overflows
//     }
//     if (('e' == *p) || ('E' == *p)) {
//         is_float = true;
//         p = p[1..];
//         parse_exponent(src, p, exponent);
//     }
//     if (is_float) {
//         const dirty_end: bool = shared.Tables.is_structural_or_whitespace_negated[p[0]];
//         write_float(src, negative, i, start_digits, digit_count, exponent, writer);
//         if (dirty_end) {
//             return ParseError.InvalidNumber;
//         }
//         return;
//     }

//     // The longest negative 64-bit number is 19 digits.
//     // The longest positive 64-bit number is 20 digits.
//     // We do it this way so we don't trigger this branch unless we must.
//     const longest_digit_count: usize = if (negative) 19 else 20;
//     if (digit_count > longest_digit_count) {
//         return ParseError.InvalidNumber;
//     }
//     if (digit_count == longest_digit_count) {
//         if (negative) {
//             // Anything negative above INT64_MAX+1 is invalid
//             if (i > uint64_t(INT64_MAX) + 1) {
//                 return ParseError.InvalidNumber;
//             }
//             WRITE_INTEGER(~i + 1, src, writer);
//             if (is_not_structural_or_whitespace(*p)) {
//                 return ParseError.InvalidNumber;
//             }
//             return;
//             // Positive overflow check:
//             // - A 20 digit number starting with 2-9 is overflow, because 18,446,744,073,709,551,615 is the
//             //   biggest uint64_t.
//             // - A 20 digit number starting with 1 is overflow if it is less than INT64_MAX.
//             //   If we got here, it's a 20 digit number starting with the digit "1".
//             // - If a 20 digit number starting with 1 overflowed (i*10+digit), the result will be smaller
//             //   than 1,553,255,926,290,448,384.
//             // - That is smaller than the smallest possible 20-digit number the user could write:
//             //   10,000,000,000,000,000,000.
//             // - Therefore, if the number is positive and lower than that, it's overflow.
//             // - The value we are looking at is less than or equal to INT64_MAX.
//             //
//         } else if (src[0] != uint8_t('1') or i <= uint64_t(INT64_MAX)) {
//             return ParseError.InvalidNumber;
//         }
//     }

//     // Write unsigned if it doesn't fit in a signed integer.
//     if (i > uint64_t(INT64_MAX)) {
//         WRITE_UNSIGNED(i, src, writer);
//     } else {
//         WRITE_INTEGER(if (negative) (~i + 1) else i, src, writer);
//     }
//     if (is_not_structural_or_whitespace(*p)) {
//         return ParseError.InvalidNumber;
//     }
//     return;
// }

// pub fn number(src: []const u8) !f64 {
// const is_negative = @intFromBool(src[0] == '-');
// if (src.len < is_negative) {
//     return ParseError.InvalidNumber;
// }
// var i: usize = is_negative;
// while (src.len > i and src[i] -% '0' <= 9) {
//     i += 1;
// }
// if (src.len > i and src[i] == '.') {
//     i += 1;
// }
// while (src.len > i and src[i] -% '0' <= 9) {
//     i += 1;
// }
// if (src.len > i and src[i] | 0x20 == 'e') {
//     i += 1;
// }
// while (src.len > i and src[i] -% '0' <= 9) {
//     i += 1;
// }
// if (src.len > i and shared.Tables.is_structural_or_whitespace_negated[src[i]]) {
//     return ParseError.InvalidNumber;
// }
// const number_slice = src[0..i];
// const literal = parseNumberLiteral(src);
// switch (literal) {
//     .int => {
//         if (is_negative == 1) {
//             return Result{ .signed = try std.fmt.parseInt(i64, number_slice, 10) };
//         } else {
//             return Result{ .unsigned = try std.fmt.parseUnsigned(u64, number_slice, 10) };
//         }
//     },
//     .float => return Result{ .float = try std.fmt.parseFloat(f64, number_slice) },
//     .big_int => return Result{ .float = try std.fmt.parseFloat(f64, number_slice) },
//     .failure => return ParseError.InvalidNumber,
// }
// return parseFloat(src);
// }

// pub fn number(src: []const u8) !NumberResult {
//     const is_negative = @intFromBool(src[0] == '-');
//     if (src.len < is_negative) {
//         return ParseError.InvalidNumber;
//     }
//     var p: u64 = 0;
//     var i: usize = 0;
//     const int_iter = src[is_negative..];
//     const first_digit = int_iter[i];
//     while (shared.Tables.digit_map[int_iter[i]]) |d| : (i += 1) {
//         p = p *| 10 +| d;
//     }
//     const digit_count = i;
//     if (digit_count == 0 or first_digit == '0') {
//         return ParseError.InvalidNumber;
//     }
//     return NumberResult{ .unsigned = i };
// }

// fn is_made_of_digits(chars: [vector_size]u8) bool {
//     return @as(mask, @bitCast(@as(vector, chars) -% @as(vector, @splat('0')) <= @as(vector, @splat(9)))) != 0;
// }

// fn parse_vector_digits(chars: [vector_size]u8) u64 {
//     const digits = @as(vector, chars) -% @as(vector, @splat('0'));
//     const tricks = @log2(vector_size);
//     inline for (1..tricks + 1) |i| {
//         const multipliers = std.simd.repeat(vector_size, [_]std.meta.Int(std.builtin.Signedness.unsigned, 8 * i){ 1, 10 * i });
//     }
// }

// fn nearest_float(w: u64, q: i64) f64 {
//     if (w == 0 or q < -342) {
//         return 0.0;
//     }
//     if (q > 308) {
//         return math.inf(f64);
//     }
//     const i = @clz(w);
//     const w2 = 2 ** i * w;
//     const z = undefined;
//     _ = w2;
//     var m = z & 0x003f_ffff_ffff_ffff;
//     const u = @divFloor(z, 2 ** 127);
//     const p = @divFloor(217706 * q, 2 ** 16) + 63 - i + u;
//     if (p <= -1022 - 64) {
//         return 0.0;
//     }
//     if (p <= -1022) {
//         const s = -1022 - p + 1;
//         m = @divFloor(m, 2 ** s);
//         m += m & 1;
//         m = @divFloor(m, 2);
//         return m * 2 ** p * 2 ** -52;
//     }
//     if (z % 2 ** 64 <= 1 and m & 1 == 1 and @divFloor(m, 2) & 1 == 0 and -4 <= q and q <= 23 and @divFloor(z, 2 ** 64)) {}
// }

const powers_of_5: [342 + 308]u128 = res: {
    var p: [342 + 308]u128 = undefined;
    var i: usize = 0;

    for (-342..-27) |q| {
        const power_5 = 5 ** -q;
        var z = 0;
        while (1 << z < power_5) {
            z += 1;
        }
        const b = 2 * z + 2 * 64;
        const c = @divFloor(2 ** b, power_5 + 1);
        while (c >= 1 << 128) {
            c = @divFloor(c, 2);
        }

        p[i] = c;
        i += 1;
    }

    for (-27..0) |q| {
        const power_5 = 5 ** -q;
        var z = 0;
        while (1 << z < power_5) {
            z += 1;
        }
        const b = z + 127;
        const c = @divFloor(2 ** b, power_5 + 1);

        p[i] = c;
        i += 1;
    }

    for (0..308 + 1) |q| {
        var power_5 = 5 ** q;
        while (power_5 < 1 << 127) {
            power_5 *= 2;
        }
        while (power_5 >= 1 << 128) {
            power_5 = @divFloor(power_5, 2);
        }

        p[i] = power_5;
        i += 1;
    }

    break :res p;
};

fn parse_digit(c: u8, i: *usize) bool {
    const digit = c - '0';
    if (digit > 9) {
        return false;
    }
    // PERF NOTE: multiplication by 10 is cheaper than arbitrary integer multiplication
    i = 10 *% i +% digit; // might overflow, we will handle the overflow later
    return true;
}

fn parse_decimal_after_separator(_: []const u8, p: *[]const u8, i: *u64, exponent: *i64) !void {
    // we continue with the fiction that we have an integer. If the
    // floating point number is representable as x * 10^z for some integer
    // z that fits in 53 bits, then we will be able to convert back the
    // the integer into a float in a lossless manner.
    const first_after_period = p[0];

    // this helps if we have lots of decimals!
    // this turns out to be frequent enough.
    if (is_made_of_eight_digits_fast(p)) {
        i = i * 100000000 + parse_eight_digits_unrolled(p);
        p += 8;
    }
    // Unrolling the first digit makes a small difference on some implementations (e.g. westmere)
    if (parse_digit(p[0], i)) {
        p.* = p.*[1..];
    }
    while (parse_digit(p[0], i)) {
        p.* = p.*[1..];
    }
    exponent = first_after_period - p[0];
    // Decimal without digits (123.) is illegal
    if (exponent == 0) {
        return ParseError.InvalidNumber;
    }
}

// check quickly whether the next 8 chars are made of digits
// at a glance, it looks better than Mula's
// http://0x80.pl/articles/swar-digits-validate.html
fn is_made_of_eight_digits_fast(chars: []const u8) bool {
    // this can read up to 7 bytes beyond the buffer size, but we require
    // SIMDJSON_PADDING of padding
    const val = @as([]const u64, @ptrCast(chars))[0];
    // a branchy method might be faster:
    // return (( val & 0xF0F0F0F0F0F0F0F0 ) == 0x3030303030303030)
    //  && (( (val + 0x0606060606060606) & 0xF0F0F0F0F0F0F0F0 ) ==
    //  0x3030303030303030);
    return (((val & 0xF0F0F0F0F0F0F0F0) |
        (((val + 0x0606060606060606) & 0xF0F0F0F0F0F0F0F0) >> 4)) ==
        0x3333333333333333);
}

fn parse_eight_digits_unrolled(chars: []const u8) u32 {
    const val = @as([]const u64, @ptrCast(chars))[0];
    val = (val & 0x0F0F0F0F0F0F0F0F) * 2561 >> 8;
    val = (val & 0x00FF00FF00FF00FF) * 6553601 >> 16;
    return (val & 0x0000FFFF0000FFFF) * 42949672960001 >> 32;
}

fn parse_exponent(_: []const u8, p: *[]const u8, exponent: *i64) !void {
    // Exp Sign: -123.456e[-]78
    const neg_exp: bool = '-' == p[0];
    if (neg_exp or '+' == *p) {
        p.* = p.*[1..];
    } // Skip + as well

    // Exponent: -123.456e-[78]
    const start_exp = p;
    var exp_number: i64 = 0;
    while (parse_digit(p[0], &exp_number)) {
        p.* = p.*[1..];
    }
    // It is possible for parse_digit to overflow.
    // In particular, it could overflow to INT64_MIN, and we cannot do - INT64_MIN.
    // Thus we *must* check for possible overflow before we negate exp_number.

    // Performance notes: it may seem like combining the two "simdjson_unlikely checks" below into
    // a single simdjson_unlikely path would be faster. The reasoning is sound, but the compiler may
    // not oblige and may, in fact, generate two distinct paths in any case. It might be
    // possible to do uint64_t(p - start_exp - 1) >= 18 but it could end up trading off
    // instructions for a simdjson_likely branch, an unconclusive gain.

    // If there were no digits, it's an error.
    if (p.ptr == start_exp.ptr) {
        return ParseError.InvalidNumber;
    }
    // We have a valid positive exponent in exp_number at this point, except that
    // it may have overflowed.

    // If there were more than 18 digits, we may have overflowed the integer. We have to do
    // something!!!!
    if (p.ptr > start_exp.ptr + 18) {
        // Skip leading zeroes: 1e000000000000000000001 is technically valid and doesn't overflow
        while (*start_exp == '0') {
            start_exp.* = start_exp.*[1..];
        }
        // 19 digits could overflow int64_t and is kind of absurd anyway. We don't
        // support exponents smaller than -999,999,999,999,999,999 and bigger
        // than 999,999,999,999,999,999.
        // We can truncate.
        // Note that 999999999999999999 is assuredly too large. The maximal ieee64 value before
        // infinity is ~1.8e308. The smallest subnormal is ~5e-324. So, actually, we could
        // truncate at 324.
        // Note that there is no reason to fail per se at this point in time.
        // E.g., 0e999999999999999999999 is a fine number.
        if (p > start_exp + 18) {
            exp_number = 999999999999999999;
        }
    }
    // At this point, we know that exp_number is a sane, positive, signed integer.
    // It is <= 999,999,999,999,999,999. As long as 'exponent' is in
    // [-8223372036854775808, 8223372036854775808], we won't overflow. Because 'exponent'
    // is bounded in magnitude by the size of the JSON input, we are fine in this universe.
    // To sum it up: the next line should never overflow.
    exponent += if (neg_exp) -exp_number else exp_number;
}
