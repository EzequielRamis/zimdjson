const std = @import("std");
const shared = @import("shared.zig");
const validator = @import("validator.zig");
const Prefixes = @import("prefixes.zig");
const Prefix = Prefixes.Prefix;
const log = std.log;

const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const TapeError = shared.TapeError;
const Self = @This();

const State = enum {
    object_begin,
    object_field,
    object_continue,
    array_begin,
    array_value,
    array_continue,
    scope_end,
    end,
};

const NodeTag = enum {
    root,
    true_atom,
    false_atom,
    null_atom,
    unsigned,
    signed,
    float,
    big_int,
    string_key,
    string_key_raw,
    string_value,
    string_value_raw,
    object_begin,
    object_end,
    array_begin,
    array_end,
};

const Node = union(NodeTag) {
    root: usize,
    true_atom: void,
    false_atom: void,
    null_atom: void,
    unsigned: u64,
    signed: i64,
    float: f64,
    big_int: [:0]const u8,
    string_key: [:0]const u8,
    string_key_raw: [:0]const u8,
    string_value: [:0]const u8,
    string_value_raw: [:0]const u8,
    object_begin: usize,
    object_end: usize,
    array_begin: usize,
    array_end: usize,
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

prefixes: Prefixes,
parsed: std.MultiArrayList(Node),
string_slices: ArrayList([:0]const u8),
strings_value: ArrayList(u8),
state: State = .end,
stack: Stack,
allocator: Allocator,

pub fn init(allocator: Allocator, prefixes: Prefixes) Self {
    return Self{
        .prefixes = prefixes,
        .parsed = std.MultiArrayList(Node){},
        .string_slices = ArrayList([:0]const u8).init(allocator),
        .strings_value = ArrayList(u8).init(allocator),
        .stack = Stack.init(allocator),
        .allocator = allocator,
    };
}

pub fn deinit(self: *Self) void {
    self.parsed.deinit(self.allocator);
    self.string_slices.deinit();
    self.strings_value.deinit();
    self.stack.deinit();
}

pub fn build(self: *Self) !void {
    if (self.prefixes.next()) |prefix| {
        switch (prefix.value()) {
            .object => self.state = .object_begin,
            .array => self.state = .array_begin,
            else => try self.visit_primitive(prefix),
        }
    } else {
        return TapeError.Empty;
    }

    while (true) {
        switch (self.state) {
            .object_begin => {
                log.debug("OBJ BEGIN", .{});
                if (self.prefixes.next()) |prefix| {
                    switch (prefix.value()) {
                        .string => try self.visit_key(prefix),
                        .object_end => {
                            self.state = .scope_end;
                            log.debug("OBJ END", .{});
                        },
                        else => return TapeError.ObjectBegin,
                    }
                } else {
                    return TapeError.ObjectBegin;
                }
            },
            .object_field => {
                if (self.prefixes.next()) |colon| {
                    if (colon.value() == .colon) {
                        if (self.prefixes.next()) |prefix| {
                            switch (prefix.value()) {
                                .object => {
                                    self.state = .object_begin;
                                    try self.stack.is_array.push(0);
                                    continue;
                                },
                                .array => {
                                    self.state = .array_begin;
                                    try self.stack.is_array.push(0);
                                    continue;
                                },
                                else => try self.visit_primitive(prefix),
                            }
                            self.state = .object_continue;
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
                if (self.prefixes.next()) |prefix| {
                    switch (prefix.value()) {
                        .comma => {
                            if (self.prefixes.next()) |maybe_key| {
                                if (maybe_key.value() == .string) {
                                    try self.visit_key(maybe_key);
                                } else {
                                    return TapeError.MissingKey;
                                }
                            } else {
                                return TapeError.MissingKey;
                            }
                        },
                        .object_end => {
                            self.state = .scope_end;
                            log.debug("OBJ END", .{});
                        },
                        else => return TapeError.MissingComma,
                    }
                } else {
                    return TapeError.MissingComma;
                }
            },
            .array_begin => {
                log.debug("ARR BEGIN", .{});
                if (self.prefixes.next()) |prefix| {
                    switch (prefix.value()) {
                        .array => {
                            try self.stack.is_array.push(1);
                            continue;
                        },
                        .array_end => {
                            self.state = .scope_end;
                            log.debug("ARR END", .{});
                            continue;
                        },
                        .object => {
                            self.state = .object_begin;
                            try self.stack.is_array.push(1);
                            continue;
                        },
                        else => try self.visit_primitive(prefix),
                    }
                    self.state = .array_continue;
                } else {
                    return TapeError.ArrayBegin;
                }
            },
            .array_value => {
                if (self.prefixes.next()) |prefix| {
                    switch (prefix.value()) {
                        .object => {
                            self.state = State.object_begin;
                            try self.stack.is_array.push(1);
                            continue;
                        },
                        .array => {
                            self.state = State.array_begin;
                            try self.stack.is_array.push(1);
                            continue;
                        },
                        else => try self.visit_primitive(prefix),
                    }
                    self.state = .array_continue;
                } else {
                    return TapeError.MissingValue;
                }
            },
            .array_continue => {
                if (self.prefixes.next()) |prefix| {
                    switch (prefix.value()) {
                        .comma => {
                            // increment count
                            self.state = .array_value;
                        },
                        .array_end => {
                            self.state = .scope_end;
                            log.debug("ARR END", .{});
                        },
                        else => return TapeError.MissingComma,
                    }
                } else {
                    return TapeError.MissingComma;
                }
            },
            .scope_end => {
                if (self.stack.is_array.bit_len == 0) {
                    self.state = .end;
                    break;
                }
                _ = self.stack.indexes.popOrNull();
                const last = self.stack.is_array.pop();
                if (last == 1) {
                    self.state = .array_continue;
                } else {
                    self.state = .object_continue;
                }
            },
            .end => break,
        }
    }

    log.info("Node size: {}", .{@bitSizeOf(Node) / 8});
    log.info("Tape size: {}", .{self.parsed.len * (@bitSizeOf(Node) / 8)});
}

fn visit_primitive(self: *Self, prefix: Prefix) !void {
    switch (prefix.value()) {
        .string => try self.visit_string(prefix),
        .tru => try self.visit_true(prefix),
        .fal => try self.visit_false(prefix),
        .nul => try self.visit_null(prefix),
        .number => try self.visit_number(prefix),
        else => return TapeError.NonValue,
    }
}

fn visit_key(self: *Self, prefix: Prefix) !void {
    if (prefix.next()) |key| {
        const field_slice = try validator.string(&self.strings_value, key.slice);
        try self.string_slices.append(field_slice);
        try self.parsed.append(self.allocator, .{ .string_value = field_slice });
        log.debug("OBJ KEY {s}", .{field_slice});
        self.state = .object_field;
    } else {
        return TapeError.MissingKey;
    }
}

fn visit_string(self: *Self, prefix: Prefix) !void {
    if (prefix.next()) |str| {
        const string_slice = try validator.string(&self.strings_value, str.slice);
        try self.string_slices.append(string_slice);
        try self.parsed.append(self.allocator, .{ .string_value = string_slice });
        log.debug("STR {s}", .{string_slice});
    } else {
        return TapeError.NonTerminatedString;
    }
}

fn visit_number(self: *Self, prefix: Prefix) !void {
    const number = try validator.number(prefix.slice);
    switch (number) {
        .unsigned => |n| {
            try self.parsed.append(self.allocator, Node{ .unsigned = n });
            log.debug("NUM {}", .{n});
        },
        .signed => |n| {
            try self.parsed.append(self.allocator, Node{ .signed = @bitCast(n) });
            log.debug("NUM {}", .{n});
        },
        .float => |n| {
            try self.parsed.append(self.allocator, Node{ .float = @bitCast(n) });
            log.debug("NUM {}", .{n});
        },
    }
}

fn visit_true(self: *Self, prefix: Prefix) !void {
    try validator.true_atom(prefix.slice);
    try self.parsed.append(self.allocator, Node{ .true_atom = {} });
    log.debug("TRU", .{});
}

fn visit_false(self: *Self, prefix: Prefix) !void {
    try validator.false_atom(prefix.slice);
    try self.parsed.append(self.allocator, .{ .false_atom = {} });
    log.debug("FAL", .{});
}

fn visit_null(self: *Self, prefix: Prefix) !void {
    try validator.null_atom(prefix.slice);
    try self.parsed.append(self.allocator, .{ .null_atom = {} });
    log.debug("NUL", .{});
}
