const std = @import("std");
const shared = @import("../shared.zig");
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

pub fn rawString(comptime opt: TokenOptions, src: *TokenIterator(opt), comptime phase: ?TokenPhase) ParseError![]const u8 {
    const doc = src.indexer.reader.document;
    const indexes = src.indexer.indexes.items;
    const ptr = indexes[src.index];
    var len: usize = 0;
    while (true) {
        const chunk = src.peekSlice(Vector.LEN_BYTES);
        const slash = Pred(.bytes).from(Vector.SLASH == chunk.*).pack();
        const quote = Pred(.bytes).from(Vector.QUOTE == chunk.*).pack();
        const slash_index = @ctz(slash);
        const quote_index = @ctz(quote);
        // none of the characters are present in the buffer
        if (quote_index == slash_index) {
            _ = src.consume(Vector.LEN_BYTES, phase);
            len += Vector.LEN_BYTES;
            continue;
        }
        // end of string
        if (quote_index < slash_index) {
            _ = src.consume(quote_index, phase);
            len += quote_index;
            return doc[ptr..][0..len];
        }
        // escape sequence
        _ = src.consume(slash_index + 1, phase);
        len += slash_index + 1;
        const escape_char = src.consume(1, phase)[0];
        if (escape_char == '\\') {
            _ = src.consume(1, phase);
            len += 1;
        }
    }
    return error.UnclosedString;
}

pub fn string(comptime opt: TokenOptions, src: *TokenIterator(opt), dst: *ArrayList(u8), comptime phase: ?TokenPhase) ParseError!void {
    while (true) {
        const chunk = src.peekSlice(Vector.LEN_BYTES);
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
            const first_literal = src.consume(4, phase)[0..4];
            const first_codepoint = try parse_dword_literal(first_literal);
            const codepoint = res: {
                if (utf16IsHighSurrogate(first_codepoint)) {
                    if (shared.intFromSlice(u16, src.peekSlice(2)).* == shared.intFromSlice(u16, "\\u").*) {
                        _ = src.consume(2, phase);
                        const high_surrogate = first_codepoint;
                        const second_literal = src.consume(4, phase)[0..4];
                        const low_surrogate = try parse_dword_literal(second_literal);
                        break :res try utf16DecodeSurrogatePair(high_surrogate, low_surrogate);
                    } else {
                        break :res unicode.replacement_character;
                    }
                } else if (utf16IsLowSurrogate(first_codepoint)) {
                    break :res unicode.replacement_character;
                }
                break :res first_codepoint;
            };
            const codepoint_len = try utf8CodepointSequenceLength(codepoint);
            const encoded_buffer = dst.addManyAsSliceAssumeCapacity(codepoint_len);
            try utf8Encode(codepoint, codepoint_len, encoded_buffer);
        } else {
            const escaped_char = shared.Tables.escape_map[escape_char] orelse return error.InvalidEscape;
            dst.appendAssumeCapacity(escaped_char);
        }
    }
    return error.UnclosedString;
}

fn parse_dword_literal(src: *const [4]u8) ParseError!u16 {
    var res: u16 = 0;
    res |= @as(u16, shared.Tables.hex_digit_map[src[0]]) << 12;
    res |= @as(u16, shared.Tables.hex_digit_map[src[1]]) << 8;
    res |= @as(u16, shared.Tables.hex_digit_map[src[2]]) << 4;
    res |= @as(u16, shared.Tables.hex_digit_map[src[3]]);
    if (res == 0xFFFF) {
        return error.InvalidEscape;
    }
    return res;
}

fn utf8CodepointSequenceLength(c: u21) ParseError!u3 {
    if (c < 0x80) return @as(u3, 1);
    if (c < 0x800) return @as(u3, 2);
    if (c < 0x10000) return @as(u3, 3);
    if (c < 0x110000) return @as(u3, 4);
    return error.InvalidEscape;
}

fn utf16IsHighSurrogate(c: u16) bool {
    return c & ~@as(u16, 0x03ff) == 0xd800;
}

fn utf16IsLowSurrogate(c: u16) bool {
    return c & ~@as(u16, 0x03ff) == 0xdc00;
}

inline fn utf16DecodeSurrogatePair(h: u16, l: u16) ParseError!u21 {
    const high_half: u21 = h;
    const low_half = l;
    if (!utf16IsLowSurrogate(low_half)) return error.InvalidEscape;
    return 0x10000 + ((high_half & 0x03ff) << 10) | (low_half & 0x03ff);
}

inline fn utf8Encode(c: u21, c_len: u3, out: []u8) ParseError!void {
    switch (c_len) {
        // The pattern for each is the same
        // - Increasing the initial shift by 6 each time
        // - Each time after the first shorten the shifted
        //   value to a max of 0b111111 (63)
        1 => out[0] = @as(u8, @intCast(c)), // Can just do 0 + codepoint for initial range
        2 => {
            out[0] = @as(u8, @intCast(0b11000000 | (c >> 6)));
            out[1] = @as(u8, @intCast(0b10000000 | (c & 0b111111)));
        },
        3 => {
            if (isSurrogateCodepoint(c)) {
                return error.InvalidEscape;
            }
            out[0] = @as(u8, @intCast(0b11100000 | (c >> 12)));
            out[1] = @as(u8, @intCast(0b10000000 | ((c >> 6) & 0b111111)));
            out[2] = @as(u8, @intCast(0b10000000 | (c & 0b111111)));
        },
        4 => {
            out[0] = @as(u8, @intCast(0b11110000 | (c >> 18)));
            out[1] = @as(u8, @intCast(0b10000000 | ((c >> 12) & 0b111111)));
            out[2] = @as(u8, @intCast(0b10000000 | ((c >> 6) & 0b111111)));
            out[3] = @as(u8, @intCast(0b10000000 | (c & 0b111111)));
        },
        else => unreachable,
    }
}

fn isSurrogateCodepoint(c: u21) bool {
    return switch (c) {
        0xD800...0xDFFF => true,
        else => false,
    };
}
