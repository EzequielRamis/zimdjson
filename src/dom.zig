//! With a Document Object Model (DOM) parser, unlike On-Demand, the entire document is
//! parsed, validated, and stored in memory as a tree-like structure. Only after the
//! process is complete can the programmer access and navigate the content.
//!
//! During parsing, the input must remain unmodified. Once parsing finishes, the input
//! can safely be discarded.
//!
//! A parser instance manages one document at a time and owns all allocated resources.
//! For optimal performance, it should be reused over several documents when possible.
//! If there is a need to have multiple documents in memory, multiple parser instances
//! should be used.
//!
//! Although the Document Object Model is an approach, it has two distinct variants:
//! * `FullParser`: The parser reads the entire document before parsing.
//! * `StreamParser`: The parser reads and parses the document progressively, handling it
//! in chunks as data arrives.
//!
//! Regardless of the variant, the complete DOM tree is constructed in memory.
//!
//! If memory usage is a concern or the document is too large, consider using the
//! `StreamParser`. Otherwise, the `FullParser` is recommended.

const std = @import("std");
const builtin = @import("builtin");
const common = @import("common.zig");
const types = @import("types.zig");
const tokens = @import("tokens.zig");
const Allocator = std.mem.Allocator;
const Number = types.Number;
const assert = std.debug.assert;
const native_endian = builtin.cpu.arch.endian();

/// The available options for parsing in full mode.
pub const FullOptions = struct {
    pub const default: @This() = .{};

    /// Use this literal if parsing is exclusively done from a reader.
    pub const reader_only: @This() = .{ .aligned = true, .assume_padding = true };

    /// This option forces the input type to have a [`zimdjson.alignment`](#zimdjson.alignment).
    /// When enabled, aligned SIMD vector instruction will be used during parsing, which may
    /// improve performance.
    ///
    /// It is useful when parsing from a reader, as the data is always loaded with alignment.
    ///
    /// When parsing from a slice, you must ensure it is aligned or a compiler error will
    /// occur.
    aligned: bool = false,

    /// This option assumes the input is padded with [`zimdjson.padding`](#zimdjson.padding).
    /// When enabled, there will be no bounds checking during parsing, improving performance.
    ///
    /// It is useful when parsing from a reader, as the data is always loaded with padding.
    ///
    /// When parsing from a slice, you must ensure it is padded or undefined behavior will
    /// occur.
    assume_padding: bool = false,
};

