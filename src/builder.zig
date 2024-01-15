const std = @import("std");
const builtin = @import("builtin");
const shared = @import("shared.zig");
const validator = @import("validator.zig");
const simd = std.simd;
const vector = shared.vector;
const vector_size = shared.vector_size;
const vector_mask = shared.vector_mask;
const mask = shared.mask;

const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const TapeError = shared.TapeError;

fn NodeWord(comptime tag: u8) type {
    return packed struct {
        tag: u8 = tag,
        value: u56 = 0,
    };
}

fn NodeDWord(comptime tag: u8) type {
    return packed struct {
        tag: u64 = tag,
        value: u64 = 0,
    };
}

pub const Node = packed union {
    true_atom: NodeWord('t'),
    false_atom: NodeWord('f'),
    null_atom: NodeWord('n'),
    signed: NodeDWord('i'),
    unsigned: NodeDWord('u'),
    float: NodeDWord('d'),
    string: NodeWord('"'),
    array_begin: NodeWord('['),
    array_end: NodeWord(']'),
    object_begin: NodeWord('{'),
    object_end: NodeWord('}'),
    root: NodeWord('r'),
};

const State = enum {
    object_begin,
    object_field,
    object_continue,
    array_begin,
    array_value,
    array_continue,
    scope_end,
};

const Stack = struct {
    is_array: std.BitStack,
    indexes: ArrayList(u56),

    pub fn init(allocator: Allocator) Stack {
        return Stack{
            .is_array = std.BitStack.init(allocator),
            .indexes = ArrayList(u56).init(allocator),
        };
    }

    pub fn deinit(self: *Stack) void {
        self.is_array.deinit();
        self.indexes.deinit();
    }
};

