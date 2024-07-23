const std = @import("std");
const common = @import("common.zig");
const types = @import("types.zig");
const Indexer = @import("Indexer.zig");
const Tape = @import("Tape.zig");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

pub const Parser = struct {
    const Buffer = std.ArrayListAligned(u8, types.Vector.LEN_BYTES);

    tape: Tape,
    buffer: Buffer,

    pub fn init(allocator: Allocator) Parser {
        return .{
            .tape = Tape.init(allocator),
            .buffer = Buffer.init(allocator),
        };
    }

    pub fn deinit(self: *Parser) void {
        self.tape.deinit();
        self.buffer.deinit();
    }

    pub fn parse(self: *Parser, document: []const u8) !Visitor {
        try self.tape.build(document);
        return Visitor{
            .tape = &self.tape,
            .index = 1,
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

const Visitor = struct {
    tape: *const Tape,
    index: u32,

    pub fn getObject(self: Visitor) ?Object {
        const w = self.tape.parsed.get(self.index);
        return switch (w) {
            .object_opening => Object{ .tape = self.tape, .root = self.index },
            else => null,
        };
    }

    pub fn getArray(self: Visitor) ?Array {
        const w = self.tape.parsed.get(self.index);
        return switch (w) {
            .array_opening => Array{ .tape = self.tape, .root = self.index },
            else => null,
        };
    }

    pub fn getString(self: Visitor) ?[]const u8 {
        const w = self.tape.parsed.get(self.index);
        return switch (w) {
            .string => |fit| self.tape.chars.items[fit.ptr..][0..fit.len],
            else => null,
        };
    }

    pub fn getNumber(self: Visitor) ?types.Number {
        const w = self.tape.parsed.get(self.index);
        return switch (w) {
            .unsigned => .{ .unsigned = self.getUnsigned().? },
            .signed => .{ .signed = self.getSigned().? },
            .float => .{ .float = self.getFloat().? },
            else => null,
        };
    }

    pub fn getUnsigned(self: Visitor) ?u64 {
        const w = self.tape.parsed.get(self.index);
        return switch (w) {
            .unsigned => |n| n,
            else => null,
        };
    }

    pub fn getSigned(self: Visitor) ?i64 {
        const w = self.tape.parsed.get(self.index);
        return switch (w) {
            .signed => |n| n,
            else => null,
        };
    }

    pub fn getFloat(self: Visitor) ?f64 {
        const w = self.tape.parsed.get(self.index);
        return switch (w) {
            .float => |n| n,
            else => null,
        };
    }

    pub fn getBool(self: Visitor) ?bool {
        const w = self.tape.parsed.get(self.index);
        return switch (w) {
            .true => true,
            .false => false,
            else => null,
        };
    }

    pub fn atKey(self: Visitor, key: []const u8) ?Object.Field {
        const obj = self.getObject() orelse return null;
        return obj.at(key);
    }

    pub fn atIndex(self: Visitor, index: u32) ?Visitor {
        const arr = self.getArray() orelse return null;
        return arr.at(index);
    }

    pub fn size(self: Visitor) ?u32 {
        if (self.getObject()) |obj| return obj.size();
        if (self.getArray()) |arr| return arr.size();
        return null;
    }
};

const Array = struct {
    tape: *const Tape,
    root: u32,

    pub const Iterator = struct {
        tape: *const Tape,
        curr: u32,

        pub fn next(self: *Iterator) ?Visitor {
            const w = self.tape.parsed.get(self.curr);
            if (w == .array_closing) return null;
            defer self.curr = switch (w) {
                .array_opening, .object_opening => |fit| fit.ptr,
                else => self.curr + 1,
            };
            return .{ .tape = self.tape, .index = self.curr };
        }
    };

    pub fn iterator(self: Array) Iterator {
        return Iterator{ .tape = self.tape, .curr = self.root + 1 };
    }

    pub fn at(self: Array, index: u32) ?Visitor {
        var it = self.iterator();
        var i: u32 = 0;
        while (it.next()) |v| : (i += 1) if (i == index) return v;
        return null;
    }

    pub fn isEmpty(self: Array) bool {
        return self.size() == 0;
    }

    pub fn size(self: Array) u32 {
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
            const w = self.tape.parsed.get(self.curr);
            if (w == .object_closing) return null;
            defer self.curr = switch (w) {
                .array_opening, .object_opening => |fit| fit.ptr,
                else => self.curr + 2,
            };
            const v = Visitor{ .tape = self.tape, .index = self.curr };
            return .{ .key = v.getString().?, .value = .{ .tape = self.tape, .index = self.curr + 1 } };
        }
    };

    pub fn iterator(self: Object) Iterator {
        return Iterator{ .tape = self.tape, .curr = self.root + 1 };
    }

    pub fn at(self: Object, key: []const u8) ?Visitor {
        var it = self.iterator();
        while (it.next()) |field| if (std.mem.eql(u8, field.key, key)) return field.value;
        return null;
    }

    pub fn isEmpty(self: Object) bool {
        return self.size() == 0;
    }

    pub fn size(self: Object) u32 {
        const w = self.tape.parsed.get(self.root);
        assert(w == .object_opening);
        return w.object_opening.len;
    }
};
