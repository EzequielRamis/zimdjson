const std = @import("std");
const shared = @import("shared.zig");
const types = @import("types.zig");
const intr = @import("intrinsics.zig");
const validator = @import("validator.zig");
const ArrayList = std.ArrayList;
const Indexer = @import("Indexer.zig");
const Vector = types.Vector;
const vector = types.vector;
const Pred = types.Predicate;
const tokens = @import("tokens.zig");
const TokenIterator = tokens.Iterator;
const TokenOptions = tokens.Options;
const log = std.log;
const assert = std.debug.assert;

const Allocator = std.mem.Allocator;
const ParseError = types.ParseError;
const ConsumeError = types.ConsumeError;

const OnDemandError = ParseError || ConsumeError;

const TOKEN_OPTIONS = TokenOptions{
    .copy_bounded = true,
};

pub const Parser = struct {
    max_depth: usize = shared.DEFAULT_MAX_DEPTH,
    indexer: Indexer,
    allocator: Allocator,
    loaded_buffer: ?[]align(types.Vector.LEN_BYTES) u8 = null,
    loaded_document_len: usize = 0,

    pub fn init(allocator: Allocator) Parser {
        return Parser{
            .indexer = Indexer.init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Parser) void {
        self.indexer.deinit();
        if (self.loaded_buffer) {
            self.allocator.free(self.loaded_buffer);
            self.loaded_buffer = null;
        }
    }

    pub fn parse(self: *Parser, document: []const u8) ParseError!Document {
        try self.indexer.index(document);
        var doc = Document.init(self.allocator);
        doc.build(self.indexer);
        return doc;
    }

    pub fn load(self: *Parser, path: []const u8) ParseError!*Document {
        const file = try std.fs.cwd().openFile(path, .{});
        const len = (try file.metadata()).size();

        if (self.loaded_buffer) |*buffer| {
            if (buffer.len < len)
                buffer.* = try self.allocator.realloc(buffer.*, len);
        } else {
            self.loaded_buffer = try self.allocator.alignedAlloc(u8, types.Vector.LEN_BYTES, len);
        }

        _ = try file.read(self.loaded_buffer.?);
        self.loaded_document_len = len;

        try self.indexer.index(self.loaded_buffer.?[0..self.loaded_document_len]);
        var doc = Document.init(self.allocator);
        doc.build(self.indexer);
        return &doc;
    }

    pub fn shrinkToFitLoad(self: *Parser) ParseError!void {
        assert(self.loaded_buffer != null);
        self.loaded_buffer.? = try self.allocator.realloc(self.loaded_buffer.?, self.loaded_document_len);
    }
};

const Document = struct {
    tokens: TokenIterator(TOKEN_OPTIONS),
    chars: ArrayList(u8),
    depth: u32 = 0,

    pub fn init(allocator: Allocator) Document {
        return Document{
            .tokens = TokenIterator(TOKEN_OPTIONS).init(),
            .chars = ArrayList(u8).init(allocator),
        };
    }

    pub fn deinit(self: *Document) void {
        self.chars.deinit();
    }

    pub fn build(self: *Document, indexer: Indexer) ParseError!Element {
        var t = &self.tokens;
        t.analyze(indexer);
        try self.chars.ensureTotalCapacity(self.tokens.indexer.reader.document.len);
        self.chars.shrinkRetainingCapacity(0);

        if (t.empty()) return error.Empty;

        return Element{ .document = self, .depth = self.depth, .index = t.index };
    }
};

const Element = struct {
    document: *const Document,
    depth: u32,
    index: u32,

    pub fn getObject(self: Element) OnDemandError!Object {
        if (self.isObject()) {
            self.document.depth += 1;
            return Object{ .root = &self };
        }
        return error.IncorrectType;
    }

    pub fn getArray(self: Element) OnDemandError!Array {
        if (self.isArray()) {
            self.document.depth += 1;
            return Array{ .root = &self };
        }
        return error.IncorrectType;
    }

    pub fn getRawString(self: Element) OnDemandError![]const u8 {
        if (self.isString()) {
            const doc = self.document;
            _ = doc.tokens.consume(1, null);
            return try validator.rawString(&doc.tokens, null);
        }
        return error.IncorrectType;
    }

    pub fn getString(self: Element) OnDemandError![]const u8 {
        if (self.isString()) {
            const doc = self.document;
            _ = doc.tokens.consume(1, null);
            const next_str = doc.chars.items.len;
            try validator.string(&doc.tokens, &doc.chars, null);
            const next_len = self.chars.items.len - 1 - next_str;
            return doc.chars.items[next_str..][0..next_len];
        }
        return error.IncorrectType;
    }

    pub fn getBool(self: Element) OnDemandError!bool {
        if (self.isBool()) {
            const p = self.document.tokens.peek();
            if (p == 't') return validator.atomTrue(TOKEN_OPTIONS, &self.document.tokens, null);
            return validator.atomFalse(TOKEN_OPTIONS, &self.document.tokens, null);
        }
        return error.IncorrectType;
    }

    pub fn getType(self: Element) ParseError!types.Element {
        const t = self.document.tokens;
        return switch (t.peek()) {
            '{' => .object,
            '[' => .array,
            '"' => .string,
            'n' => .null,
            't', 'f' => .boolean,
            '-', '0'...'9' => .number,
            else => error.NonValue,
        };
    }

    fn isObject(self: Element) bool {
        return self.document.tokens.peek() == '{';
    }

    fn isArray(self: Element) bool {
        return self.document.tokens.peek() == '[';
    }

    fn isString(self: Element) bool {
        return self.document.tokens.peek() == '"';
    }

    fn isBool(self: Element) bool {
        return switch (self.document.tokens.peek()) {
            't', 'f' => true,
            else => false,
        };
    }

    pub fn isNull(self: Element) ParseError!void {
        if (self.document.tokens.peek() == 'n') {
            return validator.atomNull(TOKEN_OPTIONS, &self.document.tokens, null);
        }
        return error.IncorrectType;
    }

    pub fn consume(self: Element) ParseError!void {
        const doc = self.document;
        const wanted_depth = self.depth;
        var actual_depth = doc.depth;
        const indexes = doc.tokens.indexer.indexes.items;

        if (actual_depth == wanted_depth) return;

        const ln_table: vector = std.simd.repeat(Vector.LEN_BYTES, [_]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 2, 0, 0 });
        const hn_table: vector = std.simd.repeat(Vector.LEN_BYTES, [_]u8{ 0, 0, 0, 0, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0 });
        const opening_table: vector = @splat(0b01);
        const closing_table: vector = @splat(0b10);

        const unbound = indexes.len - Vector.LEN_BYTES;
        while (doc.tokens.index < unbound) {
            var tkns: vector = @splat(0);
            for (0..Vector.LEN_BYTES) |i| {
                const t = indexes[doc.tokens.index + i];
                tkns[i] = t;
            }

            const low_nibbles = tkns & @as(vector, @splat(0xF));
            const high_nibbles = tkns >> @as(vector, @splat(4));
            const low_lookup_values = intr.lut(ln_table, low_nibbles);
            const high_lookup_values = intr.lut(hn_table, high_nibbles);
            const desired_values = low_lookup_values & high_lookup_values;

            const opening = desired_values & opening_table;
            const closing = (desired_values & closing_table) << 1;

            for (0..Vector.LEN_BYTES) |i| {
                const o: u1 = @truncate(opening[i]);
                const c: u1 = @truncate(closing[i]);
                actual_depth += o;
                actual_depth -= c;
                if (actual_depth == wanted_depth) return;
                _ = doc.tokens.next(null);
            }
        }

        var tkns: vector = @splat(0);
        const remain = indexes.len - doc.tokens.index;
        for (0..remain) |i| {
            const t = indexes[doc.tokens.index + i];
            tkns[i] = t;
        }

        const low_nibbles = tkns & @as(vector, @splat(0xF));
        const high_nibbles = tkns >> @as(vector, @splat(4));
        const low_lookup_values = intr.lut(ln_table, low_nibbles);
        const high_lookup_values = intr.lut(hn_table, high_nibbles);
        const desired_values = low_lookup_values & high_lookup_values;

        const opening = desired_values & opening_table;
        const closing = (desired_values & closing_table) << 1;

        for (0..remain) |i| {
            const o: u1 = @truncate(opening[i]);
            const c: u1 = @truncate(closing[i]);
            actual_depth += o;
            actual_depth -= c;
            if (actual_depth == wanted_depth) return;
            _ = doc.tokens.next(null);
        }

        if (actual_depth != wanted_depth) return error.InvalidStructure;
    }

    pub fn get(self: Element, comptime ty: type) OnDemandError!ty {
        const info = @typeInfo(ty);
        switch (info) {
            .Bool => return self.getBool(),
            .Int => |_| {},
            .Float => {},
            .Optional => |c| return if (self.isNull()) null else self.get(c.child),
            .Struct, .Enum, .Union => |s| {
                for (s.decls) |decl| {
                    if (std.mem.eql(u8, decl.name, "deserialize"))
                        return ty.deserialize(self);
                }
                @compileError("type '" ++ @typeName(ty) ++ "' has no method 'deserialize'");
            },
            else => @compileError("can not deserialize to type '" ++ @typeName(ty) ++ "'"),
        }
    }
};

