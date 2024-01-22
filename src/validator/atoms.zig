const std = @import("std");
const shared = @import("../shared.zig");
const TapeError = shared.TapeError;

pub fn true_atom(input: []const u8) TapeError!void {
    const remaining_chars = input.len;
    if (remaining_chars < 4) {
        return TapeError.TrueAtom;
    }
    const dword_true = shared.intFromSlice(u32, "true");
    const dword_atom = shared.intFromSlice(u32, input[0..4]);
    const valid = check: {
        if (remaining_chars == 4) {
            break :check dword_true == dword_atom;
        } else {
            break :check dword_true == dword_atom and shared.Tables.is_structural_or_whitespace[input[4]];
        }
    };
    if (valid) {
        return;
    }
    return TapeError.FalseAtom;
}

pub fn false_atom(input: []const u8) TapeError!void {
    const remaining_chars = input.len;
    if (remaining_chars < 5) {
        return TapeError.FalseAtom;
    }
    const dword_alse = shared.intFromSlice(u32, "alse");
    const dword_atom = shared.intFromSlice(u32, input[1..5]);
    const valid = check: {
        if (remaining_chars == 5) {
            break :check dword_alse == dword_atom;
        } else {
            break :check dword_alse == dword_atom and shared.Tables.is_structural_or_whitespace[input[5]];
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
    const dword_null = shared.intFromSlice(u32, "null");
    const dword_atom = shared.intFromSlice(u32, input[0..4]);
    const valid = check: {
        if (remaining_chars == 4) {
            break :check dword_null == dword_atom;
        } else {
            break :check dword_null == dword_atom and shared.Tables.is_structural_or_whitespace[input[4]];
        }
    };
    if (valid) {
        return;
    }
    return TapeError.FalseAtom;
}
