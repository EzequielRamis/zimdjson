const std = @import("std");
const shared = @import("shared.zig");
const types = @import("types.zig");
const Indexer = @import("Indexer.zig");
const Tape = @import("Tape.zig");
const Allocator = std.mem.Allocator;
const ParseError = shared.ParseError;

pub const Parser = struct {
    indexer: Indexer,
    tape: Tape,
    allocator: Allocator,
    loaded_buffer: ?[]align(types.Vector.LEN_BYTES) u8 = null,
    loaded_document_len: usize = 0,

    pub fn init(allocator: Allocator) Parser {
        return .{
            .indexer = Indexer.init(allocator),
            .tape = Tape.init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Parser) void {
        self.indexer.deinit();
        self.tape.deinit();
        if (self.loaded_buffer) {
            self.allocator.free(self.loaded_buffer);
            self.loaded_buffer = null;
        }
    }

    pub fn parse(self: *Parser, document: []const u8) ParseError!Element {
        try self.indexer.index(document);
        try self.tape.build(self.indexer);
        return Element{
            .tape = &self.tape,
            .raw = &self.tape.parsed.items[1],
        };
    }

    pub fn load(self: *Parser, path: []const u8) !Element {
        const file = try std.fs.cwd().openFile(path, .{});
        const len = (try file.metadata()).size();

        if (self.loaded_buffer) |*buffer| {
            buffer.* = try self.allocator.realloc(buffer.*, len);
        } else {
            self.loaded_buffer = try self.allocator.alignedAlloc(u8, types.Vector.LEN_BYTES, len);
        }

        _ = try file.read(self.loaded_buffer.?);
        self.loaded_document_len = len;

        try self.indexer.index(self.loaded_buffer.?[0..self.loaded_document_len]);
        try self.tape.build(self.indexer);
        return Element{
            .tape = &self.tape,
            .raw = &self.tape.parsed.items[1],
        };
    }
};

const Element = struct {
    tape: *Tape,
    raw: *const u64,

    const Type = enum {
        object,
        array,
        number,
        string,
        boolean,
        null,
    };

    pub fn getObject(self: Element) ?Object {
        if (!self.isObject()) return null;
        return Object{ .root = self.raw };
    }

    pub fn getArray(self: Element) ?Array {
        if (!self.isArray()) return null;
        return Array{ .root = self.raw };
    }

    pub fn getString(self: Element) ?[]const u8 {
        if (!self.isString()) return null;
        const el: Tape.Element = @bitCast(self.raw.*);
        const str_len: *u32 = @ptrCast(el.data);
        return self.tape.chars.items[el.data + 4 ..][0..str_len.*];
    }

    pub fn getUnsigned(self: Element) ?u64 {
        if (!self.isUnsigned()) return null;
        return @bitCast((self.raw + 1).*);
    }

    pub fn getSigned(self: Element) ?i64 {
        if (!self.isSigned()) return null;
        return @bitCast((self.raw + 1).*);
    }

    pub fn getFloat(self: Element) ?f64 {
        if (!self.isFloat()) return null;
        return @bitCast((self.raw + 1).*);
    }

    pub fn getBool(self: Element) ?bool {
        if (!self.isBool()) return null;
        const el: Tape.Element = @bitCast(self.raw.*);
        return el.tag == .true;
    }

    pub fn getType(self: Element) ?Type {
        const el: Tape.Element = @bitCast(self.raw.*);
        return switch (el.tag) {
            .object_begin => .object,
            .array_begin => .array,
            .true, .false => .boolean,
            .unsigned, .signed, .float => .number,
            .null => .null,
            else => null,
        };
    }

    pub fn isObject(self: Element) bool {
        const el: Tape.Element = @bitCast(self.raw.*);
        return el.tag == .object_begin;
    }

    pub fn isArray(self: Element) bool {
        const el: Tape.Element = @bitCast(self.raw.*);
        return el.tag == .array_begin;
    }

    pub fn isString(self: Element) bool {
        const el: Tape.Element = @bitCast(self.raw.*);
        return el.tag == .string;
    }

    pub fn isUnsigned(self: Element) bool {
        const el: Tape.Element = @bitCast(self.raw.*);
        return el.tag == .unsigned;
    }

    pub fn isSigned(self: Element) bool {
        const el: Tape.Element = @bitCast(self.raw.*);
        return el.tag == .signed;
    }

    pub fn isInteger(self: Element) bool {
        return self.isUnsigned() or self.isSigned();
    }

    pub fn isFloat(self: Element) bool {
        const el: Tape.Element = @bitCast(self.raw.*);
        return el.tag == .float;
    }

    pub fn isNumber(self: Element) bool {
        return self.isInteger() or self.isFloat();
    }

    pub fn isBool(self: Element) bool {
        const el: Tape.Element = @bitCast(self.raw.*);
        return el.tag == .true or el.tag == .false;
    }

    pub fn isNull(self: Element) bool {
        const el: Tape.Element = @bitCast(self.raw.*);
        return el.tag == .null;
    }

    pub fn get(self: Element, comptime ty: type) ?ty {
        const info = @typeInfo(ty);
        switch (info) {
            .Bool => return self.getBool(),
            .Int => |n| {
                if (n.signedness == .signed) {
                    return if (self.getSigned()) |i| std.math.cast(ty, i) else null;
                } else {
                    return if (self.getUnsigned()) |u| std.math.cast(ty, u) else null;
                }
            },
            .Float => return if (self.getFloat()) |d| @floatCast(d) else null,
            .Optional => |c| return self.get(c.child),
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

pub const Array = struct {
    tape: *Tape,
    root: *const u64,

    pub const Iterator = struct {
        tape: *Tape,
        curr: *u64,
        root: u64,

        pub fn next(self: *Iterator) ?Element {
            const val: *Tape.Element = @ptrCast(self.curr);
            if (val.tag == .array_end and val.data == self.root) return null;
            defer self.curr = if (val.tag == .array_begin or val.tag == .object_begin) val.data else self.curr + 1;
            return Element{ .tape = self.tape, .raw = @bitCast(val.*) };
        }
    };

    pub fn iter(self: Object) Iterator {
        return Iterator{ .root = (self.root).*, .curr = self.root + 1 };
    }

    pub fn at(self: Array, index: usize) ?Element {
        var it = self.iter();
        var i: usize = 0;
        while (it.next()) |el| : (i += 1) if (i == index) return el;
        return null;
    }

    pub fn size(self: Array) u24 {
        const root: Tape.Element = @bitCast(self.root.*);
        const container: Tape.Container = @bitCast(root.data);
        return container.count;
    }
};

pub const Object = struct {
    tape: *Tape,
    root: *const u64,

    pub const Field = struct {
        key: []const u8,
        value: Element,
    };

    pub const Iterator = struct {
        tape: *Tape,
        curr: *u64,
        root: u64,

        pub fn next(self: *Iterator) ?Field {
            const key: *Tape.Element = @ptrCast(self.curr);
            if (key.tag == .object_end and key.data == self.root) return null;
            const val: *Tape.Element = @ptrCast(self.curr + 1);
            defer self.curr = if (val.tag == .array_begin or val.tag == .object_begin) val.data else self.curr + 2;
            return Field{
                .key = (Element{ .tape = self.tape, .raw = @bitCast(key.*) }).getString().?,
                .value = Element{ .tape = self.tape, .raw = @bitCast(val.*) },
            };
        }
    };

    pub fn iter(self: Object) Iterator {
        return Iterator{ .root = (self.root).*, .curr = self.root + 1 };
    }

    pub fn at(self: Object, key: []const u8) ?Element {
        var it = self.iter();
        while (it.next()) |field| if (field.key == key) return field.value;
        return null;
    }

    pub fn size(self: Object) u24 {
        const root: Tape.Element = @bitCast(self.root.*);
        const container: Tape.Container = @bitCast(root.data);
        return container.count;
    }
};
