const std = @import("std");
const common = @import("common.zig");
const types = @import("types.zig");
const intr = @import("intrinsics.zig");
const Reader = @import("Reader.zig");
const ArrayList = std.ArrayList;
const simd = std.simd;
const vector = types.vector;
const Vector = types.Vector;
const umask = types.umask;
const imask = types.imask;
const Mask = types.Mask;
const Pred = types.Predicate;

const ParseError = types.ParseError;

pub const Validator = struct {
    reader: Reader,
    checker: Checker,

    pub fn init() Validator {
        return .{
            .reader = Reader.init(),
            .checker = Checker.init(),
        };
    }

    pub fn validate(self: *Validator, document: []const u8) ParseError!void {
        self.reader.read(document);
        var i = self.reader.index;
        while (self.reader.next()) |block| : (i = self.reader.index) {
            switch (Reader.MASKS_PER_ITER) {
                1 => {
                    try self.checker.check(block);
                },
                2 => {
                    const chunk1 = block[0..Mask.LEN_BITS];
                    const chunk2 = block[Mask.LEN_BITS..][0..Mask.LEN_BITS];
                    try self.checker.check(chunk1);
                    try self.checker.check(chunk2);
                },
                else => unreachable,
            }
        }
        if (self.reader.last()) |block| {
            switch (Reader.MASKS_PER_ITER) {
                1 => {
                    try self.checker.check(block);
                },
                2 => {
                    const chunk1 = block[0..Mask.LEN_BITS];
                    const chunk2 = block[Mask.LEN_BITS..][0..Mask.LEN_BITS];
                    try self.checker.check(chunk1);
                    try self.checker.check(chunk2);
                },
                else => unreachable,
            }
        }
        if (!self.checker.succeeded()) return error.InvalidEncoding;
    }
};

