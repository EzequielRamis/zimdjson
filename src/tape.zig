const std = @import("std");
const tracy = @import("tracy");
const common = @import("common.zig");
const types = @import("types.zig");
const tokens = @import("tokens.zig");
const ArrayList = std.ArrayList;
const MultiArrayList = std.MultiArrayList;
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

pub const FitPtr = struct {
    ptr: u32,
    len: u32,
};

const WordTag = enum(u8) {
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
    root = 'r',
};

pub const Word = union(WordTag) {
    true,
    false,
    null,
    unsigned: u64,
    signed: i64,
    float: f64,
    string: FitPtr,
    object_opening: FitPtr,
    object_closing: FitPtr,
    array_opening: FitPtr,
    array_closing: FitPtr,
    root: FitPtr,
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

        parsed: MultiArrayList(Word),
        stack: MultiArrayList(Word),
        tokens: Tokens,
        chars: ArrayList(u8),
        allocator: Allocator,

        pub fn init(allocator: Allocator) Self {
            return Self{
                .parsed = MultiArrayList(Word){},
                .stack = MultiArrayList(Word){},
                .tokens = Tokens.init(allocator),
                .chars = ArrayList(u8).init(allocator),
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.parsed.deinit(self.allocator);
            self.stack.deinit(self.allocator);
            self.tokens.deinit();
            self.chars.deinit();
        }

        pub fn build(self: *Self, doc: Aligned.slice) !void {
            const t = &self.tokens;
            try t.build(doc);

            const tracer = tracy.traceNamed(@src(), "Tape");
            defer tracer.end();

            try self.chars.ensureTotalCapacity(t.indexer.reader.document.len + types.Vector.len_bytes);
            try self.stack.ensureTotalCapacity(self.allocator, options.max_depth);
            try self.parsed.ensureTotalCapacity(self.allocator, t.indexer.indexes.items.len + 2);
            self.chars.shrinkRetainingCapacity(0);
            self.stack.shrinkRetainingCapacity(0);
            self.parsed.shrinkRetainingCapacity(0);

            self.stack.appendAssumeCapacity(.{ .root = .{ .ptr = 0, .len = 0 } });
            self.parsed.appendAssumeCapacity(.{ .root = .{ .ptr = 0, .len = 0 } });

            return self.dispatch();
        }

        fn dispatch(self: *Self) Error!void {
            state: switch (State.start) {
                .start => {
                    const t = self.tokens.next();
                    switch (t[0]) {
                        '{' => {
                            if (self.tokens.peek()[0] == '}') {
                                @branchHint(.unlikely);
                                try self.visitEmptyObject();
                                continue :state .end;
                            }
                            continue :state .object_begin;
                        },
                        '[' => {
                            if (self.tokens.peek()[0] == ']') {
                                @branchHint(.unlikely);
                                try self.visitEmptyArray();
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

                    self.stack.appendAssumeCapacity(.{ .object_opening = .{
                        .ptr = @intCast(self.parsed.len),
                        .len = 1,
                    } });
                    self.parsed.appendAssumeCapacity(.{ .object_opening = undefined });
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
                                    @branchHint(.unlikely);
                                    try self.visitEmptyObject();
                                    continue :state .object_continue;
                                }
                                continue :state .object_begin;
                            },
                            '[' => {
                                if (self.tokens.peek()[0] == ']') {
                                    @branchHint(.unlikely);
                                    try self.visitEmptyArray();
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
                            assert(self.stack.capacity != 0);
                            self.stack.len -= 1;
                            assert(self.stack.items(.tags).ptr[self.stack.len] == .object_opening);
                            const scope: *FitPtr = @ptrCast(&self.stack.items(.data).ptr[self.stack.len]);
                            assert(self.parsed.capacity != 0);
                            const scope_root: *FitPtr = @ptrCast(&self.parsed.items(.data)[scope.ptr]);
                            self.parsed.appendAssumeCapacity(.{ .object_closing = scope.* });
                            scope_root.len = scope.len;
                            scope_root.ptr = @intCast(self.parsed.len);
                            continue :state .scope_end;
                        },
                        else => return error.ExpectedObjectCommaOrEnd,
                    }
                },
                .array_begin => {
                    if (self.stack.len >= options.max_depth)
                        return error.ExceededDepth;
                    self.stack.appendAssumeCapacity(.{ .array_opening = .{
                        .ptr = @intCast(self.parsed.len),
                        .len = 1,
                    } });
                    self.parsed.appendAssumeCapacity(.{ .array_opening = undefined });
                    continue :state .array_value;
                },
                .array_value => {
                    const t = self.tokens.next();
                    switch (t[0]) {
                        '{' => {
                            if (self.tokens.peek()[0] == '}') {
                                @branchHint(.unlikely);
                                try self.visitEmptyObject();
                                continue :state .array_continue;
                            }
                            continue :state .object_begin;
                        },
                        '[' => {
                            if (self.tokens.peek()[0] == ']') {
                                @branchHint(.unlikely);
                                try self.visitEmptyArray();
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
                            assert(self.stack.capacity != 0);
                            self.stack.len -= 1;
                            assert(self.stack.items(.tags).ptr[self.stack.len] == .array_opening);
                            const scope: *FitPtr = @ptrCast(&self.stack.items(.data).ptr[self.stack.len]);
                            assert(self.parsed.capacity != 0);
                            const scope_root: *FitPtr = @ptrCast(&self.parsed.items(.data)[scope.ptr]);
                            self.parsed.appendAssumeCapacity(.{ .array_closing = scope.* });
                            scope_root.len = scope.len;
                            scope_root.ptr = @intCast(self.parsed.len);
                            continue :state .scope_end;
                        },
                        else => return error.ExpectedArrayCommaOrEnd,
                    }
                },
                .scope_end => {
                    assert(self.stack.capacity != 0);
                    const parent = self.stack.items(.tags)[self.stack.len - 1];
                    switch (parent) {
                        .array_opening => continue :state .array_continue,
                        .object_opening => continue :state .object_continue,
                        .root => {
                            @branchHint(.unlikely);
                            continue :state .end;
                        },
                        else => unreachable,
                    }
                },
                .end => {
                    const trail = self.tokens.next();
                    if (trail[0] != ' ') return error.TrailingContent;
                    assert(self.parsed.capacity != 0);
                    const root: *FitPtr = @ptrCast(&self.parsed.items(.data)[0]);
                    root.ptr = @intCast(self.parsed.len);
                    self.parsed.appendAssumeCapacity(.{ .root = .{ .ptr = 0, .len = 0 } });
                },
            }
        }

        inline fn incrementContainerCount(self: *Self) void {
            assert(self.stack.capacity != 0);
            const scope: *FitPtr = @ptrCast(&self.stack.items(.data)[self.stack.len - 1]);
            scope.len += 1;
        }

        inline fn visitPrimitive(self: *Self, ptr: [*]const u8) Error!void {
            const t = ptr[0];
            switch (t) {
                '"' => {
                    @branchHint(.likely);
                    return self.visitString(ptr);
                },
                't' => {
                    @branchHint(.unlikely);
                    return self.visitTrue(ptr);
                },
                'f' => {
                    @branchHint(.unlikely);
                    return self.visitFalse(ptr);
                },
                'n' => {
                    @branchHint(.unlikely);
                    return self.visitNull(ptr);
                },
                else => {
                    @branchHint(.likely);
                    return self.visitNumber(ptr);
                },
            }
        }

        inline fn visitEmptyObject(self: *Self) Error!void {
            self.parsed.appendAssumeCapacity(.{ .object_opening = .{
                .ptr = @intCast(self.parsed.len + 2),
                .len = 0,
            } });
            self.parsed.appendAssumeCapacity(.{ .object_closing = .{
                .ptr = @intCast(self.parsed.len),
                .len = 0,
            } });
            _ = self.tokens.next();
        }

        inline fn visitEmptyArray(self: *Self) Error!void {
            self.parsed.appendAssumeCapacity(.{ .array_opening = .{
                .ptr = @intCast(self.parsed.len + 2),
                .len = 0,
            } });
            self.parsed.appendAssumeCapacity(.{ .array_closing = .{
                .ptr = @intCast(self.parsed.len),
                .len = 0,
            } });
            _ = self.tokens.next();
        }

        inline fn visitString(self: *Self, ptr: [*]const u8) Error!void {
            const chars = &self.chars;
            const next_str = chars.items.len;
            const parse = @import("parsers/string.zig").writeString;
            try parse(ptr, chars);
            const next_len = chars.items.len - next_str;
            self.parsed.appendAssumeCapacity(.{ .string = .{ .ptr = @intCast(next_str), .len = @intCast(next_len) } });
        }

        inline fn visitNumber(self: *Self, ptr: [*]const u8) Error!void {
            const parser = @import("parsers/number/parser.zig").Parser;
            const number = try parser.parse(ptr);
            const word: Word = switch (number) {
                .unsigned => |n| .{ .unsigned = n },
                .signed => |n| .{ .signed = n },
                .float => |n| .{ .float = n },
            };
            self.parsed.appendAssumeCapacity(word);
        }

        inline fn visitTrue(self: *Self, ptr: [*]const u8) Error!void {
            const check = @import("parsers/atoms.zig").checkTrue;
            try check(ptr);
            self.parsed.appendAssumeCapacity(.true);
        }

        inline fn visitFalse(self: *Self, ptr: [*]const u8) Error!void {
            const check = @import("parsers/atoms.zig").checkFalse;
            try check(ptr);
            self.parsed.appendAssumeCapacity(.false);
        }

        inline fn visitNull(self: *Self, ptr: [*]const u8) Error!void {
            const check = @import("parsers/atoms.zig").checkNull;
            try check(ptr);
            self.parsed.appendAssumeCapacity(.null);
        }
    };
}
