const std = @import("std");
const common = @import("common.zig");
const types = @import("types.zig");
const Indexer = @import("Indexer.zig");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Vector = types.Vector;
const ParseError = types.ParseError;
const vector = types.vector;
const array = types.array;
const umask = types.umask;
const assert = std.debug.assert;

pub const Phase = enum {
    none,
    unbounded,
    bounded,
    padded,
};

pub const Options = struct {
    copy_bounded: bool,
};

pub fn Iterator(comptime options: Options) type {
    const copy_bounded = options.copy_bounded;

    return struct {
        const Self = @This();

        indexer: Indexer,
        padding: if (copy_bounded) ArrayList(u8) else [Vector.LEN_BYTES * 2]u8 = undefined,
        padding_ptr: if (copy_bounded) void else [*]const u8 = undefined,
        ptr: [*]const u8 = undefined,
        bounded_token: usize = undefined,
        token: u32 = 0,

        pub fn init(allocator: Allocator) Self {
            return .{
                .indexer = Indexer.init(allocator),
                .padding = if (copy_bounded) ArrayList(u8).init(allocator) else undefined,
            };
        }

        pub fn deinit(self: *Self) void {
            if (copy_bounded) self.padding.deinit();
            self.indexer.deinit();
        }

        pub fn iter(self: *Self, doc: []const u8) ParseError!void {
            try self.indexer.index(doc);

            const ixs = self.indexes();
            const padding_bound = doc.len -| Vector.LEN_BYTES;
            var bounded_token: usize = ixs.len - 1;
            var rev = std.mem.reverseIterator(ixs);
            while (rev.next()) |t| : (bounded_token -|= 1) {
                if (t <= padding_bound) break;
            }
            const padding_ptr = doc[padding_bound..].ptr;
            self.bounded_token = bounded_token;
            self.ptr = doc.ptr;
            if (copy_bounded) {
                const bounded_index = ixs[bounded_token];
                const padding_len = doc.len - bounded_index;
                try self.padding.ensureTotalCapacity(padding_len + Vector.LEN_BYTES);
                self.padding.items.len = padding_len + Vector.LEN_BYTES;
                @memset(self.padding.items, ' ');
                @memcpy(self.padding.items[0..padding_len], doc[bounded_index..]);
                if (bounded_token == 0) {
                    self.ptr = self.padding.items.ptr;
                }
            } else {
                self.padding_ptr = padding_ptr;
                @memset(&self.padding, ' ');
                @memcpy(self.padding[0 .. doc.len - padding_bound], doc[padding_bound..doc.len]);
            }
        }

        pub fn indexes(self: Self) []const u32 {
            return self.indexer.indexes.items;
        }

        pub fn document(self: Self) []const u8 {
            return self.indexer.reader.document;
        }

        pub fn next(self: *Self, comptime phase: Phase) ?u8 {
            const doc = self.document();
            const ixs = self.indexes();
            switch (phase) {
                .none => return self.next(.unbounded) orelse self.next(.bounded) orelse self.next(.padded),
                .unbounded => {
                    if (self.token < self.bounded_token) {
                        defer self.token += 1;
                        const i = ixs[self.token];
                        self.ptr = doc[i..].ptr;
                        return doc[i];
                    }
                    return null;
                },
                .bounded => {
                    if (self.token == self.bounded_token) {
                        defer self.token += 1;
                        const i = ixs[self.token];
                        self.ptr = if (copy_bounded) self.padding.items else doc[i..].ptr;
                        return doc[i];
                    }
                    return null;
                },
                .padded => {
                    if (self.token < ixs.len) {
                        defer self.token += 1;
                        const i = ixs[self.token];
                        const b = ixs[self.bounded_token];

                        const index_ptr = @intFromPtr(doc[i..].ptr);
                        const padding_ptr = @intFromPtr(if (copy_bounded) doc[b..].ptr else self.padding_ptr);
                        const offset_ptr = index_ptr - padding_ptr;
                        self.ptr = self.padding[offset_ptr..].ptr;

                        return doc[i];
                    }
                    return null;
                },
            }
        }

        pub fn consume(self: *Self, n: usize, comptime phase: Phase) []const u8 {
            if (!copy_bounded and phase == .bounded) {
                self.shouldSwapSource();
            }
            defer self.ptr += n;
            return self.ptr[0..n];
        }

        pub fn peek(self: Self) u8 {
            return self.ptr[0];
        }

        pub fn backTo(self: *Self, index: usize) void {
            comptime assert(copy_bounded);
            assert(index < self.token);

            const doc = self.document();
            const ixs = self.indexes();

            if (index < self.bounded_token) {
                self.ptr = doc[ixs[index]..].ptr;
            } else {
                const index_ptr = @intFromPtr(doc[ixs[index]..].ptr);
                const padding_ptr = self.padding_ptr;
                const offset_ptr = index_ptr - padding_ptr;
                self.ptr = self.padding[offset_ptr..].ptr;
            }
        }

        fn shouldSwapSource(self: *Self) void {
            comptime assert(!copy_bounded);

            const index_ptr = @intFromPtr(self.ptr);
            const padding_ptr = @intFromPtr(self.padding_ptr);
            if (index_ptr >= padding_ptr) {
                const offset_ptr = index_ptr - padding_ptr;
                self.ptr = self.padding[offset_ptr..].ptr;
                self.padding_ptr = @ptrFromInt(std.math.maxInt(usize));
            }
        }
    };
}
