const std = @import("std");
const shared = @import("shared.zig");
const validator = @import("validator.zig");
const BoundedArrayList = @import("bounded_array_list.zig").BoundedArrayList;
const BoundedBitStack = @import("BoundedBitStack.zig");
const Indexer = @import("Indexer.zig");
const TokenIterator = @import("TokenIterator.zig");
const TokenPhase = TokenIterator.Phase;
const log = std.log;
const assert = std.debug.assert;

const Allocator = std.mem.Allocator;
const ParseError = shared.ParseError;

const MAX_DEPTH = 1024;
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
    resume_object_begin,
    resume_object_field_colon,
    resume_object_field_value,
    resume_object_continue_comma,
    resume_object_continue_key,
    resume_array_value,
    resume_array_continue,
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
    string_key: usize,
    string_key_raw: usize,
    string_value: usize,
    string_value_raw: usize,
    object_begin: usize,
    object_end: usize,
    array_begin: usize,
    array_end: usize,
};

const Stack = struct {
    is_array: BoundedBitStack,
    indexes: BoundedArrayList(u56),

    pub fn init(allocator: Allocator) Stack {
        return Stack{
            .is_array = BoundedBitStack.init(allocator),
            .indexes = BoundedArrayList(u56).init(allocator),
        };
    }

    pub fn deinit(self: *Stack) void {
        self.is_array.deinit();
        self.indexes.deinit();
    }

    pub fn withCapacity(self: *Stack, size: usize) Allocator.Error!void {
        try self.is_array.withCapacity(size);
        try self.indexes.withCapacity(size);
    }
};

tokens: TokenIterator,
parsed: BoundedArrayList(Node),
chars: BoundedArrayList(u8),
stack: Stack,

pub fn init(allocator: Allocator, indexer: Indexer) Self {
    return Self{
        .tokens = TokenIterator.init(indexer),
        .parsed = BoundedArrayList(Node).init(allocator),
        .chars = BoundedArrayList(u8).init(allocator),
        .stack = Stack.init(allocator),
    };
}

pub fn deinit(self: *Self) void {
    self.parsed.deinit();
    self.chars.deinit();
    self.stack.deinit();
}

pub fn build(self: *Self) ParseError!void {
    var t = &self.tokens;
    try self.chars.withCapacity(self.tokens.indexer.reader.document.len);
    try self.parsed.withCapacity(self.tokens.indexer.indexes.list.items.len);
    try self.stack.withCapacity(MAX_DEPTH);

    if (t.empty()) {
        return ParseError.Empty;
    }
    switch (t.peek(1)) {
        '{' => try self.analyze_object_begin(.unbounded),
        '[' => try self.analyze_array_begin(.unbounded),
        else => try self.visit_primitive(.bounded),
    }

    log.info("Node size: {}", .{@bitSizeOf(Node) / 8});
    log.info("Tape size: {}", .{self.parsed.list.items.len * (@bitSizeOf(Node) / 8)});
}

inline fn dispatch(self: *Self, comptime phase: TokenPhase, next_state: State) ParseError!void {
    const next_op = switch (next_state) {
        .object_begin => analyze_object_begin,
        .object_field => analyze_object_field,
        .object_continue => analyze_object_continue,
        .array_begin => analyze_array_begin,
        .array_value => analyze_array_value,
        .array_continue => analyze_array_continue,
        .scope_end => analyze_scope_end,
        .resume_object_begin => resume_object_begin,
        .resume_object_field_colon => resume_object_field_colon,
        .resume_object_field_value => resume_object_field_value,
        .resume_object_continue_comma => resume_object_continue_comma,
        .resume_object_continue_key => resume_object_continue_key,
        .resume_array_value => resume_array_value,
        .resume_array_continue => resume_array_continue,
        else => unreachable,
    };

    return @call(.always_tail, next_op, .{ self, phase });
}

fn analyze_object_begin(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase != .bounded);
    var t = &self.tokens;
    log.info("OBJ BEGIN", .{});
    self.stack.is_array.push(0);
    if (t.advance(phase)) {
        switch (t.peek(1)) {
            '"' => {
                try self.visit_string(phase);
                return self.dispatch(phase, .object_field);
            },
            '}' => {
                log.info("OBJ END", .{});
                return self.dispatch(phase, .scope_end);
            },
            else => return ParseError.ObjectBegin,
        }
    } else {
        if (phase == .unbounded) {
            return self.dispatch(.bounded, .resume_object_begin);
        } else {
            return ParseError.ObjectBegin;
        }
    }
}

