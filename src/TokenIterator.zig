const std = @import("std");
const shared = @import("shared.zig");
const types = @import("types.zig");
const Indexer = @import("Indexer.zig");
const Vector = types.Vector;
const vector = types.vector;
const array = types.array;
const umask = types.umask;

pub const Phase = enum {
    unbounded,
    bounded,
    padded,
};

const Self = @This();
const blank_buffer = [_]u8{' '} ** (Vector.LEN_BYTES * 2);

indexer: Indexer,
remaining: [Vector.LEN_BYTES * 2]u8 = blank_buffer,
index: usize = 0,
bounded_index: usize,
remaining_ptr: [*]const u8,
curr_slice: [*]const u8,

pub fn init(indexer: Indexer) Self {
    const doc = indexer.reader.document;
    const indexes = indexer.indexes.list.items;
    const red_zone_bound = doc.len -| Vector.LEN_BYTES;
    var bounded_prefix: usize = indexer.indexes.list.items.len - 1;
    var rev = std.mem.reverseIterator(indexes);
    while (rev.next()) |prefix| : (bounded_prefix -= 1) {
        if (prefix <= red_zone_bound) break;
    }

    const remaining_ptr = doc[red_zone_bound..].ptr;
    var self = Self{
        .indexer = indexer,
        .curr_slice = doc.ptr,
        .bounded_index = bounded_prefix,
        .remaining_ptr = remaining_ptr,
    };
    @memcpy(self.remaining[0 .. doc.len - red_zone_bound], doc[red_zone_bound..doc.len]);
    return self;
}

pub fn advance(self: *Self, comptime phase: Phase) bool {
    const indexes = self.indexer.indexes.list.items;
    const document = self.indexer.reader.document;
    switch (phase) {
        .unbounded => {
            self.index += 1;
            if (self.index < self.bounded_index) {
                self.curr_slice = document[indexes[self.index]..].ptr;
                return true;
            }
            return false;
        },
        .bounded => {
            self.curr_slice = document[indexes[self.index]..].ptr;
            return true;
        },
        .padded => {
            self.index += 1;
            if (self.index < indexes.len) {
                const index_ptr = @intFromPtr(document[indexes[self.index]..].ptr);
                const remaining_ptr = @intFromPtr(self.remaining_ptr);
                const offset_ptr = index_ptr - remaining_ptr;
                self.curr_slice = self.remaining[offset_ptr..].ptr;
                return true;
            }
            return false;
        },
    }
}

pub fn empty(self: Self) bool {
    return self.indexer.indexes.list.items.len == 0;
}

pub fn next(self: *Self, comptime n: comptime_int, comptime phase: Phase) if (n == 1) u8 else *const [n]u8 {
    if (phase == .bounded) {
        self.shouldSwapSource();
    }
    defer self.curr_slice = self.curr_slice[n..];
    return self.peek(n);
}

pub fn peek(self: Self, comptime n: comptime_int) if (n == 1) u8 else *const [n]u8 {
    if (n > 1) {
        return self.curr_slice[0..n];
    } else {
        return self.curr_slice[0];
    }
}

pub fn nextSlice(self: *Self, n: usize, comptime phase: Phase) []const u8 {
    if (phase == .bounded) {
        self.shouldSwapSource();
    }
    defer self.curr_slice = self.curr_slice[n..];
    return self.peekSlice(n);
}

pub fn peekSlice(self: Self, n: usize) []const u8 {
    return self.curr_slice[0..n];
}

fn shouldSwapSource(self: *Self) void {
    const index_ptr = @intFromPtr(self.curr_slice);
    const remaining_ptr = @intFromPtr(self.remaining_ptr);
    if (index_ptr >= remaining_ptr) {
        const offset_ptr = index_ptr - remaining_ptr;
        self.curr_slice = self.remaining[offset_ptr..].ptr;
        self.remaining_ptr = @ptrFromInt(std.math.maxInt(usize));
    }
}