const Array = struct {
    root: *const Element,

    pub fn next(self: Array) ParseError!?Element {
        const doc = self.root.document;
        const p = doc.tokens.next(null) orelse return error.InvalidStructure;
        if (self.root.index == doc.tokens.index) {
            if (p == ']') return null;
            return Element{
                .document = doc,
                .depth = self.root.depth + 1,
                .index = doc.tokens.index,
            };
        }
        switch (p) {
            ',' => {
                _ = doc.tokens.next(null);
                return Element{
                    .document = doc,
                    .depth = self.root.depth + 1,
                    .index = doc.tokens.index,
                };
            },
            ']' => return null,
            else => return error.InvalidStructure,
        }
    }

    pub fn reset(self: Array) void {
        const doc = self.root.document;
        doc.tokens.backTo(self.root);
        self.root.document.depth = self.root.depth;
    }

    pub fn consume(self: Array) ParseError!void {
        self.root.consume();
    }

    pub fn at(self: Array, index: usize) OnDemandError!Element {
        var i: usize = 0;
        while (try self.next()) |el| : (i += 1) if (i == index) return el;
        return error.OutOfBounds;
    }

    pub fn isEmpty(self: Array) ParseError!bool {
        const doc = self.root.document;
        const p = doc.tokens.peekNext() orelse return error.InvalidStructure;
        return p == ']';
    }

    pub fn size(self: Array) ParseError!u24 {
        var count: u24 = 0;
        while (try self.next()) |_| count += 1;
        self.reset();
        return count;
    }
};

