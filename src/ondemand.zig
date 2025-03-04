const std = @import("std");
const builtin = @import("builtin");
const common = @import("common.zig");
const types = @import("types.zig");
const intr = @import("intrinsics.zig");
const tokens = @import("tokens.zig");
const Vector = types.Vector;
const Pred = types.Predicate;
const Allocator = std.mem.Allocator;
const Number = types.Number;
const vector = types.vector;
const log = std.log;
const assert = std.debug.assert;

pub const default_stream_chunk_length = tokens.ring_buffer.default_chunk_length;

pub fn ParserOptions(comptime Reader: ?type) type {
    return if (Reader) |_| struct {
        pub const default: @This() = .{};
        aligned: bool = false,
        stream: ?struct {
            pub const default: @This() = .{};
            chunk_length: u32 = default_stream_chunk_length,
        } = null,
        schema_identifier: []const u8 = "schema",
    } else struct {
        pub const default: @This() = .{};
        aligned: bool = false,
        assume_padding: bool = false,
        schema_identifier: []const u8 = "schema",
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

        const Aligned = types.Aligned(options.aligned);
        const Tokens = if (want_stream)
            tokens.Stream(.{
                .Reader = Reader.?,
                .aligned = aligned,
                .chunk_len = options.stream.?.chunk_length,
                .slots = 4,
            })
        else
            tokens.Iterator(.{
                .aligned = aligned,
                .assume_padding = Reader != null or options.assume_padding,
            });

        pub const Error = Tokens.Error || types.ParseError || Allocator.Error ||
            error{
            ExpectedAllocator,
        } ||
            if (builtin.mode == .Debug) error{OutOfOrderIteration} else error{} ||
            if (Reader) |reader| reader.Error else error{};

        pub const max_capacity_bound = if (want_stream) std.math.maxInt(usize) else std.math.maxInt(u32);
        pub const default_max_depth = 1024;

        allocator: if (want_stream) ?Allocator else Allocator,
        document_buffer: if (need_document_buffer) std.ArrayListAligned(u8, types.Aligned(true).alignment) else void,

        strings: types.BoundedArrayListUnmanaged(u8, max_capacity_bound),
        temporal_string_buffer: if (want_stream) [options.stream.?.chunk_length + Vector.bytes_len]u8 else void = undefined,

        cursor: Cursor,

        max_capacity: usize,
        max_depth: usize,
        capacity: usize,

        pub fn init(allocator: if (want_stream) ?Allocator else Allocator) Self {
            return .{
                .cursor = .init(allocator),
                .allocator = allocator,
                .document_buffer = if (need_document_buffer) .init(allocator) else {},
                .strings = .empty,
                .max_capacity = max_capacity_bound,
                .max_depth = default_max_depth,
                .capacity = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self.cursor.deinit();
            if (need_document_buffer) self.document_buffer.deinit();
            if (want_stream) {
                if (self.allocator) |alloc| self.strings.deinit(alloc);
            } else {
                self.strings.deinit(self.allocator);
            }
        }

        pub fn setMaximumCapacity(self: *Self, new_capacity: usize) Error!void {
            if (new_capacity > max_capacity_bound) return error.ExceededCapacity;

            if (!want_stream and new_capacity + 1 < self.tokens.indexes.items.len)
                self.tokens.indexes.shrinkAndFree(new_capacity + 1);

            if (new_capacity + types.Vector.bytes_len < self.strings.items().len) {
                if (want_stream) {
                    if (self.allocator) |alloc|
                        self.strings.list.shrinkAndFree(alloc, new_capacity + types.Vector.bytes_len);
                } else {
                    self.strings.list.shrinkAndFree(self.allocator, new_capacity + types.Vector.bytes_len);
                }
                self.strings.max_capacity = new_capacity + types.Vector.bytes_len;
            }

            self.max_capacity = new_capacity;
        }

        pub fn ensureTotalCapacity(self: *Self, new_capacity: usize) Error!void {
            if (new_capacity > self.max_capacity) return error.ExceededCapacity;

            if (need_document_buffer) {
                try self.document_buffer.ensureTotalCapacity(new_capacity + types.Vector.bytes_len);
            }

            if (!want_stream) {
                try self.cursor.tokens.ensureTotalCapacity(new_capacity);
            }

            if (want_stream) {
                if (self.allocator) |alloc|
                    try self.strings.ensureTotalCapacity(alloc, new_capacity + types.Vector.bytes_len);
            } else {
                try self.strings.ensureTotalCapacity(self.allocator, new_capacity + types.Vector.bytes_len);
            }

            self.capacity = new_capacity;
        }

        pub fn parse(self: *Self, document: if (Reader) |reader| reader else Aligned.slice) Error!Document {
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
                try self.cursor.tokens.build(self.document_buffer.items[0..len]);
            } else {
                if (!want_stream) try self.ensureTotalCapacity(document.len);
                try self.cursor.tokens.build(document);
            }
            self.strings.list.clearRetainingCapacity();
            self.cursor.document = self;
            self.cursor.strings = if (want_stream) 0 else self.strings.items().ptr;
            self.cursor.depth = 1;
            self.cursor.root = if (want_stream) 0 else @intFromPtr(self.cursor.tokens.indexes.items.ptr);
            self.cursor.err = null;
            if (builtin.mode == .Debug) {
                try self.cursor.start_positions.ensureTotalCapacity(self.max_depth);
                self.cursor.start_positions.expandToCapacity();
            }
            return .{
                .iter = .{
                    .cursor = &self.cursor,
                    .start_position = self.cursor.root,
                    .start_depth = 1,
                    .start_char = self.cursor.peekChar(),
                },
            };
        }

        pub fn parseAssumeCapacity(self: *Self, document: if (Reader) |reader| reader else Aligned.slice) Error!Document {
            if (need_document_buffer) {
                self.document_buffer.expandToCapacity();
                const len = try document.readAll(self.document_buffer.items);
                if (len > self.capacity) return error.ExceededCapacity;
                self.document_buffer.items.len = len;
                try self.document_buffer.appendNTimes(' ', types.Vector.bytes_len);
                try self.cursor.tokens.build(self.document_buffer.items[0..len]);
            } else {
                if (!want_stream) if (document.len > self.capacity) return error.ExceededCapacity;
                try self.cursor.tokens.build(document);
            }
            self.strings.list.clearRetainingCapacity();
            self.cursor.document = self;
            self.cursor.strings = if (want_stream) 0 else self.strings.items().ptr;
            self.cursor.depth = 1;
            self.cursor.root = if (want_stream) 0 else @intFromPtr(self.cursor.tokens.indexes.items.ptr);
            self.cursor.err = null;
            if (builtin.mode == .Debug) {
                try self.cursor.start_positions.ensureTotalCapacity(self.max_depth);
                self.cursor.start_positions.expandToCapacity();
            }
            return .{
                .iter = .{
                    .cursor = &self.cursor,
                    .start_position = self.cursor.root,
                    .start_depth = 1,
                    .start_char = self.cursor.peekChar(),
                },
            };
        }

        pub fn parseWithCapacity(self: *Self, document: if (Reader) |reader| reader else Aligned.slice, capacity: usize) Error!Document {
            try self.ensureTotalCapacity(capacity);
            return self.parseAssumeCapacity(document);
        }

        pub const AnyValue = union(types.ValueType) {
            null,
            bool: bool,
            number: Number,
            string: String,
            object: Object,
            array: Array,
        };

        const Cursor = struct {
            document: *Self = undefined,
            tokens: Tokens,
            strings: if (want_stream) usize else [*]u8 = undefined,
            start_positions: if (builtin.mode == .Debug) std.ArrayList(usize) else void = undefined,
            depth: u32 = 1,
            root: usize = undefined,
            err: ?Error = null,

            pub fn init(allocator: if (want_stream) ?Allocator else Allocator) Cursor {
                var self = Cursor{
                    .tokens = if (want_stream) .init else .init(allocator),
                };
                if (builtin.mode == .Debug) self.start_positions = .init(std.heap.page_allocator);
                return self;
            }

            pub fn deinit(self: *Cursor) void {
                self.tokens.deinit();
                if (builtin.mode == .Debug) {
                    self.start_positions.deinit();
                }
            }

            const position_size = if (want_stream) 1 else @sizeOf(u32);

            inline fn position(self: Cursor) usize {
                return self.tokens.position();
            }

            inline fn offset(self: Cursor) usize {
                return self.tokens.offset();
            }

            inline fn next(self: *Cursor) Error![*]const u8 {
                if (self.err) |err| return err;
                return self.tokens.next();
            }

            inline fn peekChar(self: *Cursor) u8 {
                return self.tokens.peekChar();
            }

            inline fn peek(self: *Cursor) Error![*]const u8 {
                return self.tokens.peek();
            }

            inline fn ascend(self: *Cursor, parent_depth: u32) void {
                assert(0 <= parent_depth and parent_depth < self.document.max_depth - 1);
                assert(self.depth == parent_depth + 1);
                self.depth = parent_depth;
            }

            inline fn descend(self: *Cursor, child_depth: u32) void {
                assert(1 <= child_depth and child_depth < self.document.max_depth);
                assert(self.depth == child_depth - 1);
                self.depth = child_depth;
            }

            inline fn skip(self: *Cursor, parent_depth: u32, parent_char: u8) Error!void {
                Logger.logDepth(parent_depth, self.depth);

                if (self.depth <= parent_depth) return;
                {
                    const ptr = try self.next();
                    switch (ptr[0]) {
                        '[', '{', ':' => {
                            try Logger.logStart(self.document, ptr, "skip  ", self.depth);
                        },
                        ',' => {
                            try Logger.log(self.document, ptr, "skip  ", self.depth);
                        },
                        ']', '}' => {
                            try Logger.logEnd(self.document, ptr, "skip  ", self.depth);
                            self.depth -= 1;
                            if (self.depth <= parent_depth) return;
                        },
                        '"' => {
                            const char = self.peekChar();
                            if (char == ':') {
                                try Logger.log(self.document, ptr, "key   ", self.depth);
                                _ = try self.next();
                            } else {
                                try Logger.log(self.document, ptr, "skip  ", self.depth);
                                self.depth -= 1;
                                if (self.depth <= parent_depth) return;
                            }
                        },
                        else => {
                            try Logger.log(self.document, ptr, "skip  ", self.depth);
                            self.depth -= 1;
                            if (self.depth <= parent_depth) return;
                        },
                    }
                }

                brk: while (true) {
                    const ptr = try self.next();
                    switch (ptr[0]) {
                        '[', '{' => {
                            try Logger.logStart(self.document, ptr, "skip  ", self.depth);
                            self.depth += 1;
                        },
                        ']', '}' => {
                            try Logger.logEnd(self.document, ptr, "skip  ", self.depth);
                            self.depth -= 1;
                            if (self.depth <= parent_depth) return;
                        },
                        ' ' => {
                            @branchHint(.unlikely);
                            break :brk;
                        },
                        else => {
                            try Logger.log(self.document, ptr, "skip  ", self.depth);
                        },
                    }
                }
                return self.reportError(switch (parent_char) {
                    '{' => error.IncompleteObject,
                    '[' => error.IncompleteArray,
                    else => error.TrailingContent,
                });
            }

            inline fn reportError(self: *Cursor, err: Error) Error!void {
                self.err = err;
                return err;
            }

            fn getStartPosition(self: Cursor, depth: usize) usize {
                assert(depth < self.document.max_depth);
                return self.start_positions.items[depth];
            }

            fn setStartPosition(self: *Cursor, depth: usize, pos: usize) void {
                assert(depth < self.document.max_depth);
                self.start_positions.items[depth] = pos;
            }
        };

        pub const Document = struct {
            iter: Value.Iterator,

            pub inline fn asValue(self: Document) Value {
                self.iter.assertAtRoot();
                return .{ .iter = self.iter };
            }

            pub inline fn asObject(self: Document) Error!Object {
                self.iter.assertAtRoot();
                const started, const object = try Object.start(self.iter);
                if (started or try self.iter.isAtEnd()) return object;
                return error.TrailingContent;
            }

            pub inline fn asArray(self: Document) Error!Array {
                self.iter.assertAtRoot();
                const started, const array = try Array.start(self.iter);
                if (started or try self.iter.isAtEnd()) return array;
                return error.TrailingContent;
            }

            pub inline fn asNumber(self: Document) Error!Number {
                self.iter.assertAtRoot();
                const n = try self.iter.asNumber();
                if (try self.iter.isAtEnd()) return n;
                return error.TrailingContent;
            }

            pub inline fn asUnsigned(self: Document) Error!u64 {
                self.iter.assertAtRoot();
                const n = try self.iter.asUnsigned();
                if (try self.iter.isAtEnd()) return n;
                return error.TrailingContent;
            }

            pub inline fn asSigned(self: Document) Error!i64 {
                self.iter.assertAtRoot();
                const n = try self.iter.asSigned();
                if (try self.iter.isAtEnd()) return n;
                return error.TrailingContent;
            }

            pub inline fn asFloat(self: Document) Error!f64 {
                self.iter.assertAtRoot();
                const n = try self.iter.asFloat();
                if (try self.iter.isAtEnd()) return n;
                return error.TrailingContent;
            }

            pub inline fn asString(self: Document) String {
                self.iter.assertAtRoot();
                const str = self.iter.asString() catch |err| .{
                    .iter = self.iter,
                    .raw_str = undefined,
                    .err = err,
                };
                const at_end = self.iter.isAtEnd() catch |err| return .{
                    .iter = self.iter,
                    .raw_str = undefined,
                    .err = err,
                };
                if (at_end) return str;
                return .{
                    .iter = self.iter,
                    .raw_str = undefined,
                    .err = error.TrailingContent,
                };
            }

            pub inline fn asBool(self: Document) Error!bool {
                self.iter.assertAtRoot();
                const b = try self.iter.asBool();
                if (try self.iter.isAtEnd()) return b;
                return error.TrailingContent;
            }

            pub inline fn isNull(self: Document) Error!bool {
                self.iter.assertAtRoot();
                const n = try self.iter.isNull();
                if (try self.iter.isAtEnd()) return n;
                return error.TrailingContent;
            }

            pub inline fn asAny(self: Document) Error!AnyValue {
                self.iter.assertAtRoot();
                return switch (self.iter.cursor.peekChar()) {
                    't', 'f' => .{ .bool = try self.asBool() },
                    'n' => .{ .null = brk: {
                        _ = try self.isNull();
                        break :brk {};
                    } },
                    '"' => .{ .string = self.asString() },
                    '-', '0'...'9' => switch (try self.asNumber()) {
                        .unsigned => |n| .{ .unsigned = n },
                        .signed => |n| .{ .signed = n },
                        .float => |n| .{ .float = n },
                    },
                    '[' => .{ .array = try self.asArray() },
                    '{' => .{ .object = try self.asObject() },
                    else => {
                        return error.ExpectedDocument;
                    },
                };
            }

            pub inline fn getType(self: Document) Error!types.ValueType {
                self.iter.assertAtRoot();
                return switch (self.iter.cursor.peekChar()) {
                    't', 'f' => .bool,
                    'n' => .null,
                    '"' => .string,
                    '-', '0'...'9' => .number,
                    '[' => .array,
                    '{' => .object,
                    else => error.ExpectedValue,
                };
            }

            pub inline fn as(self: Document, comptime T: type) schema.Error!std.json.Parsed(T) {
                const data = try self.asValue().as(T);
                if (try self.atEnd()) return data;
                return error.TrailingContent;
            }

            pub inline fn asAdvanced(self: Document, comptime T: type, comptime S: ?schema.Infer(T), allocator: ?Allocator) schema.Error!std.json.Parsed(T) {
                const data = try self.asValue().asAdvanced(T, S, allocator);
                if (try self.atEnd()) return data;
                return error.TrailingContent;
            }

            pub inline fn asLeaky(self: Document, comptime T: type) schema.Error!T {
                const data = try self.asValue().asLeaky(T);
                if (try self.atEnd()) return data;
                return error.TrailingContent;
            }

            pub inline fn asAdvancedLeaky(self: Document, comptime T: type, comptime S: ?schema.Infer(T), allocator: ?Allocator) schema.Error!T {
                const data = try self.asValue().asAdvancedLeaky(T, S, allocator);
                if (try self.atEnd()) return data;
                return error.TrailingContent;
            }

            pub inline fn skip(self: Document) Error!void {
                return self.iter.cursor.skip(0, self.iter.start_char);
            }

            pub inline fn atEnd(self: Document) Error!bool {
                try self.skip();
                return self.iter.isAtEnd();
            }

            pub inline fn at(self: Document, key: []const u8) Value {
                @setEvalBranchQuota(2000000);
                const obj = self.startOrResumeObject() catch |err| return .{ .iter = self.iter, .err = err };
                return obj.at(key);
            }

            pub inline fn atIndex(self: Document, index: usize) Value {
                @setEvalBranchQuota(2000000);
                const arr = self.asArray() catch |err| return .{ .iter = self.iter, .err = err };
                return arr.at(index);
            }

            inline fn startOrResumeObject(self: Document) Error!Object {
                if (self.iter.isAtStart()) {
                    return self.asObject();
                }
                return .{ .iter = self.iter };
            }
        };

        pub const Value = struct {
            iter: Iterator,
            err: ?Error = null,

            pub const Iterator = struct {
                cursor: *Cursor,
                start_position: usize,
                start_depth: u32,
                start_char: u8,

                inline fn asNumber(self: Iterator) Error!Number {
                    const n = try self.parseNumber(try self.peekScalar());
                    try self.advanceScalar();
                    return n;
                }

                inline fn asUnsigned(self: Iterator) Error!u64 {
                    const n = try self.parseUnsigned(try self.peekScalar());
                    try self.advanceScalar();
                    return n;
                }

                inline fn asSigned(self: Iterator) Error!i64 {
                    const n = try self.parseSigned(try self.peekScalar());
                    try self.advanceScalar();
                    return n;
                }

                inline fn asFloat(self: Iterator) Error!f64 {
                    const n = try self.parseFloat(try self.peekScalar());
                    try self.advanceScalar();
                    return n;
                }

                inline fn asString(self: Iterator) Error!String {
                    const raw_str = try self.peekScalar();
                    if (raw_str[0] != '"') return error.IncorrectType;
                    const str = String{
                        .iter = self,
                        .raw_str = raw_str,
                    };
                    try self.advanceScalar();
                    return str;
                }

                inline fn asBool(self: Iterator) Error!bool {
                    const is_true = try self.parseBool(try self.peekScalar());
                    try self.advanceScalar();
                    return is_true;
                }

                inline fn isNull(self: Iterator) Error!bool {
                    var is_null = false;
                    if (self.parseNull(try self.peekScalar())) {
                        is_null = true;
                        try self.advanceScalar();
                    } else |err| switch (err) {
                        error.IncorrectType, error.ExpectedValue => {},
                        else => return err,
                    }
                    return is_null;
                }

                fn parseNumber(self: Iterator, ptr: [*]const u8) Error!Number {
                    if (!(ptr[0] -% '0' < 10 or ptr[0] == '-')) return error.IncorrectType;
                    try Logger.log(self.cursor.document, ptr, "number", self.start_depth);
                    return @import("parsers/number/parser.zig").parse(null, ptr);
                }

                fn parseUnsigned(self: Iterator, ptr: [*]const u8) Error!u64 {
                    if (!(ptr[0] -% '0' < 10)) return error.IncorrectType;
                    try Logger.log(self.cursor.document, ptr, "u64   ", self.start_depth);
                    const n = try @import("parsers/number/parser.zig").parse(.unsigned, ptr);
                    return n.unsigned;
                }

                fn parseSigned(self: Iterator, ptr: [*]const u8) Error!i64 {
                    if (!(ptr[0] -% '0' < 10 or ptr[0] == '-')) return error.IncorrectType;
                    try Logger.log(self.cursor.document, ptr, "i64   ", self.start_depth);
                    const n = try @import("parsers/number/parser.zig").parse(.signed, ptr);
                    return n.signed;
                }

                fn parseFloat(self: Iterator, ptr: [*]const u8) Error!f64 {
                    if (!(ptr[0] -% '0' < 10 or ptr[0] == '-')) return error.IncorrectType;
                    try Logger.log(self.cursor.document, ptr, "f64   ", self.start_depth);
                    const n = try @import("parsers/number/parser.zig").parse(.float, ptr);
                    return switch (n) {
                        .float => |v| v,
                        inline else => |v| @floatFromInt(v),
                    };
                }

                fn parseString(self: Iterator, ptr: [*]const u8, dst: [*]u8) Error![]const u8 {
                    try Logger.log(self.cursor.document, ptr, "string", self.start_depth);
                    const write = @import("parsers/string.zig").writeString;
                    const next_len = (try write(ptr, dst)) - dst;
                    return dst[0..next_len];
                }

                inline fn parseBool(self: Iterator, ptr: [*]const u8) Error!bool {
                    if (!(ptr[0] == 't' or ptr[0] == 'f')) return error.IncorrectType;
                    try Logger.log(self.cursor.document, ptr, "bool  ", self.start_depth);
                    const check = @import("parsers/atoms.zig").checkBool;
                    return check(ptr);
                }

                inline fn parseNull(self: Iterator, ptr: [*]const u8) Error!void {
                    if (ptr[0] != 'n') return error.IncorrectType;
                    try Logger.log(self.cursor.document, ptr, "null  ", self.start_depth);
                    const check = @import("parsers/atoms.zig").checkNull;
                    return check(ptr);
                }

                inline fn endContainer(self: Iterator) void {
                    self.cursor.ascend(self.start_depth - 1);
                }

                inline fn isAtStart(self: Iterator) bool {
                    return self.cursor.position() == self.start_position;
                }

                inline fn isAtContainerStart(self: Iterator) bool {
                    const delta = self.cursor.position() - self.start_position;
                    return delta == 1 or delta == 2;
                }

                inline fn isAtKey(self: Iterator) Error!bool {
                    return self.start_depth == self.cursor.depth and self.cursor.peekChar() == '"';
                }

                inline fn isAtFirstValue(self: Iterator) bool {
                    assert(self.cursor.position() > self.start_position);
                    return self.cursor.position() == self.start_position + Cursor.position_size and self.cursor.depth == self.start_depth;
                }

                inline fn isAtFirstField(self: Iterator) bool {
                    assert(self.cursor.position() > self.start_position);
                    return self.cursor.position() == self.start_position + Cursor.position_size;
                }

                inline fn isOpen(self: Iterator) bool {
                    return self.cursor.depth >= self.start_depth;
                }

                inline fn isAtEnd(self: Iterator) Error!bool {
                    return self.cursor.peekChar() == ' ';
                }

                inline fn hasNextField(self: Iterator) Error!bool {
                    self.assertAtNext();

                    switch ((try self.cursor.next())[0]) {
                        ',' => return true,
                        '}' => {
                            self.endContainer();
                            return false;
                        },
                        else => return self.reportError(error.ExpectedObjectCommaOrEnd),
                    }
                }

                inline fn hasNextElement(self: Iterator) Error!bool {
                    self.assertAtNext();

                    switch ((try self.cursor.next())[0]) {
                        ',' => return true,
                        ']' => {
                            self.endContainer();
                            return false;
                        },
                        else => return self.reportError(error.ExpectedArrayCommaOrEnd),
                    }
                }

                inline fn startObject(self: Iterator) Error!struct { bool, Iterator } {
                    const iter = try self.startContainer('{');
                    return .{ try self.startedObject(), iter };
                }

                inline fn startedObject(self: Iterator) Error!bool {
                    self.assertAtContainerStart();
                    if (builtin.mode == .Debug) self.cursor.setStartPosition(self.start_depth, self.start_position);
                    const char = self.cursor.peekChar();
                    if (char == '}') {
                        const ptr = try self.cursor.next();
                        self.endContainer();
                        try Logger.log(self.cursor.document, ptr, "object", self.start_depth);
                        return false;
                    }
                    return true;
                }

                inline fn startArray(self: Iterator) Error!struct { bool, Iterator } {
                    const iter = try self.startContainer('[');
                    return .{ try self.startedArray(), iter };
                }

                inline fn startedArray(self: Iterator) Error!bool {
                    self.assertAtContainerStart();
                    if (builtin.mode == .Debug) self.cursor.setStartPosition(self.start_depth, self.start_position);
                    const char = self.cursor.peekChar();
                    if (char == ']') {
                        const ptr = try self.cursor.next();
                        self.endContainer();
                        try Logger.log(self.cursor.document, ptr, "array ", self.start_depth);
                        return false;
                    }
                    return true;
                }

                inline fn startContainer(self: Iterator, start_char: u8) Error!Iterator {
                    if (self.isAtStart()) {
                        self.assertAtStart();
                        const char = self.cursor.peekChar();
                        if (char != start_char) return error.IncorrectType;
                        const iter: Iterator = .{
                            .cursor = self.cursor,
                            .start_position = self.cursor.position(),
                            .start_depth = self.cursor.depth,
                            .start_char = start_char,
                        };
                        const ptr = try self.cursor.next();
                        try Logger.log(self.cursor.document, ptr, if (start_char == '{') "object" else "array ", self.start_depth);
                        return iter;
                    } else {
                        if (builtin.mode == .Debug) if (!self.isAtContainerStart()) return error.OutOfOrderIteration;

                        if (self.start_char != start_char) return error.IncorrectType;
                        return self;
                    }
                }

                inline fn peekScalar(self: Iterator) Error![*]const u8 {
                    // if (!self.isAtStart()) return error.OutOfOrderIteration;
                    self.assertAtStart();
                    return self.cursor.peek();
                }

                inline fn advanceScalar(self: Iterator) Error!void {
                    if (!self.isAtStart()) return;
                    self.assertAtStart();
                    _ = try self.cursor.next();
                    self.cursor.ascend(self.start_depth - 1);
                }

                inline fn skipChild(self: Iterator) Error!void {
                    assert(self.cursor.position() > self.start_position);
                    assert(self.cursor.depth >= self.start_depth);

                    return self.cursor.skip(self.start_depth, self.start_char);
                }

                inline fn child(self: Iterator) Error!Iterator {
                    self.assertAtChild();
                    return .{
                        .cursor = self.cursor,
                        .start_position = self.cursor.position(),
                        .start_depth = self.start_depth + 1,
                        .start_char = self.cursor.peekChar(),
                    };
                }

                inline fn findField(self: Iterator, key: []const u8, comptime unordered: bool) Error!bool {
                    var at_first = self.isAtFirstField();
                    var has_value = false;
                    var search_start = self.cursor.position();
                    if (at_first) {
                        has_value = true;
                    } else if (self.isOpen()) {
                        try self.skipChild();
                        if (unordered) search_start = self.cursor.position();
                        has_value = try self.hasNextField();
                        if (builtin.mode == .Debug) if (self.cursor.getStartPosition(self.start_depth) != self.cursor.position()) return error.OutOfOrderIteration;
                    } else {
                        if (builtin.mode == .Debug) if (self.cursor.depth < self.start_depth - 1) return error.OutOfOrderIteration;
                        if (!unordered) return false;
                        has_value = try self.resetObject();
                        at_first = true;
                    }

                    while (has_value) : (has_value = try self.hasNextField()) {
                        const field = try Object.Field.start(self);
                        if (try field.key.eqlRaw(key)) return true;
                        try self.skipChild();
                    }

                    if (!unordered or at_first) return false;
                    has_value = try self.resetObject();
                    while (true) : (has_value = try self.hasNextField()) {
                        assert(has_value);
                        const field = try Object.Field.start(self);
                        if (try field.key.eqlRaw(key)) return true;
                        try self.skipChild();
                        if (self.cursor.position() == search_start) return false;
                    }

                    unreachable;
                }

                inline fn resetObject(self: Iterator) Error!bool {
                    try self.resetContainer();
                    return self.startedObject();
                }

                inline fn resetArray(self: Iterator) Error!bool {
                    try self.resetContainer();
                    return self.startedArray();
                }

                inline fn resetContainer(self: Iterator) Error!void {
                    try self.cursor.tokens.revert(self.start_position + 1);
                    self.cursor.depth = self.start_depth;
                }

                inline fn assertAtStart(self: Iterator) void {
                    assert(self.cursor.position() == self.start_position);
                    assert(self.cursor.depth == self.start_depth);
                    assert(self.start_depth > 0);
                }

                inline fn assertAtContainerStart(self: Iterator) void {
                    assert(self.cursor.position() == self.start_position + Cursor.position_size);
                    assert(self.cursor.depth == self.start_depth);
                    assert(self.start_depth > 0);
                }

                inline fn assertAtNext(self: Iterator) void {
                    assert(self.cursor.position() > self.start_position);
                    assert(self.cursor.depth == self.start_depth);
                    assert(self.start_depth > 0);
                }

                inline fn assertAtChild(self: Iterator) void {
                    assert(self.cursor.position() > self.start_position);
                    assert(self.cursor.depth == self.start_depth + 1);
                    assert(self.start_depth > 0);
                }

                inline fn assertAtRoot(self: Iterator) void {
                    self.assertAtStart();
                    assert(self.start_depth == 1);
                }

                inline fn assertAtNonRootStart(self: Iterator) void {
                    self.assertAtStart();
                    assert(self.start_depth > 1);
                }

                inline fn reportError(self: Iterator, err: Error) Error!void {
                    return self.cursor.reportError(err);
                }
            };

            pub inline fn asObject(self: Value) Error!Object {
                if (self.err) |err| return err;
                return (try Object.start(self.iter))[1];
            }

            pub inline fn asArray(self: Value) Error!Array {
                if (self.err) |err| return err;
                return (try Array.start(self.iter))[1];
            }

            pub inline fn asNumber(self: Value) Error!Number {
                if (self.err) |err| return err;
                return self.iter.asNumber();
            }

            pub inline fn asUnsigned(self: Value) Error!u64 {
                if (self.err) |err| return err;
                return self.iter.asUnsigned();
            }

            pub inline fn asSigned(self: Value) Error!i64 {
                if (self.err) |err| return err;
                return self.iter.asSigned();
            }

            pub inline fn asFloat(self: Value) Error!f64 {
                if (self.err) |err| return err;
                return self.iter.asFloat();
            }

            pub inline fn asString(self: Value) String {
                if (self.err) |err| return .{
                    .iter = self.iter,
                    .raw_str = undefined,
                    .err = err,
                };
                return self.iter.asString() catch |err| .{
                    .iter = self.iter,
                    .raw_str = undefined,
                    .err = err,
                };
            }

            pub inline fn asBool(self: Value) Error!bool {
                if (self.err) |err| return err;
                return self.iter.asBool();
            }

            pub inline fn isNull(self: Value) Error!bool {
                if (self.err) |err| return err;
                return self.iter.isNull();
            }

            pub inline fn asAny(self: Value) Error!AnyValue {
                return switch (self.iter.cursor.peekChar()) {
                    't', 'f' => .{ .bool = try self.asBool() },
                    'n' => .{ .null = brk: {
                        _ = try self.isNull();
                        break :brk {};
                    } },
                    '"' => .{ .string = self.asString() },
                    '-', '0'...'9' => .{ .number = try self.asNumber() },
                    '[' => .{ .array = try self.asArray() },
                    '{' => .{ .object = try self.asObject() },
                    else => return error.ExpectedValue,
                };
            }

            pub inline fn getType(self: Value) Error!types.ValueType {
                if (self.err) |err| return err;
                return switch (self.iter.cursor.peekChar()) {
                    't', 'f' => .bool,
                    'n' => .null,
                    '"' => .string,
                    '-', '0'...'9' => .number,
                    '[' => .array,
                    '{' => .object,
                    else => error.ExpectedValue,
                };
            }

            pub inline fn as(self: Value, comptime T: type) schema.Error!std.json.Parsed(T) {
                return self.asAdvanced(T, null, self.iter.cursor.document.allocator);
            }

            pub inline fn asAdvanced(self: Value, comptime T: type, comptime S: ?schema.Infer(T), allocator: ?Allocator) schema.Error!std.json.Parsed(T) {
                const alloc = allocator orelse return error.ExpectedAllocator;
                var dest: std.json.Parsed(T) = .{
                    .arena = try alloc.create(std.heap.ArenaAllocator),
                    .value = schema_utils.undefinedInit(T),
                };
                errdefer alloc.destroy(dest.arena);
                dest.arena.* = .init(alloc);
                errdefer dest.arena.deinit();
                dest.value = try self.asAdvancedLeaky(T, S, dest.arena.allocator());
                return dest;
            }

            pub inline fn asLeaky(self: Value, comptime T: type) schema.Error!T {
                return self.asAdvancedLeaky(T, null, self.iter.cursor.document.allocator);
            }

            pub inline fn asAdvancedLeaky(self: Value, comptime T: type, comptime S: ?schema.Infer(T), allocator: ?Allocator) schema.Error!T {
                var dest = schema_utils.undefinedInit(T);
                const sch = schema.resolveSchema(T, S);
                const custom_parser = sch.parse_with orelse schema.inferStdParser(T);
                if (custom_parser) |handler| dest = try handler.init(allocator);
                try self.asAdvancedRef(T, sch, custom_parser, allocator, &dest);
                return dest;
            }

            inline fn asAdvancedRef(
                self: Value,
                comptime T: type,
                comptime S: schema.Infer(T),
                comptime P: ?schema.CustomParser(T),
                allocator: ?Allocator,
                dest: *T,
            ) schema.Error!void {
                const last_cursor_strings = self.iter.cursor.strings;
                errdefer {
                    self.iter.cursor.tokens.revert(self.iter.start_position) catch |err| (self.iter.cursor.reportError(err) catch {});
                    self.iter.cursor.depth = self.iter.start_depth;
                    self.iter.cursor.strings = last_cursor_strings;
                }
                if (P) |handler| return handler.parse(allocator, self, dest);
                const info = @typeInfo(T);
                switch (info) {
                    .@"struct" => {
                        if (T == String) {
                            dest.* = self.asString();
                        } else {
                            dest.* = try schema.parseStruct(T, S, allocator, self);
                        }
                    },
                    .@"union" => {
                        if (T == Number) {
                            dest.* = try self.asNumber();
                        } else if (T == AnyValue) {
                            dest.* = try self.asAny();
                        } else {
                            dest.* = try schema.parseUnion(T, S, allocator, self);
                        }
                    },
                    .@"enum" => dest.* = try schema.parseEnum(T, S, allocator, self),
                    else => dest.* = try schema.parseElement(T, S, allocator, self),
                }
            }

            fn asTypeErased(
                self: Value,
                comptime T: type,
                comptime S: schema.Infer(T),
                comptime P: ?schema.CustomParser(T),
                allocator: ?Allocator,
                dest: *anyopaque,
            ) schema.Error!void {
                return self.asAdvancedRef(T, S, P, allocator, @alignCast(@ptrCast(dest)));
            }

            pub inline fn skip(self: Value) Error!void {
                if (self.err) |err| return err;
                return self.iter.cursor.skip(self.iter.start_depth - 1, 0);
            }

            pub inline fn at(self: Value, key: []const u8) Value {
                @setEvalBranchQuota(2000000);
                if (self.err) |_| return self;
                const obj = self.startOrResumeObject() catch |err| return .{ .iter = self.iter, .err = err };
                return obj.at(key);
            }

            pub inline fn atIndex(self: Value, index: usize) Value {
                @setEvalBranchQuota(2000000);
                if (self.err) |_| return self;
                const arr = self.asArray() catch |err| return .{ .iter = self.iter, .err = err };
                return arr.at(index);
            }

            inline fn startOrResumeObject(self: Value) Error!Object {
                if (self.iter.isAtStart()) {
                    return self.asObject();
                }
                return .{ .iter = self.iter };
            }
        };

        const String = struct {
            iter: Value.Iterator,
            raw_str: [*]const u8,
            err: ?Error = null,

            pub inline fn get(self: String) Error![]const u8 {
                return self.getAdvanced(null);
            }

            pub inline fn getSentinel(self: String, comptime sentinel: u8) Error![:sentinel]const u8 {
                return self.getAdvanced(sentinel);
            }

            inline fn getAdvanced(self: String, comptime sentinel: ?u8) if (sentinel) |s| Error![:s]const u8 else Error![]const u8 {
                if (self.err) |err| return err;

                if (want_stream) {
                    const alloc = @as(?Allocator, self.iter.cursor.document.allocator) orelse return error.ExpectedAllocator;
                    try self.iter.cursor.document.strings.ensureUnusedCapacity(alloc, options.stream.?.chunk_length + Vector.bytes_len);
                    const dest = self.iter.cursor.document.strings.items().ptr;
                    const str = try self.iter.parseString(self.raw_str, dest[self.iter.cursor.strings..]);
                    if (sentinel) |s| {
                        self.iter.cursor.strings[str.len] = s;
                        self.iter.cursor.strings += str.len + 1;
                    } else {
                        self.iter.cursor.strings += str.len;
                    }
                    return str;
                } else {
                    const str = try self.iter.parseString(self.raw_str, self.iter.cursor.strings);
                    if (sentinel) |s| {
                        self.iter.cursor.strings[str.len] = s;
                        self.iter.cursor.strings += str.len + 1;
                    } else {
                        self.iter.cursor.strings += str.len;
                    }
                    return str;
                }
            }

            pub inline fn write(self: String, dest: [*]u8) Error![]const u8 {
                return self.writeAdvanced(dest, null);
            }

            pub inline fn writeSentinel(self: String, dest: [*]u8, comptime sentinel: u8) Error![:sentinel]const u8 {
                return self.writeAdvanced(dest, sentinel);
            }

            inline fn writeAdvanced(self: String, dest: [*]u8, comptime sentinel: ?u8) if (sentinel) |s| Error![:s]const u8 else Error![]const u8 {
                if (self.err) |err| return err;

                const str = try self.iter.parseString(self.raw_str, dest);
                if (sentinel) |s| dest[str.len] = s;
                return str;
            }

            pub inline fn getTemporal(self: String) Error![]const u8 {
                if (want_stream) return self.write(&self.iter.cursor.document.temporal_string_buffer);
                if (self.err) |err| return err;
                const str = try self.iter.parseString(self.raw_str, self.iter.cursor.strings);
                return str;
            }

            pub inline fn eqlRaw(self: String, target: []const u8) Error!bool {
                if (self.err) |err| return err;
                return self.raw_str[1..][target.len] == '"' and std.mem.eql(u8, self.raw_str[1..][0..target.len], target);
            }
        };

        const Array = struct {
            iter: Value.Iterator,

            pub inline fn next(self: Array) Error!?Value {
                if (!self.iter.isOpen()) return null;
                if (self.iter.isAtFirstValue()) {
                    self.iter.cursor.descend(self.iter.start_depth + 1);
                    return .{ .iter = try self.iter.child() };
                }
                try self.iter.skipChild();

                if (try self.iter.hasNextElement()) {
                    self.iter.cursor.descend(self.iter.start_depth + 1);
                    return .{ .iter = try self.iter.child() };
                }
                return null;
            }

            inline fn start(iter: Value.Iterator) Error!struct { bool, Array } {
                const started, const array = try iter.startArray();
                return .{ started, .{ .iter = array } };
            }

            pub inline fn at(self: Array, index: usize) Value {
                @setEvalBranchQuota(2000000);
                var i: usize = 0;
                while (self.next() catch |err| return .{
                    .iter = self.iter,
                    .err = err,
                }) |v| : (i += 1)
                    if (i == index) return v;

                return .{
                    .iter = self.iter,
                    .err = error.IndexOutOfBounds,
                };
            }

            pub inline fn isEmpty(self: Array) Error!bool {
                return !(try self.iter.startedArray());
            }

            pub inline fn skip(self: Array) Error!void {
                return self.iter.cursor.skip(self.iter.start_depth - 1, '[');
            }

            pub inline fn reset(self: Array) Error!void {
                _ = try self.iter.resetArray();
            }
        };

        const Object = struct {
            iter: Value.Iterator,

            pub const Field = struct {
                key: String,
                value: Value,

                inline fn start(iter: Value.Iterator) Error!Field {
                    iter.assertAtNext();
                    const key_quote = try iter.cursor.next();
                    if (key_quote[0] != '"') return iter.reportError(error.ExpectedKey);

                    // var key_len: usize = brk: {
                    //     if (want_stream) {
                    //         const offset = iter.cursor.tokens().fetchLocalOffset();
                    //         break :brk offset;
                    //     } else {
                    //         break :brk undefined;
                    //     }
                    // };

                    iter.assertAtNext();
                    const colon = try iter.cursor.next();
                    if (colon[0] != ':') return iter.reportError(error.ExpectedColon);
                    iter.cursor.descend(iter.start_depth + 1);

                    // if (!want_stream) {
                    //     key_len = @intFromPtr(colon) - @intFromPtr(key_quote);
                    // }

                    return .{
                        .key = .{
                            .iter = iter,
                            .raw_str = key_quote,
                        },
                        .value = .{ .iter = try iter.child() },
                    };
                }
            };

            pub inline fn next(self: Object) Error!?Field {
                if (!self.iter.isOpen()) return null;
                if (self.iter.isAtFirstField()) {
                    return try Field.start(self.iter);
                }
                try self.iter.skipChild();

                if (try self.iter.hasNextField()) {
                    return try Field.start(self.iter);
                }
                return null;
            }

            inline fn start(iter: Value.Iterator) Error!struct { bool, Object } {
                const started, const object = try iter.startObject();
                return .{ started, .{ .iter = object } };
            }

            pub inline fn at(self: Object, key: []const u8) Value {
                return self.atRaw(key, true);
            }

            pub inline fn atOrdered(self: Object, key: []const u8) Value {
                return self.atRaw(key, false);
            }

            inline fn atRaw(self: Object, key: []const u8, comptime unordered: bool) Value {
                @setEvalBranchQuota(2000000);
                return if (self.iter.findField(key, unordered) catch |err| return .{
                    .iter = self.iter,
                    .err = err,
                })
                    .{ .iter = self.iter.child() catch |err| return .{
                        .iter = self.iter,
                        .err = err,
                    } }
                else
                    .{
                        .iter = self.iter,
                        .err = error.MissingField,
                    };
            }

            pub inline fn isEmpty(self: Object) Error!bool {
                return !(try self.iter.startedObject());
            }

            pub inline fn skip(self: Object) Error!void {
                if (try self.iter.isAtKey()) {
                    _ = try Object.Field.start(self.iter);
                }
                return self.iter.cursor.skip(self.iter.start_depth - 1, '{');
            }

            pub inline fn reset(self: Object) Error!void {
                _ = try self.iter.resetObject();
            }
        };

        pub const schema = struct {
            const _std = @import("std");
            pub const Error = Self.Error || error{
                UnknownField,
                UnknownEnumLiteral,
                UnknownUnionVariant,
                DuplicateField,
            };

            pub fn Handler(comptime T: type) type {
                return fn (allocator: ?Allocator, value: Value, dest: *T) schema.Error!void;
            }

            pub fn SimpleHandler(comptime T: type) type {
                return fn (allocator: ?Allocator) schema.Error!T;
            }

            pub fn SimpleRefHandler(comptime T: type) type {
                return fn (allocator: ?Allocator, dest: *T) schema.Error!void;
            }

            pub fn CustomParser(comptime T: type) type {
                return struct {
                    init: SimpleHandler(T),
                    parse: Handler(T),

                    pub fn from(comptime S: type) @This() {
                        assert(@typeInfo(S) == .@"struct");
                        assert(@hasDecl(S, "init") and @TypeOf(@field(S, "init")) == SimpleHandler(T));
                        assert(@hasDecl(S, "parse") and @TypeOf(@field(S, "parse")) == Handler(T));
                        return .{
                            .init = S.init,
                            .parse = S.parse,
                        };
                    }
                };
            }

            pub const std = struct {
                pub fn ArrayList(comptime T: type) CustomParser(_std.ArrayList(T)) {
                    const Parsed = _std.ArrayList(T);
                    return .from(struct {
                        pub fn init(allocator: ?Allocator) schema.Error!Parsed {
                            const alloc = allocator orelse return error.ExpectedAllocator;
                            return .init(alloc);
                        }
                        pub fn parse(allocator: ?Allocator, value: Value, dest: *Parsed) schema.Error!void {
                            const arr = try value.asArray();
                            while (try arr.next()) |child| {
                                const item = try child.asAdvancedLeaky(T, null, allocator);
                                try dest.append(item);
                            }
                        }
                    });
                }
                pub fn ArrayListAligned(comptime T: type, comptime alignment: ?u29) CustomParser(_std.ArrayListAligned(T, alignment)) {
                    return struct {
                        pub fn inner(allocator: ?Allocator, value: Value) schema.Error!_std.ArrayListAligned(T, alignment) {
                            const alloc = allocator orelse return error.ExpectedAllocator;
                            var dest: _std.ArrayListAligned(T, alignment) = .init(alloc);
                            const arr = try value.asArray();
                            while (try arr.next()) |child| {
                                const item = try child.asAdvancedLeaky(T, null, alloc);
                                try dest.append(item);
                            }
                            return dest;
                        }
                    }.inner;
                }
                pub fn ArrayListAlignedUnmanaged(comptime T: type, comptime alignment: ?u29) CustomParser(_std.ArrayListAlignedUnmanaged(T, alignment)) {
                    return struct {
                        pub fn inner(allocator: ?Allocator, value: Value) schema.Error!_std.ArrayListAlignedUnmanaged(T, alignment) {
                            const alloc = allocator orelse return error.ExpectedAllocator;
                            var dest: _std.ArrayListAlignedUnmanaged(T, alignment) = .empty;
                            const arr = try value.asArray();
                            while (try arr.next()) |child| {
                                const item = try child.asAdvancedLeaky(T, null, alloc);
                                try dest.append(alloc, item);
                            }
                            return dest;
                        }
                    }.inner;
                }
                pub fn ArrayListUnmanaged(comptime T: type) CustomParser(_std.ArrayListUnmanaged(T)) {
                    return struct {
                        pub fn inner(allocator: ?Allocator, value: Value) schema.Error!_std.ArrayListUnmanaged(T) {
                            const alloc = allocator orelse return error.ExpectedAllocator;
                            var dest: _std.ArrayListUnmanaged(T) = .empty;
                            const arr = try value.asArray();
                            while (try arr.next()) |child| {
                                const item = try child.asAdvancedLeaky(T, null, alloc);
                                try dest.append(alloc, item);
                            }
                            return dest;
                        }
                    }.inner;
                }
                pub const BitStack: CustomParser(_std.BitStack) = struct {
                    pub fn inner(allocator: ?Allocator, value: Value) schema.Error!_std.BitStack {
                        const alloc = allocator orelse return error.ExpectedAllocator;
                        var dest: _std.BitStack = .init(alloc);
                        const arr = try value.asArray();
                        while (try arr.next()) |child| {
                            const item = try child.as(u1);
                            try dest.push(item);
                        }
                        return dest;
                    }
                }.inner;
                pub fn BoundedArray(comptime T: type, comptime buffer_capacity: usize) CustomParser(_std.BoundedArray(T, buffer_capacity)) {
                    return struct {
                        pub fn inner(allocator: ?Allocator, value: Value) schema.Error!_std.BoundedArray(T, buffer_capacity) {
                            var dest: _std.BoundedArray(T, buffer_capacity) = .init(0) catch unreachable;
                            const arr = try value.asArray();
                            while (try arr.next()) |child| {
                                const item = try child.asAdvancedLeaky(T, null, allocator);
                                try dest.append(item);
                            }
                            return dest;
                        }
                    }.inner;
                }
                pub fn BoundedArrayAligned(comptime T: type, comptime alignment: u29, comptime buffer_capacity: usize) CustomParser(_std.BoundedArrayAligned(T, alignment, buffer_capacity)) {
                    return struct {
                        pub fn inner(allocator: ?Allocator, value: Value) schema.Error!_std.BoundedArrayAligned(T, alignment, buffer_capacity) {
                            var dest: _std.BoundedArrayAligned(T, alignment, buffer_capacity) = .init(0) catch unreachable;
                            const arr = try value.asArray();
                            while (try arr.next()) |child| {
                                const item = try child.asAdvancedLeaky(T, null, allocator);
                                try dest.append(item);
                            }
                            return dest;
                        }
                    }.inner;
                }
                pub const BufMap: CustomParser(_std.BufMap) = struct {
                    pub fn inner(allocator: ?Allocator, value: Value) schema.Error!_std.BufMap {
                        const alloc = allocator orelse return error.ExpectedAllocator;
                        var dest: _std.BufMap = .init(alloc);
                        const obj = try value.asObject();
                        while (try obj.next()) |field| {
                            const key = try field.key.getTemporal();
                            const str = try field.value.asString().getTemporal();
                            try dest.put(key, str);
                        }
                        return dest;
                    }
                }.inner;
                pub const BufSet: CustomParser(_std.BufSet) = struct {
                    pub fn inner(allocator: ?Allocator, value: Value) schema.Error!_std.BufSet {
                        const alloc = allocator orelse return error.ExpectedAllocator;
                        var dest: _std.BufSet = .init(alloc);
                        const arr = try value.asArray();
                        while (try arr.next()) |child| {
                            const item = try child.asString().getTemporal();
                            try dest.insert(item);
                        }
                        return dest;
                    }
                }.inner;
                pub fn DoublyLinkedList(comptime T: type) CustomParser(_std.DoublyLinkedList(T)) {
                    return struct {
                        pub fn inner(allocator: ?Allocator, value: Value) schema.Error!_std.DoublyLinkedList(T) {
                            var dest: _std.DoublyLinkedList(T) = .{};
                            const arr = try value.asArray();
                            while (try arr.next()) |child| {
                                const item = try child.asAdvancedLeaky(T, null, allocator);
                                try dest.append(item);
                            }
                            return dest;
                        }
                    }.inner;
                }
                pub fn EnumMap(comptime E: type, comptime V: type) CustomParser(_std.EnumMap(E, V)) {
                    return struct {
                        pub fn inner(allocator: ?Allocator, value: Value) schema.Error!_std.EnumMap(E, V) {
                            var dest: _std.EnumMap(E, V) = .init(.{});
                            const obj = try value.asObject();
                            while (try obj.next()) |field| {
                                const variant = try field.key.getTemporal();
                                var enum_literal = schema_utils.undefinedInit(E);
                                try parseEnumFromSlice(E, null, variant, &enum_literal);
                                const enum_value = try field.value.asAdvancedLeaky(V, null, allocator);
                                try dest.put(enum_literal, enum_value);
                            }
                            return dest;
                        }
                    }.inner;
                }
                pub fn MultiArrayList(comptime T: type) CustomParser(_std.MultiArrayList(T)) {
                    const Parsed = _std.MultiArrayList(T);
                    return .from(struct {
                        pub fn init(_: ?Allocator) schema.Error!Parsed {
                            return .empty;
                        }
                        pub fn parse(allocator: ?Allocator, value: Value, dest: *Parsed) schema.Error!void {
                            const alloc = allocator orelse return error.ExpectedAllocator;
                            const arr = try value.asArray();
                            while (try arr.next()) |child| {
                                const item = try child.asAdvancedLeaky(T, null, alloc);
                                try dest.append(alloc, item);
                            }
                        }
                    });
                }
                pub fn SegmentedList(comptime T: type, comptime prealloc_item_count: usize) CustomParser(_std.SegmentedList(T, prealloc_item_count)) {
                    return struct {
                        pub fn inner(allocator: ?Allocator, value: Value) schema.Error!_std.SegmentedList(T, prealloc_item_count) {
                            const alloc = allocator orelse return error.ExpectedAllocator;
                            var dest: _std.SegmentedList(T, prealloc_item_count) = .{};
                            const arr = try value.asArray();
                            while (try arr.next()) |child| {
                                const item = try child.asAdvancedLeaky(T, null, alloc);
                                try dest.append(alloc, item);
                            }
                            return dest;
                        }
                    }.inner;
                }
                pub fn SinglyLinkedList(comptime T: type) CustomParser(_std.SinglyLinkedList(T)) {
                    return struct {
                        pub fn inner(allocator: ?Allocator, value: Value) schema.Error!_std.SinglyLinkedList(T) {
                            var dest: _std.SinglyLinkedList(T) = .{};
                            const arr = try value.asArray();
                            while (try arr.next()) |child| {
                                const item = try child.asAdvancedLeaky(T, null, allocator);
                                try dest.prepend(item);
                            }
                            return dest;
                        }
                    }.inner;
                }
                pub fn StringArrayHashMap(comptime V: type) CustomParser(_std.StringArrayHashMap(V)) {
                    return struct {
                        pub fn inner(allocator: ?Allocator, value: Value) schema.Error!_std.StringArrayHashMap(V) {
                            const alloc = allocator orelse return error.ExpectedAllocator;
                            var dest: _std.StringArrayHashMap(V) = .init(alloc);
                            const obj = try value.asObject();
                            while (try obj.next()) |field| {
                                const key = try field.key.get();
                                const val = try field.value.asAdvancedLeaky(V, null, alloc);
                                try dest.put(key, val);
                            }
                            return dest;
                        }
                    }.inner;
                }
                pub fn StringArrayHashMapUnmanaged(comptime V: type) CustomParser(_std.StringArrayHashMapUnmanaged(V)) {
                    return struct {
                        pub fn inner(allocator: ?Allocator, value: Value) schema.Error!_std.StringArrayHashMapUnmanaged(V) {
                            const alloc = allocator orelse return error.ExpectedAllocator;
                            var dest: _std.StringArrayHashMapUnmanaged(V) = .empty;
                            const obj = try value.asObject();
                            while (try obj.next()) |field| {
                                const key = try field.key.get();
                                const val = try field.value.asAdvancedLeaky(V, null, alloc);
                                try dest.put(alloc, key, val);
                            }
                            return dest;
                        }
                    }.inner;
                }
                pub fn StringHashMap(comptime V: type) CustomParser(_std.StringHashMap(V)) {
                    return struct {
                        pub fn inner(allocator: ?Allocator, value: Value) schema.Error!_std.StringHashMap(V) {
                            const alloc = allocator orelse return error.ExpectedAllocator;
                            var dest: _std.StringHashMap(V) = .init(alloc);
                            const obj = try value.asObject();
                            while (try obj.next()) |field| {
                                const key = try field.key.get();
                                const val = try field.value.asAdvancedLeaky(V, null, alloc);
                                try dest.put(key, val);
                            }
                            return dest;
                        }
                    }.inner;
                }
                pub fn StringHashMapUnmanaged(comptime V: type) CustomParser(_std.StringHashMapUnmanaged(V)) {
                    return struct {
                        pub fn inner(allocator: ?Allocator, value: Value) schema.Error!_std.StringHashMapUnmanaged(V) {
                            const alloc = allocator orelse return error.ExpectedAllocator;
                            var dest: _std.StringHashMapUnmanaged(V) = .empty;
                            const obj = try value.asObject();
                            while (try obj.next()) |field| {
                                const key = try field.key.get();
                                const val = try field.value.asAdvancedLeaky(V, null, alloc);
                                try dest.put(alloc, key, val);
                            }
                            return dest;
                        }
                    }.inner;
                }
            };

            fn inferStdParser(comptime T: type) ?CustomParser(T) {
                switch (@typeInfo(T)) {
                    .@"struct" => {},
                    else => return null,
                }
                // - BitStack                     0 params
                if (T == _std.BitStack) return schema.std.BitStack;

                // - BufMap                       0 params
                if (T == _std.BufMap) return schema.std.BufMap;

                // - BufSet                       0 params
                if (T == _std.BufSet) return schema.std.BufSet;

                // - ArrayList                    1 params
                // - ArrayListUnmanaged           1 params
                // - ArrayListAligned             2 params
                // - ArrayListAlignedUnmanaged    2 params
                if (@hasDecl(T, "Slice")) {
                    switch (@typeInfo(@field(T, "Slice"))) {
                        .pointer => |info| {
                            if (info.size == .slice) {
                                const child = info.child;
                                if (T == _std.ArrayList(child)) return schema.std.ArrayList(child);
                                if (T == _std.ArrayListUnmanaged(child)) return schema.std.ArrayListUnmanaged(child);
                                if (T == _std.ArrayListAligned(child, info.alignment)) return schema.std.ArrayListAligned(child, info.alignment);
                                if (T == _std.ArrayListAlignedUnmanaged(child, info.alignment)) return schema.std.ArrayListAlignedUnmanaged(child, info.alignment);
                            }
                        },
                        else => {},
                    }
                }

                // - SinglyLinkedList             1 params
                // - DoublyLinkedList             1 params
                if (@hasDecl(T, "Node")) {
                    const Node = @field(T, "Node");
                    if (@typeInfo(Node) == .@"struct" and @hasField(Node, "data")) {
                        const child = @FieldType(Node, "data");
                        if (T == _std.SinglyLinkedList(child)) return schema.std.SinglyLinkedList(child);
                        if (T == _std.DoublyLinkedList(child)) return schema.std.DoublyLinkedList(child);
                    }
                }

                // - StringArrayHashMap           1 params
                // - StringArrayHashMapUnmanaged  1 params
                // - StringHashMap                1 params
                // - StringHashMapUnmanaged       1 params
                if (@hasDecl(T, "KV")) {
                    const KV = @field(T, "KV");
                    if (@typeInfo(KV) == .@"struct" and @hasField(KV, "value")) {
                        const V = @FieldType(KV, "value");
                        if (T == _std.StringArrayHashMap(V)) return schema.std.StringArrayHashMap(V);
                        if (T == _std.StringArrayHashMapUnmanaged(V)) return schema.std.StringArrayHashMapUnmanaged(V);
                        if (T == _std.StringHashMap(V)) return schema.std.StringHashMap(V);
                        if (T == _std.StringHashMapUnmanaged(V)) return schema.std.StringHashMapUnmanaged(V);
                    }
                }

                // - BoundedArray                 2 params
                // - BoundedArrayAligned          3 params
                if (@hasField(T, "buffer")) {
                    const buffer = @FieldType(T, "buffer");
                    switch (@typeInfo(buffer)) {
                        .array => |info| {
                            const buffer_capacity = info.len;
                            const child = info.child;
                            const alignment = @alignOf(child);
                            if (T == _std.BoundedArray(child, buffer_capacity)) return schema.std.BoundedArray(child, buffer_capacity);
                            if (T == _std.BoundedArrayAligned(child, alignment, buffer_capacity)) return schema.std.BoundedArrayAligned(child, alignment, buffer_capacity);
                        },
                        else => {},
                    }
                }

                // - EnumMap                      2 params
                if (@hasDecl(T, "Value") and @hasDecl(T, "Key")) {
                    const E = @field(T, "Key");
                    const V = @field(T, "Value");
                    if (T == _std.EnumMap(E, V)) return schema.std.EnumMap(E, V);
                }

                // - SegmentedList                2 params
                if (@hasField(T, "prealloc_segment")) {
                    const prealloc_segment = @FieldType(T, "prealloc_segment");
                    switch (@typeInfo(prealloc_segment)) {
                        .array => |info| {
                            if (T == _std.SegmentedList(info.child, info.len)) return schema.std.SegmentedList(info.child, info.len);
                        },
                        else => {},
                    }
                }

                // - MultiArrayList               1 params
                if (@hasDecl(T, "get")) {
                    const get = @TypeOf(@field(T, "get"));
                    switch (@typeInfo(get)) {
                        .@"fn" => |info| {
                            if (info.return_type) |return_type| {
                                if (T == _std.MultiArrayList(return_type)) return schema.std.MultiArrayList(return_type);
                            }
                        },
                        else => {},
                    }
                }

                return null;
            }

            pub fn Infer(comptime T: type) type {
                return switch (@typeInfo(T)) {
                    .@"struct" => schema.Struct(T),
                    .@"enum" => schema.Enum(T),
                    .@"union" => schema.Union(T),
                    else => schema.Element(T),
                };
            }

            pub fn Element(comptime T: type) type {
                return struct {
                    bytes_as_string: bool = true,
                    parse_with: ?CustomParser(T) = null,
                };
            }

            pub fn Struct(comptime T: type) type {
                return struct {
                    assume_ordering: bool = false,
                    on_init: ?*const SimpleRefHandler(T) = null,
                    on_unknown_field: UnknownField(T) = .ignore,
                    on_duplicate_field: DuplicateField(T) = .@"error",

                    parse_with: ?CustomParser(T) = null,
                    rename_all: schema_utils.FieldsRenaming = .snake_case,
                    fields: StructFields(T) = .{},
                };
            }

            fn SchemaFieldHandler(comptime T: type) type {
                return fn (allocator: ?Allocator, key: []const u8, value: Value, dest: *T) schema.Error!void;
            }

            fn UnknownField(comptime T: type) type {
                return union(enum) {
                    ignore,
                    @"error",
                    handle: *const SchemaFieldHandler(T),
                };
            }

            fn DuplicateField(comptime T: type) type {
                return union(enum) {
                    use_first,
                    @"error",
                    use_last,
                    handle: *const SchemaFieldHandler(T),
                };
            }

            fn StructFields(comptime T: type) type {
                assert(@typeInfo(T) == .@"struct");
                const fields = _std.meta.fields(T);
                comptime var schema_fields: [fields.len]_std.builtin.Type.StructField = undefined;
                inline for (0..fields.len) |i| {
                    const field = fields[i];
                    if (field.is_comptime) @compileError("comptime fields are not supported: " ++ @typeName(T) ++ "." ++ field.name);
                    const schema_field = StructField(field.type);
                    schema_fields[i] = .{
                        .type = schema_field,
                        .name = field.name,
                        .default_value_ptr = &schema_field{},
                        .is_comptime = false,
                        .alignment = @alignOf(schema_field),
                    };
                }
                const sf = schema_fields;
                return @Type(.{
                    .@"struct" = .{
                        .fields = &sf,
                        .layout = .auto,
                        .decls = &.{},
                        .is_tuple = false,
                    },
                });
            }

            fn StructField(comptime T: type) type {
                return struct {
                    alias: ?[]const u8 = null,
                    skip: bool = false,
                    schema: ?schema.Infer(T) = null,
                };
            }

            fn parseStruct(comptime T: type, comptime S: schema.Struct(T), allocator: ?Allocator, value: Value) schema.Error!T {
                const fields = _std.meta.fields(T);
                if (@typeInfo(T).@"struct".is_tuple and fields.len > 0) {
                    var dest = schema_utils.undefinedInit(T);
                    const fields_schema_parser = makeFieldsSP(T, S, fields){};
                    inline for (fields) |field| {
                        const sp = @field(fields_schema_parser, field.name);
                        if (sp[1]) |handler| @field(dest, field.name) = try handler.init(allocator);
                    }
                    if (S.on_init) |handle| try handle(allocator, &dest);
                    const array = try value.asArray();
                    inline for (fields) |field| {
                        if (try array.next()) |item| {
                            const sp = @field(fields_schema_parser, field.name);
                            try item.asAdvancedRef(field.type, sp[0], sp[1], allocator, &@field(dest, field.name));
                        } else {
                            return error.IncorrectType;
                        }
                    }
                    if (try array.next()) |_| return error.IncorrectType;
                    return dest;
                }
                const object = try value.asObject();
                return parseStructWithObject(T, S, allocator, object);
            }

            fn parseStructWithObject(comptime T: type, comptime S: schema.Struct(T), allocator: ?Allocator, object: Object) schema.Error!T {
                const fields = _std.meta.fields(T);
                const is_packed = @typeInfo(T).@"struct".layout == .@"packed";
                var dest = schema_utils.undefinedInit(T);
                const fields_schema_parser = makeFieldsSP(T, S, fields){};
                inline for (fields) |field| {
                    const sp = @field(fields_schema_parser, field.name);
                    if (sp[1]) |handler| @field(dest, field.name) = try handler.init(allocator);
                }
                if (S.on_init) |handle| try handle(allocator, &dest);
                comptime var non_skipped_field_count: comptime_int = 0;
                inline for (fields) |field| {
                    const field_schema = @field(S.fields, field.name);
                    if (!field_schema.skip) non_skipped_field_count += 1;
                }
                if (non_skipped_field_count == 0) {
                    switch (S.on_unknown_field) {
                        .ignore => return .{},
                        .@"error" => if (try object.next()) |_| return error.UnknownField,
                        .handle => |handle| while (try object.next()) |field| try handle(allocator, try field.key.getTemporal(), field.value, &dest),
                    }
                    return dest;
                }
                if (S.assume_ordering) {
                    var prev_field_key: ?[]const u8 = null;
                    var prev_field_value: Value = undefined;
                    inline for (fields, 1..) |field, i| {
                        const field_schema = @field(S.fields, field.name);
                        if (field_schema.skip) continue;
                        const renamed_key: []const u8 = if (field_schema.alias) |alias| alias else comptime schema_utils.renameField(S.rename_all, field.name);
                        const field_value = brk: {
                            if (prev_field_key) |prev_key| {
                                if (_std.mem.eql(u8, prev_key, renamed_key)) break :brk prev_field_value;
                                switch (S.on_unknown_field) {
                                    .ignore => break :brk object.atOrdered(renamed_key),
                                    .@"error" => return error.UnknownField,
                                    .handle => |handle| try handle(allocator, prev_key, prev_field_value, &dest),
                                }
                            }
                            if (S.on_unknown_field == .ignore) break :brk object.atOrdered(renamed_key);
                            if (try object.next()) |next_field| {
                                const field_key = try next_field.key.getTemporal();
                                if (_std.mem.eql(u8, field_key, renamed_key)) break :brk next_field.value;
                                switch (S.on_unknown_field) {
                                    .ignore => unreachable,
                                    .@"error" => return error.UnknownField,
                                    .handle => |handle| try handle(allocator, field_key, next_field.value, &dest),
                                }
                            } else {
                                return error.MissingField;
                            }
                        };
                        if (is_packed) {
                            const packed_field_value = try field_value.asAdvancedLeaky(field.type, field_schema.schema, allocator);
                            _std.mem.writePackedIntNative(field.type, _std.mem.asBytes(&dest), @bitOffsetOf(T, field.name), packed_field_value);
                        } else {
                            @field(dest, field.name) = try field_value.asAdvancedLeaky(field.type, field_schema.schema, allocator);
                        }
                        while (true) {
                            if (try object.next()) |next_field| {
                                const next_field_key = try next_field.key.getTemporal();
                                const next_field_value = next_field.value;
                                if (_std.mem.eql(u8, next_field_key, renamed_key)) {
                                    switch (S.on_duplicate_field) {
                                        .@"error" => return error.DuplicateField,
                                        .use_first => continue,
                                        .use_last => {
                                            if (is_packed) {
                                                const packed_field_value = try next_field_value.asAdvancedLeaky(field.type, field_schema.schema, allocator);
                                                _std.mem.writePackedIntNative(field.type, _std.mem.asBytes(&dest), @bitOffsetOf(T, field.name), packed_field_value);
                                            } else {
                                                @field(dest, field.name) = try next_field_value.asAdvancedLeaky(field.type, field_schema.schema, allocator);
                                            }
                                        },
                                        .handle => |handle| try handle(allocator, next_field_key, next_field_value, &dest),
                                    }
                                } else {
                                    prev_field_key = next_field_key;
                                    prev_field_value = next_field_value;
                                    break;
                                }
                            } else if (i < fields.len) {
                                return error.MissingField;
                            } else break;
                        }
                    }
                    switch (S.on_unknown_field) {
                        .ignore => {},
                        .@"error" => if (try object.next()) |_| return error.UnknownField,
                        .handle => |handle| while (try object.next()) |field| try handle(allocator, try field.key.getTemporal(), field.value, &dest),
                    }
                } else {
                    var seen: [non_skipped_field_count]bool = @splat(false);
                    comptime var undefined_count: u16 = 0;
                    comptime var dispatches_mut: [non_skipped_field_count]struct { []const u8, StructDispatch } = undefined;
                    comptime var i: comptime_int = 0;
                    inline for (fields) |field| {
                        const field_schema = @field(S.fields, field.name);
                        if (field_schema.skip) continue;
                        defer i += 1;
                        const renamed_key: []const u8 = if (field_schema.alias) |alias| alias else comptime schema_utils.renameField(S.rename_all, field.name);
                        const has_undefined_value = @typeInfo(field.type) != .optional and field.default_value_ptr == null;
                        if (has_undefined_value) undefined_count += 1;
                        const s, const p = @field(fields_schema_parser, field.name);
                        dispatches_mut[i] = .{ renamed_key, .{
                            .offset = if (is_packed) @bitOffsetOf(T, field.name) else @offsetOf(T, field.name),
                            .bit_count = @bitSizeOf(field.type),
                            .has_undefined_value = has_undefined_value,
                            .handle = TypeErasedParser(field.type, s, p).handler,
                        } };
                    }
                    const dispatches = dispatches_mut;
                    const struct_map = comptime schema_utils.Map(StructDispatch, &dispatches);
                    var undefined_count_runtime = undefined_count;
                    while (try object.next()) |field| {
                        const key = try field.key.getTemporal();
                        const field_index = struct_map.getIndex(key) orelse switch (S.on_unknown_field) {
                            .ignore => continue,
                            .@"error" => return error.UnknownField,
                            .handle => |handle| {
                                try handle(allocator, key, field.value, &dest);
                                continue;
                            },
                        };
                        const dispatch = struct_map.atIndex(field_index);
                        if (seen[field_index]) switch (S.on_duplicate_field) {
                            .use_first => continue,
                            .use_last => {},
                            .@"error" => return error.DuplicateField,
                            .handle => |handle| {
                                try handle(allocator, key, field.value, &dest);
                                continue;
                            },
                        } else {
                            seen[field_index] = true;
                            if (dispatch.has_undefined_value) undefined_count_runtime -= 1;
                        }
                        if (is_packed) {
                            var packed_field_value: _std.meta.Int(.unsigned, @bitSizeOf(T)) = undefined;
                            try dispatch.handle(allocator, field.value, @ptrCast(&packed_field_value));
                            _std.mem.writeVarPackedInt(_std.mem.asBytes(&dest), dispatch.offset, dispatch.bit_count, packed_field_value, builtin.cpu.arch.endian());
                        } else {
                            try dispatch.handle(allocator, field.value, @ptrFromInt(@intFromPtr(&dest) + dispatch.offset));
                        }
                    }
                    if (undefined_count_runtime > 0) return error.MissingField;
                }
                return dest;
            }

            const StructDispatch = struct {
                offset: u32,
                bit_count: u16,
                has_undefined_value: bool,
                handle: *const Handler(anyopaque),
            };

            fn makeFieldsSP(comptime T: type, comptime R: schema.Struct(T), comptime fields: []const _std.builtin.Type.StructField) type {
                comptime var tuple_fields: [fields.len]_std.builtin.Type.StructField = undefined;
                inline for (fields, &tuple_fields) |field, *tuple| {
                    const field_schema = @field(R.fields, field.name);
                    const S = resolveSchema(field.type, field_schema.schema);
                    const P = S.parse_with orelse inferStdParser(field.type);
                    tuple.name = field.name;
                    tuple.type = struct { @TypeOf(S), @TypeOf(P) };
                    tuple.default_value_ptr = &@as(struct { @TypeOf(S), @TypeOf(P) }, .{ S, P });
                    tuple.alignment = @alignOf(tuple.type);
                    tuple.is_comptime = true;
                }
                const result_fields = tuple_fields;
                return @Type(.{ .@"struct" = .{
                    .fields = &result_fields,
                    .decls = &.{},
                    .layout = .auto,
                    .is_tuple = false,
                } });
            }

            pub fn Enum(comptime T: type) type {
                return struct {
                    parse_with: ?CustomParser(T) = null,
                    rename_all: schema_utils.FieldsRenaming = .snake_case,
                    aliases: schema_utils.EnumFields(T) = .{},
                };
            }

            fn parseEnum(comptime T: type, comptime S: schema.Enum(T), allocator: ?Allocator, value: Value) schema.Error!T {
                _ = allocator;
                const variant = try value.asString().getTemporal();
                return parseEnumFromSlice(T, S, variant);
            }

            fn parseEnumFromSlice(comptime T: type, comptime S: schema.Enum(T), slice: []const u8) schema.Error!T {
                const fields = _std.meta.fields(T);
                comptime var dispatches_mut: [fields.len]struct { []const u8, T } = undefined;
                inline for (fields, 0..) |field, i| {
                    const field_rename = @field(S.aliases, field.name);
                    const renamed_variant: []const u8 = if (field_rename) |rename| rename else comptime schema_utils.renameField(S.rename_all, field.name);
                    dispatches_mut[i] = .{ renamed_variant, @field(T, field.name) };
                }
                const dispatches = dispatches_mut;
                const enum_map = comptime schema_utils.Map(T, &dispatches);
                const enum_literal = enum_map.get(slice) orelse return error.UnknownEnumLiteral;
                return enum_literal;
            }

            pub fn Union(comptime T: type) type {
                return struct {
                    parse_with: ?CustomParser(T) = null,
                    rename_all: schema_utils.FieldsRenaming = .snake_case,
                    representation: schema_utils.UnionRepresentation = .externally_tagged,
                    fields: UnionFields(T) = .{},
                };
            }

            fn UnionFields(comptime T: type) type {
                assert(@typeInfo(T) == .@"union");
                const fields = _std.meta.fields(T);
                comptime var schema_fields: [fields.len]_std.builtin.Type.StructField = undefined;
                inline for (0..fields.len) |i| {
                    const field = fields[i];
                    const schema_field = UnionField(field.type);
                    schema_fields[i] = .{
                        .type = schema_field,
                        .name = field.name,
                        .default_value_ptr = &schema_field{},
                        .is_comptime = false,
                        .alignment = @alignOf(schema_field),
                    };
                }
                const sf = schema_fields;
                return @Type(.{
                    .@"struct" = .{
                        .fields = &sf,
                        .layout = .auto,
                        .decls = &.{},
                        .is_tuple = false,
                    },
                });
            }

            fn UnionField(comptime T: type) type {
                return struct {
                    alias: ?[]const u8 = null,
                    schema: ?schema.Infer(T) = null,
                };
            }

            fn parseUnion(comptime T: type, comptime S: schema.Union(T), allocator: ?Allocator, value: Value) schema.Error!T {
                const last_cursor_strings = value.iter.cursor.strings;
                const fields = _std.meta.fields(T);
                if (S.representation == .untagged) {
                    comptime var ordered_fields = fields[0..fields.len].*;
                    const fieldsCount = struct {
                        pub fn inner(_: void, lhs: _std.builtin.Type.UnionField, rhs: _std.builtin.Type.UnionField) bool {
                            const lf = schema_utils.foundFieldsCount(lhs.type);
                            const rf = schema_utils.foundFieldsCount(rhs.type);
                            return lf > rf;
                        }
                    }.inner;
                    comptime _std.mem.sort(_std.builtin.Type.UnionField, &ordered_fields, {}, fieldsCount);

                    // workaround from https://github.com/ziglang/zig/issues/9524#issuecomment-895802551
                    inline for (ordered_fields) |field| {
                        inner: {
                            const field_schema = @field(S.fields, field.name);
                            const payload = value.asAdvancedLeaky(field.type, field_schema.schema, allocator) catch {
                                value.iter.cursor.tokens.revert(value.iter.start_position) catch |err| try value.iter.cursor.reportError(err);
                                value.iter.cursor.depth = value.iter.start_depth;
                                value.iter.cursor.strings = last_cursor_strings;
                                break :inner;
                            };
                            return @unionInit(T, field.name, payload);
                        }
                    }

                    return error.UnknownUnionVariant;
                } else {
                    const tag_sch = brk: {
                        if (@typeInfo(T).@"union".tag_type) |tag_type| {
                            break :brk @as(?schema.Enum(tag_type), if (@hasDecl(tag_type, options.schema_identifier)) @field(tag_type, options.schema_identifier) else .{});
                        } else {
                            break :brk null;
                        }
                    };
                    comptime var dispatches_mut: [fields.len]struct { []const u8, UnionDispatch } = undefined;
                    inline for (fields, 0..) |field, i| {
                        const field_schema = @field(S.fields, field.name);
                        const renamed_variant: []const u8 = brk: {
                            const tag_alias: ?[]const u8 = if (tag_sch) |tag| if (@field(tag.aliases, field.name)) |tag_alias| tag_alias else null else null;
                            if (tag_alias) |alias| break :brk alias;
                            break :brk if (field_schema.alias) |alias| alias else comptime schema_utils.renameField(S.rename_all, field.name);
                        };
                        dispatches_mut[i] = .{ renamed_variant, .{
                            .handle = TaggedUnionParser(T, S.representation, field, field_schema.schema).parseTypeErased,
                        } };
                    }
                    const dispatches = dispatches_mut;
                    const union_map = comptime schema_utils.Map(UnionDispatch, &dispatches);
                    var dest = schema_utils.undefinedInit(T);
                    switch (S.representation) {
                        .externally_tagged => {
                            const object = try value.asObject();
                            if (try object.next()) |content| {
                                const tag_key = try content.key.getTemporal();
                                const dispatch = union_map.get(tag_key) orelse return error.UnknownUnionVariant;
                                try dispatch.handle(allocator, content.value, &dest);
                            } else return error.MissingField;
                            if (try object.next()) |_| return error.IncorrectType;
                        },
                        .internally_tagged => |t| {
                            const object = try value.asObject();
                            if (try object.next()) |tag| {
                                const tag_key = try tag.key.getTemporal();
                                if (!_std.mem.eql(u8, tag_key, t)) return error.UnknownField;
                                const tag_value = try tag.value.asString().getTemporal();
                                const dispatch = union_map.get(tag_value) orelse return error.UnknownUnionVariant;
                                try dispatch.handle(allocator, value, &dest);
                            } else return error.MissingField;
                        },
                        .adjacently_tagged => |a| {
                            const object = try value.asObject();
                            if (try object.next()) |tag| {
                                const tag_key = try tag.key.getTemporal();
                                if (!_std.mem.eql(u8, tag_key, a.tag)) return error.UnknownField;
                                const tag_value = try tag.value.asString().getTemporal();
                                const dispatch = union_map.get(tag_value) orelse return error.UnknownUnionVariant;
                                if (try object.next()) |content| {
                                    const content_key = try content.key.getTemporal();
                                    if (!_std.mem.eql(u8, content_key, a.content)) return error.UnknownField;
                                    try dispatch.handle(allocator, content.value, &dest);
                                } else return error.MissingField;
                                if (try object.next()) |_| return error.IncorrectType;
                            } else return error.MissingField;
                        },
                        else => unreachable,
                    }
                    return dest;
                }
            }

            const UnionDispatch = struct {
                handle: *const Handler(anyopaque),
            };

            fn TaggedUnionParser(
                comptime T: type,
                comptime repr: schema_utils.UnionRepresentation,
                comptime F: _std.builtin.Type.UnionField,
                comptime G: ?schema.Infer(F.type),
            ) type {
                return struct {
                    pub fn parse(allocator: ?Allocator, value: Value) schema.Error!T {
                        if (repr == .internally_tagged) {
                            const g = resolveSchema(F.type, G);
                            assert(@typeInfo(F.type) == .@"struct");
                            const payload = try parseStructWithObject(F.type, g, allocator, .{ .iter = value.iter });
                            return @unionInit(T, F.name, payload);
                        } else {
                            const payload = try value.asAdvancedLeaky(F.type, G, allocator);
                            return @unionInit(T, F.name, payload);
                        }
                    }

                    pub fn parseTypeErased(allocator: ?Allocator, value: Value, dest: *anyopaque) schema.Error!void {
                        const typed_dest: *T = @alignCast(@ptrCast(dest));
                        typed_dest.* = try @This().parse(allocator, value);
                    }
                };
            }

            fn parseElement(comptime T: type, comptime S: schema.Element(T), allocator: ?Allocator, value: Value) schema.Error!T {
                switch (@typeInfo(T)) {
                    .int => |info| {
                        const n = try if (info.signedness == .signed) value.asSigned() else value.asUnsigned();
                        return _std.math.cast(T, n) orelse error.NumberOutOfRange;
                    },
                    .float => return @floatCast(try value.asFloat()),
                    .bool => return value.asBool(),
                    .optional => |opt| {
                        if (try value.isNull()) {
                            return null;
                        } else {
                            const dest = try value.asAdvancedLeaky(opt.child, null, allocator);
                            return dest;
                        }
                    },
                    .null => return if (try value.isNull()) null else error.IncorrectType,
                    .array => |info| {
                        if (info.child == u8 and S.bytes_as_string) {
                            const str = try value.asString().getTemporal();
                            if (str.len != info.len) return error.IncorrectType;
                            var dest = schema_utils.undefinedInit(T);
                            @memcpy(&dest, str);
                            if (info.sentinel()) |s| {
                                dest[str.len] = s;
                            }
                            return dest;
                        } else {
                            const arr = try value.asArray();
                            var dest = schema_utils.undefinedInit(T);
                            for (0..info.len) |i| {
                                if (try arr.next()) |item| {
                                    dest[i] = try item.asAdvancedLeaky(info.child, null, allocator);
                                } else {
                                    return error.IncompleteArray;
                                }
                            }
                            if (try arr.next()) |_| return error.IncorrectType;
                            if (info.sentinel()) |s| {
                                dest[info.len] = s;
                            }
                            return dest;
                        }
                    },
                    .vector => |info| {
                        const arr = try value.asArray();
                        var dest = schema_utils.undefinedInit(T);
                        for (0..info.len) |i| {
                            if (try arr.next()) |item| {
                                dest[i] = try item.asAdvancedLeaky(info.child, null, allocator);
                            } else {
                                return error.IncompleteArray;
                            }
                        }
                        if (try arr.next()) |_| return error.IncorrectType;
                        return dest;
                    },
                    .pointer => |info| {
                        switch (info.size) {
                            .one => {
                                const alloc = allocator orelse return error.ExpectedAllocator;
                                const r = try alloc.create(info.child);
                                errdefer alloc.destroy(r);

                                try value.asAdvancedLeaky(info.child, null, allocator, r);
                                return r;
                            },
                            .slice => {
                                if (info.child == u8 and S.bytes_as_string) {
                                    if (info.sentinel()) |_| @compileError("Unable to parse into type '" ++ @typeName(T) ++ "'");
                                    if (info.sentinel()) |s| {
                                        return try value.asString().getSentinel(s);
                                    } else {
                                        return try value.asString().get();
                                    }
                                } else {
                                    const arr_parser = schema.std.ArrayList(info.child);
                                    var arr = arr_parser.init(allocator) catch unreachable;
                                    try arr_parser.parse(allocator, value, &arr);
                                    if (info.sentinel()) |s| {
                                        return try arr.toOwnedSliceSentinel(s);
                                    } else {
                                        return try arr.toOwnedSlice();
                                    }
                                }
                            },
                            else => @compileError("Unable to parse into type '" ++ @typeName(T) ++ "'"),
                        }
                    },
                    else => @compileError("Unable to parse into type '" ++ @typeName(T) ++ "'"),
                }
            }

            fn TypeErasedParser(comptime T: type, comptime S: schema.Infer(T), comptime P: ?CustomParser(T)) type {
                return struct {
                    pub fn handler(allocator: ?Allocator, value: Value, dest: *anyopaque) schema.Error!void {
                        return value.asTypeErased(T, S, P, allocator, dest);
                    }
                };
            }

            fn resolveSchema(comptime T: type, comptime S: ?schema.Infer(T)) schema.Infer(T) {
                return switch (@typeInfo(T)) {
                    inline .@"struct",
                    .@"enum",
                    .@"union",
                    => S orelse if (@hasDecl(T, options.schema_identifier)) @field(T, options.schema_identifier) else .{},
                    else => S orelse .{},
                };
            }
        };

        const Logger = struct {
            fn logDepth(expected: u32, actual: u32) void {
                if (true) return;
                std.log.info(" SKIP   > Wanted depth: {}, actual: {}", .{ expected, actual });
            }

            fn logStart(parser: *Self, ptr: [*]const u8, label: []const u8, depth: u32) !void {
                if (true) return;
                var buffer = ptr[0 .. Vector.bytes_len * 2].*;
                for (&buffer) |*b| {
                    if (b.* == '\n') b.* = ' ';
                    if (b.* == '\t') b.* = ' ';
                    if (b.* > 127) b.* = '*';
                }
                std.log.info("+{s} | {s} | depth: {} | next: {c}", .{
                    label,
                    buffer,
                    depth,
                    parser.cursor.peekChar(),
                });
            }
            fn log(parser: *Self, ptr: [*]const u8, label: []const u8, depth: u32) !void {
                if (true) return;
                var buffer = ptr[0 .. Vector.bytes_len * 2].*;
                for (&buffer) |*b| {
                    if (b.* == '\n') b.* = ' ';
                    if (b.* == '\t') b.* = ' ';
                    if (b.* > 127) b.* = '*';
                }
                std.log.info(" {s} | {s} | depth: {} | next: {c}", .{
                    label,
                    buffer,
                    depth,
                    parser.cursor.peekChar(),
                });
            }
            fn logEnd(parser: *Self, ptr: [*]const u8, label: []const u8, depth: u32) !void {
                if (true) return;
                var buffer = ptr[0 .. Vector.bytes_len * 2].*;
                for (&buffer) |*b| {
                    if (b.* == '\n') b.* = ' ';
                    if (b.* == '\t') b.* = ' ';
                    if (b.* > 127) b.* = '*';
                }
                std.log.info("-{s} | {s} | depth: {} | next: {c}", .{
                    label,
                    buffer,
                    depth,
                    parser.cursor.peekChar(),
                });
            }
        };
    };
}

