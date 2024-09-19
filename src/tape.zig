const std = @import("std");
const tracy = @import("tracy");
const common = @import("common.zig");
const types = @import("types.zig");
const tokens = @import("tokens.zig");
const ArrayList = std.ArrayList;
const MultiArrayList = std.MultiArrayList;
const Phase = tokens.Phase;
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
        .copy_bounded = false,
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
            if (t.next(.unbounded)) |r| {
                @branchHint(.likely);
                return switch (r.*) {
                    '{' => self.dispatch(.unbounded, .object_begin),
                    '[' => self.dispatch(.unbounded, .array_begin),
                    else => unreachable,
                };
            }
            const r = t.next(.bounded).?.*;
            return switch (r) {
                '{' => self.dispatch(.padded, .object_begin),
                '[' => self.dispatch(.padded, .array_begin),
                't', 'f', 'n' => {
                    t.ptr = t.padding[0..].ptr;
                    t.padding_ptr = @ptrFromInt(std.math.maxInt(usize));
                    return self.visitRootPrimitive(.padded, r);
                },
                else => self.visitRootPrimitive(.bounded, r),
            };
        }

        fn dispatch(self: *Self, comptime phase: Phase, state: State) Error!void {
            assert(phase != .bounded);

            next: switch (state) {
                .object_begin => {
                    if (self.stack.len >= options.max_depth)
                        return error.ExceededDepth;

                    if (self.tokens.next(phase)) |t| {
                        @branchHint(.likely);
                        if (t.* == '}') {
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
                        switch (t.*) {
                            '"' => {
                                const word = Word{ .object_opening = .{
                                    .ptr = @intCast(self.parsed.len),
                                    .len = 0,
                                } };
                                self.parsed.appendAssumeCapacity(word);
                                self.stack.appendAssumeCapacity(word);
                                self.incrementContainerCount();
                                try self.visitString(.unbounded);
                                continue :next .object_field;
                            },
                            else => return error.ExpectedObjectCommaOrEnd,
                        }
                    } else {
                        if (phase == .unbounded) {
                            const t = self.tokens.next(.bounded).?;
                            if (t.* == '}') {
                                @branchHint(.unlikely);
                                self.parsed.appendAssumeCapacity(.{ .object_opening = .{
                                    .ptr = @intCast(self.parsed.len + 2),
                                    .len = 0,
                                } });
                                self.parsed.appendAssumeCapacity(.{ .object_closing = .{
                                    .ptr = @intCast(self.parsed.len),
                                    .len = 0,
                                } });
                                return self.dispatch(.padded, .scope_end);
                            }
                            switch (t.*) {
                                '"' => {
                                    const word = Word{ .object_opening = .{
                                        .ptr = @intCast(self.parsed.len),
                                        .len = 0,
                                    } };
                                    self.parsed.appendAssumeCapacity(word);
                                    self.stack.appendAssumeCapacity(word);
                                    self.incrementContainerCount();
                                    try self.visitString(.bounded);
                                    return self.dispatch(.padded, .object_field);
                                },
                                else => return error.ExpectedObjectCommaOrEnd,
                            }
                        } else {
                            return error.ExpectedObjectCommaOrEnd;
                        }
                    }
                },
                .object_field => {
                    if (self.tokens.next(phase)) |t| {
                        @branchHint(.likely);
                        if (t.* == ':') {
                            if (self.tokens.next(phase)) |r| {
                                switch (r.*) {
                                    '{' => continue :next .object_begin,
                                    '[' => continue :next .array_begin,
                                    else => |u| {
                                        try self.visitPrimitive(.unbounded, u);
                                        continue :next .object_continue;
                                    },
                                }
                            } else {
                                if (phase == .unbounded) {
                                    switch (self.tokens.next(.bounded).?.*) {
                                        '{' => return self.dispatch(.padded, .object_begin),
                                        '[' => return self.dispatch(.padded, .array_begin),
                                        else => |r| {
                                            try self.visitPrimitive(.bounded, r);
                                            return self.dispatch(.padded, .object_continue);
                                        },
                                    }
                                } else {
                                    return error.ExpectedValue;
                                }
                            }
                        } else {
                            return error.ExpectedColon;
                        }
                    } else {
                        if (phase == .unbounded) {
                            if (self.tokens.next(.bounded).?.* == ':') {
                                if (self.tokens.next(.padded)) |t| {
                                    switch (t.*) {
                                        '{' => return self.dispatch(.padded, .object_begin),
                                        '[' => return self.dispatch(.padded, .array_begin),
                                        else => |r| {
                                            try self.visitPrimitive(.padded, r);
                                            return self.dispatch(.padded, .object_continue);
                                        },
                                    }
                                } else {
                                    return error.ExpectedValue;
                                }
                            } else {
                                return error.ExpectedColon;
                            }
                        } else {
                            return error.IncompleteObject;
                        }
                    }
                },
                .object_continue => {
                    if (self.tokens.next(phase)) |t| {
                        @branchHint(.likely);
                        switch (t.*) {
                            ',' => {
                                if (self.tokens.next(phase)) |r| {
                                    @branchHint(.likely);
                                    if (r.* == '"') {
                                        self.incrementContainerCount();
                                        try self.visitString(.unbounded);
                                        continue :next .object_field;
                                    } else {
                                        return error.ExpectedKeyAsString;
                                    }
                                } else {
                                    if (phase == .unbounded) {
                                        if (self.tokens.next(.bounded).?.* == '"') {
                                            self.incrementContainerCount();
                                            try self.visitString(.bounded);
                                            return self.dispatch(.padded, .object_field);
                                        } else {
                                            return error.ExpectedKeyAsString;
                                        }
                                    } else {
                                        return error.IncompleteObject;
                                    }
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
                    } else {
                        if (phase == .unbounded) {
                            switch (self.tokens.next(.bounded).?.*) {
                                ',' => {
                                    if (self.tokens.next(.padded)) |t| {
                                        if (t.* == '"') {
                                            self.incrementContainerCount();
                                            try self.visitString(.padded);
                                            return self.dispatch(.padded, .object_field);
                                        } else {
                                            return error.ExpectedKeyAsString;
                                        }
                                    } else {
                                        return error.IncompleteObject;
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
                                    return self.dispatch(.padded, .scope_end);
                                },
                                else => return error.ExpectedObjectCommaOrEnd,
                            }
                        } else {
                            return error.ExpectedObjectCommaOrEnd;
                        }
                    }
                },
                .array_begin => {
                    if (self.stack.len >= options.max_depth)
                        return error.ExceededDepth;
                    if (self.tokens.next(phase)) |t| {
                        @branchHint(.likely);
                        if (t.* == ']') {
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
                        switch (t.*) {
                            '{' => continue :next .object_begin,
                            '[' => continue :next .array_begin,
                            else => |r| {
                                try self.visitPrimitive(.unbounded, r);
                                continue :next .array_continue;
                            },
                        }
                    } else {
                        if (phase == .unbounded) {
                            const t = self.tokens.next(.bounded).?;
                            if (t.* == ']') {
                                @branchHint(.unlikely);
                                self.parsed.appendAssumeCapacity(.{ .array_opening = .{
                                    .ptr = @intCast(self.parsed.len + 2),
                                    .len = 0,
                                } });
                                self.parsed.appendAssumeCapacity(.{ .array_closing = .{
                                    .ptr = @intCast(self.parsed.len),
                                    .len = 0,
                                } });
                                return self.dispatch(.padded, .scope_end);
                            }
                            const word = Word{ .array_opening = .{ .ptr = @intCast(self.parsed.len), .len = 0 } };
                            self.parsed.appendAssumeCapacity(word);
                            self.stack.appendAssumeCapacity(word);
                            self.incrementContainerCount();
                            switch (t.*) {
                                '{' => return self.dispatch(.padded, .object_begin),
                                '[' => return self.dispatch(.padded, .array_begin),
                                else => |r| {
                                    try self.visitPrimitive(.bounded, r);
                                    return self.dispatch(.padded, .array_continue);
                                },
                            }
                        } else {
                            return error.IncompleteArray;
                        }
                    }
                },
                .array_value => {
                    if (self.tokens.next(phase)) |t| {
                        @branchHint(.likely);
                        self.incrementContainerCount();
                        switch (t.*) {
                            '{' => continue :next .object_begin,
                            '[' => continue :next .array_begin,
                            else => |r| {
                                try self.visitPrimitive(.unbounded, r);
                                continue :next .array_continue;
                            },
                        }
                    } else {
                        if (phase == .unbounded) {
                            self.incrementContainerCount();
                            switch (self.tokens.next(.bounded).?.*) {
                                '{' => return self.dispatch(.padded, .object_begin),
                                '[' => return self.dispatch(.padded, .array_begin),
                                else => |t| {
                                    try self.visitPrimitive(.bounded, t);
                                    return self.dispatch(.padded, .array_continue);
                                },
                            }
                        } else {
                            return error.IncompleteArray;
                        }
                    }
                },
                .array_continue => {
                    if (self.tokens.next(phase)) |t| {
                        @branchHint(.likely);
                        switch (t.*) {
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
                    } else {
                        if (phase == .unbounded) {
                            switch (self.tokens.next(.bounded).?.*) {
                                ',' => {
                                    return self.dispatch(.padded, .array_value);
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
                                    return self.dispatch(.padded, .scope_end);
                                },
                                else => return error.ExpectedArrayCommaOrEnd,
                            }
                        } else {
                            return error.IncompleteArray;
                        }
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
                        assert(phase == .padded);
                        if (self.tokens.next(phase)) |_| return error.TrailingContent;
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

        fn visitRootPrimitive(self: *Self, comptime phase: Phase, token: u8) Error!void {
            assert(phase != .unbounded);
            if (self.tokens.indexer.indexes.items.len > 1) return error.TrailingContent;
            if (phase == .bounded) {
                if (token -% '0' < 10 or token == '-') {
                    try self.visitNumber(phase);
                } else if (token == '"') {
                    try self.visitString(phase);
                } else return error.ExpectedValue;
            } else {
                try switch (token) {
                    't' => self.visitTrue(),
                    'f' => self.visitFalse(),
                    'n' => self.visitNull(),
                    else => return error.ExpectedValue,
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

        inline fn visitPrimitive(self: *Self, comptime phase: Phase, token: u8) Error!void {
            if (token == '"') {
                return self.visitString(phase);
            } else if (token -% '0' < 10 or token == '-') {
                return self.visitNumber(phase);
            } else {
                @branchHint(.unlikely);
                return switch (token) {
                    't' => self.visitTrue(),
                    'f' => self.visitFalse(),
                    'n' => self.visitNull(),
                    else => error.ExpectedValue,
                };
            }
        }

        inline fn visitString(self: *Self, comptime phase: Phase) Error!void {
            const t = &self.tokens;
            t.consume(1, phase);
            const chars = &self.chars;
            const next_str = chars.items.len;
            const parse = @import("parsers/string.zig").writeString;
            try parse(token_options, phase, t, chars);
            const next_len = chars.items.len - next_str;
            self.parsed.appendAssumeCapacity(.{ .string = .{ .ptr = @intCast(next_str), .len = @intCast(next_len) } });
        }

        inline fn visitNumber(self: *Self, comptime phase: Phase) Error!void {
            const t = &self.tokens;
            const parser = @import("parsers/number/parser.zig").Parser(token_options);
            const number = try parser.parse(phase, t);
            const word: Word = switch (number) {
                .unsigned => |n| .{ .unsigned = n },
                .signed => |n| .{ .signed = n },
                .float => |n| .{ .float = n },
            };
            self.parsed.appendAssumeCapacity(word);
        }

        inline fn visitTrue(self: *Self) Error!void {
            const t = self.tokens;
            const check = @import("parsers/atoms.zig").checkTrue;
            try check(token_options, t);
            self.parsed.appendAssumeCapacity(.true);
        }

        inline fn visitFalse(self: *Self) Error!void {
            const t = self.tokens;
            const check = @import("parsers/atoms.zig").checkFalse;
            try check(token_options, t);
            self.parsed.appendAssumeCapacity(.false);
        }

        inline fn visitNull(self: *Self) Error!void {
            const t = self.tokens;
            const check = @import("parsers/atoms.zig").checkNull;
            try check(token_options, t);
            self.parsed.appendAssumeCapacity(.null);
        }
    };
}
