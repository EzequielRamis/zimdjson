const std = @import("std");
const builtin = @import("builtin");
const common = @import("common.zig");
const types = @import("types.zig");
const tokens = @import("tokens.zig");
const Allocator = std.mem.Allocator;
const Number = types.Number;
const assert = std.debug.assert;
const native_endian = builtin.cpu.arch.endian();

pub fn ParserOptions(comptime Reader: ?type) type {
    return if (Reader) |_| struct {
        pub const default: @This() = .{};
        stream: ?struct {
            pub const default: @This() = .{};
            chunk_length: u32 = tokens.ring_buffer.default_chunk_length,
        } = null,
    } else struct {
        pub const default: @This() = .{};
        aligned: bool = false,
        assume_padding: bool = false,
    };
}

pub fn parserFromSlice(comptime options: ParserOptions(null)) type {
    return Parser(null, options);
}

pub fn parserFromFile(comptime options: ParserOptions(std.fs.File.Reader)) type {
    return Parser(std.fs.File.Reader, options);
}

pub fn Parser(comptime Reader: ?type, comptime options: ParserOptions(Reader)) type {
    const want_stream = Reader != null and options.stream != null;
    const need_document_buffer = Reader != null and options.stream == null;
    const aligned = Reader != null or options.aligned;

    return struct {
        const Self = @This();

        const Aligned = types.Aligned(aligned);
        const Tokens = if (want_stream)
            tokens.Stream(.{
                .Reader = Reader.?,
                .aligned = aligned,
                .chunk_len = options.stream.?.chunk_length,
                .slots = 2,
            })
        else
            tokens.Iterator(.{
                .aligned = aligned,
                .assume_padding = Reader != null or options.assume_padding,
            });

        pub const Error = Tokens.Error || types.ParseError || Allocator.Error || if (Reader) |reader| reader.Error else error{};
        pub const max_capacity_bound = if (want_stream) std.math.maxInt(u32) * @sizeOf(Tape.Word) else std.math.maxInt(u32);

        document_buffer: if (need_document_buffer) std.ArrayListAligned(u8, types.Aligned(true).alignment) else void,
        tape: Tape,

        max_capacity: usize,
        capacity: usize,

        pub fn init(allocator: Allocator) Self {
            return .{
                .document_buffer = if (need_document_buffer) .init(allocator) else {},
                .tape = .init(allocator),
                .max_capacity = max_capacity_bound,
                .capacity = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            if (need_document_buffer) self.document_buffer.deinit();
            self.tape.deinit();
        }

        pub fn setMaximumCapacity(self: *Self, new_capacity: usize) Error!void {
            if (new_capacity > max_capacity_bound) return error.ExceededCapacity;

            if (!want_stream and new_capacity + 1 < self.tape.tokens.indexes.items.len)
                self.tape.tokens.indexes.shrinkAndFree(new_capacity + 1);

            if (new_capacity < self.tape.words.list.items.len) {
                self.tape.words.list.shrinkAndFree(self.tape.allocator, new_capacity + (new_capacity >> 1) + 1);
                self.tape.words.max_capacity = new_capacity;
            }

            if (new_capacity + types.Vector.bytes_len < self.tape.strings.items().len) {
                self.tape.strings.list.shrinkAndFree(self.tape.allocator, new_capacity + types.Vector.bytes_len);
                self.tape.strings.max_capacity = new_capacity + types.Vector.bytes_len;
            }

            self.max_capacity = new_capacity;
        }

        pub fn setMaximumDepth(self: *Self, new_depth: usize) Error!void {
            if (new_depth > std.math.maxInt(u32)) return error.ExceededDepth;
            try self.tape.stack.setMaxDepth(self.tape.allocator, new_depth);
        }

        pub fn ensureTotalCapacity(self: *Self, new_capacity: usize) Error!void {
            if (new_capacity > self.max_capacity) return error.ExceededCapacity;

            if (need_document_buffer) {
                try self.document_buffer.ensureTotalCapacity(new_capacity + types.Vector.bytes_len);
            }

            if (!want_stream) {
                try self.tape.tokens.ensureTotalCapacity(new_capacity);
            }

            try self.tape.stack.ensureTotalCapacity(self.tape.allocator, self.max_depth);
            try self.tape.strings.ensureTotalCapacity(self.tape.allocator, new_capacity + types.Vector.bytes_len);

            self.capacity = new_capacity;
        }

        pub fn parse(self: *Self, document: if (Reader) |reader| reader else Aligned.slice) Error!Value {
            if (need_document_buffer) {
                self.document_buffer.clearRetainingCapacity();
                try @as(Error!void, @errorCast(common.readAllArrayListAlignedRetainingCapacity(
                    document,
                    types.Aligned(true).alignment,
                    &self.document_buffer,
                    self.max_capacity,
                )));
                const len = self.document_buffer.items.len;
                try self.document_buffer.appendNTimes(' ', types.Vector.bytes_len);
                try self.ensureTotalCapacity(len);
                try self.tape.build(self.document_buffer.items[0..len]);
            } else {
                if (!want_stream) try self.ensureTotalCapacity(document.len);
                try self.tape.build(document);
            }
            return .{
                .tape = &self.tape,
                .index = 0,
            };
        }

        pub fn parseAssumeCapacity(self: *Self, document: if (Reader) |reader| reader else Aligned.slice) Error!Value {
            if (need_document_buffer) {
                self.document_buffer.expandToCapacity();
                const len = try document.readAll(self.document_buffer.items);
                if (len > self.capacity) return error.ExceededCapacity;
                self.document_buffer.items.len = len;
                try self.document_buffer.appendNTimes(' ', types.Vector.bytes_len);
                try self.tape.build(self.document_buffer.items[0..len]);
            } else {
                if (!want_stream) if (document.len > self.capacity) return error.ExceededCapacity;
                try self.tape.build(document);
            }
            return .{
                .tape = &self.tape,
                .index = 0,
            };
        }

        pub fn parseWithCapacity(self: *Self, document: if (Reader) |reader| reader else Aligned.slice, capacity: usize) Error!Value {
            try self.ensureTotalCapacity(capacity);
            return self.parseAssumeCapacity(document);
        }

        pub const Element = union(types.ElementType) {
            null,
            bool: bool,
            number: Number,
            string: []const u8,
            object: Object,
            array: Array,
        };

        pub const Value = struct {
            tape: *const Tape,
            index: u32,
            err: ?Error = null,

            pub fn asObject(self: Value) Error!Object {
                if (self.err) |err| return err;

                return switch (self.tape.get(self.index).tag) {
                    .object_opening => Object{ .tape = self.tape, .root = self.index },
                    else => error.IncorrectType,
                };
            }

            pub fn asArray(self: Value) Error!Array {
                if (self.err) |err| return err;

                return switch (self.tape.get(self.index).tag) {
                    .array_opening => Array{ .tape = self.tape, .root = self.index },
                    else => error.IncorrectType,
                };
            }

            pub fn asString(self: Value) Error![]const u8 {
                if (self.err) |err| return err;

                const w = self.tape.get(self.index);
                return switch (w.tag) {
                    .string => brk: {
                        const low_bits = std.mem.readInt(u16, self.tape.strings.items()[w.data.ptr..][0..@sizeOf(u16)], native_endian);
                        const high_bits: u64 = w.data.len;
                        const len = high_bits << @bitSizeOf(Tape.StringHighBits) | low_bits;
                        const ptr = self.tape.strings.items()[w.data.ptr + @sizeOf(u16) ..];
                        break :brk ptr[0..len];
                    },
                    else => error.IncorrectType,
                };
            }

            pub fn asNumber(self: Value) Error!Number {
                if (self.err) |err| return err;

                const w = self.tape.get(self.index);
                const number = self.tape.get(self.index + 1);
                return switch (w.tag) {
                    inline .unsigned, .signed, .float => |t| @unionInit(Number, @tagName(t), @bitCast(number)),
                    else => error.IncorrectType,
                };
            }

            pub fn asUnsigned(self: Value) Error!u64 {
                if (self.err) |err| return err;

                const w = self.tape.get(self.index);
                const number = self.tape.get(self.index + 1);
                return switch (w.tag) {
                    .unsigned => @bitCast(number),
                    .signed => std.math.cast(u64, @as(i64, @bitCast(number))) orelse error.NumberOutOfRange,
                    else => error.IncorrectType,
                };
            }

            pub fn asSigned(self: Value) Error!i64 {
                if (self.err) |err| return err;

                const w = self.tape.get(self.index);
                const number = self.tape.get(self.index + 1);
                return switch (w.tag) {
                    .signed => @bitCast(number),
                    .unsigned => std.math.cast(i64, @as(u64, @bitCast(number))) orelse error.NumberOutOfRange,
                    else => error.IncorrectType,
                };
            }

            pub fn asFloat(self: Value) Error!f64 {
                if (self.err) |err| return err;

                const w = self.tape.get(self.index);
                const number = self.tape.get(self.index + 1);
                return switch (w.tag) {
                    .float => @bitCast(number),
                    .unsigned => @floatFromInt(@as(u64, @bitCast(number))),
                    .signed => @floatFromInt(@as(i64, @bitCast(number))),
                    else => error.IncorrectType,
                };
            }

            pub fn asBool(self: Value) Error!bool {
                if (self.err) |err| return err;

                return switch (self.tape.get(self.index).tag) {
                    .true => true,
                    .false => false,
                    else => error.IncorrectType,
                };
            }

            pub fn isNull(self: Value) Error!bool {
                if (self.err) |err| return err;

                return self.tape.get(self.index).tag == .null;
            }

            pub fn asAny(self: Value) Error!Element {
                if (self.err) |err| return err;

                const w = self.tape.get(self.index);
                return switch (w.tag) {
                    .true => .{ .bool = true },
                    .false => .{ .bool = false },
                    .null => .null,
                    .unsigned, .signed, .float => .{ .number = self.asNumber() catch unreachable },
                    .string => .{ .string = self.asString() catch unreachable },
                    .object_opening => .{ .object = .{ .tape = self.tape, .root = self.index } },
                    .array_opening => .{ .array = .{ .tape = self.tape, .root = self.index } },
                    else => unreachable,
                };
            }

            pub fn as(self: Value, comptime T: type) Error!T {
                const info = @typeInfo(T);
                switch (info) {
                    .int => {
                        const n = try self.asNumber();
                        return switch (n) {
                            .float => error.IncorrectType,
                            inline else => n.cast(T) orelse error.NumberOutOfRange,
                        };
                    },
                    .float => return @floatCast(try self.asFloat()),
                    .bool => return self.asBool(),
                    .optional => |opt| {
                        if (try self.isNull()) return null;
                        const child = try self.as(opt.child);
                        return child;
                    },
                    else => {
                        if (T == []const u8) return self.asString() else @compileError(std.fmt.comptimePrint("it is not possible to automagically cast a JSON value to type {s}", .{@typeName(T)}));
                    },
                }
            }

            pub fn getType(self: Value) Error!types.ElementType {
                if (self.err) |err| return err;

                const w = self.tape.get(self.index);
                return switch (w.tag) {
                    .true, .false => .bool,
                    .null => .null,
                    .number => .number,
                    .string => .string,
                    .object_opening => .object,
                    .array_opening => .array,
                    else => unreachable,
                };
            }

            pub inline fn at(self: Value, ptr: anytype) Value {
                @setEvalBranchQuota(10000);
                if (self.err) |_| return self;

                const query = brk: {
                    if (common.isString(@TypeOf(ptr))) {
                        const obj = self.asObject() catch |err| return .{
                            .tape = self.tape,
                            .index = self.index,
                            .err = err,
                        };
                        break :brk obj.at(ptr);
                    }
                    if (common.isIndex(@TypeOf(ptr))) {
                        const arr = self.asArray() catch |err| return .{
                            .tape = self.tape,
                            .index = self.index,
                            .err = err,
                        };
                        break :brk arr.at(ptr);
                    }
                    @compileError(common.error_messages.at_type);
                };
                return query;
            }

            pub fn getSize(self: Value) Error!u24 {
                if (self.err) |err| return err;

                if (self.asArray()) |arr| return arr.getSize() else |_| {}
                if (self.asObject()) |obj| return obj.getSize() else |_| {}
                return error.IncorrectType;
            }
        };

        pub const Array = struct {
            tape: *const Tape,
            root: u32,

            pub const Iterator = struct {
                tape: *const Tape,
                curr: u32,

                pub fn next(self: *Iterator) ?Value {
                    const curr = self.tape.get(self.curr);
                    if (curr.tag == .array_closing) return null;
                    defer self.curr = switch (curr.tag) {
                        .array_opening, .object_opening => curr.data.ptr,
                        .unsigned, .signed, .float => self.curr + 2,
                        else => self.curr + 1,
                    };
                    return .{ .tape = self.tape, .index = self.curr };
                }
            };

            pub fn iterator(self: Array) Iterator {
                return .{
                    .tape = self.tape,
                    .curr = self.root + 1,
                };
            }

            pub inline fn at(self: Array, index: u32) Value {
                @setEvalBranchQuota(10000);
                var it = self.iterator();
                var i: u32 = 0;
                while (it.next()) |v| : (i += 1) if (i == index) return v;
                return .{
                    .tape = self.tape,
                    .index = self.root,
                    .err = error.IndexOutOfBounds,
                };
            }

            pub fn isEmpty(self: Array) bool {
                return self.getSize() == 0;
            }

            pub fn getSize(self: Array) u24 {
                assert(self.tape.get(self.root).tag == .array_opening);
                return self.tape.get(self.root).data.len;
            }
        };

        pub const Object = struct {
            tape: *const Tape,
            root: u32,

            pub const Field = struct {
                key: []const u8,
                value: Value,
            };

            pub const Iterator = struct {
                tape: *const Tape,
                curr: u32,

                pub fn next(self: *Iterator) ?Field {
                    if (self.tape.get(self.curr).tag == .object_closing) return null;
                    const field = Value{ .tape = self.tape, .index = self.curr };
                    const value = Value{ .tape = self.tape, .index = self.curr + 1 };
                    const curr = self.tape.get(self.curr + 1);
                    defer self.curr = switch (curr.tag) {
                        .array_opening, .object_opening => curr.data.ptr,
                        .unsigned, .signed, .float => self.curr + 3,
                        else => self.curr + 2,
                    };
                    return .{
                        .key = field.asString() catch unreachable,
                        .value = value,
                    };
                }
            };

            pub fn iterator(self: Object) Iterator {
                return .{
                    .tape = self.tape,
                    .curr = self.root + 1,
                };
            }

            pub inline fn at(self: Object, key: []const u8) Value {
                @setEvalBranchQuota(2000000);
                var it = self.iterator();
                while (it.next()) |field| if (std.mem.eql(u8, field.key, key)) return field.value;
                return .{
                    .tape = self.tape,
                    .index = self.root,
                    .err = error.MissingField,
                };
            }

            pub fn isEmpty(self: Object) bool {
                return self.getSize() == 0;
            }

            pub fn getSize(self: Object) u24 {
                assert(self.tape.get(self.root).tag == .object_opening);
                return self.tape.get(self.root).data.len;
            }
        };

        const Tape = struct {
            const State = enum(u8) {
                start = 0,
                object_begin = '{',
                object_field = 1,
                object_continue = '{' + 1,
                object_end = '}',
                array_begin = '[',
                array_value = 2,
                array_continue = '[' + 1,
                array_end = ']',
                end = 3,
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

            const Word = packed struct(u64) {
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

            const StringHighBits = if (want_stream) u24 else u16;

            allocator: Allocator,
            tokens: Tokens,

            words: types.BoundedArrayListUnmanaged(u64, max_capacity_bound),
            stack: Stack,

            strings: types.BoundedArrayListUnmanaged(u8, max_capacity_bound),

            pub fn init(allocator: Allocator) Tape {
                return .{
                    .allocator = allocator,
                    .tokens = if (want_stream) .init else .init(allocator),
                    .words = .empty,
                    .stack = .empty,
                    .strings = .empty,
                };
            }

            pub fn deinit(self: *Tape) void {
                self.tokens.deinit();
                self.words.deinit(self.allocator);
                self.stack.deinit(self.allocator);
                self.strings.deinit(self.allocator);
            }

            pub inline fn build(self: *Tape, document: if (want_stream) Reader.? else Aligned.slice) Error!void {
                try self.tokens.build(document);
                try self.stack.ensureTotalCapacity(self.allocator, self.stack.max_depth);

                if (!want_stream) {
                    const tokens_count = self.tokens.indexes.items.len;
                    // if there are only n numbers, there must be n - 1 commas plus an ending container token, so almost half of the tokens are numbers
                    try self.words.ensureTotalCapacity(self.allocator, tokens_count + (tokens_count >> 1) + 1);
                }

                self.words.list.clearRetainingCapacity();
                self.stack.list.clearRetainingCapacity();

                self.strings.list.clearRetainingCapacity();

                return self.dispatch();
            }

            pub inline fn get(self: Tape, index: u32) Word {
                return @bitCast(self.words.items()[index]);
            }

            fn dispatch(self: *Tape) Error!void {
                state: switch (State.start) {
                    .start => {
                        const t = try self.tokens.next();
                        switch (t[0]) {
                            '{', '[' => |container_begin| {
                                if (self.tokens.peekChar() == container_begin + 2) {
                                    @branchHint(.unlikely);
                                    try self.visitEmptyContainer(container_begin);
                                    continue :state .end;
                                }
                                continue :state @enumFromInt(container_begin);
                            },
                            else => {
                                try self.visitPrimitive(t);
                                continue :state .end;
                            },
                        }
                    },
                    .object_begin => {
                        if (self.stack.list.len > self.stack.max_capacity) return error.ExceededDepth;

                        const curr: u32 = @intCast(self.words.items().len);
                        self.stack.appendAssumeCapacity(.{
                            .tag = .object_opening,
                            .data = .{
                                .ptr = curr,
                                .len = 1,
                            },
                        });

                        if (want_stream) try self.words.ensureUnusedCapacity(self.allocator, 1);
                        self.words.list.items.len += 1;

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
                                '{', '[' => |container_begin| {
                                    if (self.tokens.peekChar() == container_begin + 2) {
                                        try self.visitEmptyContainer(container_begin);
                                        continue :state .object_continue;
                                    }
                                    continue :state @enumFromInt(container_begin);
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
                                assert(self.stack.list.items(.tag)[self.stack.list.len - 1] == .object_opening);
                                assert(self.stack.list.capacity != 0);
                                const scope = self.stack.list.items(.data)[self.stack.list.len - 1];
                                if (want_stream) try self.words.ensureUnusedCapacity(self.allocator, 1);
                                self.words.appendAssumeCapacity(
                                    @bitCast(Word{
                                        .tag = .object_closing,
                                        .data = .{
                                            .ptr = scope.ptr,
                                            .len = undefined,
                                        },
                                    }),
                                );
                                const curr: u32 = @intCast(self.words.items().len);
                                self.words.items()[scope.ptr] = @bitCast(Word{
                                    .tag = .object_opening,
                                    .data = .{
                                        .ptr = curr,
                                        .len = @intCast(@min(scope.len, std.math.maxInt(u24))),
                                    },
                                });
                                continue :state .scope_end;
                            },
                            else => return error.ExpectedObjectCommaOrEnd,
                        }
                    },
                    .array_begin => {
                        if (self.stack.list.len > self.stack.max_capacity) return error.ExceededDepth;

                        const curr: u32 = @intCast(self.words.items().len);
                        self.stack.appendAssumeCapacity(.{
                            .tag = .array_opening,
                            .data = .{
                                .ptr = curr,
                                .len = 1,
                            },
                        });

                        if (want_stream) try self.words.ensureUnusedCapacity(self.allocator, 1);
                        self.words.list.items.len += 1;

                        continue :state .array_value;
                    },
                    .array_value => {
                        const t = try self.tokens.next();
                        switch (t[0]) {
                            '{', '[' => |container_begin| {
                                if (self.tokens.peekChar() == container_begin + 2) {
                                    try self.visitEmptyContainer(container_begin);
                                    continue :state .array_continue;
                                }
                                continue :state @enumFromInt(container_begin);
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
                                assert(self.stack.list.items(.tag)[self.stack.list.len - 1] == .array_opening);
                                assert(self.stack.list.capacity != 0);
                                const scope = self.stack.list.items(.data)[self.stack.list.len - 1];
                                if (want_stream) try self.words.ensureUnusedCapacity(self.allocator, 1);
                                self.words.appendAssumeCapacity(@bitCast(Word{
                                    .tag = .array_closing,
                                    .data = .{
                                        .ptr = scope.ptr,
                                        .len = undefined,
                                    },
                                }));
                                const curr: u32 = @intCast(self.words.items().len);
                                self.words.items()[scope.ptr] = @bitCast(Word{
                                    .tag = .array_opening,
                                    .data = .{
                                        .ptr = curr,
                                        .len = @intCast(@min(scope.len, std.math.maxInt(u24))),
                                    },
                                });

                                continue :state .scope_end;
                            },
                            else => return error.ExpectedArrayCommaOrEnd,
                        }
                    },
                    .scope_end => {
                        self.stack.list.len -= 1;
                        if (self.stack.list.len == 0) {
                            @branchHint(.unlikely);
                            continue :state .end;
                        }
                        assert(self.stack.list.capacity != 0);
                        const parent = self.stack.list.items(.tag)[self.stack.list.len - 1];
                        continue :state @enumFromInt(@intFromEnum(parent) + 1);
                    },
                    .end => {
                        const trail = try self.tokens.next();
                        if (!common.tables.is_whitespace[trail[0]]) return error.TrailingContent;
                        if (self.words.items().len == 0) return error.Empty;
                    },
                }
            }

            inline fn incrementContainerCount(self: *Tape) void {
                assert(self.stack.list.capacity != 0);
                const scope = &self.stack.list.items(.data)[self.stack.list.len - 1];
                scope.len += 1;
            }

            inline fn visitPrimitive(self: *Tape, ptr: [*]const u8) Error!void {
                const t = ptr[0];
                switch (t) {
                    '"' => {
                        @branchHint(.likely);
                        return self.visitString(ptr);
                    },
                    't' => return self.visitTrue(ptr),
                    'f' => return self.visitFalse(ptr),
                    'n' => return self.visitNull(ptr),
                    else => {
                        @branchHint(.likely);
                        return self.visitNumber(ptr);
                    },
                }
            }

            inline fn visitEmptyContainer(self: *Tape, tag: u8) Error!void {
                if (want_stream) try self.words.ensureUnusedCapacity(self.allocator, 2);
                const curr: u32 = @intCast(self.words.items().len);
                self.words.appendAssumeCapacity(
                    @bitCast(Word{
                        .tag = @enumFromInt(tag),
                        .data = .{
                            .ptr = curr + 2,
                            .len = 0,
                        },
                    }),
                );
                self.words.appendAssumeCapacity(
                    @bitCast(Word{
                        .tag = @enumFromInt(tag + 2),
                        .data = .{
                            .ptr = curr,
                            .len = undefined,
                        },
                    }),
                );
                _ = try self.tokens.next();
            }

            inline fn visitString(self: *Tape, ptr: [*]const u8) Error!void {
                if (want_stream) {
                    try self.words.ensureUnusedCapacity(self.allocator, 1);
                    try self.strings.ensureUnusedCapacity(self.allocator, options.stream.?.chunk_length);
                }
                const writeString = @import("parsers/string.zig").writeString;
                const curr: u32 = @intCast(self.strings.items().len);
                const low_bits = self.strings.items()[curr..].ptr;
                const next_str = low_bits + @sizeOf(u16);
                const sentinel = try writeString(ptr, next_str);
                const next_len: u32 = @intCast(@intFromPtr(sentinel) - @intFromPtr(next_str));
                std.mem.writeInt(u16, low_bits[0..@sizeOf(u16)], @truncate(next_len), native_endian);
                const high_bits: StringHighBits = @truncate(next_len >> @bitSizeOf(StringHighBits));
                self.words.appendAssumeCapacity(
                    @bitCast(Word{
                        .tag = .string,
                        .data = .{
                            .ptr = curr,
                            .len = high_bits,
                        },
                    }),
                );
                self.strings.list.items.len += next_len + @sizeOf(u16);
            }

            inline fn visitNumber(self: *Tape, ptr: [*]const u8) Error!void {
                if (want_stream) {
                    try self.words.ensureUnusedCapacity(self.allocator, 1);
                }
                const number = try @import("parsers/number/parser.zig").parse(null, ptr);
                self.words.appendAssumeCapacity(
                    @bitCast(Word{
                        .tag = @enumFromInt(@intFromEnum(number)),
                        .data = undefined,
                    }),
                );
                switch (number) {
                    inline else => |n| self.words.appendAssumeCapacity(@bitCast(n)),
                }
            }

            inline fn visitTrue(self: *Tape, ptr: [*]const u8) Error!void {
                if (want_stream) try self.words.ensureUnusedCapacity(self.allocator, 1);
                const check = @import("parsers/atoms.zig").checkTrue;
                try check(ptr);
                self.words.appendAssumeCapacity(
                    @bitCast(Word{
                        .tag = .true,
                        .data = undefined,
                    }),
                );
            }

            inline fn visitFalse(self: *Tape, ptr: [*]const u8) Error!void {
                if (want_stream) try self.words.ensureUnusedCapacity(self.allocator, 1);
                const check = @import("parsers/atoms.zig").checkFalse;
                try check(ptr);
                self.words.appendAssumeCapacity(
                    @bitCast(Word{
                        .tag = .false,
                        .data = undefined,
                    }),
                );
            }

            inline fn visitNull(self: *Tape, ptr: [*]const u8) Error!void {
                if (want_stream) try self.words.ensureUnusedCapacity(self.allocator, 1);
                const check = @import("parsers/atoms.zig").checkNull;
                try check(ptr);
                self.words.appendAssumeCapacity(
                    @bitCast(Word{
                        .tag = .null,
                        .data = undefined,
                    }),
                );
            }
        };
    };
}
