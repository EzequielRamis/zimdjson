const std = @import("std");
const shared = @import("shared.zig");
const unicode = std.unicode;
const vector = shared.vector;
const vector_size = shared.vector_size;
const mask = shared.mask;
const ArrayList = std.ArrayList;
const TapeError = shared.TapeError;
const Node = shared.Node;

pub fn true_atom(input: []const u8) TapeError!void {
    const remaining_chars = input.len;
    if (remaining_chars < 4) {
        return TapeError.TrueAtom;
    }
    const dword_true = shared.intFromSlice(u32, "true");
    const dword_atom = shared.intFromSlice(u32, input[0..4]);
    const valid = check: {
        if (remaining_chars == 4) {
            break :check dword_true == dword_atom;
        } else {
            break :check dword_true == dword_atom and shared.Tables.is_structural_or_whitespace[input[4]];
        }
    };
    if (valid) {
        return;
    }
    return TapeError.FalseAtom;
}

pub fn false_atom(input: []const u8) TapeError!void {
    const remaining_chars = input.len;
    if (remaining_chars < 5) {
        return TapeError.FalseAtom;
    }
    const dword_alse = shared.intFromSlice(u32, "alse");
    const dword_atom = shared.intFromSlice(u32, input[1..5]);
    const valid = check: {
        if (remaining_chars == 5) {
            break :check dword_alse == dword_atom;
        } else {
            break :check dword_alse == dword_atom and shared.Tables.is_structural_or_whitespace[input[5]];
        }
    };
    if (valid) {
        return;
    }
    return TapeError.FalseAtom;
}

pub fn null_atom(input: []const u8) TapeError!void {
    const remaining_chars = input.len;
    if (remaining_chars < 4) {
        return TapeError.NullAtom;
    }
    const dword_null = shared.intFromSlice(u32, "null");
    const dword_atom = shared.intFromSlice(u32, input[0..4]);
    const valid = check: {
        if (remaining_chars == 4) {
            break :check dword_null == dword_atom;
        } else {
            break :check dword_null == dword_atom and shared.Tables.is_structural_or_whitespace[input[4]];
        }
    };
    if (valid) {
        return;
    }
    return TapeError.FalseAtom;
}

pub fn string(strings: *ArrayList(u8), input: []const u8) ![:0]const u8 {
    const strings_len = strings.items.len;
    var buffer_mem = [_]u8{0} ** vector_size;
    var iter: []const u8 = input;
    var i: usize = 0;
    while (i < input.len) {
        iter = input[i..];
        buffer_mem = [_]u8{0} ** vector_size;
        const content_len = @min(iter.len, vector_size);
        @memcpy(&buffer_mem, iter[0..content_len]);
        const buffer: vector = buffer_mem;
        const quotes = @as(mask, @bitCast(buffer == shared.quote));
        const bslash = @as(mask, @bitCast(buffer == shared.slash));
        const first_quote_index = @ctz(quotes);
        const first_slash_index = @ctz(bslash);
        // none of the characters are present in the buffer
        if (first_quote_index == first_slash_index) {
            try strings.appendSlice(iter);
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
    res |= @as(u16, shared.Tables.digit_map[input[0]] orelse return TapeError.InvalidEscape) << 12;
    res |= @as(u16, shared.Tables.digit_map[input[1]] orelse return TapeError.InvalidEscape) << 8;
    res |= @as(u16, shared.Tables.digit_map[input[2]] orelse return TapeError.InvalidEscape) << 4;
    res |= @as(u16, shared.Tables.digit_map[input[3]] orelse return TapeError.InvalidEscape);
    return res;
}

pub fn number(input: []const u8) !u64 {
    const negative = input[0] == '-';
    if (negative and input.len < 2) {
        return TapeError.InvalidNumber;
    }
    var i: u64 = 0;
    var iter = input[@intFromBool(negative)..];
    if (is_made_of_digits(iter[0..vector_size].*)) {
        std.debug.print("is_made_of_digits\n", .{});
    }
    while (parse_digit(iter[0], &i)) : (iter = iter[1..]) {}
    return i;
}

fn parse_digit(char: u8, n: *u64) bool {
    const digit = @as(u64, char -% '0');
    if (digit > 9) {
        return false;
    }
    n.* = n.* * 10 + digit;
    return true;
}

fn is_made_of_digits(chars: [vector_size]u8) bool {
    return @as(mask, @bitCast(@as(vector, chars) -% @as(vector, @splat('0')) <= @as(vector, @splat(9)))) != 0;
}
