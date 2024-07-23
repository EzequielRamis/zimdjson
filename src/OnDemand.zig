const std = @import("std");
const common = @import("common.zig");
const types = @import("types.zig");
const intr = @import("intrinsics.zig");
const parsers = @import("parsers.zig");
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
const Error = types.Error;

const TOKEN_OPTIONS = TokenOptions{
    .copy_bounded = true,
};

const NumberParser = parsers.Number(TOKEN_OPTIONS);

pub const Parser = struct {
    const Buffer = std.ArrayListAligned(u8, types.Vector.LEN_BYTES);

    buffer: Buffer,
    tokens: TokenIterator(TOKEN_OPTIONS),
    chars: ArrayList(u8),
    depth: u32 = 0,

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
        var t = &self.tokens;
        try t.build(document);

        try self.chars.ensureTotalCapacity(t.indexer.reader.document.len + Vector.LEN_BYTES);
        self.chars.shrinkRetainingCapacity(0);

        return Visitor{
            .document = self,
            .depth = self.depth,
            .index = self.tokens.token,
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

pub const Visitor = struct {
    document: *Parser,
    depth: u32,
    index: u32,

    pub fn getObject(self: *Visitor) Object {
        assert(self.isObject());
        self.document.depth += 1;
        return Object{ .root = &self };
    }

    pub fn getArray(self: *Visitor) Array {
        assert(self.isArray());
        self.document.depth += 1;
        return Array{ .root = &self };
    }

    pub fn getNumber(self: *Visitor) Error!NumberParser.Result {
        assert(self.isNumber());
        return NumberParser.parse(.none, &self.document.tokens);
    }

    pub fn getUnsigned(self: *Visitor) Error!u64 {
        assert(self.isUnsigned());
        return NumberParser.parseUnsigned(.none, &self.document.tokens);
    }

    pub fn getSigned(self: *Visitor) Error!i64 {
        assert(self.isNumber());
        return NumberParser.parseSigned(.none, &self.document.tokens);
    }

    pub fn getFloat(self: *Visitor) Error!f64 {
        assert(self.isNumber());
        return NumberParser.parseFloat(.none, &self.document.tokens);
    }

    pub fn getString(self: *Visitor) Error![]const u8 {
        assert(self.isString());
        const doc = self.document;
        _ = doc.tokens.consume(1, .none);
        const next_str = doc.chars.items.len;
        try parsers.writeString(&doc.tokens, &doc.chars, .none);
        const next_len = self.chars.items.len - 1 - next_str;
        return doc.chars.items[next_str..][0..next_len];
    }

    pub fn getBool(self: *Visitor) Error!bool {
        assert(self.isBool());
        const t = self.document.tokens;
        switch (t.peek()) {
            't' => {
                try parsers.checkTrue(TOKEN_OPTIONS, t);
                _ = self.document.tokens.consume(4, .none);
                return true;
            },
            'f' => {
                try parsers.checkFalse(TOKEN_OPTIONS, t);
                _ = self.document.tokens.consume(5, .none);
                return false;
            },
            else => unreachable,
        }
    }

    pub fn isObject(self: Visitor) bool {
        return self.document.tokens.peek() == '{';
    }

    pub fn isArray(self: Visitor) bool {
        return self.document.tokens.peek() == '[';
    }

    pub fn isNumber(self: Visitor) bool {
        return self.isUnsigned() or self.isSigned();
    }

    pub fn isSigned(self: Visitor) bool {
        return self.document.tokens.peek() == '-';
    }

    pub fn isUnsigned(self: Visitor) bool {
        return self.document.tokens.peek() -% '0' < 10;
    }

    pub fn isString(self: Visitor) bool {
        return self.document.tokens.peek() == '"';
    }

    pub fn isBool(self: Visitor) bool {
        const p = self.document.tokens.peek();
        return p == 't' or p == 'f';
    }

    pub fn isNull(self: *Visitor) Error!void {
        try parsers.checkNull(TOKEN_OPTIONS, &self.document.tokens);
        _ = self.document.tokens.consume(4, .none);
    }

    pub fn consume(self: *Visitor) Error!void {
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
            const low_lookup_values = intr.lookupTable(ln_table, low_nibbles);
            const high_lookup_values = intr.lookupTable(hn_table, high_nibbles);
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
        const low_lookup_values = intr.lookupTable(ln_table, low_nibbles);
        const high_lookup_values = intr.lookupTable(hn_table, high_nibbles);
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
};

pub const Array = struct {
    root: *const Visitor,

    pub fn next(self: Array) Error!?Visitor {
        const doc = self.root.document;
        const p = doc.tokens.next(null) orelse return error.InvalidStructure;
        if (self.root.index == doc.tokens.index) {
            if (p == ']') return null;
            return Visitor{
                .document = doc,
                .depth = self.root.depth + 1,
                .index = doc.tokens.index,
            };
        }
        switch (p) {
            ',' => {
                _ = doc.tokens.next(null);
                return Visitor{
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

    pub fn consume(self: Array) Error!void {
        self.root.consume();
    }

    pub fn at(self: Array, index: usize) Error!Visitor {
        var i: usize = 0;
        while (try self.next()) |el| : (i += 1) if (i == index) return el;
        return error.OutOfBounds;
    }

    pub fn isEmpty(self: Array) Error!bool {
        const doc = self.root.document;
        const p = doc.tokens.peekNext() orelse return error.InvalidStructure;
        return p == ']';
    }

    pub fn size(self: Array) Error!u24 {
        var count: u24 = 0;
        while (try self.next()) |_| count += 1;
        self.reset();
        return count;
    }
};

pub const Object = struct {
    root: *const Visitor,

    pub const Field = struct {
        root: *const Visitor,

        pub fn key(self: Field) Error![]const u8 {
            const doc = self.root.document;
            _ = doc.tokens.consume(1, .none);
            const next_str = doc.chars.items.len;
            try parsers.writeString(&doc.tokens, &doc.chars, .none);
            const next_len = self.chars.items.len - 1 - next_str;
            return doc.chars.items[next_str..][0..next_len];
        }

        pub fn value(self: Field) Error!Visitor {
            const doc = self.root.document;
            const colon = doc.tokens.next(null) orelse return error.InvalidStructure;
            if (colon == ':') {
                _ = doc.tokens.next(null);
                return Visitor{
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

        pub fn consume(self: Field) Error!void {
            self.reset();
            const el = try self.value();
            return try el.consume();
        }
    };

    pub fn next(self: Object) Error!?Field {
        const doc = self.root.document;
        const p = doc.tokens.next(null) orelse return error.InvalidStructure;
        if (self.root.index == doc.tokens.index) {
            if (p == '}') return null;
            return Field{ .root = Visitor{
                .document = doc,
                .depth = self.root.depth + 1,
                .index = doc.tokens.index,
            } };
        }
        switch (p) {
            ',' => {
                _ = doc.tokens.next(null);
                return Field{ .root = Visitor{
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

    pub fn consume(self: Object) Error!void {
        self.root.consume();
    }

    pub fn at(self: Object, key: []const u8) Error!Visitor {
        while (try self.next()) |field| if (std.mem.eql(u8, try field.key(), key)) return field.value() else field.consume();
        return error.MissingField;
    }

    pub fn isEmpty(self: Object) Error!bool {
        const doc = self.root.document;
        const p = doc.tokens.peekNext() orelse return error.InvalidStructure;
        return p == '}';
    }

    pub fn size(self: Object) Error!u24 {
        var count: u24 = 0;
        while (try self.next()) |_| count += 1;
        self.reset();
        return count;
    }
};