pub const Checker = struct {
    err: vector = @splat(0),
    prev_vec: vector = @splat(0),
    prev_incomplete: vector = @splat(0),

    pub fn init() Checker {
        return Checker{};
    }

    pub fn succeeded(self: Checker) bool {
        const err = self.err | self.prev_incomplete;
        return simd.prefixScan(.Or, 1, err)[Vector.LEN_BYTES - 1] == 0;
    }

    pub fn check(self: *Checker, block: *const [Mask.LEN_BITS]u8) void {
        if (isASCII(block)) {
            self.err |= self.prev_incomplete;
        } else {
            inline for (0..Mask.COMPUTED_VECTORS) |i| {
                const offset = i * Vector.LEN_BYTES;
                const vec = Vector.fromPtr(block[offset..][0..Vector.LEN_BYTES]).to(.bytes);
                self.checkUTF8Bytes(vec);
            }
        }
        const last_vec = Vector.fromPtr(block[(Mask.COMPUTED_VECTORS - 1) * Vector.LEN_BYTES ..][0..Vector.LEN_BYTES]).to(.bytes);
        self.prev_incomplete = isIncomplete(last_vec);
        self.prev_vec = last_vec;
    }

    fn isASCII(block: *const [Mask.LEN_BITS]u8) bool {
        var reduced: vector = @splat(0);
        inline for (0..Mask.COMPUTED_VECTORS) |i| {
            const offset = i * Vector.LEN_BYTES;
            const vec = Vector.fromPtr(block[offset..][0..Vector.LEN_BYTES]).to(.bytes);
            reduced |= vec;
        }
        return simd.prefixScan(.Or, 1, reduced)[Vector.LEN_BYTES - 1] < 0x80;
    }

    fn isIncomplete(vec: vector) vector {
        var max: vector = @splat(255);
        max[Vector.LEN_BYTES - 1] = 0b11000000 - 1;
        max[Vector.LEN_BYTES - 2] = 0b11100000 - 1;
        max[Vector.LEN_BYTES - 3] = 0b11110000 - 1;
        return Pred(.bytes).from(vec > max).unpack();
    }

    fn checkUTF8Bytes(self: *Checker, vec: vector) void {
        const shift1_mask = simd.iota(i32, Vector.LEN_BYTES) - @as(@Vector(Vector.LEN_BYTES, i32), @splat(1));
        const shift2_mask = simd.iota(i32, Vector.LEN_BYTES) - @as(@Vector(Vector.LEN_BYTES, i32), @splat(2));
        const shift3_mask = simd.iota(i32, Vector.LEN_BYTES) - @as(@Vector(Vector.LEN_BYTES, i32), @splat(3));
        const prev1 = @shuffle(u8, vec, self.prev_vec, shift1_mask);

        // zig fmt: off
        // Bit 0 = Too Short (lead byte/ASCII followed by lead byte/ASCII)
        // Bit 1 = Too Long (ASCII followed by continuation)
        // Bit 2 = Overlong 3-byte
        // Bit 4 = Surrogate
        // Bit 5 = Overlong 2-byte
        // Bit 7 = Two Continuations
        const TOO_SHORT      :u8 = 1 << 0; // 11______ 0_______
                                           // 11______ 11______
        const TOO_LONG       :u8 = 1 << 1; // 0_______ 10______
        const OVERLONG_3     :u8 = 1 << 2; // 11100000 100_____
        const SURROGATE      :u8 = 1 << 4; // 11101101 101_____
        const OVERLONG_2     :u8 = 1 << 5; // 1100000_ 10______
        const TWO_CONTS      :u8 = 1 << 7; // 10______ 10______
        const TOO_LARGE      :u8 = 1 << 3; // 11110100 1001____
                                           // 11110100 101_____
                                           // 11110101 1001____
                                           // 11110101 101_____
                                           // 1111011_ 1001____
                                           // 1111011_ 101_____
                                           // 11111___ 1001____
                                           // 11111___ 101_____
        const TOO_LARGE_1000 :u8 = 1 << 6;
                                           // 11110101 1000____
                                           // 1111011_ 1000____
                                           // 11111___ 1000____
        const OVERLONG_4     :u8 = 1 << 6; // 11110000 1000____

        const byte_1_high = intr.lookupTable(simd.repeat(Vector.LEN_BYTES, [_]u8{
            // 0_______ ________ <ASCII in byte 1>
            TOO_LONG, TOO_LONG, TOO_LONG, TOO_LONG,
            TOO_LONG, TOO_LONG, TOO_LONG, TOO_LONG,
            // 10______ ________ <continuation in byte 1>
            TWO_CONTS, TWO_CONTS, TWO_CONTS, TWO_CONTS,
            // 1100____ ________ <two byte lead in byte 1>
            TOO_SHORT | OVERLONG_2,
            // 1101____ ________ <two byte lead in byte 1>
            TOO_SHORT,
            // 1110____ ________ <three byte lead in byte 1>
            TOO_SHORT | OVERLONG_3 | SURROGATE,
            // 1111____ ________ <four+ byte lead in byte 1>
            TOO_SHORT | TOO_LARGE | TOO_LARGE_1000 | OVERLONG_4,
        }), prev1 >> @as(vector, @splat(4)));

        const CARRY = TOO_SHORT | TOO_LONG | TWO_CONTS; // These all have ____ in byte 1 .

        const byte_1_low = intr.lookupTable(simd.repeat(Vector.LEN_BYTES, [_]u8{
            // ____0000 ________
            CARRY | OVERLONG_3 | OVERLONG_2 | OVERLONG_4,
            // ____0001 ________
            CARRY | OVERLONG_2,
            // ____001_ ________
            CARRY,
            CARRY,

            // ____0100 ________
            CARRY | TOO_LARGE,
            // ____0101 ________
            CARRY | TOO_LARGE | TOO_LARGE_1000,
            // ____011_ ________
            CARRY | TOO_LARGE | TOO_LARGE_1000,
            CARRY | TOO_LARGE | TOO_LARGE_1000,

            // ____1___ ________
            CARRY | TOO_LARGE | TOO_LARGE_1000,
            CARRY | TOO_LARGE | TOO_LARGE_1000,
            CARRY | TOO_LARGE | TOO_LARGE_1000,
            CARRY | TOO_LARGE | TOO_LARGE_1000,
            CARRY | TOO_LARGE | TOO_LARGE_1000,
            // ____1101 ________
            CARRY | TOO_LARGE | TOO_LARGE_1000 | SURROGATE,
            CARRY | TOO_LARGE | TOO_LARGE_1000,
            CARRY | TOO_LARGE | TOO_LARGE_1000,
        }), prev1 & @as(vector, @splat(0x0F)));

        const byte_2_high = intr.lookupTable(simd.repeat(Vector.LEN_BYTES, [_]u8{
            // ________ 0_______ <ASCII in byte 2>
            TOO_SHORT, TOO_SHORT, TOO_SHORT, TOO_SHORT,
            TOO_SHORT, TOO_SHORT, TOO_SHORT, TOO_SHORT,

            // ________ 1000____
            TOO_LONG | OVERLONG_2 | TWO_CONTS | OVERLONG_3 | TOO_LARGE_1000 | OVERLONG_4,
            // ________ 1001____
            TOO_LONG | OVERLONG_2 | TWO_CONTS | OVERLONG_3 | TOO_LARGE,
            // ________ 101_____
            TOO_LONG | OVERLONG_2 | TWO_CONTS | SURROGATE  | TOO_LARGE,
            TOO_LONG | OVERLONG_2 | TWO_CONTS | SURROGATE  | TOO_LARGE,

            // ________ 11______
            TOO_SHORT, TOO_SHORT, TOO_SHORT, TOO_SHORT,
        }), vec >> @as(vector, @splat(4)));
        // zig fmt: on

        const special_cases = byte_1_high & byte_1_low & byte_2_high;

        const prev2 = @shuffle(u8, vec, self.prev_vec, shift2_mask);
        const prev3 = @shuffle(u8, vec, self.prev_vec, shift3_mask);

        const is_third_byte = Pred(.bytes).from(prev2 >= @as(vector, @splat(0xE0))).unpack();
        const is_fourth_byte = Pred(.bytes).from(prev3 >= @as(vector, @splat(0xF0))).unpack();

        const must_be_2_3_continuation = is_third_byte ^ is_fourth_byte;
        const must_be_2_3_80 = must_be_2_3_continuation & @as(vector, @splat(0x80));

        self.err |= must_be_2_3_80 ^ special_cases;
    }
};
