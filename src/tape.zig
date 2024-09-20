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
    object_begin,
    object_field,
    object_continue,
    array_begin,
    array_value,
    array_continue,
    scope_end,
};

pub const FitPtr = packed struct {
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
            const r = self.tokens.next();
            return switch (r[0]) {
                '{' => self.dispatch(.object_begin),
                '[' => self.dispatch(.array_begin),
                else => self.visitRootPrimitive(r),
            };
        }

        fn dispatch(self: *Self, state: State) Error!void {
            next: switch (state) {
                .object_begin => {
                    if (self.stack.len >= options.max_depth)
                        return error.ExceededDepth;

                    const t = self.tokens.next();
                    if (t[0] == '}') {
                        @branchHint(.unlikely);
                        self.parsed.appendAssumeCapacity(.{ .object_opening = .{
                            .ptr = @intCast(self.parsed.len + 2),
                            .len = 0,
                        } });
                        self.parsed.appendAssumeCapacity(.{ .object_closing = .{
                            .ptr = @intCast(self.parsed.len),
                            .len = 0,
                        } });
                        continue :next .scope_end;
                    }
                    switch (t[0]) {
                        '"' => {
                            const word = Word{ .object_opening = .{
                                .ptr = @intCast(self.parsed.len),
                                .len = 0,
                            } };
                            self.parsed.appendAssumeCapacity(word);
                            self.stack.appendAssumeCapacity(word);
                            self.incrementContainerCount();
                            try self.visitString(t);
                            continue :next .object_field;
                        },
                        else => return error.ExpectedObjectCommaOrEnd,
                    }
                },
                .object_field => {
                    const t = self.tokens.next();
                    if (t[0] == ':') {
                        const r = self.tokens.next();
                        switch (r[0]) {
                            '{' => continue :next .object_begin,
                            '[' => continue :next .array_begin,
                            else => {
                                try self.visitPrimitive(r);
                                continue :next .object_continue;
                            },
                        }
                    } else {
                        return error.ExpectedColon;
                    }
                },
                .object_continue => {
                    const t = self.tokens.next();
                    switch (t[0]) {
                        ',' => {
                            const r = self.tokens.next();
                            if (r[0] == '"') {
                                self.incrementContainerCount();
                                try self.visitString(r);
                                continue :next .object_field;
                            } else {
                                return error.ExpectedKeyAsString;
                            }
                        },
                        '}' => {
                            const scope = self.stack.pop();
                            const scope_fit = scope.object_opening;
                            const scope_root: *FitPtr = brk: {
                                assert(self.parsed.capacity != 0);
                                const data = @call(.always_inline, MultiArrayList(Word).items, .{ self.parsed, .data });
                                break :brk @ptrCast(&data[scope_fit.ptr]);
                            };
                            self.parsed.appendAssumeCapacity(.{ .object_closing = scope_fit });
                            scope_root.len = scope_fit.len;
                            scope_root.ptr = @intCast(self.parsed.len);
                            continue :next .scope_end;
                        },
                        else => return error.ExpectedObjectCommaOrEnd,
                    }
                },
                .array_begin => {
                    if (self.stack.len >= options.max_depth)
                        return error.ExceededDepth;
                    const t = self.tokens.next();
                    if (t[0] == ']') {
                        @branchHint(.unlikely);
                        self.parsed.appendAssumeCapacity(.{ .array_opening = .{
                            .ptr = @intCast(self.parsed.len + 2),
                            .len = 0,
                        } });
                        self.parsed.appendAssumeCapacity(.{ .array_closing = .{
                            .ptr = @intCast(self.parsed.len),
                            .len = 0,
                        } });
                        continue :next .scope_end;
                    }
                    const word = Word{ .array_opening = .{ .ptr = @intCast(self.parsed.len), .len = 0 } };
                    self.parsed.appendAssumeCapacity(word);
                    self.stack.appendAssumeCapacity(word);
                    self.incrementContainerCount();
                    switch (t[0]) {
                        '{' => continue :next .object_begin,
                        '[' => continue :next .array_begin,
                        else => {
                            try self.visitPrimitive(t);
                            continue :next .array_continue;
                        },
                    }
                },
                .array_value => {
                    const t = self.tokens.next();
                    self.incrementContainerCount();
                    switch (t[0]) {
                        '{' => continue :next .object_begin,
                        '[' => continue :next .array_begin,
                        else => {
                            try self.visitPrimitive(t);
                            continue :next .array_continue;
                        },
                    }
                },
                .array_continue => {
                    const t = self.tokens.next();
                    switch (t[0]) {
                        ',' => {
                            self.incrementContainerCount();
                            continue :next .array_value;
                        },
                        ']' => {
                            const scope = self.stack.pop();
                            const scope_fit = scope.array_opening;
                            const scope_root: *FitPtr = brk: {
                                assert(self.parsed.capacity != 0);
                                const data = @call(.always_inline, MultiArrayList(Word).items, .{ self.parsed, .data });
                                break :brk @ptrCast(&data[scope_fit.ptr]);
                            };
                            self.parsed.appendAssumeCapacity(.{ .array_closing = scope_fit });
                            scope_root.len = scope_fit.len;
                            scope_root.ptr = @intCast(self.parsed.len);
                            continue :next .scope_end;
                        },
                        else => return error.ExpectedArrayCommaOrEnd,
                    }
                },
                .scope_end => {
                    const parent = brk: {
                        assert(self.stack.capacity != 0);
                        const tags = @call(.always_inline, MultiArrayList(Word).items, .{ self.stack, .tags });
                        break :brk tags[self.stack.len - 1];
                    };
                    if (parent == .root) {
                        @branchHint(.unlikely);
                        const tail = self.tokens.next();
                        if (tail[0] != ' ') return error.TrailingContent;
                        _ = self.stack.pop();
                        const root: *FitPtr = brk: {
                            assert(self.parsed.capacity != 0);
                            const data = @call(.always_inline, MultiArrayList(Word).items, .{ self.parsed, .data });
                            break :brk @ptrCast(&data[0]);
                        };
                        root.ptr = @intCast(self.parsed.len);
                        self.parsed.appendAssumeCapacity(.{ .root = .{ .ptr = 0, .len = 0 } });
                        return;
                    }
                    switch (parent) {
                        .array_opening => continue :next .array_continue,
                        .object_opening => continue :next .object_continue,
                        else => unreachable,
                    }
                },
            }
        }

        inline fn incrementContainerCount(self: *Self) void {
            const scope: *FitPtr = brk: {
                assert(self.stack.capacity != 0);
                const data = @call(.always_inline, MultiArrayList(Word).items, .{ self.stack, .data });
                break :brk @ptrCast(&data[self.stack.len - 1]);
            };
            scope.len += 1;
        }

        fn visitRootPrimitive(self: *Self, ptr: [*]const u8) Error!void {
            if (self.tokens.indexer.indexes.items.len > 2) return error.TrailingContent;
            if (ptr[0] == '"') {
                try self.visitString(ptr);
            } else if (ptr[0] -% '0' < 10 or ptr[0] == '-') {
                try self.visitNumber(ptr);
            } else {
                @branchHint(.unlikely);
                try switch (ptr[0]) {
                    't' => self.visitTrue(ptr),
                    'f' => self.visitFalse(ptr),
                    'n' => self.visitNull(ptr),
                    else => error.ExpectedValue,
                };
            }
            const s = self.stack.pop();
            self.parsed.appendAssumeCapacity(s);
            const root: *FitPtr = brk: {
                assert(self.parsed.capacity != 0);
                const data = @call(.always_inline, MultiArrayList(Word).items, .{ self.parsed, .data });
                break :brk @ptrCast(&data[0]);
            };
            root.ptr = @intCast(self.parsed.len);
        }

        inline fn visitPrimitive(self: *Self, src: [*]const u8) Error!void {
            const t = src[0];
            const ptr = self.tokens.challengePtr(src);
            if (t == '"') {
                return self.visitString(ptr);
            } else if (t -% '0' < 10 or t == '-') {
                return self.visitNumber(ptr);
            } else {
                @branchHint(.unlikely);
                return switch (t) {
                    't' => self.visitTrue(ptr),
                    'f' => self.visitFalse(ptr),
                    'n' => self.visitNull(ptr),
                    else => error.ExpectedValue,
                };
            }
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
