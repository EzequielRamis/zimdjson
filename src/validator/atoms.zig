const std = @import("std");
const shared = @import("../shared.zig");
const types = @import("../types.zig");
const tokens = @import("../tokens.zig");
const TokenIterator = tokens.Iterator;
const TokenOptions = tokens.Options;
const TokenPhase = tokens.Phase;
const ParseError = types.ParseError;

pub fn atomTrue(comptime opt: TokenOptions, token: *TokenIterator(opt), comptime phase: ?TokenPhase) ParseError!void {
    const chunk = token.consume(5, phase);
    const dword_true = shared.intFromSlice(u32, "true").*;
    const dword_atom = shared.intFromSlice(u32, chunk[0..4]).*;
    const not_struct_white = shared.Tables.is_structural_or_whitespace_negated;
    if (dword_true != dword_atom or not_struct_white[chunk[4]]) {
        return error.TrueAtom;
    }
}

pub fn atomFalse(comptime opt: TokenOptions, token: *TokenIterator(opt), comptime phase: ?TokenPhase) ParseError!void {
    const chunk = token.consume(6, phase);
    const dword_alse = shared.intFromSlice(u32, "alse").*;
    const dword_atom = shared.intFromSlice(u32, chunk[1..][0..4]).*;
    const not_struct_white = shared.Tables.is_structural_or_whitespace_negated;
    if (dword_alse != dword_atom or not_struct_white[chunk[5]]) {
        return error.FalseAtom;
    }
}

pub fn atomNull(comptime opt: TokenOptions, token: *TokenIterator(opt), comptime phase: ?TokenPhase) ParseError!void {
    const chunk = token.consume(5, phase);
    const dword_null = shared.intFromSlice(u32, "null").*;
    const dword_atom = shared.intFromSlice(u32, chunk[0..4]).*;
    const not_struct_white = shared.Tables.is_structural_or_whitespace_negated;
    if (dword_null != dword_atom or not_struct_white[chunk[4]]) {
        return error.NullAtom;
    }
}
