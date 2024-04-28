const std = @import("std");
const shared = @import("shared.zig");
const types = @import("types.zig");
const validator = @import("validator.zig");
const tokens = @import("tokens.zig");
const ArrayList = std.ArrayList;
const BitStack = std.BitStack;
const Indexer = @import("Indexer.zig");
const TokenIterator = tokens.Iterator;
const TokenOptions = tokens.Options;
const TokenPhase = tokens.Phase;
const log = std.log;
const assert = std.debug.assert;

const Allocator = std.mem.Allocator;
const ParseError = types.ParseError;

const TOKEN_OPTIONS = TokenOptions{
    .copy_bounded = false,
};

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

max_depth: usize = shared.DEFAULT_MAX_DEPTH,
tokens: TokenIterator(TOKEN_OPTIONS),
parsed: ArrayList(u64),
stack: ArrayList(u64),
chars: ArrayList(u8),

pub fn init(allocator: Allocator) Self {
    return Self{
        .tokens = TokenIterator(TOKEN_OPTIONS).init(),
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
    if (t.empty()) return error.Empty;

    try self.chars.ensureTotalCapacity(self.tokens.indexer.reader.document.len);
    try self.stack.ensureTotalCapacity(self.max_depth);
    try self.parsed.ensureTotalCapacity(self.tokens.indexer.indexes.items.len);
    self.chars.shrinkRetainingCapacity(0);
    self.stack.shrinkRetainingCapacity(0);
    self.parsed.shrinkRetainingCapacity(0);

    self.parsed.appendAssumeCapacity(@bitCast(Element{ .tag = Tag.root }));
    self.stack.appendAssumeCapacity(@bitCast(Element{ .tag = Tag.root }));

    switch (t.next(.unbounded).?) {
        '{' => try self.analyze_object_begin(.unbounded),
        '[' => try self.analyze_array_begin(.unbounded),
        else => |token| try self.visit_primitive(.bounded, token),
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
    log.info("OBJ BEGIN", .{});

    if (self.stack.items.len >= self.max_depth)
        return error.Depth;
    const elem = Element{
        .tag = Tag.object_begin,
        .data = @bitCast(Container{
            .index = @truncate(self.parsed.items.len),
            .count = 0,
        }),
    };
    self.parsed.appendAssumeCapacity(@bitCast(elem));
    self.stack.appendAssumeCapacity(@bitCast(elem));

    if (self.tokens.next(phase)) |t| {
        switch (t) {
            '"' => {
                self.increment_container_count();
                try self.visit_string(phase);
                return self.dispatch(phase, .object_field);
            },
            '}' => {
                log.info("OBJ END", .{});
                return self.dispatch(phase, .scope_end);
            },
            else => return error.InvalidStructure,
        }
    } else {
        if (phase == .unbounded) {
            return self.dispatch(.bounded, .resume_object_begin);
        } else {
            return error.InvalidStructure;
        }
    }
}

fn resume_object_begin(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase == .bounded);
    switch (self.tokens.next(phase).?) {
        '"' => {
            self.increment_container_count();
            try self.visit_string(.padded);
            return self.dispatch(.padded, .object_field);
        },
        '}' => {
            log.info("OBJ END", .{});
            return self.dispatch(.padded, .scope_end);
        },
        else => return error.InvalidStructure,
    }
}

fn analyze_object_field(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase != .bounded);
    if (self.tokens.next(phase)) |t| {
        if (t == ':') {
            if (self.tokens.next(phase)) |r| {
                switch (r) {
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
                    return error.InvalidStructure;
                }
            }
        } else {
            return error.InvalidStructure;
        }
    } else {
        if (phase == .unbounded) {
            return self.dispatch(.bounded, .resume_object_field_colon);
        } else {
            return error.InvalidStructure;
        }
    }
}

fn resume_object_field_colon(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase == .bounded);
    if (self.tokens.next(phase).? == ':') {
        if (self.tokens.next(.padded)) |t| {
            switch (t) {
                '{' => return self.dispatch(.padded, .object_begin),
                '[' => return self.dispatch(.padded, .array_begin),
                else => {
                    try self.visit_primitive(.padded);
                    return self.dispatch(.padded, .object_continue);
                },
            }
        } else {
            return error.InvalidStructure;
        }
    } else {
        return error.InvalidStructure;
    }
}