fn resume_object_begin(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase == .bounded);
    var t = &self.tokens;
    _ = t.advance(phase);
    switch (t.peek(1)) {
        '"' => {
            try self.visit_string(.padded);
            return self.dispatch(.padded, .object_field);
        },
        '}' => {
            log.info("OBJ END", .{});
            return self.dispatch(.padded, .scope_end);
        },
        else => return ParseError.ObjectBegin,
    }
}

fn analyze_object_field(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase != .bounded);
    var t = &self.tokens;
    if (t.advance(phase)) {
        if (t.peek(1) == ':') {
            if (t.advance(phase)) {
                switch (t.peek(1)) {
                    '{' => return self.dispatch(phase, .object_begin),
                    '[' => return self.dispatch(phase, .array_begin),
                    else => {
                        try self.visit_primitive(phase);
                        return self.dispatch(phase, .object_continue);
                    },
                }
            } else {
                if (phase == .unbounded) {
                    return self.dispatch(.bounded, .resume_object_field_value);
                } else {
                    return ParseError.MissingValue;
                }
            }
        } else {
            return ParseError.Colon;
        }
    } else {
        if (phase == .unbounded) {
            return self.dispatch(.bounded, .resume_object_field_colon);
        } else {
            return ParseError.Colon;
        }
    }
}

fn resume_object_field_colon(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase == .bounded);
    var t = &self.tokens;
    _ = t.advance(phase);
    if (t.peek(1) == ':') {
        if (t.advance(.padded)) {
            switch (t.peek(1)) {
                '{' => return self.dispatch(.padded, .object_begin),
                '[' => return self.dispatch(.padded, .array_begin),
                else => {
                    try self.visit_primitive(.padded);
                    return self.dispatch(.padded, .object_continue);
                },
            }
        } else {
            return ParseError.MissingValue;
        }
    } else {
        return ParseError.Colon;
    }
}

fn resume_object_field_value(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase == .bounded);
    var t = &self.tokens;
    _ = t.advance(phase);
    switch (t.peek(1)) {
        '{' => return self.dispatch(.padded, .object_begin),
        '[' => return self.dispatch(.padded, .array_begin),
        else => {
            try self.visit_primitive(.padded);
            return self.dispatch(.padded, .object_continue);
        },
    }
}

fn analyze_object_continue(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase != .bounded);
    var t = &self.tokens;
    if (t.advance(phase)) {
        switch (t.peek(1)) {
            ',' => {
                if (t.advance(phase)) {
                    if (t.peek(1) == '"') {
                        try self.visit_string(phase);
                        return self.dispatch(phase, .object_field);
                    } else {
                        return ParseError.MissingKey;
                    }
                } else {
                    if (phase == .unbounded) {
                        return self.dispatch(.bounded, .resume_object_continue_key);
                    } else {
                        return ParseError.MissingKey;
                    }
                }
            },
            '}' => {
                log.info("OBJ END", .{});
                return self.dispatch(phase, .scope_end);
            },
            else => return ParseError.MissingComma,
        }
    } else {
        if (phase == .unbounded) {
            return self.dispatch(.bounded, .resume_object_continue_comma);
        } else {
            return ParseError.MissingComma;
        }
    }
}

fn resume_object_continue_comma(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase == .bounded);
    var t = &self.tokens;
    _ = t.advance(phase);
    switch (t.peek(1)) {
        ',' => {
            if (t.advance(.padded)) {
                if (t.peek(1) == '"') {
                    try self.visit_string(.padded);
                    return self.dispatch(.padded, .object_field);
                } else {
                    return ParseError.MissingKey;
                }
            } else {
                return ParseError.MissingKey;
            }
        },
        '}' => {
            log.info("OBJ END", .{});
            return self.dispatch(.padded, .scope_end);
        },
        else => return ParseError.MissingComma,
    }
}

fn resume_object_continue_key(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase == .bounded);
    var t = &self.tokens;
    _ = t.advance(phase);
    if (t.peek(1) == '"') {
        try self.visit_string(.padded);
        return self.dispatch(.padded, .object_field);
    } else {
        return ParseError.MissingKey;
    }
}

fn analyze_array_begin(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase != .bounded);
    log.info("ARR BEGIN", .{});
    self.stack.is_array.push(1);
    return self.dispatch(phase, .array_value);
}

