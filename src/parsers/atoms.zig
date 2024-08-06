const std = @import("std");
const common = @import("../common.zig");
const types = @import("../types.zig");
const tokens = @import("../tokens.zig");
const TokenIterator = tokens.Iterator;
const TokenOptions = tokens.Options;
const TokenPhase = tokens.Phase;
const Error = types.Error;
const readInt = std.mem.readInt;

pub inline fn checkBool(comptime opt: TokenOptions, src: TokenIterator(opt)) Error!bool {
    const is_true = if (checkTrue(opt, src)) true else |_| false;
    const is_false = if (checkFalse(opt, src)) true else |_| false;
    return if (is_true or is_false) is_true else error.ExpectedValue;
}

pub inline fn checkTrue(comptime opt: TokenOptions, src: TokenIterator(opt)) Error!void {
    const chunk = src.ptr[0..5];
    const dword_true = readInt(u32, "true", .little);
    const dword_atom = readInt(u32, chunk[0..4], .little);
    const not_struct_white = common.tables.is_structural_or_whitespace_negated;
    if (dword_true != dword_atom or not_struct_white[chunk[4]]) {
        return error.ExpectedValue;
    }
}

pub inline fn checkFalse(comptime opt: TokenOptions, src: TokenIterator(opt)) Error!void {
    const chunk = src.ptr[0..6];
    const dword_alse = readInt(u32, "alse", .little);
    const dword_atom = readInt(u32, chunk[1..][0..4], .little);
    const not_struct_white = common.tables.is_structural_or_whitespace_negated;
    if (dword_alse != dword_atom or not_struct_white[chunk[5]]) {
        return error.ExpectedValue;
    }
}

pub inline fn checkNull(comptime opt: TokenOptions, src: TokenIterator(opt)) Error!void {
    const chunk = src.ptr[0..5];
    const dword_null = readInt(u32, "null", .little);
    const dword_atom = readInt(u32, chunk[0..4], .little);
    const not_struct_white = common.tables.is_structural_or_whitespace_negated;
    if (dword_null != dword_atom or not_struct_white[chunk[4]]) {
        return error.ExpectedValue;
    }
}
