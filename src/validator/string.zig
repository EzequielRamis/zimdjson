const std = @import("std");
const shared = @import("../shared.zig");
const unicode = std.unicode;
const vector = shared.vector;
const vector_size = shared.vector_size;
const vector_mask = shared.vector_mask;
const ArrayList = std.ArrayList;
const TapeError = shared.TapeError;

pub fn string(strings: *ArrayList(u8), input: []const u8) ![:0]const u8 {
    const strings_len = strings.items.len;
    var buffer_mem = [_]u8{0} ** vector_size;
    var iter: []const u8 = input;
    var i: usize = 0;
    while (i < input.len) {
        iter = input[i..];
        buffer_mem = [_]u8{0} ** vector_size;
        const content_len = @min(iter.len, vector_size);
        @memcpy((&buffer_mem)[0..content_len], iter[0..content_len]);
        const buffer: vector = buffer_mem;
        const quotes = @as(vector_mask, @bitCast(buffer == shared.quote));
        const bslash = @as(vector_mask, @bitCast(buffer == shared.slash));
        const first_quote_index = @ctz(quotes);
        const first_slash_index = @ctz(bslash);
        // none of the characters are present in the buffer
        if (first_quote_index == first_slash_index) {
            try strings.appendSlice(iter[0..vector_size]);
            i += vector_size;
            continue;
        }
        // end of string
        if (first_quote_index < first_slash_index) {
            try strings.appendSlice(iter[0..first_quote_index]);
            try strings.append(0);
            return strings.items[strings_len..strings.items.len -| 1 :0];
        }
        // escape sequence
        try strings.appendSlice(iter[0..first_slash_index]);
        iter = iter[first_slash_index..];
        if (iter.len < 2) {
            break;
        }
        i += first_slash_index;
        const escape_char = iter[1];
        if (escape_char == 'u') {
            if (iter.len < 6) {
                break;
            }
            const first_literal = iter[2..6].*;
            const first_codepoint = try parse_dword_literal(first_literal);
            const codepoint = res: {
                i += 6;
                if (unicode.utf16IsHighSurrogate(first_codepoint)) {
                    if (iter.len >= 12 and shared.intFromSlice(u16, iter[6..8]) == shared.intFromSlice(u16, "\\u")) {
                        i += 6;
                        const second_literal = iter[8..12].*;
                        const high_surrogate = try parse_dword_literal(first_literal);
                        const low_surrogate = try parse_dword_literal(second_literal);
                        break :res try unicode.utf16DecodeSurrogatePair(&[_]u16{ high_surrogate, low_surrogate });
                    } else {
                        break :res unicode.replacement_character;
                    }
                } else if (unicode.utf16IsLowSurrogate(first_codepoint)) {
                    break :res unicode.replacement_character;
                }
                break :res first_codepoint;
            };
            const encoded_buffer = try strings.addManyAsSlice(try unicode.utf8CodepointSequenceLength(codepoint));
            _ = try unicode.utf8Encode(codepoint, encoded_buffer);
        } else {
            const escaped_char = shared.Tables.escape_map[escape_char] orelse return TapeError.InvalidEscape;
            try strings.append(escaped_char);
            i += 2;
        }
    }
    return TapeError.NonTerminatedString;
}

fn parse_dword_literal(input: [4]u8) TapeError!u16 {
    var res: u16 = 0;
    res |= @as(u16, shared.Tables.hex_digit_map[input[0]] orelse return TapeError.InvalidEscape) << 12;
    res |= @as(u16, shared.Tables.hex_digit_map[input[1]] orelse return TapeError.InvalidEscape) << 8;
    res |= @as(u16, shared.Tables.hex_digit_map[input[2]] orelse return TapeError.InvalidEscape) << 4;
    res |= @as(u16, shared.Tables.hex_digit_map[input[3]] orelse return TapeError.InvalidEscape);
    return res;
}
