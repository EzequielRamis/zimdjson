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

const Capacity = enum(u64) {
    infinite = std.math.maxInt(u64),
    normal = std.math.maxInt(u32),
    _,

    fn greater(self: Capacity, other: Capacity) bool {
        return @intFromEnum(self) > @intFromEnum(other);
    }
};

pub const StreamOptions = struct {
    pub const default: StreamOptions = .{};

    chunk_length: u32 = tokens.StreamOptions.default.chunk_length,
    manual_manage_strings: bool = false,
};

pub const Options = struct {
    pub const default: Options = .{};

    max_capacity: Capacity = .normal,
    max_depth: u32 = 1024,
    aligned: bool = false,
    stream: ?StreamOptions = null,
};

pub fn Parser(comptime Reader: ?type, comptime options: Options) type {
    const NumberParser = @import("parsers/number/parser.zig").Parser;

    if (options.stream == null and comptime options.max_capacity.greater(.normal))
        @compileError("Larger documents are not supported in non-stream mode. Consider using stream mode.");

    const manual_manage_strings = if (options.stream) |s| s.manual_manage_strings else false;

    const must_be_manual_manage_strings = options.max_capacity == .infinite;
    if (must_be_manual_manage_strings and !manual_manage_strings)
        @compileError("Strings stored in parser are not supported with infinite capacity");

    return struct {
        const Self = @This();

        const Aligned = types.Aligned(options.aligned);
        const Tokens = tokens.Tokens(.{
            .Reader = Reader,
            .aligned = options.aligned,
            .stream = if (options.stream) |s|
                .{
                    .chunk_length = s.chunk_length,
                }
            else
                null,
        });

        pub const Error = types.ParserError || (if (options.stream) |_| types.StreamError else error{});

        allocator: ?Allocator,
        tokens: Tokens,
        buffer: if (options.stream) |_| void else std.ArrayListAligned(u8, types.Aligned(true).alignment),
        chars: std.ArrayListUnmanaged(u8),
        chars_ptr: [*]u8 = undefined,
        cursor: Cursor = undefined,

        // para streaming enchufarle el tipo ?Allocator en el init, para que el usuario tenga la opcion de mandarle un allocator por si sabe el tamaño del documento
        // o si no, que el usuario se encargue de mandar buffers para los fields y los strings
        pub fn init(allocator: if (manual_manage_strings) ?Allocator else Allocator) Self {
            return .{
                .allocator = allocator,
                .tokens = if (options.stream) |_| .init({}) else .init(allocator),
                .buffer = if (options.stream) |_| {} else .init(allocator),
                .chars = .empty,
            };
        }

        pub fn deinit(self: *Self) void {
            self.tokens.deinit();
            if (self.allocator) |alloc| self.chars.deinit(alloc);
            if (options.stream == null) {
                self.buffer.deinit();
            }
        }

        pub fn parseFromSlice(self: *Self, document: Aligned.slice) !Document {
            if (options.stream) |_| @compileError(common.error_messages.stream_slice);

            if (document.len > @intFromEnum(options.max_capacity)) return error.DocumentCapacity;
            try self.tokens.build(document);

            try self.chars.ensureTotalCapacity(self.allocator.?, document.len);
            self.chars.shrinkRetainingCapacity(0);
            self.chars_ptr = self.chars.items.ptr;

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

        pub fn parseFromFile(self: *Self, file: std.fs.File) !Document {
            const stat = try file.stat();
            if (stat.size > @intFromEnum(options.max_capacity)) return error.DocumentCapacity;
            if (!manual_manage_strings) {
                try self.chars.ensureTotalCapacity(self.allocator.?, stat.size);
                self.chars.shrinkRetainingCapacity(0);
                self.chars_ptr = self.chars.items.ptr;
            }
            if (options.stream == null) {
                try self.buffer.resize(stat.size);
                _ = try file.readAll(self.buffer.items);
                try self.tokens.build(self.buffer.items);
            } else {
                try self.tokens.build(file.reader().any());
            }

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

        // pub fn parseFromReader(self : *Self, reader: anytype) !Document {}

        pub const Element = union(types.ElementType) {
            null,
            bool: bool,
            number: Number,
            string: []const u8,
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
                assert(0 <= parent_depth and parent_depth < options.max_depth - 1);
                assert(self.depth == parent_depth + 1);
                self.depth = parent_depth;
            }

            fn descend(self: *Cursor, child_depth: u32) void {
                assert(1 <= child_depth and child_depth < options.max_depth);
                assert(self.depth == child_depth - 1);
                self.depth = child_depth;
            }

            fn getNextStringPtr(self: Cursor) [*]u8 {
                return self.document.chars_ptr;
            }

            fn setNextStringPtr(self: *Cursor, ptr: [*]u8) void {
                self.document.chars_ptr = ptr;
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

            fn getObject(self: Document) Error!Object {
                if (self.err) |err| return err;
                return Object.startRoot(self.iter);
            }

            fn getArray(self: Document) Error!Array {
                if (self.err) |err| return err;
                return Array.startRoot(self.iter);
            }

            fn getNumber(self: Document) Error!Number {
                if (self.err) |err| return err;
                return self.iter.getRootNumber();
            }

            fn getUnsigned(self: Document) Error!u64 {
                if (self.err) |err| return err;
                return self.iter.getRootUnsigned();
            }

            fn getSigned(self: Document) Error!i64 {
                if (self.err) |err| return err;
                return self.iter.getRootSigned();
            }

            fn getFloat(self: Document) Error!f64 {
                if (self.err) |err| return err;
                return self.iter.getRootFloat();
            }

            fn getString(self: Document) Error![]const u8 {
                if (self.err) |err| return err;
                return self.iter.getRootString();
            }

            fn getBool(self: Document) Error!bool {
                if (self.err) |err| return err;
                return self.iter.getRootBool();
            }

            fn isNull(self: Document) Error!void {
                if (self.err) |err| return err;
                return self.iter.isRootNull();
            }

            fn getAny(self: Document) Error!Element {
                if (self.err) |err| return err;
                self.iter.assertAtRoot();
                return switch (try self.iter.cursor.peekChar()) {
                    't', 'f' => .{ .bool = try self.getBool() },
                    'n' => .{ .null = try self.isNull() },
                    '"' => .{ .string = try self.getString() },
                    '-', '0'...'9' => switch (try self.getNumber()) {
                        .unsigned => |n| .{ .unsigned = n },
                        .signed => |n| .{ .signed = n },
                        .float => |n| .{ .float = n },
                    },
                    '[' => .{ .array = try self.getArray() },
                    '{' => .{ .object = try self.getObject() },
                    else => {
                        return error.ExpectedDocument;
                    },
                };
            }

            fn skip(self: Document) Error!void {
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
                return query catch |err| .{ .iter = self.iter, .err = err };
            }

            fn startOrResumeObject(self: Document) Error!Object {
                if (self.iter.isAtRoot()) {
                    return self.getObject();
                }
                return .{ .iter = self.iter };
            }

            fn startOrResumeArray(self: Document) Error!Array {
                if (self.iter.isAtRoot()) {
                    return self.getArray();
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

                fn getNumber(self: Iterator) Error!Number {
                    const n = try self.parseNumber(try self.peekNonRootScalar());
                    try self.advanceNonRootScalar();
                    return n;
                }

                fn getUnsigned(self: Iterator) Error!u64 {
                    const n = try self.parseUnsigned(try self.peekNonRootScalar());
                    try self.advanceNonRootScalar();
                    return n;
                }

                fn getSigned(self: Iterator) Error!i64 {
                    const n = try self.parseSigned(try self.peekNonRootScalar());
                    try self.advanceNonRootScalar();
                    return n;
                }

                fn getFloat(self: Iterator) Error!f64 {
                    const n = try self.parseFloat(try self.peekNonRootScalar());
                    try self.advanceNonRootScalar();
                    return n;
                }

                fn getString(self: Iterator) Error![]const u8 {
                    const str = try self.parseString(try self.peekNonRootScalar());
                    try self.advanceNonRootScalar();
                    return str;
                }

                fn getBool(self: Iterator) Error!bool {
                    const is_true = try self.parseBool(try self.peekNonRootScalar());
                    try self.advanceNonRootScalar();
                    return is_true;
                }

                fn isNull(self: Iterator) Error!void {
                    try self.parseNull(try self.peekNonRootScalar());
                    try self.advanceNonRootScalar();
                }

                fn getRootNumber(self: Iterator) Error!Number {
                    const n = try self.parseNumber(try self.peekRootScalar());
                    try self.advanceRootScalar();
                    return n;
                }

                fn getRootUnsigned(self: Iterator) Error!u64 {
                    const n = try self.parseUnsigned(try self.peekRootScalar());
                    try self.advanceRootScalar();
                    return n;
                }

                fn getRootSigned(self: Iterator) Error!i64 {
                    const n = try self.parseSigned(try self.peekRootScalar());
                    try self.advanceRootScalar();
                    return n;
                }

                fn getRootFloat(self: Iterator) Error!f64 {
                    const n = try self.parseFloat(try self.peekRootScalar());
                    try self.advanceRootScalar();
                    return n;
                }

                fn getRootString(self: Iterator) Error![]const u8 {
                    const str = try self.parseString(try self.peekRootScalar());
                    try self.advanceRootScalar();
                    return str;
                }

                fn getRootBool(self: Iterator) Error!bool {
                    const is_true = try self.parseBool(try self.peekRootScalar());
                    try self.advanceRootScalar();
                    return is_true;
                }

                fn isRootNull(self: Iterator) Error!void {
                    try self.parseNull(try self.peekRootScalar());
                    try self.advanceRootScalar();
                }

                fn parseNumber(_: Iterator, ptr: [*]const u8) Error!Number {
                    return NumberParser.parse(ptr);
                }

                fn parseUnsigned(_: Iterator, ptr: [*]const u8) Error!u64 {
                    return NumberParser.parseUnsigned(ptr);
                }

                fn parseSigned(_: Iterator, ptr: [*]const u8) Error!i64 {
                    return NumberParser.parseSigned(ptr);
                }

                fn parseFloat(_: Iterator, ptr: [*]const u8) Error!f64 {
                    return NumberParser.parseFloat(ptr);
                }

                fn parseString(self: Iterator, ptr: [*]const u8) Error![]const u8 {
                    // if (options.stream != null and options.stream.?.manual_manage_strings)
                    //     @compileError("Strings stored in parser are not available. Consider enabling `.manage_strings` or using `writeString`.");

                    if (ptr[0] != '"') return error.IncorrectType;

                    const next_str = self.cursor.getNextStringPtr();
                    const write = @import("parsers/string.zig").writeString;
                    const sentinel = try write(ptr, next_str);
                    const next_len = @intFromPtr(sentinel) - @intFromPtr(next_str);
                    self.cursor.setNextStringPtr(sentinel);
                    return next_str[0..next_len];
                }

                fn parseBool(_: Iterator, ptr: [*]const u8) Error!bool {
                    const check = @import("parsers/atoms.zig").checkBool;
                    return check(ptr);
                }

                fn parseNull(_: Iterator, ptr: [*]const u8) Error!void {
                    const check = @import("parsers/atoms.zig").checkNull;
                    return check(ptr);
                }

                fn getFieldKey(self: Iterator) Error![]const u8 {
                    // TODO: cambiar este if
                    if (options.stream != null and options.stream.?.manual_manage_strings)
                        @compileError("Strings stored in parser are not available. Consider enabling `.manage_strings` or using `writeString`.");

                    self.assertAtNext();
                    const ptr = try self.cursor.next();
                    if (ptr[0] != '"') return self.reportError(error.ExpectedKey);

                    const next_str = self.cursor.getNextStringPtr();
                    const write = @import("parsers/string.zig").writeString;
                    const sentinel = try write(ptr, next_str);
                    const next_len = @intFromPtr(sentinel) - @intFromPtr(next_str);
                    self.cursor.setNextStringPtr(sentinel);

                    return next_str[0..next_len];
                }

                fn goToFieldValue(self: Iterator) Error!void {
                    self.assertAtNext();
                    const ptr = try self.cursor.next();
                    if (ptr[0] != ':') return self.reportError(error.ExpectedColon);
                    self.cursor.descend(self.start_depth + 1);
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
                        const actual_key = try self.getFieldKey();
                        try self.goToFieldValue();
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

            pub fn from(document: Document) Value {
                return .{ .iter = document.iter, .err = document.err };
            }

            pub fn getObject(self: Value) Error!Object {
                if (self.err) |err| return err;
                return Object.start(self.iter);
            }

            pub fn getArray(self: Value) Error!Array {
                if (self.err) |err| return err;
                return Array.start(self.iter);
            }

            pub fn getNumber(self: Value) Error!Number {
                if (self.err) |err| return err;
                return self.iter.getNumber();
            }

            pub fn getUnsigned(self: Value) Error!u64 {
                if (self.err) |err| return err;
                return self.iter.getUnsigned();
            }

            pub fn getSigned(self: Value) Error!i64 {
                if (self.err) |err| return err;
                return self.iter.getSigned();
            }

            pub fn getFloat(self: Value) Error!f64 {
                if (self.err) |err| return err;
                return self.iter.getFloat();
            }

            pub fn getString(self: Value) Error![]const u8 {
                if (self.err) |err| return err;
                return self.iter.getString();
            }

            pub fn getBool(self: Value) Error!bool {
                if (self.err) |err| return err;
                return self.iter.getBool();
            }

            pub fn isNull(self: Value) Error!void {
                if (self.err) |err| return err;
                return self.iter.isNull();
            }

            pub fn getAny(self: Value) Error!Element {
                if (self.err) |err| return err;
                return switch (try self.iter.cursor.peekChar()) {
                    't', 'f' => .{ .bool = try self.getBool() },
                    'n' => .{ .null = try self.isNull() },
                    '"' => .{ .string = try self.getString() },
                    '-', '0'...'9' => .{ .number = try self.getNumber() },
                    '[' => .{ .array = try self.getArray() },
                    '{' => .{ .object = try self.getObject() },
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
                return query catch |err| .{ .iter = self.iter, .err = err };
            }

            fn startOrResumeObject(self: Value) Error!Object {
                if (self.iter.isAtStart()) {
                    return self.getObject();
                }
                return .{ .iter = self.iter };
            }

            fn startOrResumeArray(self: Value) Error!Array {
                if (self.iter.isAtStart()) {
                    return self.getArray();
                }
                return .{ .iter = self.iter };
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

            pub fn at(self: Array, index: usize) Error!Value {
                var i: usize = 0;
                while (try self.next()) |v| : (i += 1)
                    if (i == index) return v;

                return error.IndexOutOfBounds;
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
                key: []const u8,
                value: Value,
            };

            pub fn next(self: Object) Error!?Field {
                if (!self.iter.isOpen()) return null;
                if (self.iter.isAtFirstValue()) {
                    const key = try self.iter.getFieldKey();
                    try self.iter.goToFieldValue();
                    return .{
                        .key = key,
                        .value = .{ .iter = try self.iter.child() },
                    };
                }
                try self.iter.skipChild();

                if (try self.iter.hasNextField()) {
                    const key = try self.iter.getFieldKey();
                    try self.iter.goToFieldValue();
                    return .{
                        .key = key,
                        .value = .{ .iter = try self.iter.child() },
                    };
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

            pub fn at(self: Object, key: []const u8) Error!Value {
                return if (try self.iter.findField(key))
                    .{ .iter = try self.iter.child() }
                else
                    error.MissingField;
            }

            pub fn isEmpty(self: Object) Error!bool {
                return !(try self.iter.startedObject());
            }

            pub fn skip(self: Object) Error!void {
                if (try self.iter.isAtKey()) {
                    _ = try self.iter.getFieldKey();
                    try self.iter.goToFieldValue();
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
