const std = @import("std");
const common = @import("common.zig");
const types = @import("types.zig");
const indexer = @import("indexer.zig");
const tape = @import("tape.zig");
const Allocator = std.mem.Allocator;
const Error = types.Error;
const Number = types.Number;
const assert = std.debug.assert;

pub const Options = struct {
    max_capacity: u32 = common.default_max_capacity,
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
            try self.tape.build(document);
            return Visitor{
                .tape = &self.tape,
                .index = 1,
            };
        }

        const Element = union(enum) {
            null,
            bool: bool,
            unsigned: u64,
            signed: i64,
            float: f64,
            string: []const u8,
            object: Object,
            array: Array,
        };

        const Visitor = struct {
            tape: *const Tape,
            index: u32,
            err: ?Error = null,

            pub fn getObject(self: Visitor) Error!Object {
                if (self.err) |err| return err;

                const w = self.tape.parsed.items(.tags)[self.index];
                return switch (w) {
                    .object_opening => Object{ .tape = self.tape, .root = self.index },
                    else => error.IncorrectType,
                };
            }

            pub fn getArray(self: Visitor) Error!Array {
                if (self.err) |err| return err;

                const w = self.tape.parsed.items(.tags)[self.index];
                return switch (w) {
                    .array_opening => Array{ .tape = self.tape, .root = self.index },
                    else => error.IncorrectType,
                };
            }

            pub fn getString(self: Visitor) Error![]const u8 {
                if (self.err) |err| return err;

                const w = self.tape.parsed.get(self.index);
                return switch (w) {
                    .string => |fit| self.tape.chars.items[fit.ptr..][0..fit.len],
                    else => error.IncorrectType,
                };
            }

            pub fn getNumber(self: Visitor) Error!Number {
                if (self.err) |err| return err;

                const w = self.tape.parsed.get(self.index);
                return switch (w) {
                    .unsigned => |n| .{ .unsigned = n },
                    .signed => |n| .{ .signed = n },
                    .float => |n| .{ .float = n },
                    else => error.IncorrectType,
                };
            }

            pub fn getUnsigned(self: Visitor) Error!u64 {
                if (self.err) |err| return err;

                const w = self.tape.parsed.get(self.index);
                return switch (w) {
                    .unsigned => |n| n,
                    .signed => |n| std.math.cast(u64, n) orelse error.NumberOutOfRange,
                    else => error.IncorrectType,
                };
            }

            pub fn getSigned(self: Visitor) Error!i64 {
                if (self.err) |err| return err;

                const w = self.tape.parsed.get(self.index);
                return switch (w) {
                    .signed => |n| n,
                    .unsigned => |n| std.math.cast(i64, n) orelse error.NumberOutOfRange,
                    else => error.IncorrectType,
                };
            }

            pub fn getFloat(self: Visitor) Error!f64 {
                if (self.err) |err| return err;

                const w = self.tape.parsed.get(self.index);
                return switch (w) {
                    .float => |n| n,
                    else => error.IncorrectType,
                };
            }

            pub fn getBool(self: Visitor) Error!bool {
                if (self.err) |err| return err;

                const w = self.tape.parsed.items(.tags)[self.index];
                return switch (w) {
                    .true => true,
                    .false => false,
                    else => error.IncorrectType,
                };
            }

            pub fn isNull(self: Visitor) Error!bool {
                if (self.err) |err| return err;

                const w = self.tape.parsed.items(.tags)[self.index];
                return w == .null;
            }

            pub fn getAny(self: Visitor) Error!Element {
                if (self.err) |err| return err;

                const w = self.tape.parsed.get(self.index);
                return switch (w) {
                    .true => .{ .bool = true },
                    .false => .{ .bool = false },
                    .null => .{.null},
                    .unsigned => |n| .{ .unsigned = n },
                    .signed => |n| .{ .signed = n },
                    .float => |n| .{ .float = n },
                    .string => |fit| .{ .string = self.tape.chars.items[fit.ptr..][0..fit.len] },
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

        const Array = struct {
            tape: *const Tape,
            root: u32,

            pub const Iterator = struct {
                tape: *const Tape,
                curr: u32,

                pub fn next(self: *Iterator) ?Visitor {
                    const word = self.tape.parsed.get(self.curr);
                    if (word == .array_closing) return null;
                    defer self.curr = switch (word) {
                        .array_opening, .object_opening => |fit| fit.ptr,
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

            pub fn getSize(self: Array) u32 {
                const w = self.tape.parsed.get(self.root);
                assert(w == .array_opening);
                return w.array_opening.len;
            }
        };

        const Object = struct {
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
                    const word = self.tape.parsed.get(self.curr);
                    if (word == .object_closing) return null;
                    const field = Visitor{ .tape = self.tape, .index = self.curr };
                    const value = Visitor{ .tape = self.tape, .index = self.curr + 1 };
                    const value_word = self.tape.parsed.get(self.curr + 1);
                    defer self.curr = switch (value_word) {
                        .array_opening, .object_opening => |fit| fit.ptr,
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

            pub fn getSize(self: Object) u32 {
                const w = self.tape.parsed.get(self.root);
                assert(w == .object_opening);
                return w.object_opening.len;
            }
        };
    };
}
