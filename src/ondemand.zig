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
const ArenaAllocator = std.heap.ArenaAllocator;
const ArrayList = std.ArrayListUnmanaged;

pub const FullOptions = struct {
    pub const default: @This() = .{};

    /// Use this literal if you are certain that parsing will only be done from a reader.
    pub const reader_only: @This() = .{ .aligned = true, .assume_padding = true };

    aligned: bool = false,
    assume_padding: bool = false,
    schema_identifier: []const u8 = "schema",
};

pub const StreamOptions = struct {
    pub const default: @This() = .{};

    chunk_length: u32 = tokens.ring_buffer.default_chunk_length,
    schema_identifier: []const u8 = "schema",
};

const Options = union(enum) {
    full: FullOptions,
    stream: StreamOptions,
};

pub fn FullParser(comptime options: FullOptions) type {
    return Parser(.json, .{ .full = options });
}

pub fn StreamParser(comptime options: StreamOptions) type {
    return Parser(.json, .{ .stream = options });
}

pub const ReaderError = types.ReaderError;
pub const ParseError = types.ParseError;
pub const StreamError = tokens.stream.StreamError;
pub const IndexerError = @import("indexer.zig").Error;

pub fn Parser(comptime format: types.Format, comptime options: Options) type {
    _ = format;
    const want_stream = options == .stream;
    const aligned = options == .full and options.full.aligned;
    const schema_identifier = switch (options) {
        inline else => |o| o.schema_identifier,
    };

    return struct {
        const Self = @This();

        const Aligned = types.Aligned(aligned);
        const Tokens = if (want_stream)
            tokens.stream.Stream(.{
                .aligned = true,
                .chunk_len = options.stream.chunk_length,
                .slots = 4,
            })
        else
            tokens.iterator.Iterator(.{
                .aligned = aligned,
                .assume_padding = options.full.assume_padding,
            });

        pub const Error = Tokens.Error || types.ParseError || Allocator.Error ||
            error{
            ExpectedAllocator,
        } ||
            (if (builtin.mode == .Debug) error{OutOfOrderIteration} else error{});

        pub const max_capacity_bound = if (want_stream) std.math.maxInt(usize) else std.math.maxInt(u32);

        // only used in full mode
        document_buffer: std.ArrayListAlignedUnmanaged(u8, types.Aligned(true).alignment),
        reader_error: ?std.meta.Int(.unsigned, @bitSizeOf(anyerror)),

        string_buffer: types.StringBuffer(max_capacity_bound),

        cursor: Cursor,

        max_capacity: usize,
        max_depth: usize,

        pub const init: Self = .{
            .cursor = .init,
            .string_buffer = .init,
            .max_capacity = max_capacity_bound,
            .max_depth = common.default_max_depth,
            .document_buffer = .empty,
            .reader_error = null,
        };

        pub fn deinit(self: *Self, allocator: Allocator) void {
            self.cursor.deinit(allocator);
            self.document_buffer.deinit(allocator);
            self.string_buffer.deinit();
        }

        pub fn expectDocumentSize(self: *Self, allocator: Allocator, size: usize) Error!void {
            return self.ensureTotalCapacityForReader(allocator, size);
        }

        fn ensureTotalCapacityForSlice(self: *Self, allocator: Allocator, new_capacity: usize) Error!void {
            if (new_capacity > self.max_capacity) return error.ExceededCapacity;

            try self.cursor.tokens.ensureTotalCapacity(allocator, new_capacity);

            self.string_buffer.allocator = allocator;
            try self.string_buffer.ensureTotalCapacity(new_capacity);
        }

        fn ensureTotalCapacityForReader(self: *Self, allocator: Allocator, new_capacity: usize) Error!void {
            if (new_capacity > self.max_capacity) return error.ExceededCapacity;

            if (!want_stream) {
                try self.document_buffer.ensureTotalCapacity(allocator, new_capacity + types.Vector.bytes_len);
                try self.cursor.tokens.ensureTotalCapacity(allocator, new_capacity);
            }

            self.string_buffer.allocator = allocator;
            try self.string_buffer.ensureTotalCapacity(new_capacity);
        }

        pub fn parseFromSlice(self: *Self, allocator: Allocator, document: Aligned.slice) Error!Document {
            if (want_stream) @compileError("Parsing from a slice is not supported in stream mode");
            self.reader_error = null;

            if (builtin.mode == .Debug) {
                try self.cursor.start_positions.ensureTotalCapacity(allocator, self.max_depth);
                self.cursor.start_positions.expandToCapacity();
            }

            self.string_buffer.reset();
            self.string_buffer.allocator = allocator;

            try self.ensureTotalCapacityForSlice(allocator, document.len);
            try self.cursor.tokens.build(allocator, document);

            self.cursor.document = self;
            self.cursor.depth = 1;
            self.cursor.root = if (want_stream) 0 else @intFromPtr(self.cursor.tokens.indexes.items.ptr);
            self.cursor.err = null;

            return .{
                .iter = .{
                    .cursor = &self.cursor,
                    .start_position = self.cursor.root,
                    .start_depth = 1,
                    .start_char = self.cursor.peekChar(),
                },
            };
        }

        pub fn parseFromReader(self: *Self, allocator: Allocator, reader: std.io.AnyReader) (Error || ReaderError)!Document {
            if (builtin.mode == .Debug) {
                try self.cursor.start_positions.ensureTotalCapacity(allocator, self.max_depth);
                self.cursor.start_positions.expandToCapacity();
            }
            self.reader_error = null;

            self.string_buffer.reset();
            self.string_buffer.allocator = allocator;

            if (want_stream) {
                try self.cursor.tokens.build(allocator, reader);
            } else {
                self.document_buffer.clearRetainingCapacity();
                common.readAllRetainingCapacity(
                    allocator,
                    reader,
                    types.Aligned(true).alignment,
                    &self.document_buffer,
                    self.max_capacity,
                ) catch |err| switch (err) {
                    Allocator.Error.OutOfMemory => |e| return e,
                    else => |e| {
                        self.reader_error = @intFromError(e);
                        return error.AnyReader;
                    },
                };
                const len = self.document_buffer.items.len;
                try self.ensureTotalCapacityForReader(allocator, len);
                self.document_buffer.appendNTimesAssumeCapacity(' ', types.Vector.bytes_len);
                try self.cursor.tokens.build(allocator, self.document_buffer.items[0..len]);
            }

            self.cursor.document = self;
            self.cursor.depth = 1;
            self.cursor.root = if (want_stream) 0 else @intFromPtr(self.cursor.tokens.indexes.items.ptr);
            self.cursor.err = null;

            return .{
                .iter = .{
                    .cursor = &self.cursor,
                    .start_position = self.cursor.root,
                    .start_depth = 1,
                    .start_char = self.cursor.peekChar(),
                },
            };
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
            start_positions: if (builtin.mode == .Debug) ArrayList(usize) else void,
            depth: u32,
            root: usize = undefined,
            err: ?Error,

            pub const init: Cursor = .{
                .tokens = .init,
                .start_positions = if (builtin.mode == .Debug) .empty else {},
                .depth = 1,
                .err = null,
            };

            pub fn deinit(self: *Cursor, allocator: Allocator) void {
                self.tokens.deinit(allocator);
                if (builtin.mode == .Debug) {
                    self.start_positions.deinit(allocator);
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

            pub fn asValue(self: Document) Value {
                if (builtin.mode == .Debug) if (!self.iter.isAtRoot()) return .{ .iter = self.iter, .err = error.OutOfOrderIteration };
                self.iter.assertAtRoot();
                return .{ .iter = self.iter };
            }

            pub fn asObject(self: Document) Error!Object {
                if (builtin.mode == .Debug) if (!self.iter.isAtRoot()) return error.OutOfOrderIteration;
                self.iter.assertAtRoot();
                const started, const object = try Object.start(self.iter);
                if (started or try self.iter.isAtEnd()) return object;
                return error.TrailingContent;
            }

            pub fn asArray(self: Document) Error!Array {
                if (builtin.mode == .Debug) if (!self.iter.isAtRoot()) return error.OutOfOrderIteration;
                self.iter.assertAtRoot();
                const started, const array = try Array.start(self.iter);
                if (started or try self.iter.isAtEnd()) return array;
                return error.TrailingContent;
            }

            pub fn asNumber(self: Document) Error!Number {
                if (builtin.mode == .Debug) if (!self.iter.isAtRoot()) return error.OutOfOrderIteration;
                self.iter.assertAtRoot();
                const n = try self.iter.asNumber();
                if (try self.iter.isAtEnd()) return n;
                return error.TrailingContent;
            }

            pub fn asUnsigned(self: Document) Error!u64 {
                if (builtin.mode == .Debug) if (!self.iter.isAtRoot()) return error.OutOfOrderIteration;
                self.iter.assertAtRoot();
                const n = try self.iter.asUnsigned();
                if (try self.iter.isAtEnd()) return n;
                return error.TrailingContent;
            }

            pub fn asSigned(self: Document) Error!i64 {
                if (builtin.mode == .Debug) if (!self.iter.isAtRoot()) return error.OutOfOrderIteration;
                self.iter.assertAtRoot();
                const n = try self.iter.asSigned();
                if (try self.iter.isAtEnd()) return n;
                return error.TrailingContent;
            }

            pub fn asDouble(self: Document) Error!f64 {
                if (builtin.mode == .Debug) if (!self.iter.isAtRoot()) return error.OutOfOrderIteration;
                self.iter.assertAtRoot();
                const n = try self.iter.asDouble();
                if (try self.iter.isAtEnd()) return n;
                return error.TrailingContent;
            }

            pub fn asString(self: Document) String {
                if (builtin.mode == .Debug) if (!self.iter.isAtRoot()) return .{ .iter = self.iter, .raw_str = undefined, .err = error.OutOfOrderIteration };
                self.iter.assertAtRoot();
                const str: String = self.iter.asString() catch |err| .{
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

            pub fn asBool(self: Document) Error!bool {
                if (builtin.mode == .Debug) if (!self.iter.isAtRoot()) return error.OutOfOrderIteration;
                self.iter.assertAtRoot();
                const b = try self.iter.asBool();
                if (try self.iter.isAtEnd()) return b;
                return error.TrailingContent;
            }

            pub fn isNull(self: Document) Error!bool {
                if (builtin.mode == .Debug) if (!self.iter.isAtRoot()) return error.OutOfOrderIteration;
                self.iter.assertAtRoot();
                const n = try self.iter.isNull();
                if (try self.iter.isAtEnd()) return n;
                return error.TrailingContent;
            }

            pub fn asAny(self: Document) Error!AnyValue {
                if (builtin.mode == .Debug) if (!self.iter.isAtRoot()) return error.OutOfOrderIteration;
                self.iter.assertAtRoot();
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
                    else => return error.IncorrectType,
                };
            }

            pub fn getType(self: Document) Error!types.ValueType {
                return switch (self.iter.start_char) {
                    't', 'f' => .bool,
                    'n' => .null,
                    '"' => .string,
                    '-', '0'...'9' => .number,
                    '[' => .array,
                    '{' => .object,
                    else => error.IncorrectType,
                };
            }

            pub fn getArraySize(self: Document) Error!usize {
                const arr = try self.asArray();
                const size = try arr.getSize();
                try self.iter.reset();
                return size;
            }

            pub fn getObjectSize(self: Document) Error!usize {
                const arr = try self.asObject();
                const size = try arr.getSize();
                try self.iter.reset();
                return size;
            }

            pub inline fn as(
                self: Document,
                comptime T: type,
                allocator: Allocator,
                schema_options: schema.Options(T),
            ) schema.Error!std.json.Parsed(T) {
                const data = try self.asValue().as(T, allocator, schema_options);
                if (try self.atEnd()) return data;
                return error.TrailingContent;
            }

            pub inline fn asLeaky(
                self: Document,
                comptime T: type,
                allocator: ?Allocator,
                schema_options: schema.Options(T),
            ) schema.Error!T {
                const data = try self.asValue().asLeaky(T, allocator, schema_options);
                if (try self.atEnd()) return data;
                return error.TrailingContent;
            }

            fn skip(self: Document) Error!void {
                return self.iter.cursor.skip(0, self.iter.start_char);
            }

            pub fn atEnd(self: Document) Error!bool {
                try self.skip();
                return self.iter.isAtEnd();
            }

            pub fn at(self: Document, key: []const u8) Value {
                const obj = self.startOrResumeObject() catch |err| return .{ .iter = self.iter, .err = err };
                return obj.at(key);
            }

            pub fn atIndex(self: Document, index: usize) Value {
                const arr = self.asArray() catch |err| return .{ .iter = self.iter, .err = err };
                return arr.at(index);
            }

            pub fn reset(self: Document) Error!void {
                try self.iter.reset();
                self.iter.cursor.document.string_buffer.reset();
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

                inline fn asDouble(self: Iterator) Error!f64 {
                    const n = try self.parseDouble(try self.peekScalar());
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
                        error.IncorrectType => {},
                        else => return err,
                    }
                    return is_null;
                }

                fn parseNumber(self: Iterator, ptr: [*]const u8) Error!Number {
                    // if (!(ptr[0] -% '0' < 10 or ptr[0] == '-')) return error.IncorrectType;
                    try Logger.log(self.cursor.document, ptr, "number", self.start_depth);
                    return @import("parsers/number/parser.zig").parse(null, ptr);
                }

                fn parseUnsigned(self: Iterator, ptr: [*]const u8) Error!u64 {
                    // if (!(ptr[0] -% '0' < 10)) return error.IncorrectType;
                    try Logger.log(self.cursor.document, ptr, "u64   ", self.start_depth);
                    const n = try @import("parsers/number/parser.zig").parse(.unsigned, ptr);
                    return n.unsigned;
                }

                fn parseSigned(self: Iterator, ptr: [*]const u8) Error!i64 {
                    // if (!(ptr[0] -% '0' < 10 or ptr[0] == '-')) return error.IncorrectType;
                    try Logger.log(self.cursor.document, ptr, "i64   ", self.start_depth);
                    const n = try @import("parsers/number/parser.zig").parse(.signed, ptr);
                    return n.signed;
                }

                fn parseDouble(self: Iterator, ptr: [*]const u8) Error!f64 {
                    // if (!(ptr[0] -% '0' < 10 or ptr[0] == '-')) return error.IncorrectType;
                    try Logger.log(self.cursor.document, ptr, "f64   ", self.start_depth);
                    const n = try @import("parsers/number/parser.zig").parse(.double, ptr);
                    return switch (n) {
                        .double => |v| v,
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
                    // if (!(ptr[0] == 't' or ptr[0] == 'f')) return error.IncorrectType;
                    try Logger.log(self.cursor.document, ptr, "bool  ", self.start_depth);
                    const check = @import("parsers/atoms.zig").checkBool;
                    return check(ptr);
                }

                inline fn parseNull(self: Iterator, ptr: [*]const u8) Error!void {
                    // if (ptr[0] != 'n') return error.IncorrectType;
                    try Logger.log(self.cursor.document, ptr, "null  ", self.start_depth);
                    const check = @import("parsers/atoms.zig").checkNull;
                    return check(ptr);
                }

                inline fn endContainer(self: Iterator) void {
                    self.cursor.ascend(self.start_depth - 1);
                }

                inline fn isAtStart(self: Iterator) bool {
                    const pos = self.cursor.position();
                    return pos == self.start_position;
                }

                inline fn isAtRoot(self: Iterator) bool {
                    return self.isAtStart() and self.start_depth == 1;
                }

                inline fn isAtContainerStart(self: Iterator) bool {
                    const pos = self.cursor.position();
                    const delta = pos - self.start_position;
                    return delta == 1 * Cursor.position_size or delta == 2 * Cursor.position_size;
                }

                inline fn isAtKey(self: Iterator) Error!bool {
                    return self.start_depth == self.cursor.depth and self.cursor.peekChar() == '"';
                }

                inline fn isAtFirstField(self: Iterator) bool {
                    const pos = self.cursor.position();
                    assert(pos > self.start_position);
                    return pos == self.start_position + Cursor.position_size;
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
                        ',' => {
                            self.cursor.descend(self.cursor.depth + 1);
                            return true;
                        },
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
                    if (builtin.mode == .Debug) {
                        self.cursor.setStartPosition(self.start_depth, self.start_position);
                    }
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
                    const char = self.cursor.peekChar();
                    if (char == ']') {
                        const ptr = try self.cursor.next();
                        self.endContainer();
                        try Logger.log(self.cursor.document, ptr, "array ", self.start_depth);
                        return false;
                    }
                    self.cursor.descend(self.cursor.depth + 1);
                    if (builtin.mode == .Debug) {
                        self.cursor.setStartPosition(self.start_depth, self.start_position);
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
                    if (!self.isAtStart()) return self.peekStart();
                    self.assertAtStart();
                    return self.cursor.peek();
                }

                inline fn peekStart(self: Iterator) Error![*]const u8 {
                    return self.cursor.tokens.peekPosition(self.start_position);
                }

                inline fn advanceScalar(self: Iterator) Error!void {
                    if (!self.isAtStart()) return;
                    self.assertAtStart();
                    _ = try self.cursor.next();
                    self.cursor.ascend(self.start_depth - 1);
                }

                inline fn skipChild(self: Iterator) Error!void {
                    const pos = self.cursor.position();
                    assert(pos > self.start_position);
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
                        if (builtin.mode == .Debug) if (self.cursor.getStartPosition(self.start_depth) != self.start_position) return error.OutOfOrderIteration;
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
                        const pos = self.cursor.position();
                        if (pos == search_start) return false;
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
                    if (want_stream) {
                        try self.cursor.tokens.revert(self.start_position + 1);
                    } else {
                        try self.cursor.tokens.revert(self.start_position + 1 * @sizeOf(u32));
                    }
                    self.cursor.depth = self.start_depth;
                }

                inline fn reset(self: Iterator) Error!void {
                    if (want_stream) {
                        try self.cursor.tokens.revert(self.start_position);
                    } else {
                        try self.cursor.tokens.revert(self.start_position);
                    }
                    self.cursor.depth = self.start_depth;
                }

                inline fn assertAtStart(self: Iterator) void {
                    const pos = self.cursor.position();
                    assert(pos == self.start_position);
                    assert(self.cursor.depth == self.start_depth);
                    assert(self.start_depth > 0);
                }

                inline fn assertAtContainerStart(self: Iterator) void {
                    const pos = self.cursor.position();
                    assert(pos == self.start_position + Cursor.position_size);
                    assert(self.cursor.depth == self.start_depth);
                    assert(self.start_depth > 0);
                }

                inline fn assertAtNext(self: Iterator) void {
                    const pos = self.cursor.position();
                    assert(pos > self.start_position);
                    assert(self.cursor.depth == self.start_depth);
                    assert(self.start_depth > 0);
                }

                inline fn assertAtChild(self: Iterator) void {
                    const pos = self.cursor.position();
                    assert(pos > self.start_position);
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

            pub fn asObject(self: Value) Error!Object {
                if (self.err) |err| return err;
                return (try Object.start(self.iter))[1];
            }

            pub fn asArray(self: Value) Error!Array {
                if (self.err) |err| return err;
                return (try Array.start(self.iter))[1];
            }

            pub fn asNumber(self: Value) Error!Number {
                if (self.err) |err| return err;
                return self.iter.asNumber();
            }

            pub fn asUnsigned(self: Value) Error!u64 {
                if (self.err) |err| return err;
                return self.iter.asUnsigned();
            }

            pub fn asSigned(self: Value) Error!i64 {
                if (self.err) |err| return err;
                return self.iter.asSigned();
            }

            pub fn asDouble(self: Value) Error!f64 {
                if (self.err) |err| return err;
                return self.iter.asDouble();
            }

            pub fn asString(self: Value) String {
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

            pub fn asBool(self: Value) Error!bool {
                if (self.err) |err| return err;
                return self.iter.asBool();
            }

            pub fn isNull(self: Value) Error!bool {
                if (self.err) |err| return err;
                return self.iter.isNull();
            }

            pub fn asAny(self: Value) Error!AnyValue {
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
                    else => return error.IncorrectType,
                };
            }

            pub fn getType(self: Value) Error!types.ValueType {
                if (self.err) |err| return err;
                return switch (self.iter.start_char) {
                    't', 'f' => .bool,
                    'n' => .null,
                    '"' => .string,
                    '-', '0'...'9' => .number,
                    '[' => .array,
                    '{' => .object,
                    else => error.IncorrectType,
                };
            }

            pub fn getArraySize(self: Value) Error!usize {
                if (self.err) |err| return err;

                const arr = try self.asArray();
                const size = try arr.getSize();
                try self.iter.reset();
                return size;
            }

            pub fn getObjectSize(self: Value) Error!usize {
                if (self.err) |err| return err;

                const arr = try self.asObject();
                const size = try arr.getSize();
                try self.iter.reset();
                return size;
            }

            pub inline fn as(
                self: Value,
                comptime T: type,
                allocator: Allocator,
                schema_options: schema.Options(T),
            ) schema.Error!std.json.Parsed(T) {
                var dest: std.json.Parsed(T) = .{
                    .arena = try allocator.create(std.heap.ArenaAllocator),
                    .value = schema_utils.undefinedInit(T),
                };
                errdefer allocator.destroy(dest.arena);
                dest.arena.* = .init(allocator);
                errdefer dest.arena.deinit();
                dest.value = try self.asLeaky(T, dest.arena.allocator(), schema_options);
                return dest;
            }

            pub inline fn asLeaky(
                self: Value,
                comptime T: type,
                allocator: ?Allocator,
                schema_options: schema.Options(T),
            ) schema.Error!T {
                var dest = schema_utils.undefinedInit(T);
                const sch = comptime schema.resolveSchema(T, schema_options.schema);
                const custom_parser = comptime sch.parse_with orelse schema.CustomParser(T).infer();
                if (custom_parser) |handler| dest = handler.init;
                try self.asAdvancedInner(T, sch, custom_parser, allocator, &dest);
                return dest;
            }

            fn asAdvancedInner(
                self: Value,
                comptime T: type,
                comptime S: schema.Infer(T),
                comptime P: ?schema.CustomParser(T),
                allocator: ?Allocator,
                dest: *T,
            ) schema.Error!void {
                const string_index = self.iter.cursor.document.string_buffer.saveIndex();
                errdefer {
                    self.iter.reset() catch |err| (self.iter.cursor.reportError(err) catch {});
                    self.iter.cursor.document.string_buffer.loadIndex(string_index);
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
                return self.asAdvancedInner(T, S, P, allocator, @alignCast(@ptrCast(dest)));
            }

            fn skip(self: Value) Error!void {
                if (self.err) |err| return err;
                return self.iter.cursor.skip(self.iter.start_depth - 1, 0);
            }

            pub fn at(self: Value, key: []const u8) Value {
                if (self.err) |_| return self;
                const obj = self.startOrResumeObject() catch |err| return .{ .iter = self.iter, .err = err };
                return obj.at(key);
            }

            pub fn atIndex(self: Value, index: usize) Value {
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

            pub fn get(self: String) Error![]const u8 {
                return self.getAdvanced(null);
            }

            pub fn getSentinel(self: String, comptime sentinel: u8) Error![:sentinel]const u8 {
                return self.getAdvanced(sentinel);
            }

            pub fn getTemporal(self: String) Error![]const u8 {
                const buffer = &self.iter.cursor.document.string_buffer;
                const str = try self.write(null, buffer);
                return str;
            }

            inline fn getAdvanced(self: String, comptime sentinel: ?u8) if (sentinel) |s| Error![:s]const u8 else Error![]const u8 {
                const string_buffer = &self.iter.cursor.document.string_buffer;
                const str = try self.write(sentinel, string_buffer);
                if (sentinel) |_| {
                    string_buffer.advance(str.len + 1);
                } else {
                    string_buffer.advance(str.len);
                }
                return str;
            }

            inline fn write(self: String, comptime sentinel: ?u8, string_buffer: *types.StringBuffer(max_capacity_bound)) if (sentinel) |s| Error![:s]const u8 else Error![]const u8 {
                if (self.err) |err| return err;

                if (want_stream) {
                    try string_buffer.ensureUnusedCapacity(options.stream.chunk_length + Vector.bytes_len);
                }
                const dest = string_buffer.peek();

                const str = try self.iter.parseString(self.raw_str, dest);
                if (sentinel) |s| {
                    dest[str.len] = s;
                }
                return str;
            }

            pub fn eqlRaw(self: String, target: []const u8) Error!bool {
                if (self.err) |err| return err;
                return self.raw_str[1..][target.len] == '"' and std.mem.eql(u8, self.raw_str[1..][0..target.len], target);
            }
        };

        pub const Array = struct {
            iter: Value.Iterator,

            pub const Iterator = struct {
                iter: Value.Iterator,
                first: bool = true,

                pub fn next(self: *Iterator) Error!?Value {
                    if (!self.iter.isOpen()) return null;
                    if (self.first) {
                        const value: Value = .{ .iter = try self.iter.child() };
                        self.first = false;
                        return value;
                    }
                    try self.iter.skipChild();
                    if (try self.iter.hasNextElement()) {
                        return .{ .iter = try self.iter.child() };
                    }
                    return null;
                }
            };

            pub fn iterator(self: Array) Iterator {
                if (builtin.mode == .Debug)
                    if (!self.iter.isAtContainerStart()) {
                        self.iter.cursor.reportError(error.OutOfOrderIteration) catch {};
                    };

                return .{ .iter = self.iter };
            }

            inline fn start(iter: Value.Iterator) Error!struct { bool, Array } {
                const started, const array = try iter.startArray();
                return .{ started, .{ .iter = array } };
            }

            pub fn at(self: Array, index: usize) Value {
                var i: usize = 0;
                var it = self.iterator();
                while (it.next() catch |err| return .{
                    .iter = self.iter,
                    .err = err,
                }) |v| : (i += 1) if (i == index) return v;
                return .{
                    .iter = self.iter,
                    .err = error.IndexOutOfBounds,
                };
            }

            pub fn isEmpty(self: Array) Error!bool {
                return !try self.iter.resetArray();
            }

            fn skip(self: Array) Error!void {
                return self.iter.cursor.skip(self.iter.start_depth - 1, '[');
            }

            pub fn reset(self: Array) Error!void {
                _ = try self.iter.resetArray();
            }

            pub fn getSize(self: Array) Error!usize {
                var size: usize = 0;
                var it = self.iterator();
                while (try it.next()) |_| size += 1;
                _ = try self.reset();
                return size;
            }
        };

        pub const Object = struct {
            iter: Value.Iterator,

            pub const Field = struct {
                key: String,
                value: Value,

                inline fn start(iter: Value.Iterator) Error!Field {
                    iter.assertAtNext();
                    const key_quote = try iter.cursor.next();
                    if (key_quote[0] != '"') return iter.reportError(error.ExpectedKey);

                    iter.assertAtNext();
                    const colon = try iter.cursor.next();
                    if (colon[0] != ':') return iter.reportError(error.ExpectedColon);
                    iter.cursor.descend(iter.start_depth + 1);

                    return .{
                        .key = .{
                            .iter = iter,
                            .raw_str = key_quote,
                        },
                        .value = .{ .iter = try iter.child() },
                    };
                }
            };

            pub const Iterator = struct {
                iter: Value.Iterator,
                first: bool = true,

                pub fn next(self: *Iterator) Error!?Field {
                    if (!self.iter.isOpen()) return null;
                    if (self.first) {
                        const field = try Field.start(self.iter);
                        self.first = false;
                        return field;
                    }
                    try self.iter.skipChild();
                    if (try self.iter.hasNextField()) {
                        return try Field.start(self.iter);
                    }
                    return null;
                }
            };

            pub fn iterator(self: Object) Iterator {
                if (builtin.mode == .Debug)
                    if (!self.iter.isAtContainerStart()) {
                        self.iter.cursor.reportError(error.OutOfOrderIteration) catch {};
                    };

                return .{ .iter = self.iter };
            }

            inline fn start(iter: Value.Iterator) Error!struct { bool, Object } {
                const started, const object = try iter.startObject();
                return .{ started, .{ .iter = object } };
            }

            pub fn at(self: Object, key: []const u8) Value {
                return self.atRaw(key, true);
            }

            pub fn atOrdered(self: Object, key: []const u8) Value {
                return self.atRaw(key, false);
            }

            fn atRaw(self: Object, key: []const u8, comptime unordered: bool) Value {
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

            pub fn isEmpty(self: Object) Error!bool {
                return !try self.iter.resetObject();
            }

            fn skip(self: Object) Error!void {
                if (try self.iter.isAtKey()) {
                    _ = try Object.Field.start(self.iter);
                }
                return self.iter.cursor.skip(self.iter.start_depth - 1, '{');
            }

            pub fn reset(self: Object) Error!void {
                _ = try self.iter.resetObject();
            }

            pub fn getSize(self: Object) Error!usize {
                var size: usize = 0;
                var it = self.iterator();
                while (try it.next()) |_| size += 1;
                _ = try self.reset();
                return size;
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

            pub fn Options(comptime T: type) type {
                return struct {
                    schema: ?Infer(T) = null,
                };
            }

            pub fn Handler(comptime T: type) type {
                return fn (allocator: ?Allocator, value: Value, dest: *T) schema.Error!void;
            }

            pub fn SimpleRefHandler(comptime T: type) type {
                return fn (allocator: ?Allocator, dest: *T) schema.Error!void;
            }

            pub fn CustomParser(comptime T: type) type {
                return struct {
                    init: T,
                    parse: *const Handler(T),

                    pub fn from(comptime S: type) @This() {
                        assert(@typeInfo(S) == .@"struct");
                        assert(@hasDecl(S, "parse") and @TypeOf(@field(S, "parse")) == Handler(T));
                        return .{
                            .init = S.init,
                            .parse = S.parse,
                        };
                    }

                    fn infer() ?@This() {
                        const std_data_structure = schema_utils.StandardDataStructure.infer(T) orelse return null;
                        return switch (std_data_structure) {
                            .array_list => |p| schema.std.ArrayList(p[0]),
                            .array_list_aligned => |p| schema.std.ArrayListAligned(p[0], p[1]),
                            // .bit_stack => schema.std.BitStack,
                            // .buf_map => schema.std.BufMap,
                            // .buf_set => schema.std.BufSet,
                            .bounded_array => |p| schema.std.BoundedArray(p[0], p[1]),
                            .bounded_array_aligned => |p| schema.std.BoundedArrayAligned(p[0], p[1], p[2]),
                            .enum_map => |p| schema.std.EnumMap(p[0], p[1]),
                            .singly_linked_list => |p| schema.std.SinglyLinkedList(p[0]),
                            .doubly_linked_list => |p| schema.std.DoublyLinkedList(p[0]),
                            .multi_array_list => |p| schema.std.MultiArrayList(p[0]),
                            .segmented_list => |p| schema.std.SegmentedList(p[0], p[1]),
                            .string_array_hash_map => |p| schema.std.StringArrayHashMap(p[0]),
                            .string_hash_map => |p| schema.std.StringHashMap(p[0]),
                        };
                    }
                };
            }

            pub const std = struct {
                pub fn ArrayList(comptime T: type) CustomParser(_std.ArrayListUnmanaged(T)) {
                    const Parsed = _std.ArrayListUnmanaged(T);
                    return .from(struct {
                        pub const init: Parsed = .empty;
                        pub fn parse(allocator: ?Allocator, value: Value, dest: *Parsed) schema.Error!void {
                            const alloc = allocator orelse return error.ExpectedAllocator;
                            var arr = (try value.asArray()).iterator();
                            while (try arr.next()) |child| {
                                const item = try child.asLeaky(T, alloc, .{});
                                try dest.append(alloc, item);
                            }
                        }
                    });
                }
                pub fn ArrayListAligned(comptime T: type, comptime alignment: ?u29) CustomParser(_std.ArrayListAlignedUnmanaged(T, alignment)) {
                    const Parsed = _std.ArrayListAlignedUnmanaged(T, alignment);
                    return .from(struct {
                        pub const init: Parsed = .empty;
                        pub fn parse(allocator: ?Allocator, value: Value, dest: *Parsed) schema.Error!void {
                            const alloc = allocator orelse return error.ExpectedAllocator;
                            var arr = (try value.asArray()).iterator();
                            while (try arr.next()) |child| {
                                const item = try child.asLeaky(T, alloc, .{});
                                try dest.append(alloc, item);
                            }
                        }
                    });
                }
                // pub const BitStack: CustomParser(_std.BitStack) = brk: {
                //     const Parsed = _std.BitStack;
                //     break :brk .from(struct {
                //         pub fn init(allocator: ?Allocator) schema.Error!Parsed {
                //             const alloc = allocator orelse return error.ExpectedAllocator;
                //             return .init(alloc);
                //         }
                //         pub fn parse(_: ?Allocator, value: Value, dest: *Parsed) schema.Error!void {
                //             const arr = try value.asArray();
                //             while (try arr.next()) |child| {
                //                 const item = try child.asLeaky(u1, null, null);
                //                 try dest.push(item);
                //             }
                //         }
                //     });
                // };
                pub fn BoundedArray(comptime T: type, comptime buffer_capacity: usize) CustomParser(_std.BoundedArray(T, buffer_capacity)) {
                    const Parsed = _std.BoundedArray(T, buffer_capacity);
                    return .from(struct {
                        pub const init: Parsed = Parsed.init(0) catch unreachable;
                        pub fn parse(allocator: ?Allocator, value: Value, dest: *Parsed) schema.Error!void {
                            var arr = (try value.asArray()).iterator();
                            while (try arr.next()) |child| {
                                const item = try child.asLeaky(T, allocator, .{});
                                dest.append(item) catch return error.ExceededCapacity;
                            }
                        }
                    });
                }
                pub fn BoundedArrayAligned(
                    comptime T: type,
                    comptime alignment: u29,
                    comptime buffer_capacity: usize,
                ) CustomParser(_std.BoundedArrayAligned(T, alignment, buffer_capacity)) {
                    const Parsed = _std.BoundedArrayAligned(T, alignment, buffer_capacity);
                    return .from(struct {
                        pub const init: Parsed = Parsed.init(0) catch unreachable;
                        pub fn parse(allocator: ?Allocator, value: Value, dest: *Parsed) schema.Error!void {
                            var arr = (try value.asArray()).iterator();
                            while (try arr.next()) |child| {
                                const item = try child.asLeaky(T, allocator, .{});
                                dest.append(item) catch return error.ExceededCapacity;
                            }
                        }
                    });
                }
                // pub const BufMap: CustomParser(_std.BufMap) = brk: {
                //     const Parsed = _std.BufMap;
                //     break :brk .from(struct {
                //         pub fn init(allocator: ?Allocator) schema.Error!Parsed {
                //             const alloc = allocator orelse return error.ExpectedAllocator;
                //             return .init(alloc);
                //         }
                //         pub fn parse(_: ?Allocator, value: Value, dest: *Parsed) schema.Error!void {
                //             const obj = try value.asObject();
                //             while (try obj.next()) |field| {
                //                 const key = try field.key.get();
                //                 const str = try field.value.asString().getTemporal();
                //                 try dest.put(key, str);
                //             }
                //         }
                //     });
                // };
                // pub const BufSet: CustomParser(_std.BufSet) = brk: {
                //     const Parsed = _std.BufSet;
                //     break :brk .from(struct {
                //         pub fn init(allocator: ?Allocator) schema.Error!Parsed {
                //             const alloc = allocator orelse return error.ExpectedAllocator;
                //             return .init(alloc);
                //         }
                //         pub fn parse(_: ?Allocator, value: Value, dest: *Parsed) schema.Error!void {
                //             const arr = try value.asArray();
                //             while (try arr.next()) |child| {
                //                 const item = try child.asString().getTemporal();
                //                 try dest.insert(item);
                //             }
                //         }
                //     });
                // };
                pub fn DoublyLinkedList(comptime T: type) CustomParser(_std.DoublyLinkedList(T)) {
                    const Parsed = _std.DoublyLinkedList(T);
                    return .from(struct {
                        pub const init: Parsed = .{};
                        pub fn parse(allocator: ?Allocator, value: Value, dest: *Parsed) schema.Error!void {
                            const alloc = allocator orelse return error.ExpectedAllocator;
                            var arr = (try value.asArray()).iterator();
                            while (try arr.next()) |child| {
                                const item = try child.asLeaky(T, allocator, .{});
                                const node = try alloc.create(Parsed.Node);
                                node.* = .{ .data = item };
                                dest.append(node);
                            }
                        }
                    });
                }
                pub fn EnumMap(comptime E: type, comptime V: type) CustomParser(_std.EnumMap(E, V)) {
                    const Parsed = _std.EnumMap(E, V);
                    return .from(struct {
                        pub const init: Parsed = .init(.{});
                        pub fn parse(allocator: ?Allocator, value: Value, dest: *Parsed) schema.Error!void {
                            const enum_schema = comptime resolveSchema(E, null);
                            var obj = (try value.asObject()).iterator();
                            while (try obj.next()) |field| {
                                const variant = try field.key.getTemporal();
                                const enum_literal = try parseEnumFromSlice(E, enum_schema, variant);
                                const enum_value = try field.value.asLeaky(V, allocator, .{});
                                dest.put(enum_literal, enum_value);
                            }
                        }
                    });
                }
                pub fn MultiArrayList(comptime T: type) CustomParser(_std.MultiArrayList(T)) {
                    const Parsed = _std.MultiArrayList(T);
                    return .from(struct {
                        pub const init: Parsed = .empty;
                        pub fn parse(allocator: ?Allocator, value: Value, dest: *Parsed) schema.Error!void {
                            const alloc = allocator orelse return error.ExpectedAllocator;
                            var arr = (try value.asArray()).iterator();
                            while (try arr.next()) |child| {
                                const item = try child.asLeaky(T, alloc, .{});
                                try dest.append(alloc, item);
                            }
                        }
                    });
                }
                pub fn SegmentedList(comptime T: type, comptime prealloc_item_count: usize) CustomParser(_std.SegmentedList(T, prealloc_item_count)) {
                    const Parsed = _std.SegmentedList(T, prealloc_item_count);
                    return .from(struct {
                        pub const init: Parsed = .{};
                        pub fn parse(allocator: ?Allocator, value: Value, dest: *Parsed) schema.Error!void {
                            const alloc = allocator orelse return error.ExpectedAllocator;
                            var arr = (try value.asArray()).iterator();
                            while (try arr.next()) |child| {
                                const item = try child.asLeaky(T, alloc, .{});
                                try dest.append(alloc, item);
                            }
                        }
                    });
                }
                pub fn SinglyLinkedList(comptime T: type) CustomParser(_std.SinglyLinkedList(T)) {
                    const Parsed = _std.SinglyLinkedList(T);
                    return .from(struct {
                        pub const init: Parsed = .{};
                        pub fn parse(allocator: ?Allocator, value: Value, dest: *Parsed) schema.Error!void {
                            const alloc = allocator orelse return error.ExpectedAllocator;
                            var arr = (try value.asArray()).iterator();
                            if (try arr.next()) |first| {
                                {
                                    const item = try first.asLeaky(T, allocator, .{});
                                    const node = try alloc.create(Parsed.Node);
                                    node.* = .{ .data = item };
                                    dest.prepend(node);
                                }
                                var head = dest.first.?;
                                while (try arr.next()) |child| {
                                    const item = try child.asLeaky(T, allocator, .{});
                                    const node = try alloc.create(Parsed.Node);
                                    node.* = .{ .data = item };
                                    head.insertAfter(node);
                                    head = head.next.?;
                                }
                            }
                        }
                    });
                }
                pub fn StringArrayHashMap(comptime V: type) CustomParser(_std.StringArrayHashMapUnmanaged(V)) {
                    const Parsed = _std.StringArrayHashMapUnmanaged(V);
                    return .from(struct {
                        pub const init: Parsed = .empty;
                        pub fn parse(allocator: ?Allocator, value: Value, dest: *Parsed) schema.Error!void {
                            const alloc = allocator orelse return error.ExpectedAllocator;
                            var obj = (try value.asObject()).iterator();
                            while (try obj.next()) |field| {
                                const key = try field.key.get();
                                const val = try field.value.asLeaky(V, alloc, .{});
                                try dest.put(alloc, key, val);
                            }
                        }
                    });
                }
                pub fn StringHashMap(comptime V: type) CustomParser(_std.StringHashMapUnmanaged(V)) {
                    const Parsed = _std.StringHashMapUnmanaged(V);
                    return .from(struct {
                        pub const init: Parsed = .empty;
                        pub fn parse(allocator: ?Allocator, value: Value, dest: *Parsed) schema.Error!void {
                            const alloc = allocator orelse return error.ExpectedAllocator;
                            var obj = (try value.asObject()).iterator();
                            while (try obj.next()) |field| {
                                const key = try field.key.get();
                                const val = try field.value.asLeaky(V, alloc, .{});
                                try dest.put(alloc, key, val);
                            }
                        }
                    });
                }
            };

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
                    rename: ?[]const u8 = null,
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
                        const field_schema = @field(S.fields, field.name);
                        if (field_schema.rename) |_| @compileError("Renamed fields are not supported in tuple struct '" ++ @typeName(T) ++ "'");
                        if (field_schema.skip) @compileError("Skipped fields are not supported in tuple struct '" ++ @typeName(T) ++ "'");
                        const sp = @field(fields_schema_parser, field.name);
                        if (sp[1]) |handler| @field(dest, field.name) = handler.init;
                    }
                    var array = (try value.asArray()).iterator();
                    inline for (fields) |field| {
                        if (try array.next()) |item| {
                            const sp = @field(fields_schema_parser, field.name);
                            try item.asAdvancedInner(field.type, sp[0], sp[1], allocator, &@field(dest, field.name));
                        } else {
                            return error.IncorrectType;
                        }
                    }
                    if (try array.next()) |_| return error.IncorrectType;
                    return dest;
                }
                const object = try value.asObject();
                var it = object.iterator();
                return parseStructWithObjectIterator(T, S, allocator, &it);
            }

            fn parseStructWithObjectIterator(comptime T: type, comptime S: schema.Struct(T), allocator: ?Allocator, it: *Object.Iterator) schema.Error!T {
                const fields = _std.meta.fields(T);
                const is_packed = @typeInfo(T).@"struct".layout == .@"packed";
                var dest = schema_utils.undefinedInit(T);
                const fields_schema_parser = makeFieldsSP(T, S, fields){};
                comptime var non_skipped_field_count: comptime_int = 0;
                inline for (fields) |field| {
                    const field_schema = @field(S.fields, field.name);
                    const sp = @field(fields_schema_parser, field.name);
                    if (sp[1]) |handler| @field(dest, field.name) = handler.init;
                    if (field_schema.skip) {
                        if (sp[1]) |_| {} else @compileError("Missing default value for skipped field '" ++ @typeName(T) ++ "." ++ field.name ++ "'");
                    } else {
                        non_skipped_field_count += 1;
                    }
                }
                if (non_skipped_field_count == 0) {
                    switch (S.on_unknown_field) {
                        .ignore => {},
                        .@"error" => if (try it.next()) |_| return error.UnknownField,
                        .handle => |handle| while (try it.next()) |field| try handle(allocator, try field.key.get(), field.value, &dest),
                    }
                    return dest;
                }
                if (S.assume_ordering) {
                    var prev_field_key: ?[]const u8 = null;
                    var prev_field_value: Value = undefined;
                    inline for (fields, 1..) |field, i| {
                        const field_schema = @field(S.fields, field.name);
                        if (field_schema.skip) continue;
                        const renamed_key: []const u8 = if (field_schema.rename) |rename| rename else comptime schema_utils.renameField(S.rename_all, field.name);
                        const field_value = brk: {

                            // handle the adjacent field after the previous queried field
                            if (prev_field_key) |prev_key| {
                                if (_std.mem.eql(u8, prev_key, renamed_key)) break :brk prev_field_value;
                                switch (S.on_unknown_field) {
                                    .ignore => {
                                        while (try it.next()) |next_field| {
                                            const next_field_key = try next_field.key.getTemporal();
                                            if (_std.mem.eql(u8, next_field_key, renamed_key)) break :brk next_field.value;
                                        }
                                        return error.MissingField;
                                    },
                                    .@"error" => return error.UnknownField,
                                    .handle => |handle| {
                                        prev_field_value.iter.cursor.document.string_buffer.advance(prev_key.len);
                                        try handle(allocator, prev_key, prev_field_value, &dest);
                                    },
                                }
                            }

                            // search for the first queried field ignoring previous unknown fields
                            if (S.on_unknown_field == .ignore) {
                                while (try it.next()) |next_field| {
                                    const next_field_key = try next_field.key.getTemporal();
                                    if (_std.mem.eql(u8, next_field_key, renamed_key)) break :brk next_field.value;
                                }
                                return error.MissingField;
                            }

                            // handle the first found field
                            if (try it.next()) |next_field| {
                                const field_key = try next_field.key.getTemporal();
                                if (_std.mem.eql(u8, field_key, renamed_key)) break :brk next_field.value;
                                switch (S.on_unknown_field) {
                                    .ignore => unreachable,
                                    .@"error" => return error.UnknownField,
                                    .handle => |handle| {
                                        next_field.value.iter.cursor.document.string_buffer.advance(field_key.len);
                                        try handle(allocator, field_key, next_field.value, &dest);
                                    },
                                }
                            } else {
                                return error.MissingField;
                            }
                        };
                        if (is_packed) {
                            const packed_field_value = try field_value.asLeaky(field.type, allocator, .{ .schema = field_schema.schema });
                            _std.mem.writePackedIntNative(field.type, _std.mem.asBytes(&dest), @bitOffsetOf(T, field.name), packed_field_value);
                        } else {
                            @field(dest, field.name) = try field_value.asLeaky(field.type, allocator, .{ .schema = field_schema.schema });
                        }
                        while (true) {
                            if (try it.next()) |next_field| {
                                const next_field_key = try next_field.key.getTemporal();
                                const next_field_value = next_field.value;
                                if (_std.mem.eql(u8, next_field_key, renamed_key)) {
                                    @branchHint(.unlikely);
                                    switch (S.on_duplicate_field) {
                                        .@"error" => return error.DuplicateField,
                                        .use_first => continue,
                                        .use_last => {
                                            next_field.value.iter.cursor.document.string_buffer.advance(next_field_key.len);
                                            if (is_packed) {
                                                const packed_field_value = try next_field_value.asLeaky(field.type, allocator, .{ .schema = field_schema.schema });
                                                _std.mem.writePackedIntNative(field.type, _std.mem.asBytes(&dest), @bitOffsetOf(T, field.name), packed_field_value);
                                            } else {
                                                @field(dest, field.name) = try next_field_value.asLeaky(field.type, allocator, .{ .schema = field_schema.schema });
                                            }
                                        },
                                        .handle => |handle| {
                                            next_field.value.iter.cursor.document.string_buffer.advance(next_field_key.len);
                                            try handle(allocator, next_field_key, next_field_value, &dest);
                                        },
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
                        .@"error" => if (try it.next()) |_| return error.UnknownField,
                        .handle => |handle| while (try it.next()) |field| try handle(allocator, try field.key.get(), field.value, &dest),
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
                        const renamed_key: []const u8 = if (field_schema.rename) |rename| rename else comptime schema_utils.renameField(S.rename_all, field.name);
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
                    while (try it.next()) |field| {
                        const key = try field.key.getTemporal();
                        const field_index = struct_map.getIndex(key) orelse switch (S.on_unknown_field) {
                            .ignore => continue,
                            .@"error" => return error.UnknownField,
                            .handle => |handle| {
                                field.value.iter.cursor.document.string_buffer.advance(key.len);
                                try handle(allocator, key, field.value, &dest);
                                continue;
                            },
                        };
                        const dispatch = struct_map.atIndex(field_index);
                        if (seen[field_index]) {
                            @branchHint(.unlikely);
                            switch (S.on_duplicate_field) {
                                .use_first => continue,
                                .use_last => {},
                                .@"error" => return error.DuplicateField,
                                .handle => |handle| {
                                    field.value.iter.cursor.document.string_buffer.advance(key.len);
                                    try handle(allocator, key, field.value, &dest);
                                    continue;
                                },
                            }
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

            inline fn makeFieldsSP(comptime T: type, comptime R: schema.Struct(T), comptime fields: []const _std.builtin.Type.StructField) type {
                comptime var tuple_fields: [fields.len]_std.builtin.Type.StructField = undefined;
                inline for (fields, &tuple_fields) |field, *tuple| {
                    const field_schema = @field(R.fields, field.name);
                    const S = comptime resolveSchema(field.type, field_schema.schema);
                    const P = comptime S.parse_with orelse CustomParser(field.type).infer();
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
                    renames: schema_utils.EnumFields(T) = .{},
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
                    const field_rename = @field(S.renames, field.name);
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
                    rename: ?[]const u8 = null,
                    schema: ?schema.Infer(T) = null,
                };
            }

            fn parseUnion(comptime T: type, comptime S: schema.Union(T), allocator: ?Allocator, value: Value) schema.Error!T {
                const string_index = value.iter.cursor.document.string_buffer.saveIndex();
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
                            const payload = value.asLeaky(field.type, allocator, .{ .schema = field_schema.schema }) catch {
                                value.iter.reset() catch |err| try value.iter.cursor.reportError(err);
                                value.iter.cursor.document.string_buffer.loadIndex(string_index);
                                break :inner;
                            };
                            return @unionInit(T, field.name, payload);
                        }
                    }

                    return error.UnknownUnionVariant;
                } else {
                    const tag_sch = brk: {
                        if (@typeInfo(T).@"union".tag_type) |tag_type| {
                            break :brk @as(?schema.Enum(tag_type), if (@hasDecl(tag_type, schema_identifier)) @field(tag_type, schema_identifier) else .{});
                        } else {
                            break :brk null;
                        }
                    };
                    comptime var dispatches_mut: [fields.len]struct { []const u8, UnionDispatch } = undefined;
                    inline for (fields, 0..) |field, i| {
                        const field_schema = @field(S.fields, field.name);
                        const renamed_variant: []const u8 = brk: {
                            const tag_rename: ?[]const u8 = if (tag_sch) |tag| if (@field(tag.renames, field.name)) |tag_rename| tag_rename else null else null;
                            if (tag_rename) |rename| break :brk rename;
                            break :brk if (field_schema.rename) |rename| rename else comptime schema_utils.renameField(S.rename_all, field.name);
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
                            var object = (try value.asObject()).iterator();
                            if (try object.next()) |content| {
                                const tag_key = try content.key.getTemporal();
                                const dispatch = union_map.get(tag_key) orelse return error.UnknownUnionVariant;
                                try dispatch.handle(allocator, content.value, &dest);
                            } else return error.MissingField;
                            if (try object.next()) |_| return error.IncorrectType;
                        },
                        .internally_tagged => |t| {
                            var object = (try value.asObject()).iterator();
                            if (try object.next()) |tag| {
                                const tag_key = try tag.key.getTemporal();
                                if (!_std.mem.eql(u8, tag_key, t)) return error.UnknownField;
                                const tag_value = try tag.value.asString().getTemporal();
                                const dispatch = union_map.get(tag_value) orelse return error.UnknownUnionVariant;
                                try dispatch.handle(allocator, value, &dest);
                            } else return error.MissingField;
                        },
                        .adjacently_tagged => |a| {
                            var object = (try value.asObject()).iterator();
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
                            const g = comptime resolveSchema(F.type, G);
                            assert(@typeInfo(F.type) == .@"struct");
                            var it: Object.Iterator = .{ .first = false, .iter = value.iter };
                            const payload = try parseStructWithObjectIterator(F.type, g, allocator, &it);
                            return @unionInit(T, F.name, payload);
                        } else {
                            const payload = try value.asLeaky(F.type, allocator, .{ .schema = G });
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
                    .float => return @floatCast(try value.asDouble()),
                    .bool => return value.asBool(),
                    .optional => |info| {
                        if (!isParseable(info.child)) @compileError("Unable to parse into type '" ++ @typeName(T) ++ "'");
                        if (try value.isNull()) {
                            return null;
                        } else {
                            const dest = try value.asLeaky(info.child, allocator, .{});
                            return dest;
                        }
                    },
                    .void => return if (try value.isNull()) {} else error.IncorrectType,
                    .array => |info| {
                        if (!isParseable(info.child)) @compileError("Unable to parse into type '" ++ @typeName(T) ++ "'");
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
                            var arr = (try value.asArray()).iterator();
                            var dest = schema_utils.undefinedInit(T);
                            for (0..info.len) |i| {
                                if (try arr.next()) |item| {
                                    dest[i] = try item.asLeaky(info.child, allocator, .{});
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
                        if (!isParseable(info.child)) @compileError("Unable to parse into type '" ++ @typeName(T) ++ "'");
                        var arr = (try value.asArray()).iterator();
                        var dest = schema_utils.undefinedInit(T);
                        for (0..info.len) |i| {
                            if (try arr.next()) |item| {
                                dest[i] = try item.asLeaky(info.child, allocator, .{});
                            } else {
                                return error.IncompleteArray;
                            }
                        }
                        if (try arr.next()) |_| return error.IncorrectType;
                        return dest;
                    },
                    .pointer => |info| {
                        if (!isParseable(info.child)) @compileError("Unable to parse into type '" ++ @typeName(T) ++ "'");
                        switch (@typeInfo(info.child)) {
                            .@"fn", .@"opaque" => @compileError("Unable to parse into type '" ++ @typeName(T) ++ "'"),
                            else => {},
                        }
                        switch (info.size) {
                            .one => {
                                const alloc = allocator orelse return error.ExpectedAllocator;
                                const r = try alloc.create(info.child);
                                errdefer alloc.destroy(r);

                                r.* = try value.asLeaky(info.child, alloc, .{});
                                return r;
                            },
                            .slice => {
                                if (info.child == u8 and S.bytes_as_string) {
                                    if (info.sentinel()) |_| @compileError("Unable to parse into type '" ++ @typeName(T) ++ "'");
                                    return try value.asString().getAdvanced(info.sentinel());
                                } else {
                                    const arr_parser = schema.std.ArrayList(info.child);
                                    var arr = arr_parser.init;
                                    try arr_parser.parse(allocator, value, &arr);
                                    const alloc = allocator orelse return error.ExpectedAllocator;
                                    if (info.sentinel()) |s| {
                                        return try arr.toOwnedSliceSentinel(alloc, s);
                                    } else {
                                        return try arr.toOwnedSlice(alloc);
                                    }
                                }
                            },
                            else => @compileError("Unable to parse into type '" ++ @typeName(T) ++ "'"),
                        }
                    },
                    else => @compileError("Unable to parse into type '" ++ @typeName(T) ++ "'"),
                }
            }

            inline fn isParseable(comptime T: type) bool {
                return switch (@typeInfo(T)) {
                    .type,
                    .noreturn,
                    .comptime_float,
                    .comptime_int,
                    .undefined,
                    .null,
                    .error_union,
                    .error_set,
                    .@"fn",
                    .@"opaque",
                    .frame,
                    .@"anyframe",
                    .enum_literal,
                    => false,
                    else => true,
                };
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
                    => S orelse if (@hasDecl(T, schema_identifier)) @field(T, schema_identifier) else .{},
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

const schema_utils = struct {
    const Map = @import("schema_map.zig").SchemaMap;

    const UnionRepresentation = union(enum) {
        untagged,
        externally_tagged,
        internally_tagged: []const u8,
        adjacently_tagged: struct {
            tag: []const u8,
            content: []const u8,
        },
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
    fn renameField(case: FieldsRenaming, name: []const u8) []const u8 {
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

    fn EnumFields(comptime T: type) type {
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
            switch (@typeInfo(field.type)) {
                .optional => @field(result, field.name) = null,
                else => {
                    const default_value: *field.type = @constCast(@alignCast(@ptrCast(
                        field.default_value_ptr orelse continue,
                    )));
                    @field(result, field.name) = default_value.*;
                },
            }
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

    const StandardDataStructure = union(enum) {
        array_list: struct { type },
        array_list_aligned: struct { type, ?u29 },
        // bit_stack,
        // buf_map,
        // buf_set,
        bounded_array: struct { type, usize },
        bounded_array_aligned: struct { type, u29, usize },
        enum_map: struct { type, type },
        singly_linked_list: struct { type },
        doubly_linked_list: struct { type },
        multi_array_list: struct { type },
        segmented_list: struct { type, usize },
        string_array_hash_map: struct { type },
        string_hash_map: struct { type },

        pub fn infer(comptime T: type) ?@This() {
            switch (@typeInfo(T)) {
                .@"struct" => {},
                else => return null,
            }

            // if (T == std.BitStack) return .bit_stack;

            // if (T == std.BufMap) return .buf_map;

            // if (T == std.BufSet) return .buf_set;

            if (@hasDecl(T, "Slice")) {
                switch (@typeInfo(@field(T, "Slice"))) {
                    .pointer => |info| {
                        if (info.size == .slice) {
                            const child = info.child;
                            if (T == std.ArrayListUnmanaged(child))
                                return .{ .array_list = .{child} };
                            if (T == std.ArrayListAlignedUnmanaged(child, info.alignment))
                                return .{ .array_list_aligned = .{ child, info.alignment } };
                        }
                    },
                    else => {},
                }
            }

            if (@hasDecl(T, "Node")) {
                const Node = @field(T, "Node");
                if (@typeInfo(Node) == .@"struct" and @hasField(Node, "data")) {
                    const child = @FieldType(Node, "data");
                    if (T == std.SinglyLinkedList(child))
                        return .{ .singly_linked_list = .{child} };
                    if (T == std.DoublyLinkedList(child))
                        return .{ .doubly_linked_list = .{child} };
                }
            }

            if (@hasDecl(T, "KV")) {
                const KV = @field(T, "KV");
                if (@typeInfo(KV) == .@"struct" and @hasField(KV, "value")) {
                    const V = @FieldType(KV, "value");
                    if (T == std.StringHashMapUnmanaged(V))
                        return .{ .string_hash_map = .{V} };
                    if (T == std.StringArrayHashMapUnmanaged(V))
                        return .{ .string_array_hash_map = .{V} };
                }
            }

            if (@hasField(T, "buffer")) {
                const buffer = @FieldType(T, "buffer");
                switch (@typeInfo(buffer)) {
                    .array => |info| {
                        const buffer_capacity = info.len;
                        const child = info.child;
                        // if T == std.BoundedArrayAligned(sth aligned at 4, 32, ...), @alignOf(child) == 4 but wanted 32
                        // that is why I search for it in the constSlice function
                        const constSlice = @TypeOf(@field(T, "constSlice"));
                        switch (@typeInfo(constSlice)) {
                            .@"fn" => |fn_info| {
                                if (fn_info.return_type) |return_type| {
                                    const alignment = std.meta.alignment(return_type);
                                    if (T == std.BoundedArray(child, buffer_capacity))
                                        return .{ .bounded_array = .{ child, buffer_capacity } };
                                    if (T == std.BoundedArrayAligned(child, alignment, buffer_capacity))
                                        return .{ .bounded_array_aligned = .{ child, alignment, buffer_capacity } };
                                }
                            },
                            else => {},
                        }
                    },
                    else => {},
                }
            }

            if (@hasDecl(T, "Value") and @hasDecl(T, "Key")) {
                const E = @field(T, "Key");
                const V = @field(T, "Value");
                if (T == std.EnumMap(E, V)) return .{ .enum_map = .{ E, V } };
            }

            if (@hasField(T, "prealloc_segment")) {
                const prealloc_segment = @FieldType(T, "prealloc_segment");
                switch (@typeInfo(prealloc_segment)) {
                    .array => |info| {
                        if (T == std.SegmentedList(info.child, info.len))
                            return .{ .segmented_list = .{ info.child, info.len } };
                    },
                    else => {},
                }
            }

            if (@hasDecl(T, "get")) {
                const get = @TypeOf(@field(T, "get"));
                switch (@typeInfo(get)) {
                    .@"fn" => |info| {
                        if (info.return_type) |return_type| {
                            if (T == std.MultiArrayList(return_type))
                                return .{ .multi_array_list = .{return_type} };
                        }
                    },
                    else => {},
                }
            }

            return null;
        }
    };
};