pub const schema_utils = struct {
    pub const Map = @import("schema_map.zig").SchemaMap;

    const UnionRepresentation = union(enum) {
        externally_tagged,
        internally_tagged: []const u8,
        adjacently_tagged: struct {
            tag: []const u8,
            content: []const u8,
        },
        untagged,
    };

    const FieldsRenaming = enum {
        lowercase,
        UPPERCASE,
        PascalCase,
        camelCase,
        snake_case,
        SCREAMING_SNAKE_CASE,
        @"kebab-case",
        @"SCREAMING-KEBAB-CASE",
    };

    /// It is assumed the name is snake_cased
    pub fn renameField(case: FieldsRenaming, name: []const u8) []const u8 {
        var output = std.fmt.comptimePrint("{s}", .{name}).*;
        var output_len = name.len;
        switch (case) {
            .lowercase, .snake_case => {},
            .UPPERCASE, .SCREAMING_SNAKE_CASE => _ = std.ascii.upperString(&output, name),
            .@"kebab-case" => std.mem.replaceScalar(u8, &output, '_', '-'),
            .@"SCREAMING-KEBAB-CASE" => {
                _ = std.ascii.upperString(&output, name);
                std.mem.replaceScalar(u8, &output, '_', '-');
            },
            .camelCase, .PascalCase => {
                var capitalize = case == .PascalCase;
                var i: usize = 0;
                for (name) |c| {
                    if (c == '_') {
                        capitalize = true;
                    } else if (capitalize) {
                        output[i] = std.ascii.toUpper(c);
                        i += 1;
                        capitalize = false;
                    } else {
                        output[i] = c;
                        i += 1;
                    }
                }
                output_len = i;
            },
        }
        const output_copy = output;
        return output_copy[0..output_len];
    }

    pub fn EnumFields(comptime T: type) type {
        assert(@typeInfo(T) == .@"enum");
        const fields = std.meta.fields(T);
        comptime var schema_fields: [fields.len]std.builtin.Type.StructField = undefined;
        inline for (0..fields.len) |i| {
            const field = fields[i];
            const schema_field = ?[]const u8;
            schema_fields[i] = .{
                .type = schema_field,
                .name = field.name,
                .default_value_ptr = &@as(schema_field, null),
                .is_comptime = false,
                .alignment = @alignOf(schema_field),
            };
        }
        const sf = schema_fields;
        return @Type(.{
            .@"struct" = .{
                .fields = &sf,
                .layout = .auto,
                .decls = &.{},
                .is_tuple = false,
            },
        });
    }

    fn undefinedInit(comptime T: type) T {
        const info = @typeInfo(T);
        if (info != .@"struct") return undefined;
        comptime var result: T = undefined;
        inline for (std.meta.fields(T)) |field| {
            const default_value: *field.type = @constCast(@alignCast(@ptrCast(
                field.default_value_ptr orelse if (@typeInfo(field.type) == .optional) null else continue,
            )));
            @field(result, field.name) = default_value.*;
        }
        return result;
    }

    fn foundFieldsCount(comptime T: type) comptime_int {
        switch (@typeInfo(T)) {
            .@"struct" => {
                comptime var count: comptime_int = 0;
                inline for (std.meta.fields(T)) |field| {
                    count += foundFieldsCount(field.type) + 1;
                }
                return count;
            },
            .@"union" => {
                comptime var max: comptime_int = 0;
                inline for (std.meta.fields(T)) |field| {
                    max = @max(max, foundFieldsCount(field.type));
                }
                return max;
            },
            inline .optional, .pointer, .array => |info| return foundFieldsCount(info.child),
            else => return 0,
        }
    }
};
