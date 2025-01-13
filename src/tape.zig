const std = @import("std");
const builtin = @import("builtin");
const tracy = @import("tracy");
const common = @import("common.zig");
const types = @import("types.zig");
const tokens = @import("tokens.zig");
const ArrayList = std.ArrayList;
const MultiArrayList = std.MultiArrayList;
const assert = std.debug.assert;
const native_endian = builtin.cpu.arch.endian();

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
    data: packed struct {
        ptr: u32,
        len: u24,
    },
    tag: Tag,
};

const Context = struct {
    tag: Tag,
    data: struct {
        len: u32,
        ptr: u32,
    },
};

pub const Capacity = enum(u64) {
    large = std.math.maxInt(u32) * @sizeOf(Word),
    normal = std.math.maxInt(u32),
    _,

    pub fn greater(self: Capacity, other: Capacity) bool {
        return @intFromEnum(self) > @intFromEnum(other);
    }
};

pub const Options = struct {
    pub const default: Options = .{};

    max_capacity: Capacity = .normal,
    max_depth: u32,
    aligned: bool,
    stream: ?tokens.StreamOptions,
};

pub fn Tape(comptime options: Options) type {
    return struct {
        const Self = @This();
        const Aligned = types.Aligned(options.aligned);
        const Tokens = tokens.Tokens(.{
            .aligned = options.aligned,
            .stream = options.stream,
        });
        const Words = ArrayList(u64);
        const Stack = MultiArrayList(Context);
        pub const StringHighBits = if (options.stream != null and options.max_capacity.greater(.normal)) u24 else u16;

        parsed: Words,
        parsed_ptr: [*]u64 = undefined,
        stack: Stack,
        tokens: Tokens,
        chars: ArrayList(u8),
        chars_ptr: [*]u8 = undefined,
        allocator: Allocator,

        pub fn init(allocator: Allocator) Self {
            return Self{
                .parsed = .init(allocator),
                .stack = .empty,
                .tokens = if (options.stream) |_| .init({}) else .init(allocator),
                .chars = .init(allocator),
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.parsed.deinit();
            self.stack.deinit(self.allocator);
            self.tokens.deinit();
            self.chars.deinit();
        }

        pub inline fn build(self: *Self, document: if (options.stream) |_| std.fs.File else Aligned.slice, len: ?usize) !void {
            const document_len = if (options.stream) |_| len.? else document.len;

            try self.tokens.build(document);

            try self.chars.ensureTotalCapacityPrecise(document_len + types.Vector.bytes_len);
            try self.stack.ensureTotalCapacity(self.allocator, options.max_depth);
            try self.parsed.ensureTotalCapacityPrecise(document_len);

            self.chars_ptr = self.chars.items.ptr;
            self.stack.shrinkRetainingCapacity(0);
            self.parsed.shrinkRetainingCapacity(0);
            self.parsed_ptr = self.parsed.items.ptr;

            return self.dispatch();
        }

        pub inline fn get(self: Self, index: u32) Word {
            return @bitCast(self.parsed.items[index]);
        }

        fn dispatch(self: *Self) Error!void {
            state: switch (State.start) {
                .start => {
                    const t = try self.tokens.next();
                    switch (t[0]) {
                        '{' => {
                            if (try self.tokens.peekChar() == '}') {
                                try self.visitEmptyObject();
                                continue :state .end;
                            }
                            continue :state .object_begin;
                        },
                        '[' => {
                            if (try self.tokens.peekChar() == ']') {
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

                    self.stack.appendAssumeCapacity(.{
                        .tag = .object_opening,
                        .data = .{
                            .ptr = self.currentIndex(),
                            .len = 1,
                        },
                    });
                    self.parsed_ptr += 1;
                    continue :state .object_field;
                },
                .object_field => {
                    {
                        const t = try self.tokens.next();
                        if (t[0] == '"') {
                            try self.visitString(t);
                        } else {
                            return error.ExpectedKey;
                        }
                    }
                    if ((try self.tokens.next())[0] == ':') {
                        const t = try self.tokens.next();
                        switch (t[0]) {
                            '{' => {
                                if (try self.tokens.peekChar() == '}') {
                                    try self.visitEmptyObject();
                                    continue :state .object_continue;
                                }
                                continue :state .object_begin;
                            },
                            '[' => {
                                if (try self.tokens.peekChar() == ']') {
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
                    switch ((try self.tokens.next())[0]) {
                        ',' => {
                            self.incrementContainerCount();
                            continue :state .object_field;
                        },
                        '}' => {
                            assert(self.stack.items(.tag)[self.stack.len - 1] == .object_opening);
                            assert(self.stack.capacity != 0);
                            const scope = self.stack.items(.data)[self.stack.len - 1];
                            self.parsed_ptr[0] = @bitCast(Word{
                                .tag = .object_closing,
                                .data = .{
                                    .ptr = scope.ptr,
                                    .len = undefined,
                                },
                            });
                            self.parsed_ptr += 1;
                            self.parsed.items.ptr[scope.ptr] = @bitCast(Word{
                                .tag = .object_opening,
                                .data = .{
                                    .ptr = self.currentIndex(),
                                    .len = @intCast(@min(scope.len, std.math.maxInt(u24))),
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
                        .data = .{
                            .ptr = self.currentIndex(),
                            .len = 1,
                        },
                    });
                    self.parsed_ptr += 1;
                    continue :state .array_value;
                },
                .array_value => {
                    const t = try self.tokens.next();
                    switch (t[0]) {
                        '{' => {
                            if (try self.tokens.peekChar() == '}') {
                                try self.visitEmptyObject();
                                continue :state .array_continue;
                            }
                            continue :state .object_begin;
                        },
                        '[' => {
                            if (try self.tokens.peekChar() == ']') {
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
                    const t = try self.tokens.next();
                    switch (t[0]) {
                        ',' => {
                            self.incrementContainerCount();
                            continue :state .array_value;
                        },
                        ']' => {
                            assert(self.stack.items(.tag)[self.stack.len - 1] == .array_opening);
                            assert(self.stack.capacity != 0);
                            const scope = self.stack.items(.data)[self.stack.len - 1];
                            self.parsed_ptr[0] = @bitCast(Word{
                                .tag = .array_closing,
                                .data = .{
                                    .ptr = scope.ptr,
                                    .len = undefined,
                                },
                            });
                            self.parsed_ptr += 1;
                            self.parsed.items.ptr[scope.ptr] = @bitCast(Word{
                                .tag = .array_opening,
                                .data = .{
                                    .ptr = self.currentIndex(),
                                    .len = @intCast(@min(scope.len, std.math.maxInt(u24))),
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
                    const trail = try self.tokens.next();
                    if (trail[0] != Tokens.bogus_token) return error.TrailingContent;
                    self.chars.items.len = @intFromPtr(self.chars_ptr) - @intFromPtr(self.chars.items.ptr);
                    self.parsed.items.len = self.currentIndex();
                    if (self.parsed.items.len == 0) return error.Empty;
                },
            }
        }

        inline fn incrementContainerCount(self: *Self) void {
            assert(self.stack.capacity != 0);
            const scope = &self.stack.items(.data)[self.stack.len - 1];
            scope.len += 1;
        }

        inline fn currentIndex(self: Self) u32 {
            return @intCast((@intFromPtr(self.parsed_ptr) -
                @intFromPtr(self.parsed.items.ptr)) / @sizeOf(u64));
        }

        inline fn visitPrimitive(self: *Self, ptr: [*]const u8) Error!void {
            const t = ptr[0];
            switch (t) {
                '"' => {
                    @branchHint(.likely);
                    return self.visitString(ptr);
                },
                't', 'f', 'n' => {
                    @branchHint(.unlikely);
                    return switch (t) {
                        't' => return self.visitTrue(ptr),
                        'f' => return self.visitFalse(ptr),
                        'n' => return self.visitNull(ptr),
                        else => unreachable,
                    };
                },
                else => return self.visitNumber(ptr),
            }
        }

        inline fn visitEmptyObject(self: *Self) !void {
            self.parsed_ptr[0] = @bitCast(Word{
                .tag = .object_opening,
                .data = .{
                    .ptr = self.currentIndex() + 2,
                    .len = 0,
                },
            });
            self.parsed_ptr[1] = @bitCast(Word{
                .tag = .object_closing,
                .data = .{
                    .ptr = self.currentIndex(),
                    .len = undefined,
                },
            });
            self.parsed_ptr += 2;
            _ = try self.tokens.next();
        }

        inline fn visitEmptyArray(self: *Self) !void {
            self.parsed_ptr[0] = @bitCast(Word{
                .tag = .array_opening,
                .data = .{
                    .ptr = self.currentIndex() + 2,
                    .len = 0,
                },
            });
            self.parsed_ptr[1] = @bitCast(Word{
                .tag = .array_closing,
                .data = .{
                    .ptr = self.currentIndex(),
                    .len = undefined,
                },
            });
            self.parsed_ptr += 2;
            _ = try self.tokens.next();
        }

        inline fn visitString(self: *Self, ptr: [*]const u8) Error!void {
            const parse = @import("parsers/string.zig").writeString;
            const low_bits = self.chars_ptr;
            const next_str = self.chars_ptr + @sizeOf(u16);
            const sentinel = try parse(ptr, next_str);
            const next_len: u32 = @intCast(@intFromPtr(sentinel) - @intFromPtr(next_str));
            std.mem.writeInt(u16, low_bits[0..@sizeOf(u16)], @truncate(next_len), native_endian);
            const high_bits: StringHighBits = @truncate(next_len >> @bitSizeOf(StringHighBits));
            self.parsed_ptr[0] = @bitCast(Word{
                .tag = .string,
                .data = .{
                    .ptr = @intCast(@intFromPtr(self.chars_ptr) - @intFromPtr(self.chars.items.ptr)),
                    .len = high_bits,
                },
            });
            self.parsed_ptr += 1;
            self.chars_ptr = sentinel;
        }

        inline fn visitNumber(self: *Self, ptr: [*]const u8) Error!void {
            const parser = @import("parsers/number/parser.zig").Parser;
            const number = try parser.parse(ptr);
            self.parsed_ptr[0] = @bitCast(Word{
                .tag = @enumFromInt(@intFromEnum(number)),
                .data = undefined,
            });
            self.parsed_ptr[1] = switch (number) {
                .unsigned => |n| @bitCast(n),
                .signed => |n| @bitCast(n),
                .float => |n| @bitCast(n),
            };
            self.parsed_ptr += 2;
        }

        inline fn visitTrue(self: *Self, ptr: [*]const u8) Error!void {
            const check = @import("parsers/atoms.zig").checkTrue;
            try check(ptr);
            self.parsed_ptr[0] = @bitCast(Word{
                .tag = .true,
                .data = undefined,
            });
            self.parsed_ptr += 1;
        }

        inline fn visitFalse(self: *Self, ptr: [*]const u8) Error!void {
            const check = @import("parsers/atoms.zig").checkFalse;
            try check(ptr);
            self.parsed_ptr[0] = @bitCast(Word{
                .tag = .false,
                .data = undefined,
            });
            self.parsed_ptr += 1;
        }

        inline fn visitNull(self: *Self, ptr: [*]const u8) Error!void {
            const check = @import("parsers/atoms.zig").checkNull;
            try check(ptr);
            self.parsed_ptr[0] = @bitCast(Word{
                .tag = .null,
                .data = undefined,
            });
            self.parsed_ptr += 1;
        }
    };
}
