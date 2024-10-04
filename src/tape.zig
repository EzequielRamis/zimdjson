const std = @import("std");
const tracy = @import("tracy");
const common = @import("common.zig");
const types = @import("types.zig");
const tokens = @import("tokens.zig");
const ArrayList = std.ArrayList;
const MultiArrayList = @import("multi_array_list.zig").MultiArrayList;
const assert = std.debug.assert;

const Allocator = std.mem.Allocator;
const Error = types.Error;

const State = enum {
    start,
    object_begin,
    object_field,
    object_continue,
    array_begin,
    array_value,
    array_continue,
    scope_end,
    end,
};

const Tag = enum(u8) {
    true = 't',
    false = 'f',
    null = 'n',
    unsigned = @intFromEnum(types.Number.unsigned),
    signed = @intFromEnum(types.Number.signed),
    float = @intFromEnum(types.Number.float),
    string = 's',
    object_opening = '{',
    object_closing = '}',
    array_opening = '[',
    array_closing = ']',
};

const Word = packed struct {
    tag: Tag,
    data: packed struct {
        len: u24,
        ptr: u32,
    },
};

const Context = struct {
    tag: Tag,
    len: u32,
    ptr: u32,
};

pub const Options = struct {
    max_depth: u32,
    aligned: bool,
};