const Object = struct {
    root: *const Element,

    pub const Field = struct {
        root: *const Element,

        pub fn key(self: Field) OnDemandError![]const u8 {
            const doc = self.root.document;
            _ = doc.tokens.consume(1, null);
            const next_str = doc.chars.items.len;
            try validator.string(&doc.tokens, &doc.chars, null);
            const next_len = self.chars.items.len - 1 - next_str;
            return doc.chars.items[next_str..][0..next_len];
        }

        pub fn rawKey(self: Field) OnDemandError![]const u8 {
            const doc = self.root.document;
            _ = doc.tokens.consume(1, null);
            return try validator.rawString(&doc.tokens, null);
        }

        pub fn value(self: Field) OnDemandError!Element {
            const doc = self.root.document;
            const colon = doc.tokens.next(null) orelse return error.InvalidStructure;
            if (colon == ':') {
                _ = doc.tokens.next(null);
                return Element{
                    .document = doc,
                    .depth = self.root.depth,
                    .index = doc.tokens.index,
                };
            }
            return error.InvalidStructure;
        }

        pub fn reset(self: Field) void {
            const doc = self.root.document;
            doc.tokens.backTo(self.root);
            self.root.document.depth = self.root.depth;
        }

        pub fn consume(self: Field) ParseError!void {
            self.reset();
            const el = try self.value();
            return try el.consume();
        }
    };

    pub fn next(self: Object) ParseError!?Field {
        const doc = self.root.document;
        const p = doc.tokens.next(null) orelse return error.InvalidStructure;
        if (self.root.index == doc.tokens.index) {
            if (p == '}') return null;
            return Field{ .root = Element{
                .document = doc,
                .depth = self.root.depth + 1,
                .index = doc.tokens.index,
            } };
        }
        switch (p) {
            ',' => {
                _ = doc.tokens.next(null);
                return Field{ .root = Element{
                    .document = doc,
                    .depth = self.root.depth + 1,
                    .index = doc.tokens.index,
                } };
            },
            '}' => return null,
            else => return error.InvalidStructure,
        }
    }

    pub fn reset(self: Object) void {
        const doc = self.root.document;
        doc.tokens.backTo(self.root);
        self.root.document.depth = self.root.depth;
    }

    pub fn consume(self: Object) ParseError!void {
        self.root.consume();
    }

    pub fn at(self: Object, key: []const u8) OnDemandError!Element {
        while (try self.next()) |field| if (std.mem.eql(u8, try field.key(), key)) return field.value() else field.consume();
        return error.NoSuchField;
    }

    pub fn atRaw(self: Object, raw_key: []const u8) OnDemandError!Element {
        while (try self.next()) |field| if (std.mem.eql(u8, try field.rawKey(), raw_key)) return field.value() else field.consume();
        return error.NoSuchField;
    }

    pub fn isEmpty(self: Object) ParseError!bool {
        const doc = self.root.document;
        const p = doc.tokens.peekNext() orelse return error.InvalidStructure;
        return p == '}';
    }

    pub fn size(self: Object) ParseError!u24 {
        var count: u24 = 0;
        while (try self.next()) |_| count += 1;
        self.reset();
        return count;
    }
};
