const std = @import("std");
const shared = @import("../shared.zig");
const types = @import("../types.zig");
const BoundedArrayList = @import("../bounded_array_list.zig").BoundedArrayList;
const TokenIterator = @import("../TokenIterator.zig");
const TokenPhase = TokenIterator.Phase;
const unicode = std.unicode;
const vector = types.vector;
const array = types.array;
const Vector = types.Vector;
const Pred = types.Predicate;
const ArrayList = std.ArrayList;
const ParseError = shared.ParseError;

pub fn string(src: *TokenIterator, dst: *BoundedArrayList(u8), comptime phase: TokenPhase) !void {
    while (true) {
        const chunk = src.peek(Vector.LEN_BYTES);
        const slash = Pred(.bytes).from(Vector.SLASH == chunk.*).pack();
        const quote = Pred(.bytes).from(Vector.QUOTE == chunk.*).pack();
        const slash_index = @ctz(slash);
        const quote_index = @ctz(quote);
        // none of the characters are present in the buffer
        if (quote_index == slash_index) {
            dst.appendSlice(chunk, Vector.LEN_BYTES);
            _ = src.next(Vector.LEN_BYTES, phase);
            continue;
        }
        // end of string
        if (quote_index < slash_index) {
            dst.appendSlice(chunk, quote_index);
            dst.append(0);
            _ = src.nextSlice(quote_index, phase);
            return;
        }
        // escape sequence
        dst.appendSlice(chunk, slash_index);
        _ = src.nextSlice(slash_index + 1, phase);
        const escape_char = src.next(1, phase);
        if (escape_char == 'u') {
            const first_literal = src.next(4, phase);
            const first_codepoint = parse_dword_literal(first_literal);
            const codepoint = res: {
                if (unicode.utf16IsHighSurrogate(first_codepoint)) {
                    if (shared.intFromSlice(u16, src.peek(2)) == shared.intFromSlice(u16, "\\u")) {
                        _ = src.next(2, phase);
                        const second_literal = src.next(4, phase);
                        const high_surrogate = parse_dword_literal(first_literal);
                        const low_surrogate = parse_dword_literal(second_literal);
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
            const escaped_char = shared.Tables.escape_map[escape_char] orelse return ParseError.InvalidEscape;
            dst.append(escaped_char);
        }
    }
    return ParseError.NonTerminatedString;
}

fn parse_dword_literal(src: *const [4]u8) u16 {
    var res: u16 = 0;
    res |= @as(u16, shared.Tables.hex_digit_map[src[0]]) << 12;
    res |= @as(u16, shared.Tables.hex_digit_map[src[1]]) << 8;
    res |= @as(u16, shared.Tables.hex_digit_map[src[2]]) << 4;
    res |= @as(u16, shared.Tables.hex_digit_map[src[3]]);
    return res;
}