pub fn Tape(comptime options: Options) type {
    const token_options = tokens.Options{
        .aligned = options.aligned,
    };

    return struct {
        const Self = @This();
        const Tokens = tokens.Iterator(token_options);
        const Aligned = types.Aligned(options.aligned);
        const Words = ArrayList(u64);
        const Stack = MultiArrayList(Context);

        parsed: Words,
        stack: Stack,
        tokens: Tokens,
        chars_buf: ArrayList(u8),
        chars_ptr: [*]u8 = undefined,
        allocator: Allocator,

        pub fn init(allocator: Allocator) Self {
            return Self{
                .parsed = Words.init(allocator),
                .stack = Stack{},
                .tokens = Tokens.init(allocator),
                .chars_buf = ArrayList(u8).init(allocator),
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.parsed.deinit();
            self.stack.deinit(self.allocator);
            self.tokens.deinit();
            self.chars_buf.deinit();
        }

        pub fn build(self: *Self, doc: Aligned.slice) !void {
            const t = &self.tokens;
            try t.build(doc);

            const tracer = tracy.traceNamed(@src(), "Tape");
            defer tracer.end();

            try self.chars_buf.ensureTotalCapacity(t.indexer.reader.document.len + types.Vector.len_bytes);
            try self.stack.ensureTotalCapacity(self.allocator, options.max_depth);
            try self.parsed.ensureTotalCapacity(t.indexer.indexes.items.len);

            self.chars_ptr = self.chars_buf.items.ptr;
            self.stack.shrinkRetainingCapacity(0);
            self.parsed.shrinkRetainingCapacity(0);

            return self.dispatch();
        }

        fn dispatch(self: *Self) Error!void {
            state: switch (State.start) {
                .start => {
                    const t = self.tokens.next();
                    switch (t[0]) {
                        '{' => {
                            if (self.tokens.peek()[0] == '}') {
                                self.visitEmptyObject();
                                continue :state .end;
                            }
                            continue :state .object_begin;
                        },
                        '[' => {
                            if (self.tokens.peek()[0] == ']') {
                                self.visitEmptyArray();
                                continue :state .end;
                            }
                            continue :state .array_begin;
                        },
                        else => {
                            try self.visitPrimitive(t);
                            continue :state .end;
                        },
                    }
                },
                .object_begin => {
                    if (self.stack.len >= options.max_depth)
                        return error.ExceededDepth;

                    self.stack.appendAssumeCapacity(.{
                        .tag = .object_opening,
                        .ptr = @intCast(self.parsed.items.len),
                        .len = 1,
                    });
                    self.parsed.items.len += 1;
                    continue :state .object_field;
                },
                .object_field => {
                    {
                        const t = self.tokens.next();
                        if (t[0] == '"') {
                            try self.visitString(t);
                        } else {
                            return error.ExpectedKey;
                        }
                    }
                    if (self.tokens.next()[0] == ':') {
                        const t = self.tokens.next();
                        switch (t[0]) {
                            '{' => {
                                if (self.tokens.peek()[0] == '}') {
                                    self.visitEmptyObject();
                                    continue :state .object_continue;
                                }
                                continue :state .object_begin;
                            },
                            '[' => {
                                if (self.tokens.peek()[0] == ']') {
                                    self.visitEmptyArray();
                                    continue :state .object_continue;
                                }
                                continue :state .array_begin;
                            },
                            else => {
                                try self.visitPrimitive(t);
                                continue :state .object_continue;
                            },
                        }
                    } else {
                        return error.ExpectedColon;
                    }
                },
                .object_continue => {
                    switch (self.tokens.next()[0]) {
                        ',' => {
                            self.incrementContainerCount();
                            continue :state .object_field;
                        },
                        '}' => {
                            assert(self.stack.items(.tag)[self.stack.len - 1] == .object_opening);
                            assert(self.stack.capacity != 0);
                            const scope_ptr = self.stack.items(.ptr)[self.stack.len - 1];
                            assert(self.stack.capacity != 0);
                            const scope_len = self.stack.items(.len)[self.stack.len - 1];
                            self.parsed.appendAssumeCapacity(@bitCast(Word{
                                .tag = .object_closing,
                                .data = .{
                                    .ptr = scope_ptr,
                                    .len = undefined,
                                },
                            }));
                            self.parsed.items[scope_ptr] = @bitCast(Word{
                                .tag = .object_opening,
                                .data = .{
                                    .ptr = @intCast(self.parsed.items.len),
                                    .len = @intCast(@min(scope_len, std.math.maxInt(u24))),
                                },
                            });
                            continue :state .scope_end;
                        },
                        else => return error.ExpectedObjectCommaOrEnd,
                    }
                },
                .array_begin => {
                    if (self.stack.len >= options.max_depth)
                        return error.ExceededDepth;
                    self.stack.appendAssumeCapacity(.{
                        .tag = .array_opening,
                        .ptr = @intCast(self.parsed.items.len),
                        .len = 1,
                    });
                    self.parsed.items.len += 1;
                    continue :state .array_value;
                },
                .array_value => {
                    const t = self.tokens.next();
                    switch (t[0]) {
                        '{' => {
                            if (self.tokens.peek()[0] == '}') {
                                self.visitEmptyObject();
                                continue :state .array_continue;
                            }
                            continue :state .object_begin;
                        },
                        '[' => {
                            if (self.tokens.peek()[0] == ']') {
                                self.visitEmptyArray();
                                continue :state .array_continue;
                            }
                            continue :state .array_begin;
                        },
                        else => {
                            try self.visitPrimitive(t);
                            continue :state .array_continue;
                        },
                    }
                },
                .array_continue => {
                    const t = self.tokens.next();
                    switch (t[0]) {
                        ',' => {
                            self.incrementContainerCount();
                            continue :state .array_value;
                        },
                        ']' => {
                            assert(self.stack.items(.tag)[self.stack.len - 1] == .array_opening);
                            assert(self.stack.capacity != 0);
                            const scope_ptr = self.stack.items(.ptr)[self.stack.len - 1];
                            assert(self.stack.capacity != 0);
                            const scope_len = self.stack.items(.len)[self.stack.len - 1];
                            self.parsed.appendAssumeCapacity(@bitCast(Word{
                                .tag = .array_closing,
                                .data = .{
                                    .ptr = scope_ptr,
                                    .len = undefined,
                                },
                            }));
                            self.parsed.items[scope_ptr] = @bitCast(Word{
                                .tag = .array_opening,
                                .data = .{
                                    .ptr = @intCast(self.parsed.items.len),
                                    .len = @intCast(@min(scope_len, std.math.maxInt(u24))),
                                },
                            });
                            continue :state .scope_end;
                        },
                        else => return error.ExpectedArrayCommaOrEnd,
                    }
                },
                .scope_end => {
                    self.stack.len -= 1;
                    if (self.stack.len == 0) {
                        @branchHint(.unlikely);
                        continue :state .end;
                    }
                    assert(self.stack.capacity != 0);
                    const parent = self.stack.items(.tag)[self.stack.len - 1];
                    switch (parent) {
                        .array_opening => continue :state .array_continue,
                        .object_opening => continue :state .object_continue,
                        else => unreachable,
                    }
                },
                .end => {
                    // const trail = self.tokens.next();
                    // if (trail[0] != ' ') return error.TrailingContent;
                    self.chars_buf.items.len = @intFromPtr(self.chars_ptr) - @intFromPtr(self.chars_buf.items.ptr);
                },
            }
        }

        inline fn incrementContainerCount(self: *Self) void {
            assert(self.stack.capacity != 0);
            const scope: *u32 = @ptrCast(&self.stack.items(.len)[self.stack.len - 1]);
            scope.* += 1;
        }

        inline fn visitPrimitive(self: *Self, ptr: [*]const u8) Error!void {
            const t = ptr[0];
            switch (t) {
                '"' => {
                    @branchHint(.likely);
                    return self.visitString(ptr);
                },
                else => switch (t) {
                    't' => return self.visitTrue(ptr),
                    'f' => return self.visitFalse(ptr),
                    'n' => return self.visitNull(ptr),
                    else => {
                        @branchHint(.likely);
                        return self.visitNumber(ptr);
                    },
                },
            }
        }

        inline fn visitEmptyObject(self: *Self) void {
            self.parsed.appendAssumeCapacity(@bitCast(Word{
                .tag = .object_opening,
                .data = .{
                    .ptr = @intCast(self.parsed.items.len + 2),
                    .len = 0,
                },
            }));
            self.parsed.appendAssumeCapacity(@bitCast(Word{
                .tag = .object_closing,
                .data = .{
                    .ptr = @intCast(self.parsed.items.len),
                    .len = undefined,
                },
            }));
            _ = self.tokens.next();
        }

        inline fn visitEmptyArray(self: *Self) void {
            self.parsed.appendAssumeCapacity(@bitCast(Word{
                .tag = .array_opening,
                .data = .{
                    .ptr = @intCast(self.parsed.items.len + 2),
                    .len = 0,
                },
            }));
            self.parsed.appendAssumeCapacity(@bitCast(Word{
                .tag = .array_closing,
                .data = .{
                    .ptr = @intCast(self.parsed.items.len),
                    .len = undefined,
                },
            }));
            _ = self.tokens.next();
        }

        inline fn visitString(self: *Self, ptr: [*]const u8) Error!void {
            const parse = @import("parsers/string.zig").writeString;
            const next_len = self.chars_buf.addManyAsArrayAssumeCapacity(4);
            const next_str = self.chars_ptr + 4;
            const sentinel = try parse(ptr, next_str);
            next_len.* = @bitCast(@as(u32, @intCast(@intFromPtr(sentinel) - @intFromPtr(next_str))));
            self.parsed.appendAssumeCapacity(@bitCast(Word{
                .tag = .string,
                .data = .{
                    .ptr = @intCast(@intFromPtr(next_str) - @intFromPtr(self.chars_buf.items.ptr)),
                    .len = undefined,
                },
            }));
            self.chars_ptr = sentinel;
        }

        inline fn visitNumber(self: *Self, ptr: [*]const u8) Error!void {
            const parser = @import("parsers/number/parser.zig").Parser;
            const number = try parser.parse(ptr);
            self.parsed.appendAssumeCapacity(@bitCast(Word{
                .tag = @enumFromInt(@intFromEnum(number)),
                .data = undefined,
            }));
            self.parsed.appendAssumeCapacity(switch (number) {
                .unsigned => |n| @bitCast(n),
                .signed => |n| @bitCast(n),
                .float => |n| @bitCast(n),
            });
        }

        inline fn visitTrue(self: *Self, ptr: [*]const u8) Error!void {
            const check = @import("parsers/atoms.zig").checkTrue;
            try check(ptr);
            self.parsed.appendAssumeCapacity(@bitCast(Word{
                .tag = .true,
                .data = undefined,
            }));
        }

        inline fn visitFalse(self: *Self, ptr: [*]const u8) Error!void {
            const check = @import("parsers/atoms.zig").checkFalse;
            try check(ptr);
            self.parsed.appendAssumeCapacity(@bitCast(Word{
                .tag = .false,
                .data = undefined,
            }));
        }

        inline fn visitNull(self: *Self, ptr: [*]const u8) Error!void {
            const check = @import("parsers/atoms.zig").checkNull;
            try check(ptr);
            self.parsed.appendAssumeCapacity(@bitCast(Word{
                .tag = .null,
                .data = undefined,
            }));
        }
    };
}
