const std = @import("std");
const shared = @import("../shared.zig");
const TokenIterator = @import("../TokenIterator.zig");
const TapeError = shared.TapeError;

pub fn true_atom(token: *TokenIterator) TapeError!void {
    const dword_true = shared.intFromSlice(u32, "true");
    const dword_atom = shared.intFromSlice(u32, token.nextNibble());
    if (dword_true != dword_atom) {
        return TapeError.FalseAtom;
    }
}

pub fn false_atom(token: *TokenIterator) TapeError!void {
    token.nextVoid(1);
    const dword_alse = shared.intFromSlice(u32, "alse");
    const dword_atom = shared.intFromSlice(u32, token.nextNibble());
    if (dword_alse != dword_atom) {
        return TapeError.NullAtom;
    }
}

pub fn null_atom(token: *TokenIterator) TapeError!void {
    const dword_null = shared.intFromSlice(u32, "null");
    const dword_atom = shared.intFromSlice(u32, token.nextNibble());
    if (dword_null != dword_atom) {
        return TapeError.NullAtom;
    }
}
