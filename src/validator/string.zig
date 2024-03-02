const std = @import("std");
const shared = @import("../shared.zig");
const types = @import("../types.zig");
const BoundedArrayList = @import("../bounded_array_list.zig").BoundedArrayList;
const TokenIterator = @import("../TokenIterator.zig");
const unicode = std.unicode;
const vector = types.vector;
const array = types.array;
const Vector = types.Vector;
const Pred = types.Predicate;
const ArrayList = std.ArrayList;
const TapeError = shared.TapeError;

pub fn string(src: *TokenIterator, dst: *BoundedArrayList(u8)) !void {
    while (true) {
        const chunk = src.peekVector();
        const slash = Pred(.bytes).from(Vector.SLASH == chunk.*).pack();
        const quote = Pred(.bytes).from(Vector.QUOTE == chunk.*).pack();
        const slash_index = @ctz(slash);
        const quote_index = @ctz(quote);
        // none of the characters are present in the buffer
        if (quote_index == slash_index) {
            dst.appendSlice(chunk);
            src.nextVoid(Vector.LEN_BYTES);
            continue;
        }
        // end of string
        if (quote_index < slash_index) {
            dst.appendSlice(chunk[0..quote_index]);
            src.nextVoid(quote_index);
            dst.append(0);
            return;
        }
        // escape sequence
        dst.appendSlice(chunk[0..slash_index]);
        src.nextVoid(slash_index);
        const escape_char = src.next();
        if (escape_char == 'u') {
            const first_literal = src.nextNibble();
            const first_codepoint = try parse_dword_literal(first_literal);
            const codepoint = res: {
                if (unicode.utf16IsHighSurrogate(first_codepoint)) {
                    if (shared.intFromSlice(u16, src.curr_slice[0..2]) == shared.intFromSlice(u16, "\\u")) {
                        src.nextVoid(2);
                        const second_literal = src.nextNibble();
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
            const encoded_buffer = dst.addManyAsSlice(try unicode.utf8CodepointSequenceLength(codepoint));
            _ = try unicode.utf8Encode(codepoint, encoded_buffer);
        } else {
            const escaped_char = shared.Tables.escape_map[escape_char] orelse return TapeError.InvalidEscape;
            dst.append(escaped_char);
        }
    }
    return TapeError.NonTerminatedString;
}

fn parse_dword_literal(src: *const [4]u8) TapeError!u16 {
    var res: u16 = 0;
    res |= @as(u16, shared.Tables.hex_digit_map[src[0]] orelse return TapeError.InvalidEscape) << 12;
    res |= @as(u16, shared.Tables.hex_digit_map[src[1]] orelse return TapeError.InvalidEscape) << 8;
    res |= @as(u16, shared.Tables.hex_digit_map[src[2]] orelse return TapeError.InvalidEscape) << 4;
    res |= @as(u16, shared.Tables.hex_digit_map[src[3]] orelse return TapeError.InvalidEscape);
    return res;
}
