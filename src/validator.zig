const std = @import("std");
const shared = @import("shared.zig");
const vector = shared.vector;
const vector_size = shared.vector_size;
const mask = shared.mask;
const ArrayList = std.ArrayList;
const TapeError = shared.TapeError;

pub fn true_atom(input: []const u8) TapeError!void {
    const remaining_chars = input.len;
    if (remaining_chars < 4) {
        return TapeError.TrueAtom;
    }
    const vec_true: @Vector(4, u8) = "true".*;
    const vec_atom: @Vector(4, u8) = input[0..4].*;
    const valid = check: {
        if (remaining_chars == 4) {
            break :check vec_true == vec_atom;
        } else {
            break :check vec_true == vec_atom and shared.Tables.is_structural_or_whitespace[input[4]];
        }
    };
    if (valid) {
        return;
    }
    return TapeError.TrueAtom;
}

pub fn false_atom(input: []const u8) TapeError!void {
    const remaining_chars = input.len;
    if (remaining_chars < 5) {
        return TapeError.FalseAtom;
    }
    const vec_false: @Vector(5, u8) = "false".*;
    const vec_atom: @Vector(5, u8) = input[0..5].*;
    const valid = check: {
        if (remaining_chars == 5) {
            break :check vec_false == vec_atom;
        } else {
            break :check vec_false == vec_atom and shared.Tables.is_structural_or_whitespace[input[5]];
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
    const vec_null: @Vector(4, u8) = "null".*;
    const vec_atom: @Vector(4, u8) = input[0..4].*;
    const valid = check: {
        if (remaining_chars == 4) {
            break :check vec_null == vec_atom;
        } else {
            break :check vec_null == vec_atom and shared.Tables.is_structural_or_whitespace[input[4]];
        }
    };
    if (valid) {
        return;
    }
    return TapeError.NullAtom;
}

pub fn string(strings: *ArrayList(u8), input: []const u8) TapeError!void {
    var buffer_mem = [_]u8{' '} ** vector_size;
    var iter: []const u8 = input;
    var i: usize = 0;
    while (i >= input.len) {
        iter = input[i..];
        buffer_mem = [_]u8{' '} ** vector_size;
        const content_len = @min(iter.len, vector_size);
        @memcpy(buffer_mem, iter[0..content_len]);
        const buffer: vector = buffer_mem;
        const quotes = @as(mask, @bitCast(buffer == shared.quote));
        const bslash = @as(mask, @bitCast(buffer == shared.slash));
        const first_quote_index = @ctz(quotes);
        const first_slash_index = @ctz(bslash);
        // none of the characters are present in the buffer
        if (first_quote_index == first_slash_index) {
            strings.appendSlice(iter);
            i += vector_size;
            continue;
        }
        if (first_quote_index < first_slash_index) {
            strings.appendSlice(iter[0..first_quote_index]);
            strings.append(0);
            return;
        }
        strings.appendSlice(iter[0..first_slash_index]);
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
            const first_literal = iter[2..6];
            if (iter.len > 7) {
                const utf_literal = undefined;
                if (iter[7] == '\\' and iter[8] == 'u') {
                    const second_literal = iter[9..13];
                    utf_literal = try parse_utf8_literal(first_literal, second_literal);
                    i += 12;
                } else {
                    utf_literal = try parse_utf8_literal(first_literal, null);
                    i += 6;
                }
                const codepoint = try std.unicode.utf8Decode(utf_literal);
                const encoded_buffer = try strings.addManyAsSlice(4);
                try std.unicode.utf8Encode(codepoint, encoded_buffer);
            }
        } else {
            const escaped_char = shared.Tables.escape_map[escape_char] orelse return TapeError.InvalidEscape;
            strings.append(escaped_char);
            i += 2;
        }
    }
    return TapeError.NonTerminatedString;
}

fn parse_utf8_literal(dword: [4]u8, pair: ?[4]u8) TapeError![]const u8 {
    var high_surr = [_]u8{ 0, 0 };
    var low_surr = [_]u8{ 0, 0 };
    const codepoint = undefined;
    high_surr[0] = shared.Tables.digit_map[dword[0]] orelse return TapeError.InvalidEscape;
    high_surr[0] += (shared.Tables.digit_map[dword[1]] orelse return TapeError.InvalidEscape) << 4;
    high_surr[1] = shared.Tables.digit_map[dword[2]] orelse return TapeError.InvalidEscape;
    high_surr[1] += (shared.Tables.digit_map[dword[3]] orelse return TapeError.InvalidEscape) << 4;
    if (pair) {
        low_surr[0] = shared.Tables.digit_map[pair[0]] orelse return TapeError.InvalidEscape;
        low_surr[0] += (shared.Tables.digit_map[pair[1]] orelse return TapeError.InvalidEscape) << 4;
        low_surr[1] = shared.Tables.digit_map[pair[2]] orelse return TapeError.InvalidEscape;
        low_surr[1] += (shared.Tables.digit_map[pair[3]] orelse return TapeError.InvalidEscape) << 4;
        codepoint = high_surr ++ low_surr;
    } else {
        codepoint = high_surr;
    }
    if (codepoint[0] == 0) {
        return &codepoint[1..];
    }
    return &codepoint;
}