fn analyze_array_value(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase != .bounded);
    var t = &self.tokens;
    if (t.advance(phase)) {
        switch (t.peek(1)) {
            '{' => return self.dispatch(phase, .object_begin),
            '[' => return self.dispatch(phase, .array_begin),
            ']' => return self.dispatch(phase, .scope_end),
            else => {
                try self.visit_primitive(phase);
                return self.dispatch(phase, .array_continue);
            },
        }
    } else {
        if (phase == .unbounded) {
            return self.dispatch(.bounded, .resume_array_value);
        } else {
            return ParseError.MissingValue;
        }
    }
}

fn resume_array_value(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase == .bounded);
    var t = &self.tokens;
    _ = t.advance(phase);
    switch (t.peek(1)) {
        '{' => return self.dispatch(.padded, .object_begin),
        '[' => return self.dispatch(.padded, .array_begin),
        ']' => return self.dispatch(.padded, .scope_end),
        else => {
            try self.visit_primitive(.padded);
            return self.dispatch(.padded, .array_continue);
        },
    }
}

fn analyze_array_continue(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase != .bounded);
    var t = &self.tokens;
    if (t.advance(phase)) {
        switch (t.peek(1)) {
            ',' => {
                // increment count
                return self.dispatch(phase, .array_value);
            },
            ']' => {
                log.info("ARR END", .{});
                return self.dispatch(phase, .scope_end);
            },
            else => return ParseError.MissingComma,
        }
    } else {
        if (phase == .unbounded) {
            return self.dispatch(.bounded, .resume_array_continue);
        } else {
            return ParseError.MissingComma;
        }
    }
}

fn resume_array_continue(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase == .bounded);
    var t = &self.tokens;
    _ = t.advance(phase);
    switch (t.peek(1)) {
        ',' => {
            // increment count
            return self.dispatch(.padded, .array_value);
        },
        ']' => {
            log.info("ARR END", .{});
            return self.dispatch(.padded, .scope_end);
        },
        else => return ParseError.MissingComma,
    }
}

fn analyze_scope_end(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase != .bounded);
    // _ = self.stack.indexes.pop();
    _ = self.stack.is_array.pop();
    if (self.stack.is_array.bit_len == 0) {
        return;
    }
    const last = self.stack.is_array.peek();
    if (last == 1) {
        return self.dispatch(phase, .array_continue);
    } else {
        return self.dispatch(phase, .object_continue);
    }
}

inline fn visit_primitive(self: *Self, comptime phase: TokenPhase) ParseError!void {
    var t = &self.tokens;
    switch (t.peek(1)) {
        '"' => try self.visit_string(phase),
        't' => try self.visit_true(phase),
        'f' => try self.visit_false(phase),
        'n' => try self.visit_null(phase),
        '-', '0'...'9' => try self.visit_number(phase),
        else => return ParseError.NonValue,
    }
}

inline fn visit_string(self: *Self, comptime phase: TokenPhase) ParseError!void {
    var t = &self.tokens;
    _ = t.next(1, phase);
    const next_str = self.chars.len;
    try validator.string(t, &self.chars, phase);
    const next_len = self.chars.len - 1;
    self.parsed.append(.{ .string_value = next_str });
    log.info("STR {s}", .{self.chars.list.items[next_str..next_len]});
}

inline fn visit_number(_: *Self, comptime _: TokenPhase) ParseError!void {
    // var t = &self.tokens;
    // const number = try validator.number(tokens);
    // try self.parsed.append(.{ .float = number });
    log.info("NUM", .{});
}

inline fn visit_true(self: *Self, comptime phase: TokenPhase) ParseError!void {
    const t = &self.tokens;
    try validator.true_atom(t, phase);
    self.parsed.append(.{ .true_atom = {} });
    log.info("TRU", .{});
}

inline fn visit_false(self: *Self, comptime phase: TokenPhase) ParseError!void {
    const t = &self.tokens;
    try validator.false_atom(t, phase);
    self.parsed.append(.{ .false_atom = {} });
    log.info("FAL", .{});
}

inline fn visit_null(self: *Self, comptime phase: TokenPhase) ParseError!void {
    const t = &self.tokens;
    try validator.null_atom(t, phase);
    self.parsed.append(.{ .null_atom = {} });
    log.info("NUL", .{});
}
