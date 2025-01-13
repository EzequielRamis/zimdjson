const std = @import("std");
const builtin = @import("builtin");
const common = @import("common.zig");
const types = @import("types.zig");
const tape = @import("tape.zig");
const tokens = @import("tokens.zig");
const Allocator = std.mem.Allocator;
const Error = types.Error;
const Number = types.Number;
const assert = std.debug.assert;
const native_endian = builtin.cpu.arch.endian();

pub const Options = struct {
    pub const default: Options = .{};

    max_capacity: tape.Capacity = .normal,
    max_depth: u32 = 1024,
    aligned: bool = false,
    stream: ?tokens.StreamOptions = null,
};

pub fn Parser(comptime options: Options) type {
    return struct {
        const Self = @This();
        const Aligned = types.Aligned(options.aligned);
        const Tape = tape.Tape(.{
            .max_capacity = options.max_capacity,
            .max_depth = options.max_depth,
            .aligned = options.aligned,
            .stream = options.stream,
        });
        const FileBuffer = std.ArrayListAligned(u8, types.Aligned(true).alignment);

        tape: Tape,
        buffer: if (options.stream) |_| void else FileBuffer,

        pub fn init(allocator: Allocator) Self {
            return .{
                .tape = .init(allocator),
                .buffer = if (options.stream) |_| {} else .init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.tape.deinit();
            if (options.stream == null) self.buffer.deinit();
        }

        pub fn parse(self: *Self, document: Aligned.slice) !Value {
            if (options.stream) |_| @compileError(common.error_messages.stream_slice);
            if (comptime options.max_capacity.greater(.normal))
                @compileError("Larger documents are not supported in non-stream mode. Consider using the DOM API with stream mode.");

            if (document.len > @intFromEnum(options.max_capacity)) return error.DocumentCapacity;
            try self.tape.build(document, null);

            return Value{
                .tape = &self.tape,
                .index = 0,
            };
        }

        pub fn load(self: *Self, file: std.fs.File) !Value {
            const stat = try file.stat();
            if (options.stream) |_| {
                if (comptime options.max_capacity.greater(.large))
                    @compileError("Too large documents are not supported in stream mode. Consider using the On-Demand API with stream mode.");

                try self.tape.build(file, stat.size);
            } else {
                if (comptime options.max_capacity.greater(.normal))
                    @compileError("Larger documents are not supported in non-stream mode. Consider using the DOM API with stream mode.");

                if (stat.size > @intFromEnum(options.max_capacity)) return error.DocumentCapacity;
                try self.buffer.resize(stat.size);
                _ = try file.readAll(self.buffer.items);
                try self.tape.build(self.buffer.items, null);
            }
            return Value{
                .tape = &self.tape,
                .index = 0,
            };
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
            err: Error!void = {},

            pub fn getObject(self: Value) Error!Object {
                try self.err;

                return switch (self.tape.get(self.index).tag) {
                    .object_opening => Object{ .tape = self.tape, .root = self.index },
                    else => error.IncorrectType,
                };
            }

            pub fn getArray(self: Value) Error!Array {
                try self.err;

                return switch (self.tape.get(self.index).tag) {
                    .array_opening => Array{ .tape = self.tape, .root = self.index },
                    else => error.IncorrectType,
                };
            }

            pub fn getString(self: Value) Error![]const u8 {
                try self.err;

                const w = self.tape.get(self.index);
                return switch (w.tag) {
                    .string => brk: {
                        const low_bits = std.mem.readInt(u16, self.tape.chars.items[w.data.ptr..][0..@sizeOf(u16)], native_endian);
                        const high_bits = w.data.len;
                        const len: u64 = high_bits << @bitSizeOf(Tape.StringHighBits) | low_bits;
                        const ptr = self.tape.chars.items[w.data.ptr + @sizeOf(u16) ..];
                        break :brk ptr[0..len];
                    },
                    else => error.IncorrectType,
                };
            }

            pub fn getNumber(self: Value) Error!Number {
                try self.err;

                const number = self.tape.get(self.index + 1);
                return switch (self.tape.get(self.index).tag) {
                    .unsigned => .{ .unsigned = @bitCast(number) },
                    .signed => .{ .signed = @bitCast(number) },
                    .float => .{ .float = @bitCast(number) },
                    else => error.IncorrectType,
                };
            }

            pub fn getUnsigned(self: Value) Error!u64 {
                try self.err;

                const number = self.tape.get(self.index + 1);
                return switch (self.tape.get(self.index).tag) {
                    .unsigned => @bitCast(number),
                    .signed => std.math.cast(u64, @as(i64, @bitCast(number))) orelse error.NumberOutOfRange,
                    else => error.IncorrectType,
                };
            }

            pub fn getSigned(self: Value) Error!i64 {
                try self.err;

                const number = self.tape.get(self.index + 1);
                return switch (self.tape.get(self.index).tag) {
                    .signed => @bitCast(number),
                    .unsigned => std.math.cast(i64, @as(u64, @bitCast(number))) orelse error.NumberOutOfRange,
                    else => error.IncorrectType,
                };
            }

            pub fn getFloat(self: Value) Error!f64 {
                try self.err;

                const number = self.tape.get(self.index + 1);
                return switch (self.tape.get(self.index).tag) {
                    .float => @bitCast(number),
                    else => error.IncorrectType,
                };
            }

            pub fn getBool(self: Value) Error!bool {
                try self.err;

                return switch (self.tape.get(self.index).tag) {
                    .true => true,
                    .false => false,
                    else => error.IncorrectType,
                };
            }

            pub fn isNull(self: Value) Error!bool {
                try self.err;

                return self.tape.get(self.index).tag == .null;
            }

            pub fn getAny(self: Value) Error!Element {
                try self.err;

                const w = self.tape.get(self.index);
                return switch (w.tag) {
                    .true => .{ .bool = true },
                    .false => .{ .bool = false },
                    .null => .null,
                    .number => .{ .number = self.getNumber() catch unreachable },
                    .string => .{ .string = self.getString() catch unreachable },
                    .object_opening => .{ .object = .{ .tape = self.tape, .root = self.index } },
                    .array_opening => .{ .array = .{ .tape = self.tape, .root = self.index } },
                    else => unreachable,
                };
            }

            pub fn getType(self: Value) Error!types.ElementType {
                try self.err;

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

            pub fn at(self: Value, ptr: anytype) Value {
                self.err catch return self;

                const query = brk: {
                    if (common.isString(@TypeOf(ptr))) {
                        const obj = self.getObject() catch |err| return .{
                            .tape = self.tape,
                            .index = self.index,
                            .err = err,
                        };
                        break :brk obj.at(ptr);
                    }
                    if (common.isIndex(@TypeOf(ptr))) {
                        const arr = self.getArray() catch |err| return .{
                            .tape = self.tape,
                            .index = self.index,
                            .err = err,
                        };
                        break :brk arr.at(ptr);
                    }
                    @compileError(common.error_messages.at_type);
                };
                return query catch |err| .{
                    .tape = self.tape,
                    .index = self.index,
                    .err = err,
                };
            }

            pub fn getSize(self: Value) Error!u32 {
                try self.err;

                if (self.getArray()) |arr| return arr.getSize() else |_| {}
                if (self.getObject()) |obj| return obj.getSize() else |_| {}
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

            pub fn at(self: Array, index: u32) Error!Value {
                var it = self.iterator();
                var i: u32 = 0;
                while (it.next()) |v| : (i += 1) if (i == index) return v;
                return error.IndexOutOfBounds;
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
                        .key = field.getString() catch unreachable,
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

            pub fn at(self: Object, key: []const u8) Error!Value {
                var it = self.iterator();
                while (it.next()) |field| if (std.mem.eql(u8, field.key, key)) return field.value;
                return error.MissingField;
            }

            pub fn isEmpty(self: Object) bool {
                return self.getSize() == 0;
            }

            pub fn getSize(self: Object) u24 {
                assert(self.tape.get(self.root).tag == .object_opening);
                return self.tape.get(self.root).data.len;
            }
        };
    };
}
