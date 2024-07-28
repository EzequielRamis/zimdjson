const std = @import("std");
const common = @import("common.zig");
const types = @import("types.zig");
const intr = @import("intrinsics.zig");
const parsers = @import("parsers.zig");
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
const NumberParser = parsers.Number(TOKEN_OPTIONS);
const vector = types.vector;
const log = std.log;
const assert = std.debug.assert;

const TOKEN_OPTIONS = TokenOptions{
    .copy_bounded = true,
};

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
            Logger.logStart(self.document.*, "array", self.depth);
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
        errdefer t.jumpBack(t.token);
        const n = try NumberParser.parse(.none, t);
        Logger.log(self.document.*, "number", self.depth);
        self.document.depth -= 1;
        return n;
    }

    pub fn getUnsigned(self: Visitor) Error!u64 {
        if (self.err) |err| return err;

        var t = &self.document.tokens;
        errdefer t.jumpBack(t.token);

        const n = try NumberParser.parseUnsigned(.none, t);
        Logger.log(self.document.*, "u64   ", self.depth);
        self.document.depth -= 1;
        return n;
    }

    pub fn getSigned(self: Visitor) Error!i64 {
        if (self.err) |err| return err;

        var t = &self.document.tokens;
        errdefer t.jumpBack(t.token);

        const n = try NumberParser.parseSigned(.none, t);
        Logger.log(self.document.*, "i64   ", self.depth);
        self.document.depth -= 1;
        return n;
    }

    pub fn getFloat(self: Visitor) Error!f64 {
        if (self.err) |err| return err;

        var t = &self.document.tokens;
        errdefer t.jumpBack(t.token);

        const n = try NumberParser.parseFloat(.none, t);
        Logger.log(self.document.*, "f64   ", self.depth);
        self.document.depth -= 1;
        return n;
    }

    pub fn getString(self: Visitor) Error![]const u8 {
        if (self.err) |err| return err;

        if (!self.isString()) return error.IncorrectType;
        return self.getUnsafeString();
    }

    pub fn getBool(self: Visitor) Error!bool {
        if (self.err) |err| return err;

        var t = &self.document.tokens;
        errdefer t.jumpBack(t.token);

        const is_true = try parsers.checkBool(TOKEN_OPTIONS, t.*);
        _ = t.consume(if (is_true) 4 else 5, .none);
        Logger.log(self.document.*, "bool  ", self.depth);
        self.document.depth -= 1;
        return is_true;
    }

    pub fn isNull(self: Visitor) Error!void {
        if (self.err) |err| return err;

        var t = &self.document.tokens;
        errdefer t.jumpBack(t.token);

        try parsers.checkNull(TOKEN_OPTIONS, t.*);
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
            '"' => .{ .string = try self.getUnsafeString() },
            '-', '0'...'9' => switch (try self.getNumber()) {
                .unsigned => |n| .{ .unsigned = n },
                .signed => |n| .{ .signed = n },
                .float => |n| .{ .float = n },
            },
            '[' => .{ .array = try self.getArray() },
            '{' => .{ .object = try self.getObject() },
            else => {
                t.jumpBack(t.token);
                return error.ExpectedValue;
            },
        };
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
        errdefer t.jumpBack(t.token);

        _ = t.consume(1, .none);
        const chars = &self.document.chars;
        const next_str = chars.items.len;
        try parsers.writeString(TOKEN_OPTIONS, .none, t, chars);
        const next_len = chars.items.len - next_str;
        if (t.peek() == ':') {
            Logger.log(self.document.*, "key   ", self.depth);
        } else {
            Logger.log(self.document.*, "string", self.depth);
        }
        self.document.depth -= 1;
        return chars.items[next_str..][0..next_len];
    }
};

const Array = struct {
    visitor: Visitor,

    pub fn next(self: Array) Error!?Visitor {
        const doc = self.visitor.document;
        const t = &doc.tokens;
        _ = t.next(.none).?;
        if (self.visitor.token + 1 == t.token) {
            const q = t.next(.none) orelse return error.IncompleteObject;
            if (q == ']') {
                self.visitor.documenactual_depth.* -= 1;
                return null;
            }
            return self.getVisitor();
        }
        const p = t.next(.none) orelse return error.IncompleteObject;
        switch (p) {
            ',' => {
                return self.getVisitor();
            },
            ']' => {
                self.visitor.documenactual_depth.* -= 1;
                return null;
            },
            else => return error.ExpectedArrayCommaOrEnd,
        }
    }

    pub fn skip(self: Array) Error!void {
        self.visitor.skip();
    }

    pub fn at(self: Array, index: usize) Error!Visitor {
        var i: usize = 0;
        while (try self.next()) |el| : (i += 1) if (i == index) return el;
        return error.IndexOutOfBounds;
    }

    pub fn isEmpty(self: Array) Error!bool {
        return (try self.getSize()) == 0;
    }

    pub fn getSize(self: Array) Error!u32 {
        var count: u32 = 0;
        while (try self.next()) |_| count += 1;
        return count;
    }

    fn getVisitor(self: Array) Visitor {
        return Visitor{
            .document = self.visitor.document,
            .token = self.visitor.document.tokens.token,
            .depth = self.visitor.documenactual_depth.*,
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
        while (try self.next()) |field| if (std.mem.eql(u8, try field.key, key)) return field.value else field.skip();
        return error.MissingField;
    }

    pub fn isEmpty(self: Object) Error!bool {
        return (try self.getSize()) == 0;
    }

    pub fn getSize(self: Object) Error!u32 {
        var count: u32 = 0;
        while (try self.next()) |_| count += 1;
        return count;
    }

    fn getField(self: Object) Error!Field {
        const doc = self.visitor.document;
        const t = &doc.tokens;
        var key_visitor = Visitor{
            .document = doc,
            .token = t.token,
            .depth = self.visitor.document.depth,
        };
        const quote = t.next(.none) orelse return error.IncompleteObject;
        if (quote != '"') return error.ExpectedKeyAsString;
        const key = try key_visitor.getUnsafeString();
        const colon = t.next(.none) orelse return error.IncompleteObject;
        if (colon != ':') return error.ExpectedColon;
        self.visitor.document.depth += 2;
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
        std.log.info(" SKIP     Wanted depth: {}, actual: {}", .{ expected, actual });
    }

    pub fn logStart(parser: Parser, label: []const u8, depth: u32) void {
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
