// TODO: agregar dev_checks
// TODO: agregar algun logger bien hecho
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

        pub const Error = Tokens.Error || types.ParseError || Allocator.Error || error{ExpectedAllocator};
        pub const max_capacity_bound = if (want_stream) std.math.maxInt(usize) else std.math.maxInt(u32);
        pub const default_max_depth = 1024;

        allocator: if (want_stream) ?Allocator else Allocator,
        document_buffer: if (need_document_buffer) std.ArrayListAligned(u8, types.Aligned(true).alignment) else void,

        tokens: Tokens,
        strings: types.BoundedArrayListUnmanaged(u8, max_capacity_bound),
        cursor: Cursor = undefined,

        max_capacity: usize,
        max_depth: usize,
        capacity: usize,

        pub fn init(allocator: if (want_stream) ?Allocator else Allocator) Self {
            return .{
                .allocator = allocator,
                .document_buffer = if (need_document_buffer) .init(allocator) else {},
                .tokens = if (want_stream) .init else .init(allocator),
                .strings = .empty,
                .max_capacity = max_capacity_bound,
                .max_depth = default_max_depth,
                .capacity = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self.tokens.deinit();
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
                try self.tokens.ensureTotalCapacity(new_capacity);
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
                try self.tokens.build(self.document_buffer.items[0..len]);
            } else {
                if (!want_stream) try self.ensureTotalCapacity(document.len);
                try self.tokens.build(document);
            }
            self.strings.list.clearRetainingCapacity();
            self.cursor = .{ .document = self };
            return .{
                .iter = .{
                    .cursor = &self.cursor,
                    .start_position = 0,
                    .start_depth = 1,
                    .start_char = try self.cursor.peekChar(),
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
                try self.tokens.build(self.document_buffer.items[0..len]);
            } else {
                if (!want_stream) if (document.len > self.capacity) return error.ExceededCapacity;
                try self.tokens.build(document);
            }
            self.strings.list.clearRetainingCapacity();
            self.cursor = .{ .document = self };
            return .{
                .iter = .{
                    .cursor = &self.cursor,
                    .start_position = 0,
                    .start_depth = 1,
                    .start_char = try self.cursor.peekChar(),
                },
            };
        }

        pub const Element = union(types.ElementType) {
            null,
            bool: bool,
            number: Number,
            string: String,
            object: Object,
            array: Array,
        };

        const Cursor = struct {
            document: *Self,
            position: usize = 0,
            depth: u32 = 1,
            err: ?Error = null,

            fn tokens(self: Cursor) *Tokens {
                return &self.document.tokens;
            }

            fn next(self: *Cursor) Error![*]const u8 {
                if (self.err) |err| return err;

                defer self.position += 1;
                return self.tokens().next();
            }

            fn peekChar(self: *Cursor) Error!u8 {
                return self.tokens().peekChar();
            }

            fn peek(self: *Cursor) Error![*]const u8 {
                return self.tokens().peek();
            }

            fn ascend(self: *Cursor, parent_depth: u32) void {
                assert(0 <= parent_depth and parent_depth < self.document.max_depth - 1);
                assert(self.depth == parent_depth + 1);
                self.depth = parent_depth;
            }

            fn descend(self: *Cursor, child_depth: u32) void {
                assert(1 <= child_depth and child_depth < self.document.max_depth);
                assert(self.depth == child_depth - 1);
                self.depth = child_depth;
            }

            fn skip(self: *Cursor, parent_depth: u32, parent_char: u8) Error!void {
                // Logger.logDepth(parent_depth, self.depth);

                if (self.depth <= parent_depth) return;
                switch ((try self.next())[0]) {
                    '[', '{', ':' => {
                        // Logger.logStart(self.document.*, "skip  ", self.depth);
                    },
                    ',' => {
                        // Logger.log(self.document.*, "skip  ", self.depth);
                    },
                    ']', '}' => {
                        // Logger.logEnd(self.document.*, "skip  ", self.depth);
                        self.depth -= 1;
                        if (self.depth <= parent_depth) return;
                    },
                    '"' => if (try self.peekChar() == ':') {
                        // Logger.log(self.document.*, "key   ", self.depth);
                        _ = try self.next();
                    } else {
                        // Logger.log(self.document.*, "skip  ", self.depth);
                        self.depth -= 1;
                        if (self.depth <= parent_depth) return;
                    },
                    else => {
                        // Logger.log(self.document.*, "skip  ", self.depth);
                        self.depth -= 1;
                        if (self.depth <= parent_depth) return;
                    },
                }

                brk: while (true) {
                    switch ((try self.next())[0]) {
                        '[', '{' => {
                            // Logger.logStart(self.document.*, "skip  ", self.depth);
                            self.depth += 1;
                        },
                        ']', '}' => {
                            // Logger.logEnd(self.document.*, "skip  ", self.depth);
                            self.depth -= 1;
                            if (self.depth <= parent_depth) return;
                        },
                        ' ' => {
                            @branchHint(.unlikely);
                            break :brk;
                        },
                        else => {
                            // Logger.log(self.document.*, "skip  ", self.depth);
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

            pub fn asValue(self: Document) Value {
                return .{ .iter = self.iter, .err = self.err };
            }

            pub fn asObject(self: Document) Error!Object {
                if (self.err) |err| return err;
                return Object.startRoot(self.iter);
            }

            pub fn asArray(self: Document) Error!Array {
                if (self.err) |err| return err;
                return Array.startRoot(self.iter);
            }

            pub fn asNumber(self: Document) Error!Number {
                if (self.err) |err| return err;
                return self.iter.asRootNumber();
            }

            pub fn asUnsigned(self: Document) Error!u64 {
                if (self.err) |err| return err;
                return self.iter.asRootUnsigned();
            }

            pub fn asSigned(self: Document) Error!i64 {
                if (self.err) |err| return err;
                return self.iter.asRootSigned();
            }

            pub fn asFloat(self: Document) Error!f64 {
                if (self.err) |err| return err;
                return self.iter.asRootFloat();
            }

            pub fn asString(self: Document) String {
                if (self.err) |err| return .{
                    .iter = self.iter,
                    .raw_str = undefined,
                    .err = err,
                };
                return self.iter.asRootString();
            }

            pub fn asBool(self: Document) Error!bool {
                if (self.err) |err| return err;
                return self.iter.asRootBool();
            }

            pub fn isNull(self: Document) Error!bool {
                if (self.err) |err| return err;
                return self.iter.isRootNull();
            }

            pub fn asAny(self: Document) Error!Element {
                if (self.err) |err| return err;
                self.iter.assertAtRoot();
                return switch (try self.iter.cursor.peekChar()) {
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

            pub fn skip(self: Document) Error!void {
                if (self.err) |err| return err;
                return self.iter.skipChild();
            }

            pub fn at(self: Document, ptr: anytype) Value {
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

            fn startOrResumeObject(self: Document) Error!Object {
                if (self.iter.isAtRoot()) {
                    return self.asObject();
                }
                return .{ .iter = self.iter };
            }

            fn startOrResumeArray(self: Document) Error!Array {
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

                fn asNumber(self: Iterator) Error!Number {
                    const n = try self.parseNumber(try self.peekNonRootScalar());
                    try self.advanceNonRootScalar();
                    return n;
                }

                fn asUnsigned(self: Iterator) Error!u64 {
                    const n = try self.parseUnsigned(try self.peekNonRootScalar());
                    try self.advanceNonRootScalar();
                    return n;
                }

                fn asSigned(self: Iterator) Error!i64 {
                    const n = try self.parseSigned(try self.peekNonRootScalar());
                    try self.advanceNonRootScalar();
                    return n;
                }

                fn asFloat(self: Iterator) Error!f64 {
                    const n = try self.parseFloat(try self.peekNonRootScalar());
                    try self.advanceNonRootScalar();
                    return n;
                }

                fn asString(self: Iterator) Error!String {
                    const str = String{
                        .iter = self,
                        .raw_str = try self.peekNonRootScalar(),
                    };
                    try self.advanceNonRootScalar();
                    return str;
                }

                fn asBool(self: Iterator) Error!bool {
                    const is_true = try self.parseBool(try self.peekNonRootScalar());
                    try self.advanceNonRootScalar();
                    return is_true;
                }

                fn isNull(self: Iterator) Error!bool {
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

                fn asRootNumber(self: Iterator) Error!Number {
                    const n = try self.parseNumber(try self.peekRootScalar());
                    try self.advanceRootScalar();
                    return n;
                }

                fn asRootUnsigned(self: Iterator) Error!u64 {
                    const n = try self.parseUnsigned(try self.peekRootScalar());
                    try self.advanceRootScalar();
                    return n;
                }

                fn asRootSigned(self: Iterator) Error!i64 {
                    const n = try self.parseSigned(try self.peekRootScalar());
                    try self.advanceRootScalar();
                    return n;
                }

                fn asRootFloat(self: Iterator) Error!f64 {
                    const n = try self.parseFloat(try self.peekRootScalar());
                    try self.advanceRootScalar();
                    return n;
                }

                fn asRootString(self: Iterator) Error!String {
                    const str = String{
                        .iter = self,
                        .raw_str = try self.peekRootScalar(),
                    };
                    try self.advanceRootScalar();
                    return str;
                }

                fn asRootBool(self: Iterator) Error!bool {
                    const is_true = try self.parseBool(try self.peekRootScalar());
                    try self.advanceRootScalar();
                    return is_true;
                }

                fn isRootNull(self: Iterator) Error!bool {
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

                fn parseNumber(_: Iterator, ptr: [*]const u8) Error!Number {
                    return @import("parsers/number/parser.zig").parse(null, ptr);
                }

                fn parseUnsigned(_: Iterator, ptr: [*]const u8) Error!u64 {
                    const n = try @import("parsers/number/parser.zig").parse(.unsigned, ptr);
                    return n.unsigned;
                }

                fn parseSigned(_: Iterator, ptr: [*]const u8) Error!i64 {
                    const n = try @import("parsers/number/parser.zig").parse(.signed, ptr);
                    return n.signed;
                }

                fn parseFloat(_: Iterator, ptr: [*]const u8) Error!f64 {
                    const n = try @import("parsers/number/parser.zig").parse(.float, ptr);
                    return switch (n) {
                        .float => |v| v,
                        inline else => |v| @floatFromInt(v),
                    };
                }

                fn parseString(_: Iterator, ptr: [*]const u8, dst: [*]u8) Error![]const u8 {
                    if (ptr[0] != '"') return error.IncorrectType;
                    const write = @import("parsers/string.zig").writeString;
                    const next_len = try write(ptr, dst);
                    return dst[0..next_len];
                }

                fn parseBool(_: Iterator, ptr: [*]const u8) Error!bool {
                    const check = @import("parsers/atoms.zig").checkBool;
                    return check(ptr);
                }

                fn parseNull(_: Iterator, ptr: [*]const u8) Error!void {
                    const check = @import("parsers/atoms.zig").checkNull;
                    return check(ptr);
                }

                fn endContainer(self: Iterator) void {
                    self.cursor.ascend(self.start_depth - 1);
                }

                fn isAtStart(self: Iterator) bool {
                    return self.cursor.position == self.start_position;
                }

                fn isAtRoot(self: Iterator) bool {
                    return self.cursor.position == 0;
                }

                fn isAtContainerStart(self: Iterator) bool {
                    const delta = self.cursor.position - self.start_position;
                    return delta == 1 or delta == 2;
                }

                fn isAtKey(self: Iterator) Error!bool {
                    return self.start_depth == self.cursor.depth and try self.cursor.peekChar() == '"';
                }

                fn isAtFirstValue(self: Iterator) bool {
                    assert(self.cursor.position > self.start_position);
                    return self.cursor.position == self.start_position + 1;
                }

                fn isOpen(self: Iterator) bool {
                    return self.cursor.depth >= self.start_depth;
                }

                fn isAtEnd(self: Iterator) Error!bool {
                    return common.tables.is_whitespace[try self.cursor.peekChar()];
                }

                fn hasNextField(self: Iterator) Error!bool {
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

                fn hasNextElement(self: Iterator) Error!bool {
                    self.assertAtNext();

                    switch ((try self.cursor.next())[0]) {
                        ',' => {
                            self.cursor.descend(self.start_depth + 1);
                            return true;
                        },
                        ']' => {
                            self.endContainer();
                            return false;
                        },
                        else => return self.reportError(error.ExpectedArrayCommaOrEnd),
                    }
                }

                fn startObject(self: Iterator) Error!bool {
                    try self.startContainer('{');
                    return self.startedObject();
                }

                fn startRootObject(self: Iterator) Error!bool {
                    try self.startContainer('{');
                    return self.startedRootObject();
                }

                fn startedObject(self: Iterator) Error!bool {
                    self.assertAtContainerStart();
                    if (try self.cursor.peekChar() == '}') {
                        _ = try self.cursor.next();
                        self.endContainer();
                        return false;
                    }
                    return true;
                }

                fn startedRootObject(self: Iterator) Error!bool {
                    self.assertAtContainerStart();
                    if (try self.cursor.peekChar() == '}') {
                        _ = try self.cursor.next();
                        self.endContainer();
                        if (try self.isAtEnd()) return false;
                        return error.TrailingContent;
                    }
                    return true;
                }

                fn startArray(self: Iterator) Error!bool {
                    try self.startContainer('[');
                    return self.startedArray();
                }

                fn startRootArray(self: Iterator) Error!bool {
                    try self.startContainer('[');
                    return self.startedRootArray();
                }

                fn startedArray(self: Iterator) Error!bool {
                    self.assertAtContainerStart();
                    if (try self.cursor.peekChar() == ']') {
                        _ = try self.cursor.next();
                        self.endContainer();
                        return false;
                    }
                    self.cursor.descend(self.start_depth + 1);
                    return true;
                }

                fn startedRootArray(self: Iterator) Error!bool {
                    self.assertAtContainerStart();
                    if (try self.cursor.peekChar() == ']') {
                        _ = try self.cursor.next();
                        self.endContainer();
                        if (try self.isAtEnd()) return false;
                        return error.TrailingContent;
                    }
                    self.cursor.descend(self.start_depth + 1);
                    return true;
                }

                fn startContainer(self: Iterator, start_char: u8) Error!void {
                    if (self.isAtStart()) {
                        self.assertAtStart();
                        if (try self.cursor.peekChar() != start_char) return error.IncorrectType;
                        _ = try self.cursor.next();
                    } else {
                        // if (!self.isAtContainerStart()) return error.OutOfOrderIteration;
                        if (self.start_char != start_char) return error.IncorrectType;
                    }
                }

                fn peekNonRootScalar(self: Iterator) Error![*]const u8 {
                    // if (!self.isAtStart()) return error.OutOfOrderIteration;
                    self.assertAtNonRootStart();
                    return self.cursor.peek();
                }

                fn peekRootScalar(self: Iterator) Error![*]const u8 {
                    // if (!self.isAtStart()) return error.OutOfOrderIteration;
                    self.assertAtRoot();
                    return self.cursor.peek();
                }

                fn advanceNonRootScalar(self: Iterator) Error!void {
                    if (!self.isAtStart()) return;
                    self.assertAtNonRootStart();
                    _ = try self.cursor.next();
                    self.cursor.ascend(self.start_depth - 1);
                }

                fn advanceRootScalar(self: Iterator) Error!void {
                    if (!self.isAtStart()) return;
                    self.assertAtRoot();
                    _ = try self.cursor.next();
                    self.cursor.ascend(self.start_depth - 1);
                }

                fn skipChild(self: Iterator) Error!void {
                    assert(self.cursor.position > self.start_position);
                    assert(self.cursor.depth >= self.start_depth);

                    return self.cursor.skip(self.start_depth, self.start_char);
                }

                fn child(self: Iterator) Error!Iterator {
                    self.assertAtChild();
                    return .{
                        .cursor = self.cursor,
                        .start_position = self.cursor.position,
                        .start_depth = self.start_depth + 1,
                        .start_char = try self.cursor.peekChar(),
                    };
                }

                fn findField(self: Iterator, key: []const u8) Error!bool {
                    var has_value = false;
                    if (self.isAtFirstValue()) {
                        has_value = true;
                    } else if (!self.isOpen()) {
                        return false;
                    } else {
                        try self.skipChild();
                        has_value = try self.hasNextField();
                    }
                    while (has_value) : (has_value = try self.hasNextField()) {
                        const field = try Object.Field.start(self);
                        const actual_key = try field.key.get();
                        if (std.mem.eql(u8, key, actual_key)) return true;
                        try self.skipChild();
                    }
                    return false;
                }

                fn assertAtStart(self: Iterator) void {
                    assert(self.cursor.position == self.start_position);
                    assert(self.cursor.depth == self.start_depth);
                    assert(self.start_depth > 0);
                }

                fn assertAtContainerStart(self: Iterator) void {
                    assert(self.cursor.position == self.start_position + 1);
                    assert(self.cursor.depth == self.start_depth);
                    assert(self.start_depth > 0);
                }

                fn assertAtNext(self: Iterator) void {
                    assert(self.cursor.position > self.start_position);
                    assert(self.cursor.depth == self.start_depth);
                    assert(self.start_depth > 0);
                }

                fn assertAtChild(self: Iterator) void {
                    assert(self.cursor.position > self.start_position);
                    assert(self.cursor.depth == self.start_depth + 1);
                    assert(self.start_depth > 0);
                }

                fn assertAtRoot(self: Iterator) void {
                    self.assertAtStart();
                    assert(self.start_depth == 1);
                }

                fn assertAtNonRootStart(self: Iterator) void {
                    self.assertAtStart();
                    assert(self.start_depth > 1);
                }

                inline fn reportError(self: Iterator, err: Error) Error!void {
                    return self.cursor.reportError(err);
                }
            };

            pub fn asObject(self: Value) Error!Object {
                if (self.err) |err| return err;
                return Object.start(self.iter);
            }

            pub fn asArray(self: Value) Error!Array {
                if (self.err) |err| return err;
                return Array.start(self.iter);
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

            pub fn asFloat(self: Value) Error!f64 {
                if (self.err) |err| return err;
                return self.iter.asFloat();
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

            pub fn asAny(self: Value) Error!Element {
                if (self.err) |err| return err;
                return switch (try self.iter.cursor.peekChar()) {
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

            pub fn getType(self: Value) Error!types.ElementType {
                if (self.err) |err| return err;
                return switch (try self.iter.cursor.peekChar()) {
                    't', 'f' => .bool,
                    'n' => .null,
                    '"' => .string,
                    '-', '0'...'9' => .number,
                    '[' => .array,
                    '{' => .object,
                    else => error.ExpectedValue,
                };
            }

            pub fn skip(self: Value) Error!void {
                if (self.err) |err| return err;
                return self.iter.skipChild();
            }

            pub fn at(self: Value, ptr: anytype) Value {
                if (self.err) |_| return self;

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

            fn startOrResumeObject(self: Value) Error!Object {
                if (self.iter.isAtStart()) {
                    return self.asObject();
                }
                return .{ .iter = self.iter };
            }

            fn startOrResumeArray(self: Value) Error!Array {
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

            pub fn get(self: String) Error![]const u8 {
                if (self.err) |err| return err;

                if (want_stream) {
                    if (self.iter.cursor.document.allocator) |alloc|
                        try self.iter.cursor.document.strings.ensureUnusedCapacity(alloc, options.stream.?.chunk_length)
                    else
                        return error.ExpectedAllocator;
                }
                const strings = self.iter.cursor.document.strings.items();
                const str = try self.iter.parseString(self.raw_str, strings[strings.len..].ptr);
                self.iter.cursor.document.strings.list.items.len += str.len;
                return str;
            }

            pub fn write(self: String, dest: []u8) Error![]const u8 {
                if (self.err) |err| return err;

                const str = try self.iter.parseString(self.raw_str, dest.ptr);
                return str;
            }
        };

        const Array = struct {
            iter: Value.Iterator,

            pub fn next(self: Array) Error!?Value {
                if (!self.iter.isOpen()) return null;
                if (self.iter.isAtFirstValue()) {
                    return .{ .iter = try self.iter.child() };
                }
                try self.iter.skipChild();

                if (try self.iter.hasNextElement()) {
                    return .{ .iter = try self.iter.child() };
                }
                return null;
            }

            fn start(iter: Value.Iterator) Error!Array {
                _ = try iter.startArray();
                return .{ .iter = iter };
            }

            fn started(iter: Value.Iterator) Error!Array {
                _ = try iter.startedArray();
                return .{ .iter = iter };
            }

            fn startRoot(iter: Value.Iterator) Error!Array {
                _ = try iter.startRootArray();
                return .{ .iter = iter };
            }

            pub fn at(self: Array, index: usize) Value {
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

            pub fn isEmpty(self: Array) Error!bool {
                return !(try self.iter.startedArray());
            }

            pub fn skip(self: Array) Error!void {
                return self.iter.cursor.skip(self.iter.start_depth - 1, '[');
            }
        };

        const Object = struct {
            iter: Value.Iterator,

            pub const Field = struct {
                key: String,
                value: Value,

                fn start(iter: Value.Iterator) Error!Field {
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

            pub fn next(self: Object) Error!?Field {
                if (!self.iter.isOpen()) return null;
                if (self.iter.isAtFirstValue()) {
                    return try Field.start(self.iter);
                }
                try self.iter.skipChild();

                if (try self.iter.hasNextField()) {
                    return try Field.start(self.iter);
                }
                return null;
            }

            fn start(iter: Value.Iterator) Error!Object {
                _ = try iter.startObject();
                return .{ .iter = iter };
            }

            fn started(iter: Value.Iterator) Error!Object {
                _ = try iter.startedObject();
                return .{ .iter = iter };
            }

            fn startRoot(iter: Value.Iterator) Error!Object {
                _ = try iter.startRootObject();
                return .{ .iter = iter };
            }

            pub fn at(self: Object, key: []const u8) Value {
                return if (self.iter.findField(key) catch |err| return .{
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
                return !(try self.iter.startedObject());
            }

            pub fn skip(self: Object) Error!void {
                if (try self.iter.isAtKey()) {
                    _ = try Object.Field.start(self.iter);
                }
                return self.iter.cursor.skip(self.iter.start_depth - 1, '{');
            }
        };

        const Logger = struct {
            fn logDepth(expected: u32, actual: u32) void {
                if (true) return;
                std.log.info(" SKIP     Wanted depth: {}, actual: {}", .{ expected, actual });
            }

            fn logStart(parser: Self, label: []const u8, depth: u32) void {
                if (true) return;
                var t = parser.tokens;
                var buffer = t.iter.ptr[(t.iter.token - 1)[0]..][0..Vector.bytes_len].*;
                for (&buffer) |*b| {
                    if (b.* == '\n') b.* = ' ';
                    if (b.* == '\t') b.* = ' ';
                    if (b.* > 127) b.* = '*';
                }
                std.log.info("+{s} | {s} | depth: {} | next: {c}", .{ label, buffer, depth, try t.peek() });
            }
            fn log(parser: Self, label: []const u8, depth: u32) void {
                if (true) return;
                var t = parser.tokens;
                var buffer = t.iter.ptr[(t.iter.token - 1)[0]..][0..Vector.bytes_len].*;
                for (&buffer) |*b| {
                    if (b.* == '\n') b.* = ' ';
                    if (b.* == '\t') b.* = ' ';
                    if (b.* > 127) b.* = '*';
                }
                std.log.info(" {s} | {s} | depth: {} | next: {c}", .{ label, buffer, depth, try t.peek() });
            }
            fn logEnd(parser: Self, label: []const u8, depth: u32) void {
                if (true) return;
                var t = parser.tokens;
                var buffer = t.iter.ptr[(t.iter.token - 1)[0]..][0..Vector.bytes_len].*;
                for (&buffer) |*b| {
                    if (b.* == '\n') b.* = ' ';
                    if (b.* == '\t') b.* = ' ';
                    if (b.* > 127) b.* = '*';
                }
                std.log.info("-{s} | {s} | depth: {} | next: {c}", .{ label, buffer, depth, try t.peek() });
            }
        };
    };
}
