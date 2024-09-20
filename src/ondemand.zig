const std = @import("std");
const common = @import("common.zig");
const types = @import("types.zig");
const intr = @import("intrinsics.zig");
const tokens = @import("tokens.zig");
const ArrayList = std.ArrayList;
const Vector = types.Vector;
const Pred = types.Predicate;
const Allocator = std.mem.Allocator;
const Error = types.Error;
const Number = types.Number;
const vector = types.vector;
const log = std.log;
const assert = std.debug.assert;

pub const Options = struct {
    max_capacity: u32 = common.default_max_capacity,
    aligned: bool = false,
};

pub fn Parser(comptime options: Options) type {
    const token_options = tokens.Options{
        .aligned = options.aligned,
    };

    const NumberParser = @import("parsers/number/parser.zig").Parser;

    return struct {
        const Self = @This();
        const Tokens = tokens.Iterator(token_options);
        const Aligned = types.Aligned(options.aligned);

        tokens: Tokens,
        chars: ArrayList(u8),
        depth: u32 = 1,

        pub fn init(allocator: Allocator) Self {
            return .{
                .tokens = Tokens.init(allocator),
                .chars = ArrayList(u8).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.chars.deinit();
            self.tokens.deinit();
        }

        pub fn parse(self: *Self, document: Aligned.slice) !Visitor {
            if (document.len >= options.max_capacity) return error.ExceededCapacity;
            const t = &self.tokens;
            try t.build(document);

            try self.chars.ensureTotalCapacity(t.indexer.reader.document.len + Vector.len_bytes);
            self.chars.shrinkRetainingCapacity(0);
            self.depth = 1;

            return Visitor{
                .document = self,
                .token = t.token,
                .depth = self.depth,
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
            document: *Self,
            token: u32,
            depth: u32,
            err: ?Error = null,

            pub fn getObject(self: Visitor) Error!Object {
                if (self.err) |err| return err;

                const document = self.document.tokens.document();
                const indexes = self.document.tokens.indexes();
                const token = document[indexes[self.token]];

                if (token == '{') {
                    Logger.logStart(self.document.*, "object", self.depth);
                    return .{ .visitor = .{
                        .document = self.document,
                        .token = self.token,
                        .depth = self.depth,
                    } };
                }
                return error.IncorrectType;
            }

            pub fn getArray(self: Visitor) Error!Array {
                if (self.err) |err| return err;

                const document = self.document.tokens.document();
                const indexes = self.document.tokens.indexes();
                const token = document[indexes[self.token]];

                if (token == '[') {
                    Logger.logStart(self.document.*, "array ", self.depth);
                    return .{ .visitor = .{
                        .document = self.document,
                        .token = self.token,
                        .depth = self.depth,
                    } };
                }
                return error.IncorrectType;
            }

            pub fn getNumber(self: Visitor) Error!Number {
                if (self.err) |err| return err;

                var t = &self.document.tokens;
                const curr = t.token;
                errdefer t.jumpBack(curr);
                _ = t.next();

                const n = try NumberParser.parse(t.ptr);
                Logger.log(self.document.*, "number", self.depth);
                self.document.depth -= 1;
                return n;
            }

            pub fn getUnsigned(self: Visitor) Error!u64 {
                if (self.err) |err| return err;

                var t = &self.document.tokens;
                const curr = t.token;
                errdefer t.jumpBack(curr);
                _ = t.next();

                const n = try NumberParser.parseUnsigned(t.ptr);
                Logger.log(self.document.*, "u64   ", self.depth);
                self.document.depth -= 1;
                return n;
            }

            pub fn getSigned(self: Visitor) Error!i64 {
                if (self.err) |err| return err;

                var t = &self.document.tokens;
                const curr = t.token;
                errdefer t.jumpBack(curr);
                _ = t.next();

                const n = try NumberParser.parseSigned(t.ptr);
                Logger.log(self.document.*, "i64   ", self.depth);
                self.document.depth -= 1;
                return n;
            }

            pub fn getFloat(self: Visitor) Error!f64 {
                if (self.err) |err| return err;

                var t = &self.document.tokens;
                const curr = t.token;
                errdefer t.jumpBack(curr);
                _ = t.next();

                const n = try NumberParser.parseFloat(t.ptr);
                Logger.log(self.document.*, "f64   ", self.depth);
                self.document.depth -= 1;
                return n;
            }

            pub fn getString(self: Visitor) Error![]const u8 {
                if (self.err) |err| return err;

                var t = &self.document.tokens;
                const curr = t.token;
                errdefer t.jumpBack(curr);

                if (self.document.tokens.peek() != '"') return error.IncorrectType;
                _ = t.next();

                const string = try self.getUnsafeString();
                self.document.depth -= 1;
                return string;
            }

            pub fn getBool(self: Visitor) Error!bool {
                if (self.err) |err| return err;

                var t = &self.document.tokens;
                const curr = t.token;
                errdefer t.jumpBack(curr);
                _ = t.next();

                const check = @import("parsers/atoms.zig").checkBool;
                const is_true = try check(t.ptr);
                Logger.log(self.document.*, "bool  ", self.depth);
                self.document.depth -= 1;
                return is_true;
            }

            pub fn isNull(self: Visitor) Error!void {
                if (self.err) |err| return err;

                var t = &self.document.tokens;
                const curr = t.token;
                errdefer t.jumpBack(curr);
                _ = t.next();

                const check = @import("parsers/atoms.zig").checkNull;
                try check(t.ptr);
                Logger.log(self.document.*, "null  ", self.depth);
                self.document.depth -= 1;
            }

            pub fn getAny(self: Visitor) Error!Element {
                if (self.err) |err| return err;

                var t = &self.document.tokens;
                return switch (t.peek()) {
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
                        return error.ExpectedValue;
                    },
                };
            }

            pub fn at(self: Visitor, ptr: anytype) Visitor {
                if (self.err) |_| return self;

                const query = brk: {
                    if (common.isString(@TypeOf(ptr))) {
                        const obj = self.getObject() catch return self.throw(error.IncorrectPointer);
                        break :brk obj.at(ptr);
                    }
                    if (common.isIndex(@TypeOf(ptr))) {
                        const arr = self.getArray() catch return self.throw(error.IncorrectPointer);
                        break :brk arr.at(ptr);
                    }
                    @compileError("JSON Pointer must be a string or number");
                };
                return query;
            }

            pub fn getSize(self: Visitor) Error!u32 {
                if (self.err) |err| return err;

                if (self.getArray()) |arr| return arr.getSize() else |_| {}
                if (self.getObject()) |obj| return obj.getSize() else |_| {}
                return error.IncorrectType;
            }

            pub fn skip(self: Visitor) Error!void {
                if (self.err) |err| return err;

                const t = &self.document.tokens;
                const wanted_depth = self.depth - 1;
                const actual_depth = &self.document.depth;

                Logger.logDepth(wanted_depth, actual_depth.*);

                if (actual_depth.* <= wanted_depth) return;
                switch (t.next().?.*) {
                    '[', '{', ':' => {
                        Logger.logStart(self.document.*, "skip  ", actual_depth.*);
                    },
                    ',' => {
                        Logger.log(self.document.*, "skip  ", actual_depth.*);
                    },
                    ']', '}' => {
                        Logger.logEnd(self.document.*, "skip  ", actual_depth.*);
                        actual_depth.* -= 1;
                        if (actual_depth.* <= wanted_depth) return;
                    },
                    '"' => if (t.peek() == ':') {
                        Logger.log(self.document.*, "key   ", actual_depth.*);
                        _ = t.next();
                    } else {
                        Logger.log(self.document.*, "skip  ", actual_depth.*);
                        actual_depth.* -= 1;
                        if (actual_depth.* <= wanted_depth) return;
                    },
                    else => {
                        Logger.log(self.document.*, "skip  ", actual_depth.*);
                        actual_depth.* -= 1;
                        if (actual_depth.* <= wanted_depth) return;
                    },
                }

                while (t.next()) |p| {
                    switch (p.*) {
                        '[', '{' => {
                            Logger.logStart(self.document.*, "skip  ", actual_depth.*);
                            actual_depth.* += 1;
                        },
                        ']', '}' => {
                            Logger.logEnd(self.document.*, "skip  ", actual_depth.*);
                            actual_depth.* -= 1;
                            if (actual_depth.* <= wanted_depth) return;
                        },
                        else => {
                            Logger.log(self.document.*, "skip  ", actual_depth.*);
                        },
                    }
                }
                const document = self.document.tokens.document();
                const indexes = self.document.tokens.indexes();
                const token = document[indexes[self.token]];
                return if (token == '{')
                    error.IncompleteObject
                else
                    error.IncompleteArray;
            }

            fn getUnsafeString(self: Visitor) Error![]const u8 {
                var t = &self.document.tokens;

                const chars = &self.document.chars;
                const next_str = chars.items.len;
                const write = @import("parsers/string.zig").writeString;
                try write(t.ptr, chars);
                const next_len = chars.items.len - next_str;
                if (t.peek() == ':') {
                    Logger.log(self.document.*, "key   ", self.depth);
                } else {
                    Logger.log(self.document.*, "string", self.depth);
                }
                return chars.items[next_str..][0..next_len];
            }

            fn throw(self: Visitor, err: Error) Visitor {
                return .{
                    .document = self.document,
                    .token = self.token,
                    .depth = self.depth,
                    .err = err,
                };
            }
        };

        const Array = struct {
            visitor: Visitor,

            pub fn next(self: Array) Error!?Visitor {
                const doc = self.visitor.document;
                const t = &doc.tokens;
                if (self.visitor.token == t.token) {
                    _ = t.next();
                    if (t.peek() == ']') {
                        _ = t.next();
                        self.visitor.document.depth -= 1;
                        return null;
                    }
                    return self.getVisitor();
                }
                switch (t.peek()) {
                    ',' => {
                        _ = t.next();
                        return self.getVisitor();
                    },
                    ']' => {
                        _ = t.next();
                        self.visitor.document.depth -= 1;
                        return null;
                    },
                    else => return error.ExpectedArrayCommaOrEnd,
                }
            }

            pub fn skip(self: Array) Error!void {
                self.visitor.skip();
            }

            pub fn at(self: Array, index: u32) Visitor {
                var i: u32 = 0;
                while (self.next() catch |err| return self.visitor.throw(err)) |v| : (i += 1) {
                    if (i == index) {
                        return v;
                    } else {
                        v.skip() catch |err| return self.visitor.throw(err);
                    }
                }
                return self.visitor.throw(error.IndexOutOfBounds);
            }

            pub fn isEmpty(self: Array) Error!bool {
                return (try self.getSize()) == 0;
            }

            pub fn getSize(self: Array) Error!u32 {
                var count: u32 = 0;
                while (try self.next()) |v| : (try v.skip()) count += 1;
                return count;
            }

            fn getVisitor(self: Array) Visitor {
                self.visitor.document.depth += 1;
                return Visitor{
                    .document = self.visitor.document,
                    .token = self.visitor.document.tokens.token,
                    .depth = self.visitor.document.depth,
                };
            }
        };

        const Object = struct {
            visitor: Visitor,

            pub const Field = struct {
                key: []const u8,
                value: Visitor,

                pub fn skip(self: Field) Error!void {
                    return self.value.skip();
                }
            };

            pub fn next(self: Object) Error!?Field {
                const doc = self.visitor.document;
                const t = &doc.tokens;
                if (self.visitor.token == t.token) {
                    _ = t.next();
                    if (t.peek() == '}') {
                        _ = t.next();
                        self.visitor.document.depth -= 1;
                        return null;
                    }
                    return try self.getField();
                }
                switch (t.peek()) {
                    ',' => {
                        _ = t.next();
                        return try self.getField();
                    },
                    '}' => {
                        _ = t.next();
                        self.visitor.document.depth -= 1;
                        return null;
                    },
                    else => return error.ExpectedObjectCommaOrEnd,
                }
            }

            pub fn skip(self: Object) Error!void {
                return self.visitor.skip();
            }

            pub fn at(self: Object, key: []const u8) Visitor {
                while (self.next() catch |err| return self.visitor.throw(err)) |field| {
                    if (std.mem.eql(u8, field.key, key)) {
                        return field.value;
                    } else {
                        field.skip() catch |err| return self.visitor.throw(err);
                    }
                }
                return self.visitor.throw(error.MissingField);
            }

            pub fn isEmpty(self: Object) Error!bool {
                return (try self.getSize()) == 0;
            }

            pub fn getSize(self: Object) Error!u32 {
                var count: u32 = 0;
                while (try self.next()) |field| : (try field.skip()) count += 1;
                return count;
            }

            fn getField(self: Object) Error!Field {
                const doc = self.visitor.document;
                var t = &doc.tokens;
                var key_visitor = Visitor{
                    .document = doc,
                    .token = t.token,
                    .depth = self.visitor.document.depth,
                };
                const curr = t.token;
                errdefer t.jumpBack(curr);
                const quote = t.next() orelse return error.IncompleteObject;
                if (quote.* != '"') return error.ExpectedKeyAsString;
                const key = try key_visitor.getUnsafeString();
                const colon = t.next() orelse return error.IncompleteObject;
                if (colon.* != ':') return error.ExpectedColon;
                self.visitor.document.depth += 1;
                return .{
                    .key = key,
                    .value = .{
                        .document = doc,
                        .token = t.token,
                        .depth = self.visitor.document.depth,
                    },
                };
            }
        };

        const Logger = struct {
            pub fn logDepth(expected: u32, actual: u32) void {
                if (true) return;
                std.log.info(" SKIP     Wanted depth: {}, actual: {}", .{ expected, actual });
            }

            pub fn logStart(parser: Self, label: []const u8, depth: u32) void {
                if (true) return;
                const t = parser.tokens;
                var buffer = t.ptr[0..Vector.len_bytes].*;
                for (&buffer) |*b| {
                    if (b.* == '\n') b.* = ' ';
                    if (b.* == '\t') b.* = ' ';
                    if (b.* > 127) b.* = '*';
                }
                std.log.info("+{s} | {s} | depth: {} | next: {c}", .{ label, buffer, depth, t.peek() });
            }
            pub fn log(parser: Self, label: []const u8, depth: u32) void {
                if (true) return;
                const t = parser.tokens;
                var buffer = t.ptr[0..Vector.len_bytes].*;
                for (&buffer) |*b| {
                    if (b.* == '\n') b.* = ' ';
                    if (b.* == '\t') b.* = ' ';
                    if (b.* > 127) b.* = '*';
                }
                std.log.info(" {s} | {s} | depth: {} | next: {c}", .{ label, buffer, depth, t.peek() });
            }
            pub fn logEnd(parser: Self, label: []const u8, depth: u32) void {
                if (true) return;
                const t = parser.tokens;
                var buffer = t.ptr[0..Vector.len_bytes].*;
                for (&buffer) |*b| {
                    if (b.* == '\n') b.* = ' ';
                    if (b.* == '\t') b.* = ' ';
                    if (b.* > 127) b.* = '*';
                }
                std.log.info("-{s} | {s} | depth: {} | next: {c}", .{ label, buffer, depth, t.peek() });
            }
        };
    };
}
