const std = @import("std");
const tracy = @import("tracy");
const types = @import("types.zig");
const intr = @import("intrinsics.zig");
const io = @import("io.zig");
const simd = std.simd;
const vector = types.vector;
const Vector = types.Vector;
const Mask = types.Mask;
const Predicate = types.Predicate;

pub fn Checker(comptime options: io.Options) type {
    return struct {
        const Self = @This();
        const Aligned = types.Aligned(options.aligned);

        err: vector = @splat(0),
        prev_vec: vector = @splat(0),
        prev_incomplete: vector = @splat(0),

        pub fn succeeded(self: Self) bool {
            const err = self.err | self.prev_incomplete;
            return simd.prefixScan(.Or, 1, err)[Vector.len_bytes - 1] == 0;
        }

        pub inline fn check(self: *Self, vecs: types.vectors) void {
            if (isASCII(vecs)) {
                @branchHint(.likely);
                self.err |= self.prev_incomplete;
            } else {
                inline for (0..Mask.computed_vectors) |i| {
                    const vec = vecs[i];
                    self.checkUTF8Bytes(vec);
                    self.prev_vec = vec;
                    if (i == Mask.computed_vectors - 1) {
                        self.prev_incomplete = isIncomplete(vec);
                    }
                }
            }
        }

        inline fn isASCII(vecs: types.vectors) bool {
            var reduced = vecs[0];
            inline for (0..Mask.computed_vectors) |i| {
                reduced |= vecs[i];
            }
            return Predicate.pack(@as(vector, @splat(0x80)) <= reduced) == 0;
        }

        inline fn isIncomplete(vec: vector) vector {
            const max: vector = @splat(255);
            return vec -| max;
        }

        inline fn checkUTF8Bytes(self: *Self, vec: vector) void {
            @setEvalBranchQuota(10000);
            const len = Vector.len_bytes;
            const prev1_mask: @Vector(len, i32) = [_]i32{len} ++ ([_]i32{0} ** (len - 1));
            const prev2_mask: @Vector(len, i32) = [_]i32{ len - 1, len } ++ ([_]i32{0} ** (len - 2));
            const prev3_mask: @Vector(len, i32) = [_]i32{ len - 2, len - 1, len } ++ ([_]i32{0} ** (len - 3));
            const shift1_mask = comptime simd.shiftElementsRight(simd.iota(i32, len), 1, 0) - prev1_mask;
            const shift2_mask = comptime simd.shiftElementsRight(simd.iota(i32, len), 2, 0) - prev2_mask;
            const shift3_mask = comptime simd.shiftElementsRight(simd.iota(i32, len), 3, 0) - prev3_mask;
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

            const byte_1_high = intr.lookupTable(simd.repeat(Vector.len_bytes, [_]u8{
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

            const byte_1_low = intr.lookupTable(simd.repeat(Vector.len_bytes, [_]u8{
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

            const byte_2_high = intr.lookupTable(simd.repeat(Vector.len_bytes, [_]u8{
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

            const is_third_byte = prev2 -| @as(vector, @splat(0xE0 - 0x80));
            const is_fourth_byte = prev3 -| @as(vector, @splat(0xF0 - 0x80));

            const must_be_2_3_continuation = is_third_byte ^ is_fourth_byte;
            const must_be_2_3_80 = must_be_2_3_continuation & @as(vector, @splat(0x80));

            self.err |= must_be_2_3_80 ^ special_cases;
        }
    };
}
