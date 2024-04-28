const std = @import("std");
const shared = @import("shared.zig");
const types = @import("types.zig");
const Indexer = @import("Indexer.zig");
const ArrayList = std.ArrayList;
const Vector = types.Vector;
const vector = types.vector;
const array = types.array;
const umask = types.umask;
const assert = std.debug.assert;

pub const Phase = enum {
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

        indexer: Indexer = undefined,
        remaining: if (copy_bounded) ArrayList(u8) else [Vector.LEN_BYTES * 2]u8 = undefined,
        remaining_ptr: if (copy_bounded) void else [*]const u8 = undefined,
        bounded_index: usize = undefined,
        index: usize = undefined,
        curr_slice: [*]const u8 = undefined,

        pub fn init() Self {
            return Self{};
        }

        pub fn analyze(self: *Self, indexer: Indexer) if (copy_bounded) (!void) else void {
            const doc = indexer.reader.document;
            const indexes = indexer.indexes.items;
            const red_zone_bound = doc.len -| Vector.LEN_BYTES;
            var bounded_prefix: usize = indexer.indexes.items.len - 1;
            var rev = std.mem.reverseIterator(indexes);
            while (rev.next()) |prefix| : (bounded_prefix -= 1) {
                if (prefix <= red_zone_bound) break;
            }
            const remaining_ptr = doc[red_zone_bound..].ptr;
            self.indexer = indexer;
            self.index = std.math.maxInt(usize);
            self.bounded_index = bounded_prefix;
            self.curr_slice = doc.ptr;
            if (copy_bounded) {
                const bounded_index = indexes[bounded_prefix];
                const remaining_len = doc.len - doc[bounded_index];
                self.remaining.ensureTotalCapacity(remaining_len + Vector.LEN_BYTES);
                @memset(self.remaining, ' ');
                @memcpy(self.remaining[0..remaining_len], doc[bounded_index..]);
            } else {
                self.remaining_ptr = remaining_ptr;
                @memset(self.remaining, ' ');
                @memcpy(self.remaining[0 .. doc.len - red_zone_bound], doc[red_zone_bound..doc.len]);
            }
        }

        pub fn next(self: *Self, comptime phase: ?Phase) ?u8 {
            if (phase == null) {
                return self.next(.unbounded) orelse self.next(.bounded) orelse self.next(.padded);
            }
            const indexes = self.indexer.indexes.items;
            const document = self.indexer.reader.document;
            self.index +%= 1;
            switch (phase) {
                .unbounded => {
                    if (self.index < self.bounded_index) {
                        const i = indexes[self.index];
                        self.curr_slice = document[i..].ptr;
                        return document[i];
                    }
                    return null;
                },
                .bounded => {
                    if (self.index == self.bounded_index) {
                        const i = indexes[self.index];
                        self.curr_slice = if (copy_bounded) self.remaining.items else document[i..].ptr;
                        return document[i];
                    }
                    return null;
                },
                .padded => {
                    if (self.index < indexes.len) {
                        const i = indexes[self.index];
                        const b = indexes[self.bounded_index];

                        const index_ptr = @intFromPtr(document[i..].ptr);
                        const remaining_ptr = @intFromPtr(if (copy_bounded) document[b..].ptr else self.remaining_ptr);
                        const offset_ptr = index_ptr - remaining_ptr;
                        self.curr_slice = self.remaining[offset_ptr..].ptr;

                        return document[i];
                    }
                    self.index = indexes.len;
                    return null;
                },
            }
        }

        pub fn empty(self: Self) bool {
            return self.indexer.indexes.items.len == 0;
        }

        pub fn consume(self: *Self, n: usize, comptime phase: ?Phase) []const u8 {
            if (!copy_bounded and phase == .bounded) {
                self.shouldSwapSource();
            }
            defer self.curr_slice = self.curr_slice[n..];
            return self.peekSlice(n);
        }

        pub fn peek(self: Self) u8 {
            const doc = self.indexer.reader.document;
            const indexes = self.indexer.indexes.items;
            return doc[indexes[indexes.len - 1]];
        }

        pub fn peekNext(self: Self) ?u8 {
            const doc = self.indexer.reader.document;
            const indexes = self.indexer.indexes.items;
            const p = self.index + 1;
            if (p < indexes.len) return doc[indexes[p]];
            return null;
        }

        pub fn peekSlice(self: Self, n: usize) []const u8 {
            return self.curr_slice[0..n];
        }

        pub fn backTo(self: *Self, index: usize) void {
            comptime assert(copy_bounded);
            assert(index < self.index);

            const doc = self.indexer.reader.document;
            const indexes = self.indexer.indexes;

            if (index < self.bounded_index) {
                self.curr_slice = doc[indexes[index]..].ptr;
            } else {
                const index_ptr = @intFromPtr(doc[indexes[index]..].ptr);
                const remaining_ptr = self.remaining_ptr;
                const offset_ptr = index_ptr - remaining_ptr;
                self.curr_slice = self.remaining[offset_ptr..].ptr;
            }
        }

        fn shouldSwapSource(self: *Self) void {
            comptime assert(!copy_bounded);

            const index_ptr = @intFromPtr(self.curr_slice);
            const remaining_ptr = @intFromPtr(self.remaining_ptr);
            if (index_ptr >= remaining_ptr) {
                const offset_ptr = index_ptr - remaining_ptr;
                self.curr_slice = self.remaining[offset_ptr..].ptr;
                self.remaining_ptr = @ptrFromInt(std.math.maxInt(usize));
            }
        }
    };
}