pub const Tape = struct {
    document: []const u8,
    parsed: ArrayList(Node),
    string_slices: ArrayList([:0]const u8),
    strings_value: ArrayList(u8),
    state: ?State = null,
    stack: Stack,
    indexes: ArrayList(usize),
    next_structural: usize = 0,

    fn next(self: *Tape) ?[]const u8 {
        if (self.next_structural == self.indexes.items.len) {
            return null;
        }
        const res = self.document[self.indexes.items[self.next_structural]..];
        self.next_structural += 1;
        return res;
    }

    fn peek(self: *Tape) ?[]const u8 {
        if (self.next_structural == self.indexes.items.len) {
            return null;
        }
        const res = self.document[self.indexes.items[self.next_structural]..];
        return res;
    }

    pub fn init(allocator: Allocator, input: []const u8, indexes: ArrayList(usize)) Tape {
        return Tape{
            .document = input,
            .parsed = ArrayList(Node).init(allocator),
            .string_slices = ArrayList([:0]const u8).init(allocator),
            .strings_value = ArrayList(u8).init(allocator),
            .stack = Stack.init(allocator),
            .indexes = indexes,
        };
    }

    pub fn deinit(self: *Tape) void {
        self.parsed.deinit();
        self.string_slices.deinit();
        self.strings_value.deinit();
        self.stack.deinit();
    }

    pub fn build(self: *Tape) !void {
        if (self.next()) |first_char| {
            switch (first_char[0]) {
                '{' => {
                    self.state = State.object_begin;
                },
                '[' => {
                    self.state = State.array_begin;
                },
                '"' => {
                    if (first_char.len < 1) {
                        return TapeError.NonTerminatedString;
                    }
                    const strings_len = self.strings_value.items.len;
                    try validator.string(self.strings_value, first_char[1..]);
                    const string_slice = self.strings_value.items[strings_len..];
                    try self.string_slices.append(string_slice);
                    try self.parsed.append(Node{ .string = .{ .value = @intCast(strings_len) } });
                },
                't' => {
                    try validator.true_atom(first_char);
                    try self.parsed.append(Node{.true_atom});
                },
                'f' => {
                    try validator.false_atom(first_char);
                    try self.parsed.append(Node{.false_atom});
                },
                'n' => {
                    try validator.null_atom(first_char);
                    try self.parsed.append(Node{.null_atom});
                },
                '-', '0'...'9' => {},
                else => return TapeError.NonValue,
            }
        } else {
            return TapeError.Empty;
        }

        while (self.state) |state| {
            switch (state) {
                .object_begin => {
                    try self.stack.is_array.push(false);
                    if (self.next()) |char| {
                        switch (char[0]) {
                            '"' => {
                                self.state = State.object_field;
                            },
                            '}' => {
                                self.state = State.scope_end;
                            },
                            else => return TapeError.ObjectBegin,
                        }
                    } else {
                        return TapeError.ObjectBegin;
                    }
                },
                .object_field => {
                    if (self.next()) |maybe_colon| {
                        if (maybe_colon[0] == ':') {
                            if (self.next()) |value| {
                                switch (value[0]) {
                                    '{' => {
                                        self.state = State.object_begin;
                                        continue;
                                    },
                                    '[' => {
                                        self.state = State.array_begin;
                                        continue;
                                    },
                                    '"' => {
                                        if (value.len < 1) {
                                            return TapeError.NonTerminatedString;
                                        }
                                        const strings_len = self.strings_value.items.len;
                                        try validator.string(self.strings_value, value[1..]);
                                        const string_slice = self.strings_value.items[strings_len..];
                                        try self.string_slices.append(string_slice);
                                        try self.parsed.append(Node{ .string = .{ .value = @intCast(strings_len) } });
                                    },
                                    't' => {
                                        try validator.true_atom(value);
                                        try self.parsed.append(Node{.true_atom});
                                    },
                                    'f' => {
                                        try validator.false_atom(value);
                                        try self.parsed.append(Node{.false_atom});
                                    },
                                    'n' => {
                                        try validator.null_atom(value);
                                        try self.parsed.append(Node{.null_atom});
                                    },
                                    '-', '0'...'9' => {},
                                    else => return TapeError.NonValue,
                                }
                                self.state = State.object_continue;
                            } else {
                                return TapeError.MissingValue;
                            }
                        } else {
                            return TapeError.Colon;
                        }
                    } else {
                        return TapeError.Colon;
                    }
                },
                .object_continue => {
                    if (self.next()) |char| {
                        switch (char[0]) {
                            ',' => {
                                // increment count
                                if (self.next()) |maybe_key| {
                                    if (maybe_key[0] == '"') {
                                        self.state = State.object_field;
                                    } else {
                                        return TapeError.MissingKey;
                                    }
                                } else {
                                    return TapeError.MissingKey;
                                }
                            },
                            '}' => {
                                self.state = State.scope_end;
                            },
                            else => return TapeError.MissingComma,
                        }
                    } else {
                        return TapeError.MissingComma;
                    }
                },
                .array_begin => {
                    try self.stack.is_array.push(false);
                    if (self.next()) |char| {
                        switch (char[0]) {
                            '"' => {
                                self.state = State.array_field;
                            },
                            ']' => {
                                self.state = State.scope_end;
                            },
                            else => return TapeError.ArrayBegin,
                        }
                    } else {
                        return TapeError.ArrayBegin;
                    }
                },
                .array_value => {
                    if (self.next()) |value| {
                        switch (value[0]) {
                            '{' => {
                                self.state = State.object_begin;
                                continue;
                            },
                            '[' => {
                                self.state = State.array_begin;
                                continue;
                            },
                            '"' => {
                                if (value.len < 1) {
                                    return TapeError.NonTerminatedString;
                                }
                                const strings_len = self.strings_value.items.len;
                                try validator.string(self.strings_value, value[1..]);
                                const string_slice = self.strings_value.items[strings_len..];
                                try self.string_slices.append(string_slice);
                                try self.parsed.append(Node{ .string = .{ .value = @intCast(strings_len) } });
                            },
                            't' => {
                                try validator.true_atom(value);
                                try self.parsed.append(Node{.true_atom});
                            },
                            'f' => {
                                try validator.false_atom(value);
                                try self.parsed.append(Node{.false_atom});
                            },
                            'n' => {
                                try validator.null_atom(value);
                                try self.parsed.append(Node{.null_atom});
                            },
                            '-', '0'...'9' => {},
                            else => return TapeError.NonValue,
                        }
                        self.state = State.array_continue;
                    } else {
                        return TapeError.MissingValue;
                    }
                },
                .array_continue => {
                    if (self.next()) |char| {
                        switch (char[0]) {
                            ',' => {
                                // increment count
                                self.state = State.array_value;
                            },
                            ']' => {
                                self.state = State.scope_end;
                            },
                            else => return TapeError.MissingComma,
                        }
                    } else {
                        return TapeError.MissingComma;
                    }
                },
                .scope_end => {
                    // decrement count
                    if (self.stack.indexes.items.len == 0) {
                        self.state = null;
                        break;
                    }
                    if (self.stack.is_array[self.stack.indexes.items.len - 1]) {
                        self.state = State.array_continue;
                    } else {
                        self.state = State.object_continue;
                    }
                },
            }
        }

        // document_end handle
    }
};
