const std = @import("std");
const common = @import("common.zig");
const types = @import("types.zig");
const intr = @import("intrinsics.zig");
const tokens = @import("tokens.zig");
const ArrayList = std.ArrayList;
const Indexer = @import("Indexer.zig");
const Vector = types.Vector;
const Pred = types.Predicate;
const TokenIterator = tokens.Iterator;
const TokenOptions = tokens.Options;
const Allocator = std.mem.Allocator;
const Error = types.Error;
const Number = types.Number;
const vector = types.vector;
const log = std.log;
const assert = std.debug.assert;

const TOKEN_OPTIONS = TokenOptions{
    .copy_bounded = true,
};

const NumberParser = @import("parsers/number/parser.zig").Parser(TOKEN_OPTIONS);

pub const Parser = struct {
    const Buffer = std.ArrayListAligned(u8, types.Vector.LEN_BYTES);

    buffer: Buffer,
    tokens: TokenIterator(TOKEN_OPTIONS),
    chars: ArrayList(u8),
    depth: u32 = 1,

    pub fn init(allocator: Allocator) Parser {
        return Parser{
            .buffer = Buffer.init(allocator),
            .tokens = TokenIterator(TOKEN_OPTIONS).init(allocator),
            .chars = ArrayList(u8).init(allocator),
        };
    }

    pub fn deinit(self: *Parser) void {
        self.buffer.deinit();
        self.chars.deinit();
        self.tokens.deinit();
    }

    pub fn parse(self: *Parser, document: []const u8) !Visitor {
        const t = &self.tokens;
        try t.build(document);

        try self.chars.ensureTotalCapacity(t.indexer.reader.document.len + Vector.LEN_BYTES);
        self.chars.shrinkRetainingCapacity(0);
        self.depth = 1;

        return Visitor{
            .document = self,
            .token = t.token,
            .depth = self.depth,
        };
    }

    pub fn load(self: *Parser, path: []const u8) !Visitor {
        const file = try std.fs.cwd().openFile(path, .{});
        const len = (try file.metadata()).size();

        try self.buffer.resize(len);

        _ = try file.readAll(self.buffer.items);
        self.buffer.items.len = len;

        return self.parse(self.buffer.items);
    }
};

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
    document: *Parser,
    token: u32,
    depth: u32,
    err: ?Error = null,

    pub fn getObject(self: Visitor) Error!Object {
        if (self.err) |err| return err;

        if (self.isObject()) {
            Logger.logStart(self.document.*, "object", self.depth);
            return .{ .visitor = .{
                .document = self.document,
                .token = self.document.tokens.token,
                .depth = self.document.depth,
            } };
        }
        return error.IncorrectType;
    }

    pub fn getArray(self: Visitor) Error!Array {
        if (self.err) |err| return err;

        if (self.isArray()) {
            Logger.logStart(self.document.*, "array ", self.depth);
            return .{ .visitor = .{
                .document = self.document,
                .token = self.document.tokens.token,
                .depth = self.document.depth,
            } };
        }
        return error.IncorrectType;
    }

    pub fn getNumber(self: Visitor) Error!Number {
        if (self.err) |err| return err;

        var t = &self.document.tokens;
        const curr = t.token;
        errdefer t.jumpBack(curr);
        _ = t.next(.none) orelse return error.ExpectedValue;

        const n = try NumberParser.parse(.none, t);
        Logger.log(self.document.*, "number", self.depth);
        self.document.depth -= 1;
        return n;
    }

    pub fn getUnsigned(self: Visitor) Error!u64 {
        if (self.err) |err| return err;

        var t = &self.document.tokens;
        const curr = t.token;
        errdefer t.jumpBack(curr);
        _ = t.next(.none) orelse return error.ExpectedValue;

        const n = try NumberParser.parseUnsigned(.none, t);
        Logger.log(self.document.*, "u64   ", self.depth);
        self.document.depth -= 1;
        return n;
    }

    pub fn getSigned(self: Visitor) Error!i64 {
        if (self.err) |err| return err;

        var t = &self.document.tokens;
        const curr = t.token;
        errdefer t.jumpBack(curr);
        _ = t.next(.none) orelse return error.ExpectedValue;

        const n = try NumberParser.parseSigned(.none, t);
        Logger.log(self.document.*, "i64   ", self.depth);
        self.document.depth -= 1;
        return n;
    }

    pub fn getFloat(self: Visitor) Error!f64 {
        if (self.err) |err| return err;

        var t = &self.document.tokens;
        const curr = t.token;
        errdefer t.jumpBack(curr);
        _ = t.next(.none) orelse return error.ExpectedValue;

        const n = try NumberParser.parseFloat(.none, t);
        Logger.log(self.document.*, "f64   ", self.depth);
        self.document.depth -= 1;
        return n;
    }

    pub fn getString(self: Visitor) Error![]const u8 {
        if (self.err) |err| return err;

        var t = &self.document.tokens;
        const curr = t.token;
        errdefer t.jumpBack(curr);
        if (!self.isString()) return error.IncorrectType;
        _ = t.next(.none) orelse {};

        const string = try self.getUnsafeString();
        self.document.depth -= 1;
        return string;
    }

    pub fn getBool(self: Visitor) Error!bool {
        if (self.err) |err| return err;

        var t = &self.document.tokens;
        const curr = t.token;
        errdefer t.jumpBack(curr);
        _ = t.next(.none) orelse return error.ExpectedValue;

        const check = @import("parsers/atoms.zig").checkBool;
        const is_true = try check(TOKEN_OPTIONS, t.*);
        _ = t.consume(if (is_true) 4 else 5, .none);
        Logger.log(self.document.*, "bool  ", self.depth);
        self.document.depth -= 1;
        return is_true;
    }

    pub fn isNull(self: Visitor) Error!void {
        if (self.err) |err| return err;

        var t = &self.document.tokens;
        const curr = t.token;
        errdefer t.jumpBack(curr);
        _ = t.next(.none) orelse return error.ExpectedValue;

        const check = @import("parsers/atoms.zig").checkNull;
        try check(TOKEN_OPTIONS, t.*);
        _ = t.consume(4, .none);
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
                const obj = self.getObject() catch return .{
                    .document = self.document,
                    .token = self.token,
                    .depth = self.depth,
                    .err = error.IncorrectPointer,
                };
                break :brk obj.at(ptr);
            }
            if (common.isIndex(@TypeOf(ptr))) {
                const arr = self.getArray() catch return .{
                    .document = self.document,
                    .token = self.token,
                    .depth = self.depth,
                    .err = error.IncorrectPointer,
                };
                break :brk arr.at(ptr);
            }
            @compileError("JSON Pointer must be a string or number");
        };
        return if (query) |v| v else |err| .{
            .document = self.document,
            .token = self.token,
            .depth = self.depth,
            .err = err,
        };
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
        switch (t.next(.none).?) {
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
                _ = t.next(.none).?;
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

        while (t.next(.none)) |p| {
            switch (p) {
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
        return error.IncompleteObject;
    }

    fn isObject(self: Visitor) bool {
        return self.document.tokens.peek() == '{';
    }

    fn isArray(self: Visitor) bool {
        return self.document.tokens.peek() == '[';
    }

    fn isString(self: Visitor) bool {
        return self.document.tokens.peek() == '"';
    }

    fn getUnsafeString(self: Visitor) Error![]const u8 {
        var t = &self.document.tokens;

        _ = t.consume(1, .none);
        const chars = &self.document.chars;
        const next_str = chars.items.len;
        const parse = @import("parsers/string.zig").writeString;
        try parse(TOKEN_OPTIONS, .none, t, chars);
        const next_len = chars.items.len - next_str;
        if (t.peek() == ':') {
            Logger.log(self.document.*, "key   ", self.depth);
        } else {
            Logger.log(self.document.*, "string", self.depth);
        }
        return chars.items[next_str..][0..next_len];
    }
};

const Array = struct {
    visitor: Visitor,

    pub fn next(self: Array) Error!?Visitor {
        const doc = self.visitor.document;
        const t = &doc.tokens;
        if (self.visitor.token == t.token) {
            _ = t.next(.none) orelse return error.IncompleteArray;
            if (t.peek() == ']') {
                _ = t.next(.none) orelse {};
                self.visitor.document.depth -= 1;
                return null;
            }
            return self.getVisitor();
        }
        switch (t.peek()) {
            ',' => {
                _ = t.next(.none) orelse return error.IncompleteArray;
                return self.getVisitor();
            },
            ']' => {
                _ = t.next(.none) orelse {};
                self.visitor.document.depth -= 1;
                return null;
            },
            else => return error.ExpectedArrayCommaOrEnd,
        }
    }

    pub fn skip(self: Array) Error!void {
        self.visitor.skip();
    }

    pub fn at(self: Array, index: u32) Error!Visitor {
        var i: u32 = 0;
        while (try self.next()) |v| : (i += 1) if (i == index) return v else try v.skip();
        return error.IndexOutOfBounds;
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
            _ = t.next(.none) orelse return error.IncompleteObject;
            if (t.peek() == '}') {
                _ = t.next(.none) orelse {};
                self.visitor.document.depth -= 1;
                return null;
            }
            return try self.getField();
        }
        switch (t.peek()) {
            ',' => {
                _ = t.next(.none) orelse return error.IncompleteObject;
                return try self.getField();
            },
            '}' => {
                _ = t.next(.none) orelse {};
                self.visitor.document.depth -= 1;
                return null;
            },
            else => return error.ExpectedObjectCommaOrEnd,
        }
    }

    pub fn skip(self: Object) Error!void {
        return self.visitor.skip();
    }

    pub fn at(self: Object, key: []const u8) Error!Visitor {
        while (try self.next()) |field| if (std.mem.eql(u8, field.key, key)) return field.value else try field.skip();
        return error.MissingField;
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
        const quote = t.next(.none) orelse return error.IncompleteObject;
        if (quote != '"') return error.ExpectedKeyAsString;
        const key = try key_visitor.getUnsafeString();
        const colon = t.next(.none) orelse return error.IncompleteObject;
        if (colon != ':') return error.ExpectedColon;
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

    pub fn logStart(parser: Parser, label: []const u8, depth: u32) void {
        if (true) return;
        const t = parser.tokens;
        var buffer = t.ptr[0..Vector.LEN_BYTES].*;
        for (&buffer) |*b| {
            if (b.* == '\n') b.* = ' ';
            if (b.* == '\t') b.* = ' ';
            if (b.* > 127) b.* = '*';
        }
        std.log.info("+{s} | {s} | depth: {} | next: {c}", .{ label, buffer, depth, t.peek() });
    }
    pub fn log(parser: Parser, label: []const u8, depth: u32) void {
        if (true) return;
        const t = parser.tokens;
        var buffer = t.ptr[0..Vector.LEN_BYTES].*;
        for (&buffer) |*b| {
            if (b.* == '\n') b.* = ' ';
            if (b.* == '\t') b.* = ' ';
            if (b.* > 127) b.* = '*';
        }
        std.log.info(" {s} | {s} | depth: {} | next: {c}", .{ label, buffer, depth, t.peek() });
    }
    pub fn logEnd(parser: Parser, label: []const u8, depth: u32) void {
        if (true) return;
        const t = parser.tokens;
        var buffer = t.ptr[0..Vector.LEN_BYTES].*;
        for (&buffer) |*b| {
            if (b.* == '\n') b.* = ' ';
            if (b.* == '\t') b.* = ' ';
            if (b.* > 127) b.* = '*';
        }
        std.log.info("-{s} | {s} | depth: {} | next: {c}", .{ label, buffer, depth, t.peek() });
    }
};
