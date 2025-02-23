// TODO: add dev_checks
const std = @import("std");
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

        pub const Error = Tokens.Error || types.ParseError || Allocator.Error || error{
            ExpectedAllocator,
            IncorrectSchema,
            UnknownField,
            UnknownEnum,
        } || if (Reader) |reader| reader.Error else error{};
        pub const max_capacity_bound = if (want_stream) std.math.maxInt(usize) else std.math.maxInt(u32);
        pub const default_max_depth = 1024;

        allocator: if (want_stream) ?Allocator else Allocator,
        document_buffer: if (need_document_buffer) std.ArrayListAligned(u8, types.Aligned(true).alignment) else void,

        strings: types.BoundedArrayListUnmanaged(u8, max_capacity_bound),

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
            self.cursor.strings = self.strings.items().ptr;
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
            self.cursor.strings = self.strings.items().ptr;
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
            strings: [*]u8 = undefined,
            depth: u32 = 1,
            root: usize = undefined,
            err: ?Error = null,

            pub fn init(allocator: if (want_stream) ?Allocator else Allocator) Cursor {
                return .{
                    .tokens = if (want_stream) .init else .init(allocator),
                };
            }

            pub fn deinit(self: *Cursor) void {
                self.tokens.deinit();
            }

            const position_size = if (want_stream) 1 else @sizeOf(u32);

            inline fn position(self: Cursor) usize {
                return self.tokens.position();
            }

            inline fn offset(self: Cursor) usize {
                return self.tokens.offset();
            }

            inline fn next(self: *Cursor) Error![*]const u8 {
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
                        '"' => if (self.peekChar() == ':') {
                            try Logger.log(self.document, ptr, "key   ", self.depth);
                            _ = try self.next();
                        } else {
                            try Logger.log(self.document, ptr, "skip  ", self.depth);
                            self.depth -= 1;
                            if (self.depth <= parent_depth) return;
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
                    else => unreachable,
                });
            }

            inline fn reportError(self: *Cursor, err: Error) Error!void {
                self.err = err;
                return err;
            }
        };

        pub const Document = struct {
            iter: Value.Iterator,
            err: ?Error = null,

            pub inline fn asValue(self: Document) Value {
                return .{ .iter = self.iter, .err = self.err };
            }

            pub inline fn asObject(self: Document) Error!Object {
                if (self.err) |err| return err;
                return Object.startRoot(self.iter);
            }

            pub inline fn asArray(self: Document) Error!Array {
                if (self.err) |err| return err;
                return Array.startRoot(self.iter);
            }

            pub inline fn asNumber(self: Document) Error!Number {
                if (self.err) |err| return err;
                return self.iter.asRootNumber();
            }

            pub inline fn asUnsigned(self: Document) Error!u64 {
                if (self.err) |err| return err;
                return self.iter.asRootUnsigned();
            }

            pub inline fn asSigned(self: Document) Error!i64 {
                if (self.err) |err| return err;
                return self.iter.asRootSigned();
            }

            pub inline fn asFloat(self: Document) Error!f64 {
                if (self.err) |err| return err;
                return self.iter.asRootFloat();
            }

            pub inline fn asString(self: Document) String {
                if (self.err) |err| return .{
                    .iter = self.iter,
                    .raw_str = undefined,
                    .err = err,
                };
                return self.iter.asRootString() catch |err| .{
                    .iter = self.iter,
                    .raw_str = undefined,
                    .err = err,
                };
            }

            pub inline fn asBool(self: Document) Error!bool {
                if (self.err) |err| return err;
                return self.iter.asRootBool();
            }

            pub inline fn isNull(self: Document) Error!bool {
                if (self.err) |err| return err;
                return self.iter.isRootNull();
            }

            pub inline fn asAny(self: Document) Error!AnyValue {
                if (self.err) |err| return err;
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

            pub inline fn as(self: Document, comptime T: type) Error!T {
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
                        if (T == []const u8) return self.asString() else @compileError(std.fmt.comptimePrint("it is not possible to automatically cast a JSON value to type {s}", .{@typeName(T)}));
                    },
                }
            }

            pub inline fn skip(self: Document) Error!void {
                if (self.err) |err| return err;
                return self.iter.skipChild();
            }

            pub inline fn at(self: Document, ptr: anytype) Value {
                @setEvalBranchQuota(2000000);
                if (self.err) |_| return .{ .iter = self.iter };

                const query = brk: {
                    if (common.isString(@TypeOf(ptr))) {
                        const obj = self.startOrResumeObject() catch |err| return .{ .iter = self.iter, .err = err };
                        break :brk obj.at(ptr);
                    }
                    if (common.isIndex(@TypeOf(ptr))) {
                        const arr = self.startOrResumeArray() catch |err| return .{ .iter = self.iter, .err = err };
                        break :brk arr.at(ptr);
                    }
                    @compileError(common.error_messages.at_type);
                };
                return query;
            }

            inline fn startOrResumeObject(self: Document) Error!Object {
                if (self.iter.isAtRoot()) {
                    return self.asObject();
                }
                return .{ .iter = self.iter };
            }

            inline fn startOrResumeArray(self: Document) Error!Array {
                if (self.iter.isAtRoot()) {
                    return self.asArray();
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
                    const n = try self.parseNumber(try self.peekNonRootScalar());
                    try self.advanceNonRootScalar();
                    return n;
                }

                inline fn asUnsigned(self: Iterator) Error!u64 {
                    const n = try self.parseUnsigned(try self.peekNonRootScalar());
                    try self.advanceNonRootScalar();
                    return n;
                }

                inline fn asSigned(self: Iterator) Error!i64 {
                    const n = try self.parseSigned(try self.peekNonRootScalar());
                    try self.advanceNonRootScalar();
                    return n;
                }

                inline fn asFloat(self: Iterator) Error!f64 {
                    const n = try self.parseFloat(try self.peekNonRootScalar());
                    try self.advanceNonRootScalar();
                    return n;
                }

                inline fn asString(self: Iterator) Error!String {
                    const raw_str = try self.peekNonRootScalar();
                    if (raw_str[0] != '"') return error.IncorrectType;
                    const str = String{
                        .iter = self,
                        .raw_str = raw_str,
                    };
                    try self.advanceNonRootScalar();
                    return str;
                }

                inline fn asBool(self: Iterator) Error!bool {
                    const is_true = try self.parseBool(try self.peekNonRootScalar());
                    try self.advanceNonRootScalar();
                    return is_true;
                }

                inline fn isNull(self: Iterator) Error!bool {
                    var is_null = false;
                    if (self.parseNull(try self.peekNonRootScalar())) {
                        is_null = true;
                        try self.advanceNonRootScalar();
                    } else |err| switch (err) {
                        error.ExpectedValue => {},
                        else => return err,
                    }
                    return is_null;
                }

                inline fn asRootNumber(self: Iterator) Error!Number {
                    const n = try self.parseNumber(try self.peekRootScalar());
                    try self.advanceRootScalar();
                    return n;
                }

                inline fn asRootUnsigned(self: Iterator) Error!u64 {
                    const n = try self.parseUnsigned(try self.peekRootScalar());
                    try self.advanceRootScalar();
                    return n;
                }

                inline fn asRootSigned(self: Iterator) Error!i64 {
                    const n = try self.parseSigned(try self.peekRootScalar());
                    try self.advanceRootScalar();
                    return n;
                }

                inline fn asRootFloat(self: Iterator) Error!f64 {
                    const n = try self.parseFloat(try self.peekRootScalar());
                    try self.advanceRootScalar();
                    return n;
                }

                inline fn asRootString(self: Iterator) Error!String {
                    const raw_str = try self.peekRootScalar();
                    if (raw_str[0] != '"') return error.IncorrectType;
                    const str = String{
                        .iter = self,
                        .raw_str = raw_str,
                    };
                    try self.advanceRootScalar();
                    return str;
                }

                inline fn asRootBool(self: Iterator) Error!bool {
                    const is_true = try self.parseBool(try self.peekRootScalar());
                    try self.advanceRootScalar();
                    return is_true;
                }

                inline fn isRootNull(self: Iterator) Error!bool {
                    var is_null = false;
                    if (self.parseNull(try self.peekRootScalar())) {
                        is_null = true;
                        try self.advanceRootScalar();
                    } else |err| switch (err) {
                        error.ExpectedValue => {},
                        else => return err,
                    }
                    return is_null;
                }

                fn parseNumber(self: Iterator, ptr: [*]const u8) Error!Number {
                    try Logger.log(self.cursor.document, ptr, "number", self.start_depth);
                    return @import("parsers/number/parser.zig").parse(null, ptr);
                }

                fn parseUnsigned(self: Iterator, ptr: [*]const u8) Error!u64 {
                    try Logger.log(self.cursor.document, ptr, "u64   ", self.start_depth);
                    const n = try @import("parsers/number/parser.zig").parse(.unsigned, ptr);
                    return n.unsigned;
                }

                fn parseSigned(self: Iterator, ptr: [*]const u8) Error!i64 {
                    try Logger.log(self.cursor.document, ptr, "i64   ", self.start_depth);
                    const n = try @import("parsers/number/parser.zig").parse(.signed, ptr);
                    return n.signed;
                }

                fn parseFloat(self: Iterator, ptr: [*]const u8) Error!f64 {
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
                    try Logger.log(self.cursor.document, ptr, "bool  ", self.start_depth);
                    const check = @import("parsers/atoms.zig").checkBool;
                    return check(ptr);
                }

                inline fn parseNull(self: Iterator, ptr: [*]const u8) Error!void {
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

                inline fn isAtRoot(self: Iterator) bool {
                    return self.cursor.position() == self.cursor.root;
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
                    return common.tables.is_whitespace[self.cursor.peekChar()];
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

                inline fn startObject(self: Iterator) Error!Iterator {
                    const iter = try self.startContainer('{');
                    _ = try self.startedObject();
                    return iter;
                }

                inline fn startRootObject(self: Iterator) Error!Iterator {
                    const iter = try self.startContainer('{');
                    _ = try self.startedRootObject();
                    return iter;
                }

                inline fn startedObject(self: Iterator) Error!bool {
                    self.assertAtContainerStart();
                    if (self.cursor.peekChar() == '}') {
                        const ptr = try self.cursor.next();
                        self.endContainer();
                        try Logger.log(self.cursor.document, ptr, "object", self.start_depth);
                        return false;
                    }
                    return true;
                }

                inline fn startedRootObject(self: Iterator) Error!bool {
                    self.assertAtContainerStart();
                    if (self.cursor.peekChar() == '}') {
                        const ptr = try self.cursor.next();
                        self.endContainer();
                        try Logger.log(self.cursor.document, ptr, "object", self.start_depth);
                        if (try self.isAtEnd()) return false;
                        return error.TrailingContent;
                    }
                    return true;
                }

                inline fn startArray(self: Iterator) Error!Iterator {
                    const iter = try self.startContainer('[');
                    _ = try self.startedArray();
                    return iter;
                }

                inline fn startRootArray(self: Iterator) Error!Iterator {
                    const iter = try self.startContainer('[');
                    _ = try self.startedRootArray();
                    return iter;
                }

                inline fn startedArray(self: Iterator) Error!bool {
                    self.assertAtContainerStart();
                    if (self.cursor.peekChar() == ']') {
                        const ptr = try self.cursor.next();
                        self.endContainer();
                        try Logger.log(self.cursor.document, ptr, "array ", self.start_depth);
                        return false;
                    }
                    return true;
                }

                inline fn startedRootArray(self: Iterator) Error!bool {
                    self.assertAtContainerStart();
                    if (self.cursor.peekChar() == ']') {
                        const ptr = try self.cursor.next();
                        self.endContainer();
                        try Logger.log(self.cursor.document, ptr, "array ", self.start_depth);
                        if (try self.isAtEnd()) return false;
                        return error.TrailingContent;
                    }
                    return true;
                }

                inline fn startContainer(self: Iterator, start_char: u8) Error!Iterator {
                    if (self.isAtStart()) {
                        self.assertAtStart();
                        if (self.cursor.peekChar() != start_char) return error.IncorrectType;
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
                        // if (!self.isAtContainerStart()) return error.OutOfOrderIteration;
                        if (self.start_char != start_char) return error.IncorrectType;
                        return self;
                    }
                }

                inline fn peekNonRootScalar(self: Iterator) Error![*]const u8 {
                    // if (!self.isAtStart()) return error.OutOfOrderIteration;
                    self.assertAtNonRootStart();
                    return self.cursor.peek();
                }

                inline fn peekRootScalar(self: Iterator) Error![*]const u8 {
                    // if (!self.isAtStart()) return error.OutOfOrderIteration;
                    self.assertAtRoot();
                    return self.cursor.peek();
                }

                inline fn advanceNonRootScalar(self: Iterator) Error!void {
                    if (!self.isAtStart()) return;
                    self.assertAtNonRootStart();
                    _ = try self.cursor.next();
                    self.cursor.ascend(self.start_depth - 1);
                }

                inline fn advanceRootScalar(self: Iterator) Error!void {
                    if (!self.isAtStart()) return;
                    self.assertAtRoot();
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
                    // TODO: important dev checks
                    const at_first = self.isAtFirstField();
                    var has_value = false;
                    var search_start = self.cursor.position();
                    if (at_first) {
                        has_value = true;
                    } else if (self.isOpen()) {
                        try self.skipChild();
                        has_value = try self.hasNextField();
                    } else {
                        try self.skipChild();
                        if (unordered) search_start = self.cursor.position();
                        has_value = try self.hasNextField();
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
                return Object.start(self.iter);
            }

            pub inline fn asArray(self: Value) Error!Array {
                if (self.err) |err| return err;
                return Array.start(self.iter);
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
                if (self.err) |err| return err;
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
                    else => {
                        return error.ExpectedValue;
                    },
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

            pub inline fn as(self: Value, comptime T: type) Error!T {
                var dest: T = undefined;
                try self.asRef(T, &dest);
                return dest;
            }

            pub inline fn asAdvanced(self: Value, comptime T: type, comptime S: ?schema.Auto(T), allocator: ?Allocator) Error!T {
                var dest: T = undefined;
                try self.asRefAdvanced(T, S, allocator, &dest);
                return dest;
            }

            pub inline fn asRef(self: Value, comptime T: type, dest: *T) Error!void {
                return self.asRefAdvanced(T, null, null, dest);
            }

            pub inline fn asRefAdvanced(self: Value, comptime T: type, comptime S: ?schema.Auto(T), allocator: ?Allocator, dest: *T) Error!void {
                const info = @typeInfo(T);
                dest.* = brk: switch (info) {
                    .int => {
                        const n = try self.asNumber();
                        break :brk switch (n) {
                            .float => return error.IncorrectType,
                            inline else => break :brk n.cast(T) orelse return error.NumberOutOfRange,
                        };
                    },
                    .float => break :brk @floatCast(try self.asFloat()),
                    .bool => break :brk try self.asBool(),
                    .optional => |opt| {
                        if (try self.isNull()) break :brk null;
                        const child = try self.as(opt.child);
                        break :brk child;
                    },
                    .null => {
                        if (try self.isNull()) break :brk null;
                        return error.IncorrectType;
                    },
                    .@"struct" => {
                        if (T == String) break :brk self.asString();
                        return schema.parseStruct(T, S, allocator, self, dest);
                    },
                    // .@"union" => {
                    //     if (T == Number) break :brk try self.asNumber();
                    //     return schema.parseUnion(T, S, allocator, self, dest);
                    // },
                    .@"enum" => {
                        return schema.parseEnum(T, S, allocator, self, dest);
                    },
                    else => {
                        if (T == []const u8) break :brk try self.asString().get() else @compileError(std.fmt.comptimePrint("it is not possible to automatically cast a JSON value to type {s}", .{@typeName(T)}));
                    },
                };
            }

            pub inline fn skip(self: Value) Error!void {
                if (self.err) |err| return err;
                return self.iter.skipChild();
            }

            pub inline fn at(self: Value, ptr: anytype) Value {
                @setEvalBranchQuota(2000000);
                if (common.isString(@TypeOf(ptr))) {
                    return self.atKey(ptr);
                } else if (common.isIndex(@TypeOf(ptr))) {
                    return self.atIndex(ptr);
                }
                @compileError(common.error_messages.at_type);
            }

            inline fn atKey(self: Value, key: []const u8) Value {
                if (self.err) |_| return self;
                const obj = self.startOrResumeObject() catch |err| return .{ .iter = self.iter, .err = err };
                return obj.at(key);
            }

            inline fn atIndex(self: Value, index: usize) Value {
                if (self.err) |_| return self;
                const arr = self.startOrResumeArray() catch |err| return .{ .iter = self.iter, .err = err };
                return arr.at(index);
            }

            inline fn startOrResumeObject(self: Value) Error!Object {
                if (self.iter.isAtStart()) {
                    return self.asObject();
                }
                return .{ .iter = self.iter };
            }

            inline fn startOrResumeArray(self: Value) Error!Array {
                if (self.iter.isAtStart()) {
                    return self.asArray();
                }
                return .{ .iter = self.iter };
            }
        };

        const String = struct {
            iter: Value.Iterator,
            raw_str: [*]const u8,
            err: ?Error = null,

            pub inline fn get(self: String) Error![]const u8 {
                if (self.err) |err| return err;

                // if (want_stream) {
                //     if (self.iter.cursor.document.allocator) |alloc|
                //         try self.iter.cursor.document.strings.ensureUnusedCapacity(alloc, options.stream.?.chunk_length)
                //     else
                //         return error.ExpectedAllocator;
                // }
                const str = try self.iter.parseString(self.raw_str, self.iter.cursor.strings);
                self.iter.cursor.strings += str.len;
                return str;
            }

            pub inline fn write(self: String, dest: []u8) Error![]const u8 {
                if (self.err) |err| return err;

                const str = try self.iter.parseString(self.raw_str, dest.ptr);
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

            inline fn start(iter: Value.Iterator) Error!Array {
                return .{ .iter = try iter.startArray() };
            }

            inline fn startRoot(iter: Value.Iterator) Error!Array {
                return .{ .iter = try iter.startRootArray() };
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

            inline fn start(iter: Value.Iterator) Error!Object {
                return .{ .iter = try iter.startObject() };
            }

            inline fn startRoot(iter: Value.Iterator) Error!Object {
                return .{ .iter = try iter.startRootObject() };
            }

            pub inline fn at(self: Object, key: []const u8) Value {
                return self.atRaw(key, false);
            }

            pub inline fn atUnordered(self: Object, key: []const u8) Value {
                return self.atRaw(key, true);
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
            const inner = @import("std");

            pub const std = struct {
                pub fn ArrayList(comptime T: type) type {
                    return struct {
                        pub fn parse(allocator: ?Allocator, value: Value, dest: *inner.ArrayList(T)) Error!void {
                            if (allocator) |alloc| {
                                dest.* = .init(alloc);
                                const arr = try value.asArray();
                                while (try arr.next()) |child| {
                                    const item = try child.as(T);
                                    try dest.append(item);
                                }
                            } else {
                                return error.ExpectedAllocator;
                            }
                        }
                    };
                }
                pub fn ArrayListUnmanaged(comptime T: type) type {
                    return struct {
                        pub fn parse(allocator: ?Allocator, value: Value, dest: *inner.ArrayListUnmanaged(T)) Error!void {
                            if (allocator) |alloc| {
                                dest.* = .empty;
                                const arr = try value.asArray();
                                while (try arr.next()) |child| {
                                    const item = try child.as(T);
                                    try dest.append(alloc, item);
                                }
                            } else {
                                return error.ExpectedAllocator;
                            }
                        }
                    };
                }
            };

            pub fn Auto(comptime T: type) type {
                return switch (@typeInfo(T)) {
                    .@"struct" => schema.Struct(T),
                    .@"enum" => schema.Enum(T),
                    else => struct {
                        parse_with: fn (allocator: ?Allocator, value: Value, dest: *T) Error!void,
                    },
                };
            }

            pub fn Struct(comptime T: type) type {
                return struct {
                    assume_ordering: bool = false,
                    ignore_unknown_fields: bool = true,
                    duplicate_field_behavior: schema_utils.DuplicateField = .@"error", // TODO

                    parse_with: ?fn (allocator: ?Allocator, value: Value, dest: *T) Error!void = null,
                    rename_all: schema_utils.FieldsRenaming = .snake_case,
                    fields: StructFields(T) = .{},
                };
            }

            pub fn StructFields(comptime T: type) type {
                assert(@typeInfo(T) == .@"struct");
                const fields = inner.meta.fields(T);
                comptime var schema_fields: [fields.len]inner.builtin.Type.StructField = undefined;
                for (0..fields.len) |i| {
                    const field = fields[i];
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

            pub fn StructField(comptime T: type) type {
                return struct {
                    alias: ?[]const u8 = null,
                    skip: bool = false,
                    schema: ?schema.Auto(T) = null,
                };
            }

            fn parseStruct(comptime T: type, comptime S: ?schema.Struct(T), allocator: ?Allocator, value: Value, dest: *T) Error!void {
                const sch: schema.Struct(T) =
                    if (S) |s| s else if (@hasDecl(T, options.schema_identifier)) @field(T, options.schema_identifier) else .{};
                const fields = inner.meta.fields(@TypeOf(sch.fields));
                if (sch.parse_with) |customParseFn| {
                    try customParseFn(allocator, value, dest);
                    return;
                }
                const object = try value.asObject();
                if (sch.assume_ordering) {
                    inline for (fields) |field| {
                        const field_opts = @field(sch.fields, field.name);
                        if (field_opts.skip) continue;
                        const renamed_key: []const u8 = if (field_opts.alias) |alias| alias else comptime schema_utils.renameField(sch.rename_all, field.name);
                        const field_value = object.at(renamed_key);
                        const field_ty = @FieldType(T, field.name);
                        try AutoParser(field_ty, field_opts.schema).parse(allocator, field_value, &@field(dest, field.name));
                    }
                } else {
                    comptime var dispatches_mut: [fields.len]struct { []const u8, Dispatch } = undefined;
                    inline for (fields, 0..) |field, i| {
                        const field_opts = @field(sch.fields, field.name);
                        const field_ty = @FieldType(T, field.name);
                        const renamed_key: []const u8 = if (field_opts.alias) |alias| alias else comptime schema_utils.renameField(sch.rename_all, field.name);
                        dispatches_mut[i] = .{ renamed_key, .{
                            .offset = @offsetOf(T, field.name),
                            .parse_fn = if (field_opts.skip) skip else AutoParser(field_ty, field_opts.schema).parseTypeErased,
                        } };
                    }
                    const dispatches = dispatches_mut;
                    const struct_map = comptime schema_utils.Map(Dispatch, &dispatches);
                    while (try object.next()) |field| {
                        const key = try field.key.get();
                        const dispatch = struct_map.get(key) orelse if (sch.ignore_unknown_fields) continue else return error.UnknownField;
                        try dispatch.parse_fn(allocator, field.value, @ptrFromInt(@intFromPtr(dest) + dispatch.offset));
                    }
                }
            }

            pub fn Enum(comptime T: type) type {
                return struct {
                    parse_with: ?fn (allocator: ?Allocator, value: Value, dest: *T) Error!void = null,
                    rename_all: schema_utils.FieldsRenaming = .snake_case,
                    aliases: schema_utils.EnumFields(T) = .{},
                };
            }

            fn parseEnum(comptime T: type, comptime S: ?schema.Enum(T), allocator: ?Allocator, value: Value, dest: *T) Error!void {
                const sch: schema.Enum(T) =
                    if (S) |s| s else if (@hasDecl(T, options.schema_identifier)) @field(T, options.schema_identifier) else .{};
                if (sch.parse_with) |customParseFn| {
                    try customParseFn(allocator, value, dest);
                    return;
                }
                const fields = inner.meta.fields(T);
                comptime var dispatches_mut: [fields.len]struct { []const u8, T } = undefined;
                inline for (fields, 0..) |field, i| {
                    const field_rename = @field(sch.aliases, field.name);
                    const renamed_key: []const u8 = if (field_rename) |rename| rename else comptime schema_utils.renameField(sch.rename_all, field.name);
                    dispatches_mut[i] = .{ renamed_key, @field(T, field.name) };
                }
                const dispatches = dispatches_mut;
                const enum_map = comptime schema_utils.Map(T, &dispatches);
                const str = try value.asString().get();
                const enum_literal = enum_map.get(str) orelse return error.UnknownEnum;
                dest.* = enum_literal;
            }

            fn skip(_: ?Allocator, value: Value, _: *anyopaque) Error!void {
                return value.skip();
            }

            const Dispatch = struct {
                offset: usize,
                parse_fn: *const fn (?Allocator, Value, *anyopaque) Error!void,
            };

            fn AutoParser(comptime T: type, comptime S: ?schema.Auto(T)) type {
                return struct {
                    pub fn parse(allocator: ?Allocator, value: Value, dest: *T) Error!void {
                        if (S) |s| {
                            if (@typeInfo(T) == .@"struct") return parseStruct(T, S, allocator, value, dest);
                            if (@typeInfo(T) == .@"enum") return parseEnum(T, S, allocator, value, dest);
                            return s.parse_with(allocator, value, dest);
                        } else {
                            try value.asRef(T, dest);
                        }
                    }

                    pub fn parseTypeErased(allocator: ?Allocator, value: Value, dest: *anyopaque) Error!void {
                        const typed_dest: *T = @alignCast(@ptrCast(dest));
                        return @This().parse(allocator, value, typed_dest);
                    }
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

    const DuplicateField = enum {
        use_first,
        @"error",
        use_last,
    };

    pub fn renameField(case: FieldsRenaming, name: []const u8) []const u8 {
        const name_copy = std.fmt.comptimePrint("{s}", .{name});
        var output = name_copy.*;
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
        for (0..fields.len) |i| {
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
};