/// The available options for parsing in streaming mode.
pub const StreamOptions = struct {
    pub const default: @This() = .{};

    /// This option sets the stream's chunk length, which determines the number of
    /// bytes available for parsing at any given time.
    ///
    /// If a value (such a JSON string) exceeds the chunk length, an `error.BatchOverflow`
    /// will be returned.
    ///
    /// By default, the chunk length is set to 64KiB.
    chunk_length: u32 = tokens.ring_buffer.default_chunk_length,
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

    return struct {
        const Self = @This();

        const Aligned = types.Aligned(aligned);
        const Tokens = if (want_stream)
            tokens.stream.Stream(.{
                .aligned = true,
                .chunk_len = options.stream.chunk_length,
                .slots = 2,
            })
        else
            tokens.iterator.Iterator(.{
                .aligned = aligned,
                .assume_padding = options.full.assume_padding,
            });

        pub const Error = Tokens.Error || ParseError || Allocator.Error;

        /// The `FullParser` supports JSON documents up to **4GiB**.
        /// On the other hand, the `StreamParser` supports JSON documents up to **32GiB**.
        /// If the document exceeds these limits, an `error.ExceededCapacity` is returned.
        pub const max_capacity_bound = if (want_stream) std.math.maxInt(u32) * @sizeOf(Tape.Word) else std.math.maxInt(u32);

        // only used in full mode
        document_buffer: std.ArrayListAlignedUnmanaged(u8, types.Aligned(true).alignment),
        reader_error: ?std.meta.Int(.unsigned, @bitSizeOf(anyerror)),

        tape: Tape,

        max_capacity: usize,

        pub const init: Self = .{
            .tape = .init,
            .max_capacity = max_capacity_bound,
            .document_buffer = .empty,
            .reader_error = null,
        };

        /// Release all allocated memory, including the strings.
        pub fn deinit(self: *Self, allocator: Allocator) void {
            self.tape.deinit(allocator);
            self.document_buffer.deinit(allocator);
        }

        /// Recover the error returned from the reader.
        /// This method should be used only when the parser returns [`error.AnyReader`](#zimdjson.types.ReaderError).
        /// Otherwise, it results in undefined behavior.
        pub fn recoverReaderError(self: Self, comptime Reader: type) Reader.Error {
            if (want_stream) {
                assert(self.tape.tokens.reader_error != null);
                return @errorCast(@errorFromInt(self.tape.tokens.reader_error.?));
            } else {
                assert(self.reader_error != null);
                return @errorCast(@errorFromInt(self.reader_error.?));
            }
        }

        /// This method preallocates the necessary memory for a document based on its size.
        /// It should not be used when parsing from a slice, as the document size is already
        /// known, resulting in unnecessary allocations.
        pub fn expectDocumentSize(self: *Self, allocator: Allocator, size: usize) Error!void {
            return self.ensureTotalCapacityForReader(allocator, size);
        }

        fn ensureTotalCapacityForSlice(self: *Self, allocator: Allocator, new_capacity: usize) Error!void {
            if (new_capacity > self.max_capacity) return error.ExceededCapacity;

            try self.tape.tokens.ensureTotalCapacity(allocator, new_capacity);

            self.tape.string_buffer.allocator = allocator;
            try self.tape.string_buffer.ensureTotalCapacity(new_capacity);
        }

        fn ensureTotalCapacityForReader(self: *Self, allocator: Allocator, new_capacity: usize) Error!void {
            if (new_capacity > self.max_capacity) return error.ExceededCapacity;

            if (!want_stream) {
                try self.document_buffer.ensureTotalCapacity(allocator, new_capacity + types.Vector.bytes_len);
                try self.tape.tokens.ensureTotalCapacity(allocator, new_capacity);
            }

            self.tape.string_buffer.allocator = allocator;
            try self.tape.string_buffer.ensureTotalCapacity(new_capacity);
        }

        /// Parse a JSON document from slice. Allocated resources are owned by the parser.
        pub fn parseFromSlice(self: *Self, allocator: Allocator, document: Aligned.slice) Error!Value {
            if (want_stream) @compileError("Parsing from a slice is not supported in streaming mode");
            self.reader_error = null;

            self.tape.string_buffer.reset();
            self.tape.string_buffer.allocator = allocator;

            try self.ensureTotalCapacityForSlice(allocator, document.len);
            try self.tape.buildFromSlice(allocator, document);
            return .{
                .tape = &self.tape,
                .index = 0,
            };
        }

        /// Parse a JSON document from reader. Allocated resources are owned by the parser.
        pub fn parseFromReader(self: *Self, allocator: Allocator, reader: std.io.AnyReader) (Error || ReaderError)!Value {
            self.reader_error = null;

            self.tape.string_buffer.reset();
            self.tape.string_buffer.allocator = allocator;

            if (want_stream) {
                try self.tape.buildFromReader(allocator, reader);
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
                try self.tape.buildFromSlice(allocator, self.document_buffer.items[0..len]);
            }
            return .{
                .tape = &self.tape,
                .index = 0,
            };
        }

        /// Represents any valid JSON value.
        pub const AnyValue = union(types.ValueType) {
            null,
            bool: bool,
            number: Number,
            string: []const u8,
            object: Object,
            array: Array,
        };

        /// Represents a value in a JSON document.
        pub const Value = struct {
            tape: *const Tape,
            index: u32,
            err: ?Error = null,

            /// Cast the value to an object.
            pub fn asObject(self: Value) Error!Object {
                if (self.err) |err| return err;

                return switch (self.tape.get(self.index).tag) {
                    .object_opening => Object{ .tape = self.tape, .root = self.index },
                    else => error.IncorrectType,
                };
            }

            /// Cast the value to an array.
            pub fn asArray(self: Value) Error!Array {
                if (self.err) |err| return err;

                return switch (self.tape.get(self.index).tag) {
                    .array_opening => Array{ .tape = self.tape, .root = self.index },
                    else => error.IncorrectType,
                };
            }

            /// Cast the value to a string.
            /// The string is guaranteed to be valid UTF-8.
            ///
            /// **Note**: The string is stored in the parser and will be invalidated the next time it
            /// parses a document or when it is destroyed.
            pub fn asString(self: Value) Error![]const u8 {
                if (self.err) |err| return err;

                const w = self.tape.get(self.index);
                return switch (w.tag) {
                    .string => brk: {
                        const low_bits = std.mem.readInt(u16, self.tape.string_buffer.strings.items().ptr[w.data.ptr..][0..@sizeOf(u16)], native_endian);
                        const high_bits: u64 = w.data.len;
                        const len = high_bits << 16 | low_bits;
                        const ptr = self.tape.string_buffer.strings.items().ptr[w.data.ptr + @sizeOf(u16) ..];
                        break :brk ptr[0..len];
                    },
                    else => error.IncorrectType,
                };
            }

            /// Cast the value to a number.
            pub fn asNumber(self: Value) Error!Number {
                if (self.err) |err| return err;

                const w = self.tape.get(self.index);
                const number = self.tape.get(self.index + 1);
                return switch (w.tag) {
                    inline .unsigned, .signed, .double => |t| @unionInit(Number, @tagName(t), @bitCast(number)),
                    else => error.IncorrectType,
                };
            }

            /// Cast the value to an unsigned integer.
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

            /// Cast the value to a signed integer.
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

            /// Cast the value to a double floating point.
            pub fn asDouble(self: Value) Error!f64 {
                if (self.err) |err| return err;

                const w = self.tape.get(self.index);
                const number = self.tape.get(self.index + 1);
                return switch (w.tag) {
                    .double => @bitCast(number),
                    .unsigned => @floatFromInt(@as(u64, @bitCast(number))),
                    .signed => @floatFromInt(@as(i64, @bitCast(number))),
                    else => error.IncorrectType,
                };
            }

            /// Cast the value to a bool.
            pub fn asBool(self: Value) Error!bool {
                if (self.err) |err| return err;

                return switch (self.tape.get(self.index).tag) {
                    .true => true,
                    .false => false,
                    else => error.IncorrectType,
                };
            }

            /// Check whether the value is a JSON `null`.
            pub fn isNull(self: Value) Error!bool {
                if (self.err) |err| return err;

                return self.tape.get(self.index).tag == .null;
            }

            /// Cast the value to any valid JSON value.
            pub fn asAny(self: Value) Error!AnyValue {
                if (self.err) |err| return err;

                const w = self.tape.get(self.index);
                return switch (w.tag) {
                    .true => .{ .bool = true },
                    .false => .{ .bool = false },
                    .null => .null,
                    .unsigned, .signed, .double => .{ .number = self.asNumber() catch unreachable },
                    .string => .{ .string = self.asString() catch unreachable },
                    .object_opening => .{ .object = .{ .tape = self.tape, .root = self.index } },
                    .array_opening => .{ .array = .{ .tape = self.tape, .root = self.index } },
                    else => unreachable,
                };
            }

            /// Cast the value to the specified type.
            ///
            /// **Note**: The method is limited to simple types. For more complex deserialization,
            /// consider using the [`ondemand.Parser.schema`](#zimdjson.ondemand.Parser.schema) interface.
            pub fn as(self: Value, comptime T: type) Error!T {
                const info = @typeInfo(T);
                switch (info) {
                    .int => {
                        const n = try self.asNumber();
                        return switch (n) {
                            .double => error.IncorrectType,
                            inline else => n.cast(T) orelse error.NumberOutOfRange,
                        };
                    },
                    .float => return @floatCast(try self.asDouble()),
                    .bool => return self.asBool(),
                    .optional => |opt| {
                        if (try self.isNull()) return null;
                        const child = try self.as(opt.child);
                        return child;
                    },
                    .void => {
                        if (try self.isNull()) return {};
                        return error.IncorrectType;
                    },
                    else => {
                        if (T == []const u8) return self.asString();
                        if (T == Number) return self.asNumber();
                        if (T == Array) return self.asArray();
                        if (T == Object) return self.asObject();
                        if (T == AnyValue) return self.asAny();
                        @compileError("Unable to parse into type '" ++ @typeName(T) ++ "'");
                    },
                }
            }

            /// Get the type of the value.
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

            /// Get the value associated with the given key.
            /// The key is matched against **unescaped** JSON.
            /// The method has linear-time complexity.
            ///
            /// Since the method is chainable, it can be called multiple times in a row.
            /// For example:
            ///
            /// ```zig
            /// const document = try parser.parseFromSlice(allocator, "{ \"a\": { \"b\": 1 } }");
            /// const value = try document.at("a").at("b").asUnsigned();
            /// std.debug.assert(value == 1);
            /// ```
            ///
            /// If the key is not found, an `error.MissingField` will be returned when a cast method is used.
            ///
            /// **Note**: Avoid calling the `at` method repeatedly.
            pub fn at(self: Value, key: []const u8) Value {
                if (self.err) |_| return self;
                const obj = self.asObject() catch |err| return .{
                    .tape = self.tape,
                    .index = self.index,
                    .err = err,
                };
                return obj.at(key);
            }

            /// Get the value at the given index.
            /// The method has linear-time complexity.
            ///
            /// Since the method is chainable, it can be called multiple times in a row.
            /// For example:
            ///
            /// ```zig
            /// const document = try parser.parseFromSlice(allocator, "[ [], [1] ]");
            /// const value = try document.atIndex(1).atIndex(0).asUnsigned();
            /// std.debug.assert(value == 1);
            /// ```
            ///
            /// If the value is not found, an `error.IndexOutOfBounds` will be returned when a cast method is used.
            ///
            /// **Note**: Avoid calling the `atIndex` method repeatedly.
            pub fn atIndex(self: Value, index: usize) Value {
                if (self.err) |_| return self;
                const arr = self.asArray() catch |err| return .{
                    .tape = self.tape,
                    .index = self.index,
                    .err = err,
                };
                return arr.at(index);
            }

            /// Get the size of the array (number of immediate children).
            /// It is a saturated value with a maximum of `std.math.maxInt(u24)`.
            pub fn getArraySize(self: Value) Error!u24 {
                if (self.err) |err| return err;
                const arr = try self.asArray();
                return arr.getSize();
            }

            /// Get the size of the object (number of keys).
            /// It is a saturated value with a maximum of `std.math.maxInt(u24)`.
            pub fn getObjectSize(self: Value) Error!u24 {
                if (self.err) |err| return err;
                const obj = try self.asObject();
                return obj.getSize();
            }
        };

        /// A valid JSON array.
        pub const Array = struct {
            tape: *const Tape,
            root: u32,

            pub const Iterator = struct {
                tape: *const Tape,
                curr: u32,

                /// Go to the next value in the array, if any.
                pub fn next(self: *Iterator) ?Value {
                    const curr = self.tape.get(self.curr);
                    if (curr.tag == .array_closing) return null;
                    defer self.curr = switch (curr.tag) {
                        .array_opening, .object_opening => curr.data.ptr,
                        .unsigned, .signed, .double => self.curr + 2,
                        else => self.curr + 1,
                    };
                    return .{ .tape = self.tape, .index = self.curr };
                }
            };

            /// Iterate over the values in the array.
            pub fn iterator(self: Array) Iterator {
                return .{
                    .tape = self.tape,
                    .curr = self.root + 1,
                };
            }

            /// Get the value at the given index.
            /// The method has linear-time complexity.
            ///
            /// Since the method is chainable, it can be called multiple times in a row.
            /// For example:
            ///
            /// ```zig
            /// const document = try parser.parseFromSlice(allocator, "[ [], [1] ]");
            /// const value = try document.atIndex(1).atIndex(0).asUnsigned();
            /// std.debug.assert(value == 1);
            /// ```
            ///
            /// If the value is not found, an `error.IndexOutOfBounds` will be returned when a cast method is used.
            ///
            /// **Note**: Avoid calling the `at` method repeatedly.
            pub fn at(self: Array, index: usize) Value {
                var it = self.iterator();
                var i: u32 = 0;
                while (it.next()) |v| : (i += 1) if (i == index) return v;
                return .{
                    .tape = self.tape,
                    .index = self.root,
                    .err = error.IndexOutOfBounds,
                };
            }

            /// Check whether the array is empty.
            pub fn isEmpty(self: Array) bool {
                return self.getSize() == 0;
            }

            /// Get the size of the array (number of immediate children).
            /// It is a saturated value with a maximum of `std.math.maxInt(u24)`.
            pub fn getSize(self: Array) u24 {
                assert(self.tape.get(self.root).tag == .array_opening);
                return self.tape.get(self.root).data.len;
            }
        };

        /// A valid JSON object.
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

                /// Go to the next field in the object, if any.
                pub fn next(self: *Iterator) ?Field {
                    if (self.tape.get(self.curr).tag == .object_closing) return null;
                    const field = Value{ .tape = self.tape, .index = self.curr };
                    const value = Value{ .tape = self.tape, .index = self.curr + 1 };
                    const curr = self.tape.get(self.curr + 1);
                    defer self.curr = switch (curr.tag) {
                        .array_opening, .object_opening => curr.data.ptr,
                        .unsigned, .signed, .double => self.curr + 3,
                        else => self.curr + 2,
                    };
                    return .{
                        .key = field.asString() catch unreachable,
                        .value = value,
                    };
                }
            };

            /// Iterate over the fields in the object.
            pub fn iterator(self: Object) Iterator {
                return .{
                    .tape = self.tape,
                    .curr = self.root + 1,
                };
            }

            /// Get the value associated with the given key.
            /// The key is matched against **unescaped** JSON.
            /// The method has linear-time complexity.
            ///
            /// Since the method is chainable, it can be called multiple times in a row.
            /// For example:
            ///
            /// ```zig
            /// const document = try parser.parseFromSlice(allocator, "{ \"a\": { \"b\": 1 } }");
            /// const value = try document.at("a").at("b").asUnsigned();
            /// std.debug.assert(value == 1);
            /// ```
            ///
            /// If the key is not found, an `error.MissingField` will be returned when a cast method is used.
            ///
            /// **Note**: Avoid calling the `at` method repeatedly.
            pub fn at(self: Object, key: []const u8) Value {
                var it = self.iterator();
                while (it.next()) |field| if (std.mem.eql(u8, field.key, key)) return field.value;
                return .{
                    .tape = self.tape,
                    .index = self.root,
                    .err = error.MissingField,
                };
            }

            /// Check whether the object is empty.
            pub fn isEmpty(self: Object) bool {
                return self.getSize() == 0;
            }

            /// Get the size of the object (number of keys).
            /// It is a saturated value with a maximum of `std.math.maxInt(u24)`.
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
                unsigned = @intFromEnum(Number.unsigned),
                signed = @intFromEnum(Number.signed),
                double = @intFromEnum(Number.double),
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

                max_depth: usize = common.default_max_depth,
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

            string_buffer: types.StringBuffer(max_capacity_bound),

            words_ptr: if (want_stream) void else [*]u64 = undefined,
            strings_ptr: if (want_stream) void else [*]u8 = undefined,

            pub const init: Tape = .{
                .tokens = .init,
                .words = .empty,
                .stack = .empty,
                .string_buffer = .init,
            };

            pub fn deinit(self: *Tape, allocator: Allocator) void {
                self.words.deinit(allocator);
                self.stack.deinit(allocator);
                self.tokens.deinit(allocator);
                self.string_buffer.deinit();
            }

            pub inline fn buildFromSlice(self: *Tape, allocator: Allocator, document: Aligned.slice) Error!void {
                try self.tokens.build(allocator, document);
                try self.stack.ensureTotalCapacity(allocator, self.stack.max_depth);

                const tokens_count = self.tokens.indexes.items.len;
                // if there are only n numbers, there must be n - 1 commas plus an ending container token, so almost half of the tokens are numbers
                try self.words.ensureTotalCapacity(allocator, tokens_count + (tokens_count >> 1) + 1);

                self.words.list.clearRetainingCapacity();
                self.stack.clearRetainingCapacity();

                self.words_ptr = self.words.items().ptr;
                self.strings_ptr = self.string_buffer.strings.items().ptr;

                return self.dispatch(allocator);
            }

            pub inline fn buildFromReader(self: *Tape, allocator: Allocator, reader: std.io.AnyReader) Error!void {
                try self.tokens.build(allocator, reader);
                try self.stack.ensureTotalCapacity(allocator, self.stack.max_depth);

                self.words.list.clearRetainingCapacity();
                self.stack.clearRetainingCapacity();

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
                    const strings = self.string_buffer.strings.items();
                    return strings.ptr[strings.len..];
                } else {
                    return self.strings_ptr;
                }
            }

            inline fn advanceString(self: *Tape, len: usize) void {
                if (want_stream) {
                    self.string_buffer.strings.list.items.len += len;
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
                    try self.string_buffer.ensureUnusedCapacity(options.stream.chunk_length);
                }
                const writeString = @import("parsers/string.zig").writeString;
                const curr_str = self.currentString();
                const next_str = curr_str + @sizeOf(u16);
                const next_len = (try writeString(ptr, next_str)) - next_str;
                self.appendWordAssumeCapacity(.{
                    .tag = .string,
                    .data = .{
                        .ptr = @intCast(curr_str - self.string_buffer.strings.items().ptr),
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

test "dom" {
    const allocator = std.testing.allocator;
    var parser = FullParser(.default).init;
    defer parser.deinit(allocator);

    const document = try parser.parseFromSlice(allocator,
        \\{
        \\  "Image": {
        \\      "Width":  800,
        \\      "Height": 600,
        \\      "Title":  "View from 15th Floor",
        \\      "Thumbnail": {
        \\          "Url":    "http://www.example.com/image/481989943",
        \\          "Height": 125,
        \\          "Width":  100
        \\      },
        \\      "Animated" : false,
        \\      "IDs": [116, 943, 234, 38793]
        \\    }
        \\}
    );

    const image = try document.at("Image").asObject();

    const title = try image.at("Title").asString();
    try std.testing.expectEqualStrings("View from 15th Floor", title);

    const third_id = try image.at("IDs").atIndex(2).asUnsigned();
    try std.testing.expectEqual(234, third_id);
}
