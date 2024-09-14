const std = @import("std");
const tracy = @import("tracy");
const common = @import("common.zig");
const types = @import("types.zig");
const tokens = @import("tokens.zig");
const ArrayList = std.ArrayList;
const MultiArrayList = std.MultiArrayList;
const BitStack = std.BitStack;
const Phase = tokens.Phase;
const log = std.log;
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

pub const Word = union(enum) {
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
                return switch (r) {
                    '{' => self.dispatch(.unbounded, .object_begin),
                    '[' => self.dispatch(.unbounded, .array_begin),
                    else => unreachable,
                };
            }
            const r = t.next(.bounded).?;
            return switch (r) {
                '{' => self.dispatch(.padded, .object_begin),
                '[' => self.dispatch(.padded, .array_begin),
                't', 'f', 'n' => {
                    t.ptr = t.padding[0..].ptr;
                    t.padding_ptr = @ptrFromInt(std.math.maxInt(usize));
                    return self.visit_root_primitive(.padded, r);
                },
                else => self.visit_root_primitive(.bounded, r),
            };
        }

        fn dispatch(self: *Self, comptime phase: Phase, state: State) Error!void {
            assert(phase != .bounded);

            next: switch (state) {
                .object_begin => {
                    // log.info("OBJ BEGIN", .{});

                    if (self.stack.len >= options.max_depth)
                        return error.ExceededDepth;
                    const word = Word{ .object_opening = .{ .ptr = @truncate(self.parsed.len), .len = 0 } };
                    self.parsed.appendAssumeCapacity(word);
                    self.stack.appendAssumeCapacity(word);

                    if (self.tokens.next(phase)) |t| {
                        @branchHint(.likely);
                        switch (t) {
                            '"' => {
                                self.increment_container_count();
                                try self.visit_string(phase);
                                continue :next .object_field;
                            },
                            '}' => {
                                // log.info("OBJ END", .{});
                                continue :next .scope_end;
                            },
                            else => return error.ExpectedObjectCommaOrEnd,
                        }
                    } else {
                        if (phase == .unbounded) {
                            switch (self.tokens.next(.bounded).?) {
                                '"' => {
                                    self.increment_container_count();
                                    try self.visit_string(.padded);
                                    return self.dispatch(.padded, .object_field);
                                },
                                '}' => {
                                    // log.info("OBJ END", .{});
                                    return self.dispatch(.padded, .scope_end);
                                },
                                else => return error.ExpectedObjectCommaOrEnd,
                            }
                        } else {
                            return error.ExpectedObjectCommaOrEnd;
                        }
                    }
                },
                .object_field => {
                    assert(phase != .bounded);
                    if (self.tokens.next(phase)) |t| {
                        @branchHint(.likely);
                        if (t == ':') {
                            @branchHint(.likely);
                            if (self.tokens.next(phase)) |r| {
                                switch (r) {
                                    '{' => continue :next .object_begin,
                                    '[' => continue :next .array_begin,
                                    else => {
                                        try self.visit_primitive(phase, r);
                                        continue :next .object_continue;
                                    },
                                }
                            } else {
                                if (phase == .unbounded) {
                                    switch (self.tokens.next(.bounded).?) {
                                        '{' => return self.dispatch(.padded, .object_begin),
                                        '[' => return self.dispatch(.padded, .array_begin),
                                        else => |r| {
                                            try self.visit_primitive(.padded, r);
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
                            if (self.tokens.next(.bounded).? == ':') {
                                @branchHint(.likely);
                                if (self.tokens.next(.padded)) |t| {
                                    switch (t) {
                                        '{' => return self.dispatch(.padded, .object_begin),
                                        '[' => return self.dispatch(.padded, .array_begin),
                                        else => {
                                            try self.visit_primitive(.padded, t);
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
                    assert(phase != .bounded);
                    if (self.tokens.next(phase)) |t| {
                        @branchHint(.likely);
                        switch (t) {
                            ',' => {
                                if (self.tokens.next(phase)) |r| {
                                    @branchHint(.likely);
                                    if (r == '"') {
                                        @branchHint(.likely);
                                        self.increment_container_count();
                                        try self.visit_string(phase);
                                        continue :next .object_field;
                                    } else {
                                        return error.ExpectedKeyAsString;
                                    }
                                } else {
                                    if (phase == .unbounded) {
                                        if (self.tokens.next(.bounded).? == '"') {
                                            @branchHint(.likely);
                                            self.increment_container_count();
                                            try self.visit_string(.padded);
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
                                // log.info("OBJ END", .{});
                                continue :next .scope_end;
                            },
                            else => return error.ExpectedObjectCommaOrEnd,
                        }
                    } else {
                        if (phase == .unbounded) {
                            switch (self.tokens.next(.bounded).?) {
                                ',' => {
                                    if (self.tokens.next(.padded)) |t| {
                                        @branchHint(.likely);
                                        if (t == '"') {
                                            @branchHint(.likely);
                                            self.increment_container_count();
                                            try self.visit_string(.padded);
                                            return self.dispatch(.padded, .object_field);
                                        } else {
                                            return error.ExpectedKeyAsString;
                                        }
                                    } else {
                                        return error.IncompleteObject;
                                    }
                                },
                                '}' => {
                                    // log.info("OBJ END", .{});
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
                    assert(phase != .bounded);
                    // log.info("ARR BEGIN", .{});

                    if (self.stack.len >= options.max_depth)
                        return error.ExceededDepth;
                    const word = Word{ .array_opening = .{ .ptr = @truncate(self.parsed.len), .len = 0 } };
                    self.parsed.appendAssumeCapacity(word);
                    self.stack.appendAssumeCapacity(word);

                    if (self.tokens.next(phase)) |t| {
                        @branchHint(.likely);
                        if (t == ']') {
                            @branchHint(.unlikely);
                            // log.info("ARR END", .{});
                            continue :next .scope_end;
                        }
                        self.increment_container_count();
                        switch (t) {
                            '{' => continue :next .object_begin,
                            '[' => continue :next .array_begin,
                            else => {
                                try self.visit_primitive(phase, t);
                                continue :next .array_continue;
                            },
                        }
                    } else {
                        if (phase == .unbounded) {
                            const t = self.tokens.next(.bounded).?;
                            if (t == ']') {
                                @branchHint(.unlikely);
                                // log.info("ARR END", .{});
                                return self.dispatch(.padded, .scope_end);
                            }
                            self.increment_container_count();
                            switch (t) {
                                '{' => return self.dispatch(.padded, .object_begin),
                                '[' => return self.dispatch(.padded, .array_begin),
                                else => {
                                    try self.visit_primitive(.padded, t);
                                    return self.dispatch(.padded, .array_continue);
                                },
                            }
                        } else {
                            return error.IncompleteArray;
                        }
                    }
                },
                .array_value => {
                    assert(phase != .bounded);
                    if (self.tokens.next(phase)) |t| {
                        @branchHint(.likely);
                        self.increment_container_count();
                        switch (t) {
                            '{' => continue :next .object_begin,
                            '[' => continue :next .array_begin,
                            else => {
                                try self.visit_primitive(phase, t);
                                continue :next .array_continue;
                            },
                        }
                    } else {
                        if (phase == .unbounded) {
                            self.increment_container_count();
                            switch (self.tokens.next(.bounded).?) {
                                '{' => return self.dispatch(.padded, .object_begin),
                                '[' => return self.dispatch(.padded, .array_begin),
                                else => |t| {
                                    try self.visit_primitive(.padded, t);
                                    return self.dispatch(.padded, .array_continue);
                                },
                            }
                        } else {
                            return error.IncompleteArray;
                        }
                    }
                },
                .array_continue => {
                    assert(phase != .bounded);
                    if (self.tokens.next(phase)) |t| {
                        @branchHint(.likely);
                        switch (t) {
                            ',' => {
                                self.increment_container_count();
                                continue :next .array_value;
                            },
                            ']' => {
                                // log.info("ARR END", .{});
                                continue :next .scope_end;
                            },
                            else => return error.ExpectedArrayCommaOrEnd,
                        }
                    } else {
                        if (phase == .unbounded) {
                            switch (self.tokens.next(.bounded).?) {
                                ',' => {
                                    return self.dispatch(.padded, .array_value);
                                },
                                ']' => {
                                    // log.info("ARR END", .{});
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
                    assert(phase != .bounded);
                    const scope = self.stack.pop();
                    const scope_fit = switch (scope) {
                        .array_opening, .object_opening => |s| s,
                        else => unreachable,
                    };
                    const scope_root: *FitPtr = @ptrCast(&self.parsed.items(.data)[scope_fit.ptr]);
                    switch (scope) {
                        .array_opening => |s| self.parsed.appendAssumeCapacity(.{ .array_closing = s }),
                        .object_opening => |s| self.parsed.appendAssumeCapacity(.{ .object_closing = s }),
                        else => unreachable,
                    }
                    scope_root.len = scope_fit.len;
                    scope_root.ptr = @truncate(self.parsed.len);
                    const parent = self.stack.items(.tags)[self.stack.len - 1];
                    switch (parent) {
                        .array_opening => continue :next .array_continue,
                        .object_opening => continue :next .object_continue,
                        .root => {
                            assert(phase == .padded);
                            if (self.tokens.next(phase)) |_| return error.TrailingContent;
                            _ = self.stack.pop();
                            const root: *FitPtr = @ptrCast(&self.parsed.items(.data)[0]);
                            root.ptr = @truncate(self.parsed.len);
                            self.parsed.appendAssumeCapacity(.{ .root = .{ .ptr = 0, .len = 0 } });
                        },
                        else => unreachable,
                    }
                },
            }
        }

        inline fn increment_container_count(self: *Self) void {
            const scope: *FitPtr = @ptrCast(&self.stack.items(.data)[self.stack.len - 1]);
            scope.len += 1;
        }

        fn visit_root_primitive(self: *Self, comptime phase: Phase, token: u8) Error!void {
            assert(phase != .unbounded);
            if (self.tokens.indexer.indexes.items.len > 1) return error.TrailingContent;
            if (phase == .bounded) {
                if (token -% '0' < 10 or token == '-') {
                    try self.visit_number(phase);
                } else if (token == '"') {
                    try self.visit_string(phase);
                } else return error.ExpectedValue;
            } else {
                try switch (token) {
                    't' => self.visit_true(),
                    'f' => self.visit_false(),
                    'n' => self.visit_null(),
                    else => return error.ExpectedValue,
                };
            }
            const s = self.stack.pop();
            const root: *FitPtr = @ptrCast(&self.parsed.items(.data)[0]);
            root.ptr = @truncate(self.parsed.len);
            self.parsed.appendAssumeCapacity(s);
        }

        inline fn visit_primitive(self: *Self, comptime phase: Phase, token: u8) Error!void {
            if (token == '"') {
                return self.visit_string(phase);
            } else if (token -% '0' < 10 or token == '-') {
                return self.visit_number(phase);
            }
            return switch (token) {
                't' => self.visit_true(),
                'f' => self.visit_false(),
                'n' => self.visit_null(),
                else => error.ExpectedValue,
            };
        }

        inline fn visit_string(self: *Self, comptime phase: Phase) Error!void {
            const t = &self.tokens;
            _ = t.consume(1, phase);
            const chars = &self.chars;
            const next_str = chars.items.len;
            const parse = @import("parsers/string.zig").writeString;
            try parse(token_options, phase, t, chars);
            const next_len = chars.items.len - next_str;
            self.parsed.appendAssumeCapacity(.{ .string = .{ .ptr = @truncate(next_str), .len = @truncate(next_len) } });
            // log.info("STR {s}", .{chars.items[next_str..][0..next_len]});
        }

        inline fn visit_number(self: *Self, comptime phase: Phase) Error!void {
            const t = &self.tokens;
            const parser = @import("parsers/number/parser.zig").Parser(token_options);
            const number = try parser.parse(phase, t);
            switch (number) {
                .float => |n| {
                    self.parsed.appendAssumeCapacity(.{ .float = n });
                    // log.info("FLT {d}", .{n});
                },
                .signed => |n| {
                    self.parsed.appendAssumeCapacity(.{ .signed = n });
                    // log.info("INT {d}", .{n});
                },
                .unsigned => |n| {
                    self.parsed.appendAssumeCapacity(.{ .unsigned = n });
                    // log.info("UNT {d}", .{n});
                },
            }
        }

        inline fn visit_true(self: *Self) Error!void {
            const t = self.tokens;
            const check = @import("parsers/atoms.zig").checkTrue;
            try check(token_options, t);
            self.parsed.appendAssumeCapacity(.true);
            // log.info("TRU", .{});
        }

        inline fn visit_false(self: *Self) Error!void {
            const t = self.tokens;
            const check = @import("parsers/atoms.zig").checkFalse;
            try check(token_options, t);
            self.parsed.appendAssumeCapacity(.false);
            // log.info("FAL", .{});
        }

        inline fn visit_null(self: *Self) Error!void {
            const t = self.tokens;
            const check = @import("parsers/atoms.zig").checkNull;
            try check(token_options, t);
            self.parsed.appendAssumeCapacity(.null);
            // log.info("NUL", .{});
        }
    };
}
