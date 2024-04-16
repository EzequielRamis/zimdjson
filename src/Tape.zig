const std = @import("std");
const shared = @import("shared.zig");
const validator = @import("validator.zig");
const ArrayList = std.ArrayList;
const BitStack = std.BitStack;
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
    resume_array_begin,
    resume_array_value,
    resume_array_continue,
};

const Tag = enum(u8) {
    root = 'r',
    true = 't',
    false = 'f',
    null = 'n',
    unsigned = 'u',
    signed = 'i',
    float = 'd',
    string = '"',
    object_begin = '{',
    object_end = '}',
    array_begin = '[',
    array_end = ']',
    _,
};

pub const Element = packed struct(u64) {
    tag: Tag,
    data: u56 = 0,
};

pub const Container = packed struct(u56) {
    index: u32,
    count: u24,
};

tokens: TokenIterator,
parsed: ArrayList(u64),
stack: ArrayList(u64),
chars: ArrayList(u8),

pub fn init(allocator: Allocator) Self {
    return Self{
        .tokens = TokenIterator.init(),
        .parsed = ArrayList(u64).init(allocator),
        .stack = ArrayList(u64).init(allocator),
        .chars = ArrayList(u8).init(allocator),
    };
}

pub fn deinit(self: *Self) void {
    self.parsed.deinit();
    self.stack.deinit();
    self.chars.deinit();
}

pub fn build(self: *Self, indexer: Indexer) ParseError!void {
    var t = &self.tokens;
    t.analyze(indexer);
    try self.chars.ensureTotalCapacity(self.tokens.indexer.reader.document.len);
    try self.stack.ensureTotalCapacity(MAX_DEPTH);
    try self.parsed.ensureTotalCapacity(self.tokens.indexer.indexes.items.len);
    self.chars.shrinkRetainingCapacity(0);
    self.stack.shrinkRetainingCapacity(0);
    self.parsed.shrinkRetainingCapacity(0);

    if (t.empty()) {
        return ParseError.Empty;
    }

    self.parsed.appendAssumeCapacity(@bitCast(Element{ .tag = Tag.root }));
    self.stack.appendAssumeCapacity(@bitCast(Element{ .tag = Tag.root }));

    switch (t.peek(1)) {
        '{' => try self.analyze_object_begin(.unbounded),
        '[' => try self.analyze_array_begin(.unbounded),
        else => try self.visit_primitive(.bounded),
    }
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
        .resume_array_begin => resume_array_begin,
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

    if (self.stack.items.len >= MAX_DEPTH)
        return error.MaxDepth;
    const elem = Element{
        .tag = Tag.object_begin,
        .data = @bitCast(Container{
            .index = @truncate(self.parsed.items.len),
            .count = 0,
        }),
    };
    self.parsed.appendAssumeCapacity(@bitCast(elem));
    self.stack.appendAssumeCapacity(@bitCast(elem));

    if (t.advance(phase)) {
        switch (t.peek(1)) {
            '"' => {
                self.increment_container_count();
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
            self.increment_container_count();
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
                        self.increment_container_count();
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
                    self.increment_container_count();
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
        self.increment_container_count();
        try self.visit_string(.padded);
        return self.dispatch(.padded, .object_field);
    } else {
        return ParseError.MissingKey;
    }
}

fn analyze_array_begin(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase != .bounded);
    var t = &self.tokens;
    log.info("ARR BEGIN", .{});

    if (self.stack.items.len >= MAX_DEPTH)
        return error.MaxDepth;
    const elem = Element{
        .tag = Tag.array_begin,
        .data = @bitCast(Container{
            .index = @truncate(self.parsed.items.len),
            .count = 0,
        }),
    };
    self.parsed.appendAssumeCapacity(@bitCast(elem));
    self.stack.appendAssumeCapacity(@bitCast(elem));

    if (t.advance(phase)) {
        const maybe_value = t.peek(1);
        if (maybe_value == ']') {
            log.info("ARR END", .{});
            return self.dispatch(phase, .scope_end);
        }
        self.increment_container_count();
        switch (maybe_value) {
            '{' => return self.dispatch(phase, .object_begin),
            '[' => return self.dispatch(phase, .array_begin),
            else => {
                try self.visit_primitive(phase);
                return self.dispatch(phase, .array_continue);
            },
        }
    } else {
        if (phase == .unbounded) {
            return self.dispatch(.bounded, .resume_array_begin);
        } else {
            return ParseError.MissingValue;
        }
    }
}

fn resume_array_begin(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase == .bounded);
    var t = &self.tokens;
    _ = t.advance(phase);
    const maybe_value = t.peek(1);
    if (maybe_value == ']') {
        log.info("ARR END", .{});
        return self.dispatch(.padded, .scope_end);
    }
    self.increment_container_count();
    switch (t.peek(1)) {
        '{' => return self.dispatch(.padded, .object_begin),
        '[' => return self.dispatch(.padded, .array_begin),
        else => {
            try self.visit_primitive(.padded);
            return self.dispatch(.padded, .array_continue);
        },
    }
}

