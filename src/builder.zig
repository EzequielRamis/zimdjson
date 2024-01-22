const std = @import("std");
const builtin = @import("builtin");
const shared = @import("shared.zig");
const validator = @import("validator.zig");
const log = std.log;
const simd = std.simd;
const vector = shared.vector;
const vector_size = shared.vector_size;
const vector_mask = shared.vector_mask;
const mask = shared.mask;

const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const TapeError = shared.TapeError;
const Node = shared.Node;

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
                    const string_slice = try validator.string(&self.strings_value, first_char[1..]);
                    try self.string_slices.append(string_slice);

                    try self.parsed.append(.{ .string = .{ .value = @intCast(@intFromPtr(string_slice.ptr)) } });
                    log.debug("STR {s}", .{string_slice});
                },
                't' => {
                    try validator.true_atom(first_char);
                    try self.parsed.append(Node{ .true_atom = .{} });
                    log.debug("TRU", .{});
                },
                'f' => {
                    try validator.false_atom(first_char);
                    try self.parsed.append(.{ .false_atom = .{} });
                    log.debug("FAL", .{});
                },
                'n' => {
                    try validator.null_atom(first_char);
                    try self.parsed.append(.{ .null_atom = .{} });
                    log.debug("NUL", .{});
                },
                '-', '0'...'9' => {
                    const number = try validator.number(first_char);
                    switch (number) {
                        .unsigned => |n| {
                            try self.parsed.append(Node{ .unsigned = .{ .value = n } });
                            log.debug("NUM {}", .{n});
                        },
                        .signed => |n| {
                            try self.parsed.append(Node{ .signed = .{ .value = @bitCast(n) } });
                            log.debug("NUM {}", .{n});
                        },
                        .float => |n| {
                            try self.parsed.append(Node{ .float = .{ .value = @bitCast(n) } });
                            log.debug("NUM {}", .{n});
                        },
                    }
                },
                else => return TapeError.NonValue,
            }
        } else {
            return TapeError.Empty;
        }

        while (self.state) |state| {
            switch (state) {
                .object_begin => {
                    log.debug("OBJ BEGIN", .{});
                    if (self.next()) |char| {
                        switch (char[0]) {
                            '"' => {
                                if (char.len > 1) {
                                    const field_slice = try validator.string(&self.strings_value, char[1..]);
                                    log.debug("OBJ KEY {s}", .{field_slice});
                                    self.state = State.object_field;
                                } else {
                                    return TapeError.MissingKey;
                                }
                            },
                            '}' => {
                                self.state = State.scope_end;
                                log.debug("OBJ END", .{});
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
                                        try self.stack.is_array.push(0);
                                        continue;
                                    },
                                    '[' => {
                                        self.state = State.array_begin;
                                        try self.stack.is_array.push(0);
                                        continue;
                                    },
                                    '"' => {
                                        if (value.len < 1) {
                                            return TapeError.NonTerminatedString;
                                        }
                                        const string_slice = try validator.string(&self.strings_value, value[1..]);
                                        try self.string_slices.append(string_slice);
                                        try self.parsed.append(Node{ .string = .{ .value = @intCast(@intFromPtr(string_slice.ptr)) } });
                                        log.debug("STR {s}", .{string_slice});
                                    },
                                    't' => {
                                        try validator.true_atom(value);
                                        try self.parsed.append(Node{ .true_atom = .{} });
                                        log.debug("TRU", .{});
                                    },
                                    'f' => {
                                        try validator.false_atom(value);
                                        try self.parsed.append(Node{ .false_atom = .{} });
                                        log.debug("FAL", .{});
                                    },
                                    'n' => {
                                        try validator.null_atom(value);
                                        try self.parsed.append(Node{ .null_atom = .{} });
                                        log.debug("NUL", .{});
                                    },
                                    '-', '0'...'9' => {
                                        const number = try validator.number(value);
                                        switch (number) {
                                            .unsigned => |n| {
                                                try self.parsed.append(Node{ .unsigned = .{ .value = n } });
                                                log.debug("NUM {}", .{n});
                                            },
                                            .signed => |n| {
                                                try self.parsed.append(Node{ .signed = .{ .value = @bitCast(n) } });
                                                log.debug("NUM {}", .{n});
                                            },
                                            .float => |n| {
                                                try self.parsed.append(Node{ .float = .{ .value = @bitCast(n) } });
                                                log.debug("NUM {}", .{n});
                                            },
                                        }
                                    },
                                    else => return TapeError.NonValue,
                                }
                                self.state = State.object_continue;
                                log.debug("OBJ CONTINUE", .{});
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
                                    if (maybe_key[0] == '"' and maybe_key.len > 1) {
                                        const field_slice = try validator.string(&self.strings_value, maybe_key[1..]);
                                        log.debug("OBJ KEY {s}", .{field_slice});
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
                    log.debug("ARR BEGIN", .{});
                    if (self.next()) |char| {
                        log.debug("NEXT ARR {s}", .{char});
                        switch (char[0]) {
                            '{' => {
                                self.state = State.object_begin;
                                try self.stack.is_array.push(1);
                                continue;
                            },
                            '[' => {
                                self.state = State.array_begin;
                                try self.stack.is_array.push(1);
                                continue;
                            },
                            '"' => {
                                if (char.len < 1) {
                                    return TapeError.NonTerminatedString;
                                }
                                const string_slice = try validator.string(&self.strings_value, char[1..]);
                                try self.string_slices.append(string_slice);
                                try self.parsed.append(Node{ .string = .{ .value = @intCast(@intFromPtr(string_slice.ptr)) } });
                                log.debug("STR {s}", .{string_slice});
                            },
                            't' => {
                                try validator.true_atom(char);
                                try self.parsed.append(Node{ .true_atom = .{} });
                                log.debug("TRU", .{});
                            },
                            'f' => {
                                try validator.false_atom(char);
                                try self.parsed.append(Node{ .false_atom = .{} });
                                log.debug("FAL", .{});
                            },
                            'n' => {
                                try validator.null_atom(char);
                                try self.parsed.append(Node{ .null_atom = .{} });
                                log.debug("NUL", .{});
                            },
                            '-', '0'...'9' => {
                                const number = try validator.number(char);
                                switch (number) {
                                    .unsigned => |n| {
                                        try self.parsed.append(Node{ .unsigned = .{ .value = n } });
                                        log.debug("NUM {}", .{n});
                                    },
                                    .signed => |n| {
                                        try self.parsed.append(Node{ .signed = .{ .value = @bitCast(n) } });
                                        log.debug("NUM {}", .{n});
                                    },
                                    .float => |n| {
                                        try self.parsed.append(Node{ .float = .{ .value = @bitCast(n) } });
                                        log.debug("NUM {}", .{n});
                                    },
                                }
                            },
                            ']' => {
                                self.state = State.scope_end;
                                continue;
                            },
                            else => return TapeError.ArrayBegin,
                        }
                        self.state = State.array_continue;
                    } else {
                        return TapeError.ArrayBegin;
                    }
                },
                .array_value => {
                    if (self.next()) |value| {
                        switch (value[0]) {
                            '{' => {
                                self.state = State.object_begin;
                                try self.stack.is_array.push(1);
                                continue;
                            },
                            '[' => {
                                self.state = State.array_begin;
                                try self.stack.is_array.push(1);
                                continue;
                            },
                            '"' => {
                                if (value.len < 1) {
                                    return TapeError.NonTerminatedString;
                                }
                                const string_slice = try validator.string(&self.strings_value, value[1..]);
                                try self.string_slices.append(string_slice);
                                try self.parsed.append(Node{ .string = .{ .value = @intCast(@intFromPtr(string_slice.ptr)) } });
                                log.debug("STR {s}", .{string_slice});
                            },
                            't' => {
                                try validator.true_atom(value);
                                try self.parsed.append(Node{ .true_atom = .{} });
                                log.debug("TRU", .{});
                            },
                            'f' => {
                                try validator.false_atom(value);
                                try self.parsed.append(Node{ .false_atom = .{} });
                                log.debug("FAL", .{});
                            },
                            'n' => {
                                try validator.null_atom(value);
                                try self.parsed.append(Node{ .null_atom = .{} });
                                log.debug("NUL", .{});
                            },
                            '-', '0'...'9' => {
                                const number = try validator.number(value);
                                switch (number) {
                                    .unsigned => |n| {
                                        try self.parsed.append(Node{ .unsigned = .{ .value = n } });
                                        log.debug("NUM {}", .{n});
                                    },
                                    .signed => |n| {
                                        try self.parsed.append(Node{ .signed = .{ .value = @bitCast(n) } });
                                        log.debug("NUM {}", .{n});
                                    },
                                    .float => |n| {
                                        try self.parsed.append(Node{ .float = .{ .value = @bitCast(n) } });
                                        log.debug("NUM {}", .{n});
                                    },
                                }
                            },
                            else => return TapeError.NonValue,
                        }
                        self.state = State.array_continue;
                        log.debug("ARR CONTINUE", .{});
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
                                log.debug("ARR VALUE", .{});
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
                    log.debug("SCOPE END", .{});
                    if (self.stack.is_array.bit_len == 0) {
                        self.state = null;
                        continue;
                    }
                    _ = self.stack.indexes.popOrNull();
                    const last = self.stack.is_array.pop();
                    if (last == 1) {
                        self.state = State.array_continue;
                        log.debug("ARR LAST", .{});
                    } else {
                        self.state = State.object_continue;
                        log.debug("OBJ LAST", .{});
                    }
                },
            }
        }

        // document_end handle
    }
};
