const std = @import("std");
const common = @import("../common.zig");
const types = @import("../types.zig");
const tokens = @import("../tokens.zig");
const TokenIterator = tokens.Iterator;
const TokenOptions = tokens.Options;
const TokenPhase = tokens.Phase;
const ParseError = types.ParseError;
const intFromSlice = common.intFromSlice;

pub fn checkTrue(src: [*]const u8) ParseError!void {
    const chunk = src[0..5];
    const dword_true = intFromSlice(u32, "true").*;
    const dword_atom = intFromSlice(u32, chunk[0..4]).*;
    const not_struct_white = common.Tables.is_structural_or_whitespace_negated;
    if (dword_true != dword_atom or not_struct_white[chunk[4]]) {
        return error.TrueAtom;
    }
}

pub fn checkFalse(src: [*]const u8) ParseError!void {
    const chunk = src[0..6];
    const dword_alse = intFromSlice(u32, "alse").*;
    const dword_atom = intFromSlice(u32, chunk[1..][0..4]).*;
    const not_struct_white = common.Tables.is_structural_or_whitespace_negated;
    if (dword_alse != dword_atom or not_struct_white[chunk[5]]) {
        return error.FalseAtom;
    }
}

pub fn checkNull(src: [*]const u8) ParseError!void {
    const chunk = src[0..5];
    const dword_null = intFromSlice(u32, "null").*;
    const dword_atom = intFromSlice(u32, chunk[0..4]).*;
    const not_struct_white = common.Tables.is_structural_or_whitespace_negated;
    if (dword_null != dword_atom or not_struct_white[chunk[4]]) {
        return error.NullAtom;
    }
}
