const std = @import("std");
const shared = @import("shared.zig");
const types = @import("types.zig");
const Indexer = @import("Indexer.zig");
const Tape = @import("Tape.zig");
const Allocator = std.mem.Allocator;
const ParseError = shared.ParseError;
const ConsumeError = shared.ConsumeError;

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
            .el = @ptrCast(&self.tape.parsed.items[1]),
        };
    }

    pub fn load(self: *Parser, path: []const u8) ParseError!Element {
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
            .el = @ptrCast(&self.tape.parsed.items[1]),
        };
    }
};

const Element = struct {
    tape: *Tape,
    el: *const Tape.Element,

    pub fn getObjectOrNull(self: Element) ?Object {
        return self.getObject() catch null;
    }

    pub fn getArrayOrNull(self: Element) ?Array {
        return self.getArray() catch null;
    }

    pub fn getStringOrNull(self: Element) ?[]const u8 {
        return self.getString() catch null;
    }

    pub fn getUnsignedOrNull(self: Element) ?u64 {
        return self.getUnsigned() catch null;
    }

    pub fn getSignedOrNull(self: Element) ?i64 {
        return self.getSigned() catch null;
    }

    pub fn getFloatOrNull(self: Element) ?f64 {
        return self.getFloat() catch null;
    }

    pub fn getBoolOrNull(self: Element) ?bool {
        return self.getBool() catch null;
    }

    pub fn getObject(self: Element) ConsumeError!Object {
        if (!self.isObject()) return error.IncorrectType;
        return Object{ .tape = self.tape, .root = self.el };
    }

    pub fn getArray(self: Element) ConsumeError!Array {
        if (!self.isArray()) return error.IncorrectType;
        return Array{ .tape = self.tape, .root = self.el };
    }

    pub fn getString(self: Element) ConsumeError![]const u8 {
        if (!self.isString()) return error.IncorrectType;
        const str_len: *u32 = @ptrCast(self.el.data);
        return self.tape.chars.items[self.el.data + 4 ..][0..str_len.*];
    }

    pub fn getUnsigned(self: Element) ConsumeError!u64 {
        if (!self.isUnsigned()) return error.IncorrectType;
        return @bitCast((self.el + 1).*);
    }

    pub fn getSigned(self: Element) ConsumeError!i64 {
        if (!self.isSigned()) return error.IncorrectType;
        return @bitCast((self.el + 1).*);
    }

    pub fn getFloat(self: Element) ConsumeError!f64 {
        if (!self.isFloat()) return error.IncorrectType;
        return @bitCast((self.el + 1).*);
    }

    pub fn getBool(self: Element) ConsumeError!bool {
        if (!self.isBool()) return error.IncorrectType;
        return self.el.tag == .true;
    }

    pub fn getType(self: Element) types.Element {
        return switch (self.el.tag) {
            .object_begin => .object,
            .array_begin => .array,
            .true, .false => .boolean,
            .unsigned, .signed, .float => .number,
            .null => .null,
            else => unreachable,
        };
    }

    pub fn isObject(self: Element) bool {
        return self.el.tag == .object_begin;
    }

    pub fn isArray(self: Element) bool {
        return self.el.tag == .array_begin;
    }

    pub fn isString(self: Element) bool {
        return self.el.tag == .string;
    }

    pub fn isUnsigned(self: Element) bool {
        return self.el.tag == .unsigned;
    }

    pub fn isSigned(self: Element) bool {
        return self.el.tag == .signed;
    }

    pub fn isInteger(self: Element) bool {
        return self.isUnsigned() or self.isSigned();
    }

    pub fn isFloat(self: Element) bool {
        return self.el.tag == .float;
    }

    pub fn isNumber(self: Element) bool {
        return self.isInteger() or self.isFloat();
    }

    pub fn isBool(self: Element) bool {
        return self.el.tag == .true or self.el.tag == .false;
    }

    pub fn isNull(self: Element) bool {
        return self.el.tag == .null;
    }

    pub fn getOrNull(self: Element, comptime ty: type) ?ty {
        return self.get(ty) catch null;
    }

    pub fn get(self: Element, comptime ty: type) !ty {
        const info = @typeInfo(ty);
        switch (info) {
            .Bool => return self.getBool(),
            .Int => |n| {
                if (n.signedness == .signed) {
                    return std.math.cast(ty, try self.getSigned()) orelse error.InvalidNumber;
                } else {
                    return std.math.cast(ty, try self.getUnsigned()) orelse error.InvalidNumber;
                }
            },
            .Float => return @floatCast(try self.getFloat()),
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

pub const Array = struct {
    tape: *const Tape,
    root: *const Tape.Element,

    pub const Iterator = struct {
        tape: *const Tape,
        curr: *const Tape.Element,
        root: *const Tape.Element,

        pub fn next(self: *Iterator) ?Element {
            const val = self.curr;
            const val_info: Tape.Container = @bitCast(val.data);
            const root_info: Tape.Container = @bitCast(self.root.data);
            if (val.tag == .array_end and val.data == root_info.index) return null;
            defer self.curr = if (val.tag == .array_begin or val.tag == .object_begin) &self.tape[val_info.index] else val + 1;
            return Element{ .tape = self.tape, .el = val };
        }
    };

    pub fn iter(self: Object) Iterator {
        return Iterator{ .tape = self.tape, .root = self.root, .curr = self.root + 1 };
    }

    pub fn at(self: Array, index: usize) ConsumeError!Element {
        var it = self.iter();
        var i: usize = 0;
        while (it.next()) |el| : (i += 1) if (i == index) return el;
        return error.OutOfBounds;
    }

    pub fn size(self: Array) u24 {
        const info: Tape.Container = @bitCast(self.root.data);
        return info.count;
    }
};

pub const Object = struct {
    tape: *const Tape,
    root: *const Tape.Element,

    pub const Field = struct {
        key: []const u8,
        value: Element,
    };

    pub const Iterator = struct {
        tape: *const Tape,
        curr: *const Tape.Element,
        root: *const Tape.Element,

        pub fn next(self: *Iterator) ?Field {
            const key = self.curr;
            if (key.tag == .object_end and key.data == self.root) return null;
            const val: Tape.Element = self.curr + 1;
            const val_info: Tape.Container = @bitCast(val.data);
            defer self.curr = if (val.tag == .array_begin or val.tag == .object_begin) &self.tape[val_info.index] else key + 2;
            return Field{
                .key = (Element{ .tape = self.tape, .el = key }).getStringOrNull().?,
                .value = Element{ .tape = self.tape, .el = val },
            };
        }
    };

    pub fn iter(self: Object) Iterator {
        return Iterator{ .tape = self.tape, .root = self.root, .curr = self.root + 1 };
    }

    pub fn at(self: Object, key: []const u8) ConsumeError!Element {
        var it = self.iter();
        while (it.next()) |field| if (field.key == key) return field.value;
        return error.NoSuchField;
    }

    pub fn size(self: Object) u24 {
        const container: Tape.Container = @bitCast(self.root.data);
        return container.count;
    }
};
