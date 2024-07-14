const std = @import("std");
const common = @import("../common.zig");
const types = @import("../types.zig");
const tokens = @import("../tokens.zig");
const TokenIterator = tokens.Iterator;
const TokenPhase = tokens.Phase;
const TokenOptions = tokens.Options;
const unicode = std.unicode;
const vector = types.vector;
const array = types.array;
const Vector = types.Vector;
const Pred = types.Predicate;
const ArrayList = std.ArrayList;
const ParseError = types.ParseError;
const readInt = std.mem.readInt;

pub fn writeString(
    comptime opt: TokenOptions,
    src: *TokenIterator(opt),
    dst: *ArrayList(u8),
    comptime phase: TokenPhase,
) ParseError!void {
    while (true) {
        const chunk = src.ptr[0..Vector.LEN_BYTES];
        const slash = Pred(.bytes).from(Vector.SLASH == chunk.*).pack();
        const quote = Pred(.bytes).from(Vector.QUOTE == chunk.*).pack();
        const slash_index = @ctz(slash);
        const quote_index = @ctz(quote);
        // none of the characters are present in the buffer
        if (quote_index == slash_index) {
            dst.appendSliceAssumeCapacity(chunk);
            _ = src.consume(Vector.LEN_BYTES, phase);
            continue;
        }
        // end of string
        if (quote_index < slash_index) {
            const new_len = dst.items.len + quote_index;
            dst.appendSliceAssumeCapacity(chunk);
            dst.items.len = new_len;
            dst.appendAssumeCapacity(0);
            _ = src.consume(quote_index, phase);
            return;
        }
        // escape sequence
        const new_len = dst.items.len + slash_index;
        dst.appendSliceAssumeCapacity(chunk);
        dst.items.len = new_len;
        _ = src.consume(slash_index + 1, phase);
        const escape_char = src.consume(1, phase)[0];
        if (escape_char == 'u') {
            const codepoint = try handleUnicodeCodepoint(opt, src, phase);
            try utf8Encode(codepoint, dst);
        } else {
            const escaped = escape_map[escape_char];
            if (escaped == 0) return error.InvalidEscape;
            dst.appendAssumeCapacity(escaped);
        }
    }
    return error.UnclosedString;
}

fn handleUnicodeCodepoint(
    comptime opt: TokenOptions,
    src: *TokenIterator(opt),
    comptime phase: TokenPhase,
) ParseError!u32 {
    const first_literal = src.consume(4, phase)[0..4];
    const first_codepoint = parseHexDword(first_literal);
    if (utf16IsHighSurrogate(first_codepoint)) {
        if (readInt(u16, src.ptr[0..2], .little) == readInt(u16, "\\u", .little)) {
            _ = src.consume(2, phase);
            const high_surrogate = first_codepoint;
            const second_literal = src.consume(4, phase)[0..4];
            const low_surrogate = parseHexDword(second_literal);
            if (!utf16IsLowSurrogate(low_surrogate)) return error.InvalidEscape;
            const h = high_surrogate;
            const l = low_surrogate;
            return 0x10000 + ((h & 0x03ff) << 10) | (l & 0x03ff);
        } else {
            return error.InvalidEscape;
        }
    } else if (utf16IsLowSurrogate(first_codepoint)) {
        return error.InvalidEscape;
    }
    return first_codepoint;
}

fn utf8Encode(c: u32, dst: *ArrayList(u8)) ParseError!void {
    if (c < 0x80) {
        dst.appendAssumeCapacity(@as(u8, @intCast(c)));
        return;
    }
    if (c < 0x800) {
        const buf = dst.addManyAsArrayAssumeCapacity(2);
        buf[0] = @as(u8, @intCast(0b11000000 | (c >> 6)));
        buf[1] = @as(u8, @intCast(0b10000000 | (c & 0b111111)));
        return;
    }
    if (c < 0x10000) {
        const buf = dst.addManyAsArrayAssumeCapacity(3);
        buf[0] = @as(u8, @intCast(0b11100000 | (c >> 12)));
        buf[1] = @as(u8, @intCast(0b10000000 | ((c >> 6) & 0b111111)));
        buf[2] = @as(u8, @intCast(0b10000000 | (c & 0b111111)));
        return;
    }
    if (c < 0x110000) {
        const buf = dst.addManyAsArrayAssumeCapacity(4);
        buf[0] = @as(u8, @intCast(0b11110000 | (c >> 18)));
        buf[1] = @as(u8, @intCast(0b10000000 | ((c >> 12) & 0b111111)));
        buf[2] = @as(u8, @intCast(0b10000000 | ((c >> 6) & 0b111111)));
        buf[3] = @as(u8, @intCast(0b10000000 | (c & 0b111111)));
        return;
    }
    return error.InvalidEscape;
}

fn utf16IsHighSurrogate(c: u32) bool {
    return c & ~@as(u32, 0x03ff) == 0xd800;
}

fn utf16IsLowSurrogate(c: u32) bool {
    return c & ~@as(u32, 0x03ff) == 0xdc00;
}

fn parseHexDword(src: *const [4]u8) u32 {
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

fn charToDigit(c: u8) ?u32 {
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
