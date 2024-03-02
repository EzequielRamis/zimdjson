const std = @import("std");
const shared = @import("shared.zig");
const validator = @import("validator.zig");
const BoundedArrayList = @import("bounded_array_list.zig").BoundedArrayList;
const Indexer = @import("Indexer.zig");
const TokenIterator = @import("TokenIterator.zig");
const log = std.log;

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
    is_array: std.BitStack,
    indexes: std.ArrayList(u56),

    pub fn init(allocator: Allocator) Stack {
        return Stack{
            .is_array = std.BitStack.init(allocator),
            .indexes = std.ArrayList(u56).init(allocator),
        };
    }

    pub fn deinit(self: *Stack) void {
        self.is_array.deinit();
        self.indexes.deinit();
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

pub fn build(self: *Self) !void {
    var state: State = .end;
    try self.chars.withCapacity(self.tokens.indexer.reader.document.len);
    try self.parsed.withCapacity(self.tokens.indexer.indexes.list.items.len);

    if (self.tokens.empty()) {
        return TapeError.Empty;
    }
    switch (self.tokens.peek()) {
        '{' => state = .object_begin,
        '[' => state = .array_begin,
        else => try self.visit_primitive(),
    }

    // https://github.com/ziglang/zig/issues/8220
    while (true) {
        switch (state) {
            .end => break,
            .object_begin => {
                state = try self.analyze_object_begin();
                continue;
            },
            .object_field => {
                state = try self.analyze_object_field();
                continue;
            },
            .object_continue => {
                state = try self.analyze_object_continue();
                continue;
            },
            .array_begin => {
                state = try self.analyze_array_begin();
                continue;
            },
            .array_value => {
                state = try self.analyze_array_value();
                continue;
            },
            .array_continue => {
                state = try self.analyze_array_continue();
                continue;
            },
            .scope_end => {
                state = try self.analyze_scope_end();
                continue;
            },
        }
    }

    log.info("Node size: {}\n", .{@bitSizeOf(Node) / 8});
    log.info("Tape size: {}\n", .{self.parsed.list.items.len * (@bitSizeOf(Node) / 8)});
}

fn analyze_object_begin(self: *Self) !State {
    // std.debug.print("OBJ BEGIN\n", .{});
    if (self.tokens.advance()) |t| {
        switch (t.peek()) {
            '"' => {
                try self.visit_string();
                return .object_field;
            },
            '}' => {
                // std.debug.print("OBJ END\n", .{});
                return .scope_end;
            },
            else => return TapeError.ObjectBegin,
        }
    } else {
        return TapeError.ObjectBegin;
    }
}

fn analyze_object_field(self: *Self) !State {
    if (self.tokens.advance()) |c| {
        if (c.peek() == ':') {
            if (c.advance()) |p| {
                switch (p.peek()) {
                    '{' => {
                        try self.stack.is_array.push(0);
                        return .object_begin;
                    },
                    '[' => {
                        try self.stack.is_array.push(0);
                        return .array_begin;
                    },
                    else => try self.visit_primitive(),
                }
            } else {
                return TapeError.MissingValue;
            }
        } else {
            return TapeError.Colon;
        }
    } else {
        return TapeError.Colon;
    }
    return .object_continue;
}

fn analyze_object_continue(self: *Self) !State {
    if (self.tokens.advance()) |p| {
        switch (p.peek()) {
            ',' => {
                if (p.advance()) |k| {
                    if (k.peek() == '"') {
                        try self.visit_string();
                        return .object_field;
                    } else {
                        return TapeError.MissingKey;
                    }
                } else {
                    return TapeError.MissingKey;
                }
            },
            '}' => {
                // std.debug.print("OBJ END\n", .{});
                return .scope_end;
            },
            else => return TapeError.MissingComma,
        }
    } else {
        return TapeError.MissingComma;
    }
}

fn analyze_array_begin(self: *Self) !State {
    // std.debug.print("ARR BEGIN\n", .{});
    if (self.tokens.advance()) |p| {
        switch (p.peek()) {
            '[' => {
                try self.stack.is_array.push(1);
                return .array_begin;
            },
            ']' => {
                // std.debug.print("ARR END\n", .{});
                return .scope_end;
            },
            '{' => {
                try self.stack.is_array.push(1);
                return .object_begin;
            },
            else => try self.visit_primitive(),
        }
    } else {
        return TapeError.ArrayBegin;
    }
    return .array_continue;
}

fn analyze_array_value(self: *Self) !State {
    if (self.tokens.advance()) |p| {
        switch (p.peek()) {
            '{' => {
                try self.stack.is_array.push(1);
                return .object_begin;
            },
            '[' => {
                try self.stack.is_array.push(1);
                return .array_begin;
            },
            else => try self.visit_primitive(),
        }
    } else {
        return TapeError.MissingValue;
    }
    return .array_continue;
}

fn analyze_array_continue(self: *Self) !State {
    if (self.tokens.advance()) |p| {
        switch (p.peek()) {
            ',' => {
                // increment count
                return .array_value;
            },
            ']' => {
                // std.debug.print("ARR END\n", .{});
                return .scope_end;
            },
            else => return TapeError.MissingComma,
        }
    } else {
        return TapeError.MissingComma;
    }
}

fn analyze_scope_end(self: *Self) !State {
    if (self.stack.is_array.bit_len == 0) {
        return .end;
    }
    _ = self.stack.indexes.popOrNull();
    const last = self.stack.is_array.pop();
    if (last == 1) {
        return .array_continue;
    } else {
        return .object_continue;
    }
}

fn visit_primitive(self: *Self) !void {
    switch (self.tokens.peek()) {
        '"' => try self.visit_string(),
        't' => try self.visit_true(),
        'f' => try self.visit_false(),
        'n' => try self.visit_null(),
        '-', '0'...'9' => try self.visit_number(),
        else => return TapeError.NonValue,
    }
}

fn visit_string(self: *Self) !void {
    self.tokens.nextVoid(1);
    const next_str = self.chars.next;
    try validator.string(&self.tokens, &self.chars);
    self.parsed.append(.{ .string_value = next_str });
    // std.debug.print("STR {s}\n", .{self.chars.list.items[next_str..]});
}

fn visit_number(_: *Self) !void {
    // const number = try validator.number(tokens);
    // try self.parsed.append(.{ .float = number });
    // std.debug.print("NUM\n", .{});
}

fn visit_true(self: *Self) !void {
    try validator.true_atom(&self.tokens);
    self.parsed.append(.{ .true_atom = {} });
    // std.debug.print("TRU\n", .{});
}

fn visit_false(self: *Self) !void {
    try validator.false_atom(&self.tokens);
    self.parsed.append(.{ .false_atom = {} });
    // std.debug.print("FAL\n", .{});
}

fn visit_null(self: *Self) !void {
    try validator.null_atom(&self.tokens);
    self.parsed.append(.{ .null_atom = {} });
    // std.debug.print("NUL\n", .{});
}
