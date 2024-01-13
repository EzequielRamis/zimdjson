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
    const vec_true: @Vector(4, u8) = [_]u8{ 't', 'r', 'u', 'e' };
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
    const vec_false: @Vector(5, u8) = [_]u8{ 'f', 'a', 'l', 's', 'e' };
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
    const vec_null: @Vector(4, u8) = [_]u8{ 'n', 'u', 'l', 'l' };
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
            // encode utf-8
        } else {
            const escaped_char = shared.Tables.escape_map[escape_char];
            if (escaped_char == 0) {
                return TapeError.InvalidEscape;
            }
            strings.append(escaped_char);
            i += 2;
        }
    }
    return TapeError.NonTerminatedString;
}