fn analyze_array_value(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase != .bounded);
    var t = &self.tokens;
    if (t.advance(phase)) {
        self.increment_container_count();
        switch (t.peek(1)) {
            '{' => return self.dispatch(phase, .object_begin),
            '[' => return self.dispatch(phase, .array_begin),
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
    self.increment_container_count();
    switch (t.peek(1)) {
        '{' => return self.dispatch(.padded, .object_begin),
        '[' => return self.dispatch(.padded, .array_begin),
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
                self.increment_container_count();
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
    const scope: Element = @bitCast(self.stack.pop());
    const scope_info: Container = @bitCast(scope.data);
    const scope_begin: *Element = @ptrCast(&self.parsed.items[scope_info.index]);
    switch (scope.tag) {
        .array_begin => {
            self.parsed.appendAssumeCapacity(@bitCast(Element{ .tag = Tag.array_end, .data = scope_begin.data }));
            scope_begin.data = @truncate(self.parsed.items.len);
        },
        .object_begin => {
            self.parsed.appendAssumeCapacity(@bitCast(Element{ .tag = Tag.object_end, .data = scope_begin.data }));
            scope_begin.data = @truncate(self.parsed.items.len);
        },
        else => unreachable,
    }
    const parent: Element = @bitCast(self.stack.getLast());
    switch (parent.tag) {
        .array_begin => return self.dispatch(phase, .array_continue),
        .object_begin => return self.dispatch(phase, .object_continue),
        .root => {
            const root: *Element = @ptrCast(&self.parsed.items[parent.data]);
            self.parsed.appendAssumeCapacity(@bitCast(Element{ .tag = Tag.root, .data = root.data }));
            root.data = @truncate(self.parsed.items.len - 1);
        },
        else => unreachable,
    }
}

fn increment_container_count(self: *Self) void {
    const scope: *Element = @ptrCast(&self.stack.items[self.stack.items.len - 1]);
    var container: Container = @bitCast(scope.data);
    container.count +|= 1;
    scope.data = @bitCast(container);
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
    const next_str = self.chars.items.len;
    try validator.string(t, &self.chars, phase);
    const next_len = self.chars.items.len - 1;
    self.parsed.appendAssumeCapacity(@bitCast(Element{ .tag = .string, .data = @truncate(next_str) }));
    log.info("STR {s}", .{self.chars.items[next_str + 4 .. next_len]});
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
    self.parsed.appendAssumeCapacity(@bitCast(Element{ .tag = .true }));
    log.info("TRU", .{});
}

inline fn visit_false(self: *Self, comptime phase: TokenPhase) ParseError!void {
    const t = &self.tokens;
    try validator.false_atom(t, phase);
    self.parsed.appendAssumeCapacity(@bitCast(Element{ .tag = .false }));
    log.info("FAL", .{});
}

inline fn visit_null(self: *Self, comptime phase: TokenPhase) ParseError!void {
    const t = &self.tokens;
    try validator.null_atom(t, phase);
    self.parsed.appendAssumeCapacity(@bitCast(Element{ .tag = .null }));
    log.info("NUL", .{});
}
