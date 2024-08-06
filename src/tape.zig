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
    const TOKEN_OPTIONS = tokens.Options{
        .aligned = options.aligned,
        .copy_bounded = false,
    };

    return struct {
        const Self = @This();
        const Tokens = tokens.Iterator(TOKEN_OPTIONS);
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

        pub fn build(self: *Self, doc: Aligned.Slice) !void {
            const t = &self.tokens;
            try t.build(doc);

            const tracer = tracy.traceNamed(@src(), "Tape");
            defer tracer.end();

            try self.chars.ensureTotalCapacity(t.indexer.reader.document.len + types.Vector.LEN_BYTES);
            try self.stack.ensureTotalCapacity(self.allocator, options.max_depth);
            try self.parsed.ensureTotalCapacity(self.allocator, t.indexer.indexes.items.len + 2);
            self.chars.shrinkRetainingCapacity(0);
            self.stack.shrinkRetainingCapacity(0);
            self.parsed.shrinkRetainingCapacity(0);

            self.stack.appendAssumeCapacity(.{ .root = .{ .ptr = 0, .len = 0 } });
            self.parsed.appendAssumeCapacity(.{ .root = .{ .ptr = 0, .len = 0 } });
            if (t.next(.unbounded)) |r| {
                return switch (r) {
                    '{' => self.analyze_object_begin(.unbounded),
                    '[' => self.analyze_array_begin(.unbounded),
                    else => unreachable,
                };
            }
            const r = t.next(.bounded).?;
            return switch (r) {
                '{' => self.analyze_object_begin(.padded),
                '[' => self.analyze_array_begin(.padded),
                't', 'f', 'n' => {
                    t.ptr = t.padding[0..].ptr;
                    t.padding_ptr = @ptrFromInt(std.math.maxInt(usize));
                    return self.visit_root_primitive(.padded, r);
                },
                else => self.visit_root_primitive(.bounded, r),
            };
        }

        inline fn dispatch(self: *Self, comptime phase: Phase, next_state: State) Error!void {
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

        fn analyze_object_begin(self: *Self, comptime phase: Phase) Error!void {
            assert(phase != .bounded);
            // log.info("OBJ BEGIN", .{});

            if (self.stack.len >= options.max_depth)
                return error.ExceededDepth;
            const word = Word{ .object_opening = .{ .ptr = @truncate(self.parsed.len), .len = 0 } };
            self.parsed.appendAssumeCapacity(word);
            self.stack.appendAssumeCapacity(word);

            if (self.tokens.next(phase)) |t| {
                switch (t) {
                    '"' => {
                        self.increment_container_count();
                        try self.visit_string(phase);
                        return self.dispatch(phase, .object_field);
                    },
                    '}' => {
                        // log.info("OBJ END", .{});
                        return self.dispatch(phase, .scope_end);
                    },
                    else => return error.ExpectedObjectCommaOrEnd,
                }
            } else {
                if (phase == .unbounded) {
                    return self.dispatch(.bounded, .resume_object_begin);
                } else {
                    return error.ExpectedObjectCommaOrEnd;
                }
            }
        }

        fn resume_object_begin(self: *Self, comptime phase: Phase) Error!void {
            assert(phase == .bounded);
            switch (self.tokens.next(phase).?) {
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
        }

        fn analyze_object_field(self: *Self, comptime phase: Phase) Error!void {
            assert(phase != .bounded);
            if (self.tokens.next(phase)) |t| {
                if (t == ':') {
                    if (self.tokens.next(phase)) |r| {
                        switch (r) {
                            '{' => return self.dispatch(phase, .object_begin),
                            '[' => return self.dispatch(phase, .array_begin),
                            else => {
                                try self.visit_primitive(phase, r);
                                return self.dispatch(phase, .object_continue);
                            },
                        }
                    } else {
                        if (phase == .unbounded) {
                            return self.dispatch(.bounded, .resume_object_field_value);
                        } else {
                            return error.ExpectedValue;
                        }
                    }
                } else {
                    return error.ExpectedColon;
                }
            } else {
                if (phase == .unbounded) {
                    return self.dispatch(.bounded, .resume_object_field_colon);
                } else {
                    return error.IncompleteObject;
                }
            }
        }

        fn resume_object_field_colon(self: *Self, comptime phase: Phase) Error!void {
            assert(phase == .bounded);
            if (self.tokens.next(phase).? == ':') {
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
        }

        fn resume_object_field_value(self: *Self, comptime phase: Phase) Error!void {
            assert(phase == .bounded);
            switch (self.tokens.next(phase).?) {
                '{' => return self.dispatch(.padded, .object_begin),
                '[' => return self.dispatch(.padded, .array_begin),
                else => |t| {
                    try self.visit_primitive(.padded, t);
                    return self.dispatch(.padded, .object_continue);
                },
            }
        }

        fn analyze_object_continue(self: *Self, comptime phase: Phase) Error!void {
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
                                return error.ExpectedKeyAsString;
                            }
                        } else {
                            if (phase == .unbounded) {
                                return self.dispatch(.bounded, .resume_object_continue_key);
                            } else {
                                return error.IncompleteObject;
                            }
                        }
                    },
                    '}' => {
                        // log.info("OBJ END", .{});
                        return self.dispatch(phase, .scope_end);
                    },
                    else => return error.ExpectedObjectCommaOrEnd,
                }
            } else {
                if (phase == .unbounded) {
                    return self.dispatch(.bounded, .resume_object_continue_comma);
                } else {
                    return error.ExpectedObjectCommaOrEnd;
                }
            }
        }

        fn resume_object_continue_comma(self: *Self, comptime phase: Phase) Error!void {
            assert(phase == .bounded);
            switch (self.tokens.next(phase).?) {
                ',' => {
                    if (self.tokens.next(.padded)) |t| {
                        if (t == '"') {
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
        }

        fn resume_object_continue_key(self: *Self, comptime phase: Phase) Error!void {
            assert(phase == .bounded);
            if (self.tokens.next(phase).? == '"') {
                self.increment_container_count();
                try self.visit_string(.padded);
                return self.dispatch(.padded, .object_field);
            } else {
                return error.ExpectedKeyAsString;
            }
        }

        fn analyze_array_begin(self: *Self, comptime phase: Phase) Error!void {
            assert(phase != .bounded);
            // log.info("ARR BEGIN", .{});

            if (self.stack.len >= options.max_depth)
                return error.ExceededDepth;
            const word = Word{ .array_opening = .{ .ptr = @truncate(self.parsed.len), .len = 0 } };
            self.parsed.appendAssumeCapacity(word);
            self.stack.appendAssumeCapacity(word);

            if (self.tokens.next(phase)) |t| {
                if (t == ']') {
                    // log.info("ARR END", .{});
                    return self.dispatch(phase, .scope_end);
                }
                self.increment_container_count();
                switch (t) {
                    '{' => return self.dispatch(phase, .object_begin),
                    '[' => return self.dispatch(phase, .array_begin),
                    else => {
                        try self.visit_primitive(phase, t);
                        return self.dispatch(phase, .array_continue);
                    },
                }
            } else {
                if (phase == .unbounded) {
                    return self.dispatch(.bounded, .resume_array_begin);
                } else {
                    return error.IncompleteArray;
                }
            }
        }

        fn resume_array_begin(self: *Self, comptime phase: Phase) Error!void {
            assert(phase == .bounded);
            const t = self.tokens.next(phase).?;
            if (t == ']') {
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
        }

        fn analyze_array_value(self: *Self, comptime phase: Phase) Error!void {
            assert(phase != .bounded);
            if (self.tokens.next(phase)) |t| {
                self.increment_container_count();
                switch (t) {
                    '{' => return self.dispatch(phase, .object_begin),
                    '[' => return self.dispatch(phase, .array_begin),
                    else => {
                        try self.visit_primitive(phase, t);
                        return self.dispatch(phase, .array_continue);
                    },
                }
            } else {
                if (phase == .unbounded) {
                    return self.dispatch(.bounded, .resume_array_value);
                } else {
                    return error.IncompleteArray;
                }
            }
        }

        fn resume_array_value(self: *Self, comptime phase: Phase) Error!void {
            assert(phase == .bounded);
            self.increment_container_count();
            switch (self.tokens.next(phase).?) {
                '{' => return self.dispatch(.padded, .object_begin),
                '[' => return self.dispatch(.padded, .array_begin),
                else => |t| {
                    try self.visit_primitive(.padded, t);
                    return self.dispatch(.padded, .array_continue);
                },
            }
        }

        fn analyze_array_continue(self: *Self, comptime phase: Phase) Error!void {
            assert(phase != .bounded);
            if (self.tokens.next(phase)) |t| {
                switch (t) {
                    ',' => {
                        self.increment_container_count();
                        return self.dispatch(phase, .array_value);
                    },
                    ']' => {
                        // log.info("ARR END", .{});
                        return self.dispatch(phase, .scope_end);
                    },
                    else => return error.ExpectedArrayCommaOrEnd,
                }
            } else {
                if (phase == .unbounded) {
                    return self.dispatch(.bounded, .resume_array_continue);
                } else {
                    return error.IncompleteArray;
                }
            }
        }

        fn resume_array_continue(self: *Self, comptime phase: Phase) Error!void {
            assert(phase == .bounded);
            switch (self.tokens.next(phase).?) {
                ',' => {
                    return self.dispatch(.padded, .array_value);
                },
                ']' => {
                    // log.info("ARR END", .{});
                    return self.dispatch(.padded, .scope_end);
                },
                else => return error.ExpectedArrayCommaOrEnd,
            }
        }

        fn analyze_scope_end(self: *Self, comptime phase: Phase) Error!void {
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
                .array_opening => return self.dispatch(phase, .array_continue),
                .object_opening => return self.dispatch(phase, .object_continue),
                .root => {
                    if (self.tokens.next(phase)) |_| return error.TrailingContent;
                    _ = self.stack.pop();
                    const root: *FitPtr = @ptrCast(&self.parsed.items(.data)[0]);
                    root.ptr = @truncate(self.parsed.len);
                    self.parsed.appendAssumeCapacity(.{ .root = .{ .ptr = 0, .len = 0 } });
                },
                else => unreachable,
            }
        }

        fn increment_container_count(self: *Self) void {
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

        fn visit_primitive(self: *Self, comptime phase: Phase, token: u8) Error!void {
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

        fn visit_string(self: *Self, comptime phase: Phase) Error!void {
            const t = &self.tokens;
            _ = t.consume(1, phase);
            const chars = &self.chars;
            const next_str = chars.items.len;
            const parse = @import("parsers/string.zig").writeString;
            try parse(TOKEN_OPTIONS, phase, t, chars);
            const next_len = chars.items.len - next_str;
            self.parsed.appendAssumeCapacity(.{ .string = .{ .ptr = @truncate(next_str), .len = @truncate(next_len) } });
            // log.info("STR {s}", .{chars.items[next_str..][0..next_len]});
        }

        fn visit_number(self: *Self, comptime phase: Phase) Error!void {
            const t = &self.tokens;
            const parser = @import("parsers/number/parser.zig").Parser(TOKEN_OPTIONS);
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

        fn visit_true(self: *Self) Error!void {
            const t = self.tokens;
            const check = @import("parsers/atoms.zig").checkTrue;
            try check(TOKEN_OPTIONS, t);
            self.parsed.appendAssumeCapacity(.true);
            // log.info("TRU", .{});
        }

        fn visit_false(self: *Self) Error!void {
            const t = self.tokens;
            const check = @import("parsers/atoms.zig").checkFalse;
            try check(TOKEN_OPTIONS, t);
            self.parsed.appendAssumeCapacity(.false);
            // log.info("FAL", .{});
        }

        fn visit_null(self: *Self) Error!void {
            const t = self.tokens;
            const check = @import("parsers/atoms.zig").checkNull;
            try check(TOKEN_OPTIONS, t);
            self.parsed.appendAssumeCapacity(.null);
            // log.info("NUL", .{});
        }
    };
}
