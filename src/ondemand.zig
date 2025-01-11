const std = @import("std");
const common = @import("common.zig");
const types = @import("types.zig");
const intr = @import("intrinsics.zig");
const tokens = @import("tokens.zig");
const Vector = types.Vector;
const Pred = types.Predicate;
const Allocator = std.mem.Allocator;
const Error = types.Error;
const Number = types.Number;
const vector = types.vector;
const log = std.log;
const assert = std.debug.assert;

const Capacity = enum(u64) {
    infinite = std.math.maxInt(u64),
    normal = std.math.maxInt(u32),
    _,

    pub fn greater(self: Capacity, other: Capacity) bool {
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

pub fn Parser(comptime options: Options) type {
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
            .aligned = options.aligned,
            .stream = if (options.stream) |s|
                .{
                    .chunk_length = s.chunk_length,
                }
            else
                null,
        });
        const FileBuffer = std.ArrayListAligned(u8, types.Aligned(true).alignment);

        allocator: ?Allocator,
        tokens: Tokens,
        depth: u32 = 1,
        buffer: if (options.stream) |_| void else FileBuffer,
        chars: std.ArrayListUnmanaged(u8),
        chars_ptr: [*]u8 = undefined,
        curr_id: usize = undefined,

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

        pub fn parse(self: *Self, document: Aligned.slice) !Visitor {
            if (options.stream) |_| @compileError(common.error_messages.stream_slice);

            if (document.len > @intFromEnum(options.max_capacity)) return error.DocumentCapacity;
            try self.tokens.build(document);

            try self.chars.ensureTotalCapacityPrecise(self.allocator.?, document.len);
            self.chars.shrinkRetainingCapacity(0);
            self.chars_ptr = self.chars.items.ptr;
            self.depth = 1;

            return self.startVisitor();
        }

        pub fn load(self: *Self, file: std.fs.File) !Visitor {
            const stat = try file.stat();
            if (stat.size > @intFromEnum(options.max_capacity)) return error.DocumentCapacity;
            if (!manual_manage_strings) {
                try self.chars.ensureTotalCapacityPrecise(self.allocator.?, stat.size);
                self.chars.shrinkRetainingCapacity(0);
                self.chars_ptr = self.chars.items.ptr;
            }
            if (options.stream == null) {
                try self.buffer.resize(stat.size);
                _ = try file.readAll(self.buffer.items);
                try self.tokens.build(self.buffer.items);
            } else {
                try self.tokens.build(file);
            }

            self.depth = 1;

            return self.startVisitor();
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
            document: *Self,
            depth: u32,
            token: u8,
            id: usize,
            err: ?Error = null,

            pub fn getObject(self: Visitor) Error!Object {
                if (self.err) |err| return err;

                if (self.token != '{') return error.IncorrectType;
                Logger.logStart(self.document.*, "object", self.depth);
                return .{
                    .visitor = self.document.startVisitorWith(self.token),
                };
            }

            fn startOrResumeObject(self: Visitor) Error!Object {
                if (self.isAtStart()) {
                    return self.getObject();
                }
                return .{
                    .visitor = self.document.resumeVisitorWith('{'),
                    .entered = true,
                };
            }

            pub fn getArray(self: Visitor) Error!Array {
                if (self.err) |err| return err;

                if (self.token != '[') return error.IncorrectType;
                Logger.logStart(self.document.*, "array ", self.depth);
                return .{ .visitor = self.document.startVisitorWith(self.token) };
            }

            fn startOrResumeArray(self: Visitor) Error!Array {
                if (self.isAtStart()) {
                    return self.getArray();
                }
                return .{
                    .visitor = self.document.resumeVisitorWith('['),
                    .entered = true,
                };
            }

            pub fn getNumber(self: Visitor) Error!Number {
                if (self.err) |err| return err;

                var t = &self.document.tokens;
                // const curr = t.token;
                // errdefer t.revert();
                const ptr = try t.next();

                const n = try NumberParser.parse(ptr);
                Logger.log(self.document.*, "number", self.depth);
                self.document.depth -= 1;
                return n;
            }

            pub fn getUnsigned(self: Visitor) Error!u64 {
                if (self.err) |err| return err;

                var t = &self.document.tokens;
                // const curr = t.token;
                // errdefer t.revert();
                const ptr = try t.next();

                const n = try NumberParser.parseUnsigned(ptr);
                Logger.log(self.document.*, "u64   ", self.depth);
                self.document.depth -= 1;
                return n;
            }

            pub fn getSigned(self: Visitor) Error!i64 {
                if (self.err) |err| return err;

                var t = &self.document.tokens;
                // const curr = t.token;
                // errdefer t.revert();
                const ptr = try t.next();

                const n = try NumberParser.parseSigned(ptr);
                Logger.log(self.document.*, "i64   ", self.depth);
                self.document.depth -= 1;
                return n;
            }

            pub fn getFloat(self: Visitor) Error!f64 {
                if (self.err) |err| return err;

                var t = &self.document.tokens;
                // const curr = t.token;
                // errdefer t.revert();
                const ptr = try t.next();

                const n = try NumberParser.parseFloat(ptr);
                Logger.log(self.document.*, "f64   ", self.depth);
                self.document.depth -= 1;
                return n;
            }

            pub fn getString(self: Visitor) Error![]const u8 {
                if (options.stream != null and options.stream.?.manual_manage_strings)
                    @compileError("Strings stored in parser are not available. Consider enabling `.manage_strings` or using `writeString`.");

                if (self.err) |err| return err;

                var t = &self.document.tokens;
                // const curr = t.token;
                // errdefer t.revert();

                const quote = try t.next();
                if (quote[0] != '"') return error.IncorrectType;
                const str = try self.getUnsafeString(quote);
                self.document.depth -= 1;
                return str;
            }

            pub fn writeString(self: Visitor, buf: []u8) Error![]const u8 {
                if (self.err) |err| return err;

                var t = &self.document.tokens;
                // const curr = t.token;
                // errdefer t.revert();

                const quote = try t.next();
                if (quote[0] != '"') return error.IncorrectType;
                const str = try self.writeUnsafeString(quote, buf);
                self.document.depth -= 1;
                return str;
            }

            pub fn getBool(self: Visitor) Error!bool {
                if (self.err) |err| return err;

                var t = &self.document.tokens;
                // const curr = t.token;
                // errdefer t.revert();
                const ptr = try t.next();

                const check = @import("parsers/atoms.zig").checkBool;
                const is_true = try check(ptr);
                Logger.log(self.document.*, "bool  ", self.depth);
                self.document.depth -= 1;
                return is_true;
            }

            pub fn isNull(self: Visitor) Error!void {
                if (self.err) |err| return err;

                var t = &self.document.tokens;
                // const curr = t.token;
                // errdefer t.revert();
                const ptr = try t.next();

                const check = @import("parsers/atoms.zig").checkNull;
                try check(ptr);
                Logger.log(self.document.*, "null  ", self.depth);
                self.document.depth -= 1;
            }

            pub fn getAny(self: Visitor) Error!Element {
                if (self.err) |err| return err;

                var t = &self.document.tokens;
                return switch (try t.peek()) {
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
                        const obj = self.startOrResumeObject() catch return self.throw(error.IncorrectPointer);
                        break :brk obj.at(ptr);
                    }
                    if (common.isIndex(@TypeOf(ptr))) {
                        const arr = self.startOrResumeArray() catch return self.throw(error.IncorrectPointer);
                        break :brk arr.at(ptr);
                    }
                    @compileError(common.error_messages.at_type);
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
                switch ((try t.next())[0]) {
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
                    '"' => if (try t.peek() == ':') {
                        Logger.log(self.document.*, "key   ", actual_depth.*);
                        _ = try t.next();
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

                brk: while (true) {
                    switch ((try t.next())[0]) {
                        '[', '{' => {
                            Logger.logStart(self.document.*, "skip  ", actual_depth.*);
                            actual_depth.* += 1;
                        },
                        ']', '}' => {
                            Logger.logEnd(self.document.*, "skip  ", actual_depth.*);
                            actual_depth.* -= 1;
                            if (actual_depth.* <= wanted_depth) return;
                        },
                        ' ' => {
                            @branchHint(.unlikely);
                            break :brk;
                        },
                        else => {
                            Logger.log(self.document.*, "skip  ", actual_depth.*);
                        },
                    }
                }
                const token = try self.document.tokens.peek();
                return if (token == '{')
                    error.IncompleteObject
                else
                    error.IncompleteArray;
            }

            fn getUnsafeString(self: Visitor, ptr: [*]const u8) Error![]const u8 {
                var t = &self.document.tokens;

                const next_str = self.document.chars_ptr;
                const write = @import("parsers/string.zig").writeString;
                const sentinel = try write(ptr, next_str);
                const next_len = @intFromPtr(sentinel) - @intFromPtr(next_str);
                if (try t.peek() == ':') {
                    Logger.log(self.document.*, "key   ", self.depth);
                } else {
                    Logger.log(self.document.*, "string", self.depth);
                }
                self.document.chars_ptr = sentinel;
                return next_str[0..next_len];
            }

            fn writeUnsafeString(self: Visitor, ptr: [*]const u8, dest: [*]u8) Error![]const u8 {
                var t = &self.document.tokens;

                const next_str = dest;
                const write = @import("parsers/string.zig").writeString;
                const sentinel = try write(ptr, next_str);
                const next_len = @intFromPtr(sentinel) - @intFromPtr(next_str);
                if (try t.peek() == ':') {
                    Logger.log(self.document.*, "key   ", self.depth);
                } else {
                    Logger.log(self.document.*, "string", self.depth);
                }
                return next_str[0..next_len];
            }

            inline fn throw(self: Visitor, err: Error) Visitor {
                return .{
                    .document = self.document,
                    .depth = self.depth,
                    .token = self.token,
                    .id = self.id,
                    .err = err,
                };
            }

            inline fn isAtStart(self: Visitor) bool {
                return self.id == self.document.curr_id;
            }

            inline fn assertAtStart(self: Visitor) void {
                std.debug.assert(self.id == self.document.curr_id);
                std.debug.assert(self.depth == self.document.depth);
                std.debug.assert(self.document.depth > 0);
            }

            inline fn assertAtContainerStart(self: Visitor) void {
                std.debug.assert(self.id == self.document.curr_id + 1);
                std.debug.assert(self.depth == self.document.depth);
                std.debug.assert(self.document.depth > 0);
            }

            inline fn assertAtNext(self: Visitor) void {
                std.debug.assert(self.document.curr_id > self.id);
                std.debug.assert(self.depth == self.document.depth);
                std.debug.assert(self.document.depth > 0);
            }

            inline fn assertAtChild(self: Visitor) void {
                std.debug.assert(self.document.curr_id > self.id);
                std.debug.assert(self.document.depth == self.depth + 1);
                std.debug.assert(self.document.depth > 0);
            }

            inline fn assertAtRoot(self: Visitor) void {
                self.assertAtStart();
                std.debug.assert(self.document.depth == 1);
            }

            inline fn assertAtNonRoot(self: Visitor) void {
                self.assertAtStart();
                std.debug.assert(self.document.depth > 1);
            }
        };

        const Array = struct {
            visitor: Visitor,
            entered: bool = false,

            pub const Iterator = struct {
                root: Array,

                pub fn next(self: *Iterator) Error!?Visitor {
                    const doc = self.root.visitor.document;
                    const t = &doc.tokens;
                    if (!self.root.entered) {
                        defer self.root.entered = true;
                        _ = try t.next();
                        const token = try t.peek();
                        if (token == ']') {
                            _ = try t.next();
                            self.root.visitor.document.depth -= 1;
                            return null;
                        }
                        return self.root.getVisitor(token);
                    }
                    switch (try t.peek()) {
                        ',' => {
                            _ = try t.next();
                            return self.root.getVisitor(try t.peek());
                        },
                        ']' => {
                            _ = try t.next();
                            self.root.visitor.document.depth -= 1;
                            return null;
                        },
                        else => return error.ExpectedArrayCommaOrEnd,
                    }
                }
            };

            pub fn iterator(self: Array) Iterator {
                return .{ .root = self };
            }

            pub fn skip(self: Array) Error!void {
                self.visitor.skip();
            }

            pub fn at(self: Array, index: u32) Visitor {
                var it = self.iterator();
                var i: u32 = 0;
                while (it.next() catch |err| return self.visitor.throw(err)) |v| : (i += 1) {
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
                var it = self.iterator();
                var count: u32 = 0;
                while (try it.next()) |v| : (try v.skip()) count += 1;
                return count;
            }

            fn getVisitor(self: Array, token: u8) Visitor {
                return self.visitor.document.startChildVisitorWith(token);
            }
        };

        const Object = struct {
            visitor: Visitor,
            entered: bool = false,

            pub const Field = struct {
                key_buf: if (options.stream) |s| [s.chunk_length]u8 else void = undefined,
                key: []const u8,
                value: Visitor,

                pub fn skip(self: Field) Error!void {
                    return self.value.skip();
                }
            };

            pub const Iterator = struct {
                root: Object,

                pub fn next(self: *Iterator) Error!?Field {
                    const doc = self.root.visitor.document;
                    const t = &doc.tokens;
                    if (!self.root.entered) {
                        defer self.root.entered = true;
                        _ = try t.next();
                        if (try t.peek() == '}') {
                            _ = try t.next();
                            self.root.visitor.document.depth -= 1;
                            return null;
                        }
                        return try self.root.getField();
                    }
                    switch (try t.peek()) {
                        ',' => {
                            _ = try t.next();
                            return try self.root.getField();
                        },
                        '}' => {
                            _ = try t.next();
                            self.root.visitor.document.depth -= 1;
                            return null;
                        },
                        else => return error.ExpectedObjectCommaOrEnd,
                    }
                }
            };

            pub fn iterator(self: Object) Iterator {
                return .{ .root = self };
            }

            pub fn skip(self: Object) Error!void {
                return self.visitor.skip();
            }

            pub fn at(self: Object, key: []const u8) Visitor {
                var it = self.iterator();
                while (it.next() catch |err| return self.visitor.throw(err)) |field| {
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
                var it = self.iterator();
                var count: u32 = 0;
                while (try it.next()) |field| : (try field.skip()) count += 1;
                return count;
            }

            fn getField(self: Object) Error!Field {
                const doc = self.visitor.document;
                var t = &doc.tokens;
                var key_visitor = doc.startVisitorWith(undefined);
                // const curr = t.token;
                // errdefer t.revert();
                const quote = try t.next();
                if (quote[0] != '"') return error.ExpectedKey;
                const key = if (manual_manage_strings)
                    try key_visitor.writeUnsafeString(quote, &self.visitor.document.field_key_buf)
                else
                    try key_visitor.getUnsafeString(quote);
                const colon = try t.next();
                if (colon[0] != ':') return error.ExpectedColon;
                return .{
                    .key = key,
                    .value = try doc.startChildVisitor(),
                };
            }

            fn writeField(self: Object, dest: *Field) Error!Field {
                const doc = self.visitor.document;
                var t = &doc.tokens;
                var key_visitor = doc.startVisitorWith(undefined);
                // const curr = t.token;
                // errdefer t.revert();
                const quote = try t.next();
                if (quote[0] != '"') return error.ExpectedKey;
                const key = if (manual_manage_strings)
                    try key_visitor.writeUnsafeString(quote, &dest.key_buf)
                else
                    try key_visitor.getUnsafeString(quote);
                const colon = try t.next();
                if (colon[0] != ':') return error.ExpectedColon;
                dest.* = .{
                    .key = key,
                    .value = try doc.startChildVisitor(),
                };
            }
        };

        fn startVisitor(self: *Self) !Visitor {
            self.curr_id += 1;
            return .{
                .document = self,
                .depth = self.depth,
                .id = self.curr_id,
                .token = try self.tokens.peek(),
            };
        }

        fn startVisitorWith(self: *Self, token: u8) Visitor {
            self.curr_id += 1;
            return .{
                .document = self,
                .depth = self.depth,
                .id = self.curr_id,
                .token = token,
            };
        }

        fn startChildVisitor(self: *Self) !Visitor {
            self.depth += 1;
            self.curr_id += 1;
            return .{
                .document = self,
                .depth = self.depth,
                .id = self.curr_id,
                .token = try self.tokens.peek(),
            };
        }

        fn startChildVisitorWith(self: *Self, token: u8) Visitor {
            self.depth += 1;
            self.curr_id += 1;
            return .{
                .document = self,
                .depth = self.depth,
                .id = self.curr_id,
                .token = token,
            };
        }

        fn resumeVisitorWith(self: *Self, token: u8) Visitor {
            return .{
                .document = self,
                .depth = self.depth,
                .id = self.curr_id,
                .token = token,
            };
        }

        const Logger = struct {
            pub fn logDepth(expected: u32, actual: u32) void {
                if (true) return;
                std.log.info(" SKIP     Wanted depth: {}, actual: {}", .{ expected, actual });
            }

            pub fn logStart(parser: Self, label: []const u8, depth: u32) void {
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
            pub fn log(parser: Self, label: []const u8, depth: u32) void {
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
            pub fn logEnd(parser: Self, label: []const u8, depth: u32) void {
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
