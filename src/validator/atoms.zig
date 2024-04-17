const std = @import("std");
const shared = @import("../shared.zig");
const types = @import("../types.zig");
const TokenIterator = @import("../TokenIterator.zig");
const TokenPhase = TokenIterator.Phase;
const ParseError = types.ParseError;

pub fn true_atom(token: *TokenIterator, comptime phase: TokenPhase) ParseError!void {
    const dword_true = shared.intFromSlice(u32, "true").*;
    const dword_atom = shared.intFromSlice(u32, token.next(4, phase)).*;
    if (dword_true != dword_atom) {
        return ParseError.FalseAtom;
    }
}

pub fn false_atom(token: *TokenIterator, comptime phase: TokenPhase) ParseError!void {
    _ = token.next(1, phase);
    const dword_alse = shared.intFromSlice(u32, "alse").*;
    const dword_atom = shared.intFromSlice(u32, token.next(4, phase)).*;
    if (dword_alse != dword_atom) {
        return ParseError.NullAtom;
    }
}

pub fn null_atom(token: *TokenIterator, comptime phase: TokenPhase) ParseError!void {
    const dword_null = shared.intFromSlice(u32, "null").*;
    const dword_atom = shared.intFromSlice(u32, token.next(4, phase)).*;
    if (dword_null != dword_atom) {
        return ParseError.NullAtom;
    }
}
