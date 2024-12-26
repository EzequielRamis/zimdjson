const std = @import("std");
const common = @import("common.zig");
const types = @import("types.zig");
const tape = @import("tape.zig");
const Allocator = std.mem.Allocator;
const Error = types.Error;
const Number = types.Number;
const assert = std.debug.assert;

pub const Options = struct {
    length_hint: usize = common.default_length_hint,
    max_depth: u32 = common.default_max_depth,
    aligned: bool = false,
};

pub fn Parser(comptime options: Options) type {
    return struct {
        const Self = @This();
        const Tape = tape.Tape(.{
            .max_depth = options.max_depth,
            .aligned = options.aligned,
        });
        const Aligned = types.Aligned(options.aligned);

        tape: Tape,

        pub fn init(allocator: Allocator) Self {
            return .{
                .tape = Tape.init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.tape.deinit();
        }

        pub fn parse(self: *Self, document: Aligned.slice) !Visitor {
            if (document.len >= options.max_capacity) return error.ExceededCapacity;
            try self.tape.build(document, document.len);
            return Visitor{
                .tape = &self.tape,
                .index = 0,
            };
        }

        pub const Element = union(enum) {
            null,
            bool: bool,
            unsigned: u64,
            signed: i64,
            float: f64,
            string: []const u8,
            object: Object,
            array: Array,
        };

        pub const Visitor = struct {
            tape: *const Tape,
            index: u32,
            err: ?Error = null,

            pub fn getObject(self: Visitor) Error!Object {
                if (self.err) |err| return err;

                return switch (self.tape.get(self.index).tag) {
                    .object_opening => Object{ .tape = self.tape, .root = self.index },
                    else => error.IncorrectType,
                };
            }

            pub fn getArray(self: Visitor) Error!Array {
                if (self.err) |err| return err;

                return switch (self.tape.get(self.index).tag) {
                    .array_opening => Array{ .tape = self.tape, .root = self.index },
                    else => error.IncorrectType,
                };
            }

            pub fn getString(self: Visitor) Error![]const u8 {
                if (self.err) |err| return err;

                const w = self.tape.get(self.index);
                return switch (w.tag) {
                    .string => brk: {
                        const len: u32 = @bitCast(self.tape.chars.items[w.data.ptr..][0..4].*);
                        const ptr = self.tape.chars.items[w.data.ptr + 4 ..];
                        break :brk ptr[0..len];
                    },
                    else => error.IncorrectType,
                };
            }

            pub fn getNumber(self: Visitor) Error!Number {
                if (self.err) |err| return err;

                const number = self.tape.get(self.index + 1);
                return switch (self.tape.get(self.index).tag) {
                    .unsigned => .{ .unsigned = @bitCast(number) },
                    .signed => .{ .signed = @bitCast(number) },
                    .float => .{ .float = @bitCast(number) },
                    else => error.IncorrectType,
                };
            }

            pub fn getUnsigned(self: Visitor) Error!u64 {
                if (self.err) |err| return err;

                const number = self.tape.get(self.index + 1);
                return switch (self.tape.get(self.index).tag) {
                    .unsigned => @bitCast(number),
                    .signed => std.math.cast(u64, @as(i64, @bitCast(number))) orelse error.NumberOutOfRange,
                    else => error.IncorrectType,
                };
            }

            pub fn getSigned(self: Visitor) Error!i64 {
                if (self.err) |err| return err;

                const number = self.tape.get(self.index + 1);
                return switch (self.tape.get(self.index).tag) {
                    .signed => @bitCast(number),
                    .unsigned => std.math.cast(i64, @as(u64, @bitCast(number))) orelse error.NumberOutOfRange,
                    else => error.IncorrectType,
                };
            }

            pub fn getFloat(self: Visitor) Error!f64 {
                if (self.err) |err| return err;

                const number = self.tape.get(self.index + 1);
                return switch (self.tape.get(self.index).tag) {
                    .float => @bitCast(number),
                    else => error.IncorrectType,
                };
            }

            pub fn getBool(self: Visitor) Error!bool {
                if (self.err) |err| return err;

                return switch (self.tape.get(self.index).tag) {
                    .true => true,
                    .false => false,
                    else => error.IncorrectType,
                };
            }

            pub fn isNull(self: Visitor) Error!bool {
                if (self.err) |err| return err;

                return self.tape.get(self.index).tag == .null;
            }

            pub fn getAny(self: Visitor) Error!Element {
                if (self.err) |err| return err;

                const w = self.tape.get(self.index);
                return switch (w.tag) {
                    .true => .{ .bool = true },
                    .false => .{ .bool = false },
                    .null => .null,
                    .unsigned => .{ .unsigned = (self.getNumber() catch unreachable).unsigned },
                    .signed => .{ .signed = (self.getNumber() catch unreachable).signed },
                    .float => .{ .float = (self.getNumber() catch unreachable).float },
                    .string => .{ .string = self.getString() catch unreachable },
                    .object_opening => .{ .object = .{ .tape = self.tape, .root = self.index } },
                    .array_opening => .{ .array = .{ .tape = self.tape, .root = self.index } },
                    else => unreachable,
                };
            }

            pub fn at(self: Visitor, ptr: anytype) Visitor {
                if (self.err) |_| return self;

                const query = brk: {
                    if (common.isString(@TypeOf(ptr))) {
                        const obj = self.getObject() catch return .{
                            .tape = self.tape,
                            .index = self.index,
                            .err = error.IncorrectPointer,
                        };
                        break :brk obj.at(ptr);
                    }
                    if (common.isIndex(@TypeOf(ptr))) {
                        const arr = self.getArray() catch return .{
                            .tape = self.tape,
                            .index = self.index,
                            .err = error.IncorrectPointer,
                        };
                        break :brk arr.at(ptr);
                    }
                    @compileError("JSON Pointer must be a string or number");
                };
                return if (query) |v| v else |err| .{
                    .tape = self.tape,
                    .index = self.index,
                    .err = err,
                };
            }

            pub fn getSize(self: Visitor) Error!u32 {
                if (self.err) |err| return err;

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

                pub fn next(self: *Iterator) ?Visitor {
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
                return Iterator{
                    .tape = self.tape,
                    .curr = self.root + 1,
                };
            }

            pub fn at(self: Array, index: u32) Error!Visitor {
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
                value: Visitor,
            };

            pub const Iterator = struct {
                tape: *const Tape,
                curr: u32,

                pub fn next(self: *Iterator) ?Field {
                    if (self.tape.get(self.curr).tag == .object_closing) return null;
                    const field = Visitor{ .tape = self.tape, .index = self.curr };
                    const value = Visitor{ .tape = self.tape, .index = self.curr + 1 };
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
                return Iterator{
                    .tape = self.tape,
                    .curr = self.root + 1,
                };
            }

            pub fn at(self: Object, key: []const u8) Error!Visitor {
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
