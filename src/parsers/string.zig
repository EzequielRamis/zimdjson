const std = @import("std");
const builtin = @import("builtin");
const common = @import("../common.zig");
const types = @import("../types.zig");
const tokens = @import("../tokens.zig");
const unicode = std.unicode;
const vector = types.vector;
const Vector = types.Vector;
const Predicate = types.Predicate;
const Error = types.Error;
const readInt = std.mem.readInt;
const native_endian = builtin.cpu.arch.endian();

pub inline fn writeString(src: [*]const u8, _dst: [*]u8) Error![*]u8 {
    var ptr = src + 1;
    var dst = _dst;
    while (true) {
        const chunk = ptr[0..Vector.bytes_len];
        const slash = Predicate.pack(Vector.slash == chunk.*);
        const quote = Predicate.pack(Vector.quote == chunk.*);
        @memcpy(dst[0..Vector.bytes_len], chunk);

        const has_quote_first = ((slash -% 1) & quote) != 0;
        if (has_quote_first) {
            const quote_index: u8 = @ctz(quote);
            return dst + quote_index;
        }

        const has_any_slash = ((quote -% 1) & slash) != 0;
        if (has_any_slash) {
            const slash_index: u8 = @ctz(slash);
            const escape_char = ptr[slash_index + 1];
            if (escape_char == 'u') {
                ptr += slash_index;
                const codepoint = try handleUnicodeCodepoint(&ptr);
                dst += slash_index + try utf8Encode(codepoint, dst);
            } else {
                const escaped = escape_map[escape_char];
                if (escaped == 0) return error.InvalidEscape;
                dst[slash_index] = escaped;
                ptr += slash_index + 2;
                dst += slash_index + 1;
            }
        } else {
            dst += Vector.bytes_len;
            ptr += Vector.bytes_len;
        }
    }
}

inline fn handleUnicodeCodepoint(ptr: *[*]const u8) Error!u32 {
    const first_literal = ptr.*[2..][0..4].*;
    const first_codepoint = parseHexDword(first_literal);
    if (utf16IsHighSurrogate(first_codepoint)) {
        if (readInt(u16, ptr.*[2..][4..][0..2], native_endian) == readInt(u16, "\\u", native_endian)) {
            const high_surrogate = first_codepoint;
            const second_literal = ptr.*[2..][4..][2..][0..4].*;
            const low_surrogate = parseHexDword(second_literal);
            if (!utf16IsLowSurrogate(low_surrogate)) return error.InvalidUnicodeCodePoint;
            ptr.* += 12;
            const h = high_surrogate;
            const l = low_surrogate;
            return 0x10000 + ((h & 0x03ff) << 10) | (l & 0x03ff);
        } else {
            return error.InvalidUnicodeCodePoint;
        }
    } else if (utf16IsLowSurrogate(first_codepoint)) {
        return error.InvalidUnicodeCodePoint;
    }
    ptr.* += 6;
    return first_codepoint;
}

inline fn utf8Encode(c: u32, dst: [*]u8) Error!u8 {
    if (c < 0x80) {
        dst[0] = @intCast(c);
        return 1;
    }
    if (c < 0x800) {
        dst[0] = @as(u8, @intCast(0b11000000 | (c >> 6)));
        dst[1] = @as(u8, @intCast(0b10000000 | (c & 0b111111)));
        return 2;
    }
    if (c < 0x10000) {
        dst[0] = @as(u8, @intCast(0b11100000 | (c >> 12)));
        dst[1] = @as(u8, @intCast(0b10000000 | ((c >> 6) & 0b111111)));
        dst[2] = @as(u8, @intCast(0b10000000 | (c & 0b111111)));
        return 3;
    }
    if (c < 0x110000) {
        dst[0] = @as(u8, @intCast(0b11110000 | (c >> 18)));
        dst[1] = @as(u8, @intCast(0b10000000 | ((c >> 12) & 0b111111)));
        dst[2] = @as(u8, @intCast(0b10000000 | ((c >> 6) & 0b111111)));
        dst[3] = @as(u8, @intCast(0b10000000 | (c & 0b111111)));
        return 4;
    }
    return error.InvalidUnicodeCodePoint;
}

inline fn utf16IsHighSurrogate(c: u32) bool {
    return c & ~@as(u32, 0x03ff) == 0xd800;
}

inline fn utf16IsLowSurrogate(c: u32) bool {
    return c & ~@as(u32, 0x03ff) == 0xdc00;
}

inline fn parseHexDword(src: [4]u8) u32 {
    const v1 = hex_digit_map[@as(usize, src[0]) + 624];
    const v2 = hex_digit_map[@as(usize, src[1]) + 416];
    const v3 = hex_digit_map[@as(usize, src[2]) + 208];
    const v4 = hex_digit_map[@as(usize, src[3])];
    return v1 | v2 | v3 | v4;
}

const hex_err_code: u32 = 0xFFFFFFFF;
const hex_digit_map: [0xD0 * 3 + 256]u32 = init: {
    @setEvalBranchQuota(5000);
    const prefix = [_]u32{hex_err_code} ** 0x30;
    var chunk1: [256 - 0x30]u32 = undefined;
    var chunk2: [256 - 0x30]u32 = undefined;
    var chunk3: [256 - 0x30]u32 = undefined;
    var chunk4: [256 - 0x30]u32 = undefined;
    for (&chunk1, 0x30..) |*c, i| {
        c.* = if (charToDigit(i)) |d| d else hex_err_code;
    }
    for (&chunk2, 0x30..) |*c, i| {
        c.* = if (charToDigit(i)) |d| d << 4 else hex_err_code;
    }
    for (&chunk3, 0x30..) |*c, i| {
        c.* = if (charToDigit(i)) |d| d << 8 else hex_err_code;
    }
    for (&chunk4, 0x30..) |*c, i| {
        c.* = if (charToDigit(i)) |d| d << 12 else hex_err_code;
    }
    break :init prefix ++ chunk1 ++ chunk2 ++ chunk3 ++ chunk4;
};

inline fn charToDigit(c: u8) ?u32 {
    return switch (c) {
        '0'...'9' => c - 0x30,
        else => switch (c | 0x20) {
            'a' => 10,
            'b' => 11,
            'c' => 12,
            'd' => 13,
            'e' => 14,
            'f' => 15,
            else => null,
        },
    };
}

const escape_map: [256]u8 = init: {
    var res: [256]u8 = undefined;
    for (0..res.len) |i| {
        res[i] = switch (i) {
            '"' => 0x22,
            '\\' => 0x5c,
            '/' => 0x2f,
            'b' => 0x08,
            'f' => 0x0c,
            'n' => 0x0a,
            'r' => 0x0d,
            't' => 0x09,
            else => 0,
        };
    }
    break :init res;
};
