const std = @import("std");
const shared = @import("../shared.zig");
const types = @import("../types.zig");
const tokens = @import("../tokens.zig");
const TokenIterator = tokens.Iterator;
const TokenOptions = tokens.Options;
const TokenPhase = tokens.Phase;
const ParseError = types.ParseError;

pub fn true_atom(comptime opt: TokenOptions, token: *TokenIterator(opt), comptime phase: ?TokenPhase) ParseError!void {
    const dword_true = shared.intFromSlice(u32, "true").*;
    const dword_atom = shared.intFromSlice(u32, token.consume(4, phase)).*;
    if (dword_true != dword_atom) {
        return error.FalseAtom;
    }
}

pub fn false_atom(comptime opt: TokenOptions, token: *TokenIterator(opt), comptime phase: ?TokenPhase) ParseError!void {
    _ = token.consume(1, phase);
    const dword_alse = shared.intFromSlice(u32, "alse").*;
    const dword_atom = shared.intFromSlice(u32, token.consume(4, phase)).*;
    if (dword_alse != dword_atom) {
        return error.FalseAtom;
    }
}

pub fn null_atom(comptime opt: TokenOptions, token: *TokenIterator(opt), comptime phase: ?TokenPhase) ParseError!void {
    const dword_null = shared.intFromSlice(u32, "null").*;
    const dword_atom = shared.intFromSlice(u32, token.consume(4, phase)).*;
    if (dword_null != dword_atom) {
        return error.NullAtom;
    }
}