fn resume_object_field_value(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase == .bounded);
    switch (self.tokens.next(phase).?) {
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
    if (self.tokens.next(phase)) |t| {
        switch (t) {
            ',' => {
                if (self.tokens.next(phase)) |r| {
                    if (r == '"') {
                        self.increment_container_count();
                        try self.visit_string(phase);
                        return self.dispatch(phase, .object_field);
                    } else {
                        return error.InvalidStructure;
                    }
                } else {
                    if (phase == .unbounded) {
                        return self.dispatch(.bounded, .resume_object_continue_key);
                    } else {
                        return error.InvalidStructure;
                    }
                }
            },
            '}' => {
                log.info("OBJ END", .{});
                return self.dispatch(phase, .scope_end);
            },
            else => return error.InvalidStructure,
        }
    } else {
        if (phase == .unbounded) {
            return self.dispatch(.bounded, .resume_object_continue_comma);
        } else {
            return error.InvalidStructure;
        }
    }
}

fn resume_object_continue_comma(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase == .bounded);
    switch (self.tokens.next(phase).?) {
        ',' => {
            if (self.tokens.next(.padded)) |t| {
                if (t == '"') {
                    self.increment_container_count();
                    try self.visit_string(.padded);
                    return self.dispatch(.padded, .object_field);
                } else {
                    return error.InvalidStructure;
                }
            } else {
                return error.InvalidStructure;
            }
        },
        '}' => {
            log.info("OBJ END", .{});
            return self.dispatch(.padded, .scope_end);
        },
        else => return error.InvalidStructure,
    }
}

fn resume_object_continue_key(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase == .bounded);
    if (self.tokens.next(phase).? == '"') {
        self.increment_container_count();
        try self.visit_string(.padded);
        return self.dispatch(.padded, .object_field);
    } else {
        return error.InvalidStructure;
    }
}

fn analyze_array_begin(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase != .bounded);
    log.info("ARR BEGIN", .{});

    if (self.stack.items.len >= self.max_depth)
        return error.Depth;
    const elem = Element{
        .tag = Tag.array_begin,
        .data = @bitCast(Container{
            .index = @truncate(self.parsed.items.len),
            .count = 0,
        }),
    };
    self.parsed.appendAssumeCapacity(@bitCast(elem));
    self.stack.appendAssumeCapacity(@bitCast(elem));

    if (self.tokens.next(phase)) |t| {
        if (t == ']') {
            log.info("ARR END", .{});
            return self.dispatch(phase, .scope_end);
        }
        self.increment_container_count();
        switch (t) {
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
            return error.InvalidStructure;
        }
    }
}

fn resume_array_begin(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase == .bounded);
    const t = self.tokens.next(phase).?;
    if (t == ']') {
        log.info("ARR END", .{});
        return self.dispatch(.padded, .scope_end);
    }
    self.increment_container_count();
    switch (t) {
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
    if (self.tokens.next(phase)) |t| {
        self.increment_container_count();
        switch (t) {
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
            return error.InvalidStructure;
        }
    }
}

fn resume_array_value(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase == .bounded);
    self.increment_container_count();
    switch (self.tokens.next(phase).?) {
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
    if (self.tokens.next(phase)) |t| {
        switch (t) {
            ',' => {
                self.increment_container_count();
                return self.dispatch(phase, .array_value);
            },
            ']' => {
                log.info("ARR END", .{});
                return self.dispatch(phase, .scope_end);
            },
            else => return error.InvalidStructure,
        }
    } else {
        if (phase == .unbounded) {
            return self.dispatch(.bounded, .resume_array_continue);
        } else {
            return error.InvalidStructure;
        }
    }
}

fn resume_array_continue(self: *Self, comptime phase: TokenPhase) ParseError!void {
    assert(phase == .bounded);
    switch (self.tokens.next(phase).?) {
        ',' => {
            return self.dispatch(.padded, .array_value);
        },
        ']' => {
            log.info("ARR END", .{});
            return self.dispatch(.padded, .scope_end);
        },
        else => return error.InvalidStructure,
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

inline fn visit_primitive(self: *Self, comptime phase: TokenPhase, token: u8) ParseError!void {
    switch (token) {
        '"' => try self.visit_string(phase),
        't' => try self.visit_true(phase),
        'f' => try self.visit_false(phase),
        'n' => try self.visit_null(phase),
        '-', '0'...'9' => try self.visit_number(phase),
        else => return error.NonValue,
    }
}

inline fn visit_string(self: *Self, comptime phase: TokenPhase) ParseError!void {
    var t = &self.tokens;
    _ = t.consume(1, phase);
    const len_slot = shared.intFromSlice(u32, self.chars.addManyAsArrayAssumeCapacity(4));
    const next_str = self.chars.items.len;
    try validator.string(t, &self.chars, phase);
    const next_len = self.chars.items.len - 1 - next_str;
    len_slot.* = @truncate(self.chars.items.len - 1 - next_str);
    self.parsed.appendAssumeCapacity(@bitCast(Element{ .tag = .string, .data = @truncate(next_str) }));
    log.info("STR {s}", .{self.chars.items[next_str..][0..next_len]});
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
