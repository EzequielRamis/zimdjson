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
            break :check @as(i4, @bitCast(vec_true == vec_atom)) == -1;
        } else {
            break :check @as(i4, @bitCast(vec_true == vec_atom)) == -1 and shared.Tables.is_structural_or_whitespace[input[4]];
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
            break :check @as(i5, @bitCast(vec_false == vec_atom)) == -1;
        } else {
            break :check @as(i5, @bitCast(vec_false == vec_atom)) == -1 and shared.Tables.is_structural_or_whitespace[input[5]];
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
            break :check @as(i4, @bitCast(vec_null == vec_atom)) == -1;
        } else {
            break :check @as(i4, @bitCast(vec_null == vec_atom)) == -1 and shared.Tables.is_structural_or_whitespace[input[4]];
        }
    };
    if (valid) {
        return;
    }
    return TapeError.NullAtom;
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
        if (first_quote_index < first_slash_index) {
            try strings.appendSlice(iter[0..first_quote_index]);
            try strings.append(0);
            return strings.items[strings_len..strings.items.len -| 1 :0];
        }
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
            const first_literal = iter[2..6];
            if (iter.len > 7) {
                const utf_literal = res: {
                    if (iter[7] == '\\' and iter[8] == 'u') {
                        const second_literal = iter[9..13];
                        i += 12;
                        break :res try parse_utf8_literal(first_literal, second_literal);
                    } else {
                        i += 6;
                        break :res try parse_utf8_literal(first_literal, null);
                    }
                };
                const codepoint = try std.unicode.utf8Decode(utf_literal);
                const encoded_buffer = try strings.addManyAsSlice(4);
                _ = try std.unicode.utf8Encode(codepoint, encoded_buffer);
            }
        } else {
            const escaped_char = shared.Tables.escape_map[escape_char] orelse return TapeError.InvalidEscape;
            try strings.append(escaped_char);
            i += 2;
        }
    }
    return TapeError.NonTerminatedString;
}

fn parse_utf8_literal(dword: *const [4]u8, pair: ?*const [4]u8) TapeError![]const u8 {
    var high_surr = [_]u8{ 0, 0 };
    var low_surr = [_]u8{ 0, 0 };
    high_surr[0] = shared.Tables.digit_map[dword[0]] orelse return TapeError.InvalidEscape;
    high_surr[0] += (shared.Tables.digit_map[dword[1]] orelse return TapeError.InvalidEscape) << 4;
    high_surr[1] = shared.Tables.digit_map[dword[2]] orelse return TapeError.InvalidEscape;
    high_surr[1] += (shared.Tables.digit_map[dword[3]] orelse return TapeError.InvalidEscape) << 4;
    var codepoint: ?[]u8 = null;
    if (pair) |p| {
        low_surr[0] = shared.Tables.digit_map[p[0]] orelse return TapeError.InvalidEscape;
        low_surr[0] += (shared.Tables.digit_map[p[1]] orelse return TapeError.InvalidEscape) << 4;
        low_surr[1] = shared.Tables.digit_map[p[2]] orelse return TapeError.InvalidEscape;
        low_surr[1] += (shared.Tables.digit_map[p[3]] orelse return TapeError.InvalidEscape) << 4;
        codepoint.? = @ptrCast(@constCast(&(high_surr ++ low_surr)));
    } else {
        codepoint.? = @ptrCast(@constCast(&high_surr));
    }
    if (codepoint.?[0] == 0) {
        return codepoint.?[1..];
    }
    return codepoint.?;
}
