const std = @import("std");
const shared = @import("../shared.zig");
const math = std.math;
const vector = shared.vector;
const vector_size = shared.vector_size;
const mask = shared.mask;
const TapeError = shared.TapeError;

const Result = union(enum) {
    signed: i64,
    unsigned: u64,
    float: f64,
};

pub fn number(input: []const u8) !Result {
    const is_negative = @intFromBool(input[0] == '-');
    if (input.len < is_negative) {
        return TapeError.InvalidNumber;
    }
    var i: usize = is_negative;
    while (input.len > i and input[i] -% '0' <= 9) {
        i += 1;
    }
    if (input.len > i and input[i] == '.') {
        i += 1;
    }
    while (input.len > i and input[i] -% '0' <= 9) {
        i += 1;
    }
    if (input.len > i and input[i] | 0x20 == 'e') {
        i += 1;
    }
    while (input.len > i and input[i] -% '0' <= 9) {
        i += 1;
    }
    if (input.len > i and shared.Tables.is_structural_or_whitespace_negated[input[i]]) {
        return TapeError.InvalidNumber;
    }
    const number_slice = input[0..i];
    const literal = std.zig.parseNumberLiteral(number_slice);
    switch (literal) {
        .int => {
            if (is_negative == 1) {
                return Result{ .signed = try std.fmt.parseInt(i64, number_slice, 10) };
            } else {
                return Result{ .unsigned = try std.fmt.parseUnsigned(u64, number_slice, 10) };
            }
        },
        .float => return Result{ .float = try std.fmt.parseFloat(f64, number_slice) },
        .big_int => return Result{ .float = try std.fmt.parseFloat(f64, number_slice) },
        .failure => return TapeError.InvalidNumber,
    }
}

// pub fn number(input: []const u8) !NumberResult {
//     const is_negative = @intFromBool(input[0] == '-');
//     if (input.len < is_negative) {
//         return TapeError.InvalidNumber;
//     }
//     var p: u64 = 0;
//     var i: usize = 0;
//     const int_iter = input[is_negative..];
//     const first_digit = int_iter[i];
//     while (shared.Tables.digit_map[int_iter[i]]) |d| : (i += 1) {
//         p = p *| 10 +| d;
//     }
//     const digit_count = i;
//     if (digit_count == 0 or first_digit == '0') {
//         return TapeError.InvalidNumber;
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

// const powers_of_5: [650]u128 = res: {
//     var p: [650]u128 = undefined;
//     var i: usize = 0;

//     for (-342..-27) |q| {
//         const power_5 = 5 ** -q;
//         var z = 0;
//         while (1 << z < power_5) {
//             z += 1;
//         }
//         const b = 2 * z + 2 * 64;
//         const c = @divFloor(2 ** b, power_5 + 1);
//         while (c >= 1 << 128) {
//             c = @divFloor(c, 2);
//         }

//         p[i] = c;
//         i += 1;
//     }

//     for (-27..0) |q| {
//         const power_5 = 5 ** -q;
//         var z = 0;
//         while (1 << z < power_5) {
//             z += 1;
//         }
//         const b = z + 127;
//         const c = @divFloor(2 ** b, power_5 + 1);

//         p[i] = c;
//         i += 1;
//     }

//     for (0..309) |q| {
//         var power_5 = 5 ** q;
//         while (power_5 < 1 << 127) {
//             power_5 *= 2;
//         }
//         while (power_5 >= 1 << 128) {
//             power_5 = @divFloor(power_5, 2);
//         }

//         p[i] = power_5;
//         i += 1;
//     }

//     break :res p;
// };
