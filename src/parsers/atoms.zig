const std = @import("std");
const common = @import("../common.zig");
const types = @import("../types.zig");
const tokens = @import("../tokens.zig");
const TokenIterator = tokens.Iterator;
const TokenOptions = tokens.Options;
const TokenPhase = tokens.Phase;
const ParseError = types.ParseError;
const readInt = std.mem.readInt;

pub fn checkTrue(comptime opt: TokenOptions, src: TokenIterator(opt)) ParseError!void {
    const chunk = src.ptr[0..5];
    const dword_true = readInt(u32, "true", .little);
    const dword_atom = readInt(u32, chunk[0..4], .little);
    const not_struct_white = common.Tables.is_structural_or_whitespace_negated;
    if (dword_true != dword_atom or not_struct_white[chunk[4]]) {
        return error.TrueAtom;
    }
}

pub fn checkFalse(comptime opt: TokenOptions, src: TokenIterator(opt)) ParseError!void {
    const chunk = src.ptr[0..6];
    const dword_alse = readInt(u32, "alse", .little);
    const dword_atom = readInt(u32, chunk[1..][0..4], .little);
    const not_struct_white = common.Tables.is_structural_or_whitespace_negated;
    if (dword_alse != dword_atom or not_struct_white[chunk[5]]) {
        return error.FalseAtom;
    }
}

pub fn checkNull(comptime opt: TokenOptions, src: TokenIterator(opt)) ParseError!void {
    const chunk = src.ptr[0..5];
    const dword_null = readInt(u32, "null", .little);
    const dword_atom = readInt(u32, chunk[0..4], .little);
    const not_struct_white = common.Tables.is_structural_or_whitespace_negated;
    if (dword_null != dword_atom or not_struct_white[chunk[4]]) {
        return error.NullAtom;
    }
}
