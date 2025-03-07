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

        document_buffer: if (need_document_buffer) std.ArrayListAlignedUnmanaged(u8, types.Aligned(true).alignment) else void,
        tape: Tape,

        max_capacity: usize,
        capacity: usize,

        pub const init: Self = .{
            .document_buffer = if (need_document_buffer) .empty else {},
            .tape = .init,
            .max_capacity = max_capacity_bound,
            .capacity = 0,
        };

        pub fn deinit(self: *Self, allocator: Allocator) void {
            self.tape.deinit(allocator);
            if (need_document_buffer) self.document_buffer.deinit(allocator);
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

        pub fn ensureTotalCapacity(self: *Self, allocator: Allocator, new_capacity: usize) Error!void {
            if (new_capacity > self.max_capacity) return error.ExceededCapacity;

            if (need_document_buffer) {
                try self.document_buffer.ensureTotalCapacity(allocator, new_capacity + types.Vector.bytes_len);
            }

            if (!want_stream) {
                try self.tape.tokens.ensureTotalCapacity(allocator, new_capacity);
            }

            try self.tape.strings.ensureTotalCapacity(allocator, new_capacity + types.Vector.bytes_len);

            self.capacity = new_capacity;
        }

        pub fn parse(self: *Self, allocator: Allocator, document: if (Reader) |reader| reader else Aligned.slice) Error!Value {
            if (need_document_buffer) {
                self.document_buffer.clearRetainingCapacity();
                try @as(Error!void, @errorCast(common.readAllRetainingCapacity(
                    allocator,
                    document,
                    types.Aligned(true).alignment,
                    &self.document_buffer,
                    self.max_capacity,
                )));
                const len = self.document_buffer.items.len;
                try self.ensureTotalCapacity(allocator, len);
                self.document_buffer.appendNTimesAssumeCapacity(' ', types.Vector.bytes_len);
                try self.tape.build(allocator, self.document_buffer.items[0..len]);
            } else {
                if (!want_stream) try self.ensureTotalCapacity(allocator, document.len);
                try self.tape.build(allocator, document);
            }
            return .{
                .tape = &self.tape,
                .index = 0,
            };
        }

        pub const AnyValue = union(types.ValueType) {
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
                        const low_bits = std.mem.readInt(u16, self.tape.strings.items().ptr[w.data.ptr..][0..@sizeOf(u16)], native_endian);
                        const high_bits: u64 = w.data.len;
                        const len = high_bits << 16 | low_bits;
                        const ptr = self.tape.strings.items().ptr[w.data.ptr + @sizeOf(u16) ..];
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

            pub fn asAny(self: Value) Error!AnyValue {
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

            pub fn getType(self: Value) Error!types.ValueType {
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

            pub inline fn at(self: Value, key: []const u8) Value {
                @setEvalBranchQuota(10000);
                if (self.err) |_| return self;
                const obj = self.asObject() catch |err| return .{
                    .tape = self.tape,
                    .index = self.index,
                    .err = err,
                };
                return obj.at(key);
            }

            pub inline fn atIndex(self: Value, index: usize) Value {
                @setEvalBranchQuota(10000);
                if (self.err) |_| return self;
                const arr = self.asArray() catch |err| return .{
                    .tape = self.tape,
                    .index = self.index,
                    .err = err,
                };
                return arr.at(index);
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
                tag: Tag,
                data: packed struct {
                    ptr: u32,
                    len: u24,
                },
            };

            const Stack = struct {
                const Context = struct {
                    pub const Data = struct {
                        len: u32,
                        ptr: u32,
                    };
                    tag: Tag,
                    data: Data,
                };

                max_depth: usize = 1024,
                multi: std.MultiArrayList(Context) = .empty,

                pub const empty: @This() = .{};

                pub fn deinit(self: *Stack, allocator: Allocator) void {
                    self.multi.deinit(allocator);
                }

                pub inline fn ensureTotalCapacity(
                    self: *Stack,
                    allocator: Allocator,
                    new_depth: usize,
                ) Error!void {
                    if (new_depth > self.max_depth) return error.ExceededDepth;
                    return self.setMaxDepth(allocator, new_depth);
                }

                pub inline fn setMaxDepth(self: *Stack, allocator: Allocator, new_depth: usize) Error!void {
                    try self.multi.setCapacity(allocator, new_depth);
                    self.max_depth = new_depth;
                }

                pub inline fn push(self: *Stack, item: Context) Error!void {
                    if (self.multi.len >= self.multi.capacity) return error.ExceededDepth;
                    assert(self.multi.capacity != 0);
                    self.multi.appendAssumeCapacity(item);
                }

                pub inline fn pop(self: *Stack) void {
                    self.multi.len -= 1;
                }

                pub inline fn len(self: Stack) usize {
                    return self.multi.len;
                }

                pub inline fn clearRetainingCapacity(self: *Stack) void {
                    self.multi.clearRetainingCapacity();
                }

                pub inline fn incrementContainerCount(self: *Stack) void {
                    assert(self.multi.capacity != 0);
                    const scope = &self.multi.items(.data)[self.multi.len - 1];
                    scope.len += 1;
                }

                pub inline fn getScopeData(self: Stack) Context.Data {
                    assert(self.multi.capacity != 0);
                    return self.multi.items(.data)[self.multi.len - 1];
                }

                pub inline fn getScopeType(self: Stack) Tag {
                    assert(self.multi.capacity != 0);
                    return self.multi.items(.tag)[self.multi.len - 1];
                }
            };

            tokens: Tokens,

            words: types.BoundedArrayList(u64, max_capacity_bound),
            stack: Stack,

            strings: types.BoundedArrayList(u8, max_capacity_bound + types.Vector.bytes_len),

            words_ptr: if (want_stream) void else [*]u64 = undefined,
            strings_ptr: if (want_stream) void else [*]u8 = undefined,

            pub const init: Tape = .{
                .tokens = .init,
                .words = .empty,
                .stack = .empty,
                .strings = .empty,
            };

            pub fn deinit(self: *Tape, allocator: Allocator) void {
                self.words.deinit(allocator);
                self.stack.deinit(allocator);
                self.strings.deinit(allocator);
                self.tokens.deinit(allocator);
            }

            pub inline fn build(self: *Tape, allocator: Allocator, document: if (want_stream) Reader.? else Aligned.slice) Error!void {
                try self.tokens.build(allocator, document);
                try self.stack.ensureTotalCapacity(allocator, self.stack.max_depth);

                if (!want_stream) {
                    const tokens_count = self.tokens.indexes.items.len;
                    // if there are only n numbers, there must be n - 1 commas plus an ending container token, so almost half of the tokens are numbers
                    try self.words.ensureTotalCapacity(allocator, tokens_count + (tokens_count >> 1) + 1);
                }

                self.words.list.clearRetainingCapacity();
                self.stack.clearRetainingCapacity();

                self.strings.list.clearRetainingCapacity();

                if (!want_stream) {
                    self.words_ptr = self.words.items().ptr;
                    self.strings_ptr = self.strings.items().ptr;
                }

                return self.dispatch(allocator);
            }

            pub inline fn get(self: Tape, index: u32) Word {
                return @bitCast(self.words.items().ptr[index]);
            }

            inline fn currentWord(self: Tape) u32 {
                if (want_stream) {
                    return @intCast(self.words.items().len);
                } else {
                    return @intCast((@intFromPtr(self.words_ptr) - @intFromPtr(self.words.items().ptr)) / @sizeOf(Word));
                }
            }

            inline fn advanceWord(self: *Tape, len: usize) void {
                if (want_stream) {
                    self.words.list.items.len += len;
                } else {
                    self.words_ptr += len;
                }
            }

            inline fn appendWordAssumeCapacity(self: *Tape, word: Word) void {
                if (want_stream) {
                    self.words.appendAssumeCapacity(@bitCast(word));
                } else {
                    self.words_ptr[0] = @bitCast(word);
                    self.advanceWord(1);
                }
            }

            inline fn appendTwoWordsAssumeCapacity(self: *Tape, words: [2]Word) void {
                const vec: @Vector(2, u64) = @bitCast(words);
                const slice: *const [2]u64 = &vec;
                if (want_stream) {
                    const arr = self.words.list.addManyAsArrayAssumeCapacity(2);
                    @memcpy(arr, slice);
                } else {
                    @memcpy(self.words_ptr, slice);
                    self.advanceWord(2);
                }
            }

            inline fn currentString(self: Tape) [*]u8 {
                if (want_stream) {
                    const strings = self.strings.items();
                    return strings.ptr[strings.len..];
                } else {
                    return self.strings_ptr;
                }
            }

            inline fn advanceString(self: *Tape, len: usize) void {
                if (want_stream) {
                    self.strings.list.items.len += len;
                } else {
                    self.strings_ptr += len;
                }
            }

            fn dispatch(self: *Tape, allocator: Allocator) Error!void {
                // const tracy = @import("tracy");
                // var tracer = tracy.traceNamed(@src(), "dispatch");
                // defer tracer.end();

                state: switch (State.start) {
                    .start => {
                        const t = try self.tokens.next();
                        switch (t[0]) {
                            '{', '[' => |container_begin| {
                                if (self.tokens.peekChar() == container_begin + 2) {
                                    @branchHint(.unlikely);
                                    try self.visitEmptyContainer(allocator, container_begin);
                                    continue :state .end;
                                }
                                continue :state @enumFromInt(container_begin);
                            },
                            else => {
                                try self.visitPrimitive(allocator, t);
                                continue :state .end;
                            },
                        }
                    },
                    .object_begin => {
                        try self.stack.push(.{
                            .tag = .object_opening,
                            .data = .{
                                .ptr = self.currentWord(),
                                .len = 1,
                            },
                        });

                        if (want_stream) try self.words.ensureUnusedCapacity(allocator, 1);
                        self.advanceWord(1);

                        continue :state .object_field;
                    },
                    .object_field => {
                        {
                            const t = try self.tokens.next();
                            if (t[0] == '"') {
                                try self.visitString(allocator, t);
                            } else {
                                return error.ExpectedKey;
                            }
                        }
                        if ((try self.tokens.next())[0] == ':') {
                            const t = try self.tokens.next();
                            switch (t[0]) {
                                '{', '[' => |container_begin| {
                                    if (self.tokens.peekChar() == container_begin + 2) {
                                        try self.visitEmptyContainer(allocator, container_begin);
                                        continue :state .object_continue;
                                    }
                                    continue :state @enumFromInt(container_begin);
                                },
                                else => {
                                    try self.visitPrimitive(allocator, t);
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
                                self.stack.incrementContainerCount();
                                continue :state .object_field;
                            },
                            '}' => continue :state .object_end,
                            else => return error.ExpectedObjectCommaOrEnd,
                        }
                    },
                    .array_begin => {
                        try self.stack.push(.{
                            .tag = .array_opening,
                            .data = .{
                                .ptr = self.currentWord(),
                                .len = 1,
                            },
                        });

                        if (want_stream) try self.words.ensureUnusedCapacity(allocator, 1);
                        self.advanceWord(1);

                        continue :state .array_value;
                    },
                    .array_value => {
                        const t = try self.tokens.next();
                        switch (t[0]) {
                            '{', '[' => |container_begin| {
                                if (self.tokens.peekChar() == container_begin + 2) {
                                    try self.visitEmptyContainer(allocator, container_begin);
                                    continue :state .array_continue;
                                }
                                continue :state @enumFromInt(container_begin);
                            },
                            else => {
                                try self.visitPrimitive(allocator, t);
                                continue :state .array_continue;
                            },
                        }
                    },
                    .array_continue => {
                        switch ((try self.tokens.next())[0]) {
                            ',' => {
                                self.stack.incrementContainerCount();
                                continue :state .array_value;
                            },
                            ']' => continue :state .array_end,
                            else => return error.ExpectedArrayCommaOrEnd,
                        }
                    },
                    .object_end, .array_end => |tag| {
                        const scope = self.stack.getScopeData();
                        if (want_stream) try self.words.ensureUnusedCapacity(allocator, 1);
                        self.appendWordAssumeCapacity(.{
                            .tag = @enumFromInt(@intFromEnum(tag)),
                            .data = .{
                                .ptr = scope.ptr,
                                .len = undefined,
                            },
                        });
                        self.words.items().ptr[scope.ptr] = @bitCast(Word{
                            .tag = @enumFromInt(@intFromEnum(tag) - 2),
                            .data = .{
                                .ptr = self.currentWord(),
                                .len = @intCast(@min(scope.len, std.math.maxInt(u24))),
                            },
                        });
                        self.stack.pop();
                        if (self.stack.len() == 0) {
                            @branchHint(.unlikely);
                            continue :state .end;
                        }
                        const parent = self.stack.getScopeType();
                        continue :state @enumFromInt(@intFromEnum(parent) + 1);
                    },
                    .end => {
                        const trail = try self.tokens.next();
                        if (!common.tables.is_whitespace[trail[0]]) return error.TrailingContent;
                        if (self.currentWord() == 0) return error.Empty;
                    },
                }
            }

            inline fn visitPrimitive(self: *Tape, allocator: Allocator, ptr: [*]const u8) Error!void {
                const t = ptr[0];
                switch (t) {
                    '"' => {
                        @branchHint(.likely);
                        return self.visitString(allocator, ptr);
                    },
                    't' => return self.visitTrue(allocator, ptr),
                    'f' => return self.visitFalse(allocator, ptr),
                    'n' => return self.visitNull(allocator, ptr),
                    else => {
                        @branchHint(.likely);
                        return self.visitNumber(allocator, ptr);
                    },
                }
            }

            inline fn visitEmptyContainer(self: *Tape, allocator: Allocator, tag: u8) Error!void {
                if (want_stream) try self.words.ensureUnusedCapacity(allocator, 2);
                const curr = self.currentWord();
                self.appendTwoWordsAssumeCapacity(.{
                    .{
                        .tag = @enumFromInt(tag),
                        .data = .{
                            .ptr = curr + 2,
                            .len = 0,
                        },
                    },
                    .{
                        .tag = @enumFromInt(tag + 2),
                        .data = .{
                            .ptr = curr,
                            .len = undefined,
                        },
                    },
                });
                _ = try self.tokens.next();
            }

            inline fn visitString(self: *Tape, allocator: Allocator, ptr: [*]const u8) Error!void {
                if (want_stream) {
                    try self.words.ensureUnusedCapacity(allocator, 1);
                    try self.strings.ensureUnusedCapacity(allocator, options.stream.?.chunk_length);
                }
                const writeString = @import("parsers/string.zig").writeString;
                const curr_str = self.currentString();
                const next_str = curr_str + @sizeOf(u16);
                const next_len = (try writeString(ptr, next_str)) - next_str;
                self.appendWordAssumeCapacity(.{
                    .tag = .string,
                    .data = .{
                        .ptr = @intCast(curr_str - self.strings.items().ptr),
                        .len = @intCast(next_len >> 16),
                    },
                });
                std.mem.writeInt(u16, curr_str[0..@sizeOf(u16)], @truncate(next_len), native_endian);
                self.advanceString(next_len + @sizeOf(u16));
            }

            inline fn visitNumber(self: *Tape, allocator: Allocator, ptr: [*]const u8) Error!void {
                if (want_stream) {
                    try self.words.ensureUnusedCapacity(allocator, 2);
                }
                const number = try @import("parsers/number/parser.zig").parse(null, ptr);
                switch (number) {
                    inline else => |n| {
                        self.appendTwoWordsAssumeCapacity(.{
                            .{
                                .tag = @enumFromInt(@intFromEnum(number)),
                                .data = undefined,
                            },
                            @bitCast(n),
                        });
                    },
                }
            }

            inline fn visitTrue(self: *Tape, allocator: Allocator, ptr: [*]const u8) Error!void {
                if (want_stream) try self.words.ensureUnusedCapacity(allocator, 1);
                const check = @import("parsers/atoms.zig").checkTrue;
                try check(ptr);
                self.appendWordAssumeCapacity(.{
                    .tag = .true,
                    .data = undefined,
                });
            }

            inline fn visitFalse(self: *Tape, allocator: Allocator, ptr: [*]const u8) Error!void {
                if (want_stream) try self.words.ensureUnusedCapacity(allocator, 1);
                const check = @import("parsers/atoms.zig").checkFalse;
                try check(ptr);
                self.appendWordAssumeCapacity(.{
                    .tag = .false,
                    .data = undefined,
                });
            }

            inline fn visitNull(self: *Tape, allocator: Allocator, ptr: [*]const u8) Error!void {
                if (want_stream) try self.words.ensureUnusedCapacity(allocator, 1);
                const check = @import("parsers/atoms.zig").checkNull;
                try check(ptr);
                self.appendWordAssumeCapacity(.{
                    .tag = .null,
                    .data = undefined,
                });
            }
        };
    };
}
