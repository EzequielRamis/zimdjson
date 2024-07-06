const std = @import("std");
const FromString = @import("from_string.zig").FromString;
const BigInt = @import("BigInt.zig");

pub fn compute(parsed_number: FromString(.{})) f64 {
    @setCold(true);

    const sci_exp = scientificExponent(parsed_number);

    const bigint = BigInt.init();

    const digits = setBigIntMantissa(bigint, parsed_number);

    const exp: i32 = sci_exp +% 1 -% digits;
    if (exp >= 0) {} else {}
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

fn parseBigMantissa(bigint: *BigInt, number: FromString(.{})) void {
    const max_digits = 0x300 + 1;
    const step = 19;
    var counter: usize = 0;
    var digits: i32 = 0;
    var value: BigInt.Limb = 0;

    for (number.integer) |p| {}
}
