const std = @import("std");
const shared = @import("shared.zig");
const types = @import("types.zig");
const Indexer = @import("Indexer.zig");
const Vector = types.Vector;
const vector = types.vector;
const array = types.array;
const umask = types.umask;

const Self = @This();

const blank_buffer = [_]u8{' '} ** (Vector.LEN_BYTES * 2);

indexer: Indexer,
remaining: [Vector.LEN_BYTES * 2]u8 = blank_buffer,
index: usize = 0,
bounded_index: usize,
remaining_ptr: [*]const u8,
curr_slice: [*]const u8,
shouldSwapSource: *const fn (self: *Self) void = noSwapSource,

pub fn init(indexer: Indexer) Self {
    const doc = indexer.reader.document;
    const indexes = indexer.indexes.list.items;
    const red_zone_bound = doc.len -| Vector.LEN_BYTES;
    var bounded_prefix: usize = indexer.indexes.list.items.len - 1;
    var rev = std.mem.reverseIterator(indexes);
    while (rev.next()) |prefix| : (bounded_prefix -= 1) {
        if (prefix <= red_zone_bound) break;
    }

    const bounded_index = indexes[bounded_prefix];
    if (doc[bounded_index] == '"' and !(bounded_index + 1 <= red_zone_bound)) {
        bounded_prefix -= 1;
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

pub fn advance(self: *Self) ?*Self {
    const indexes = self.indexer.indexes.list.items;
    const document = self.indexer.reader.document;
    self.index +|= 1;
    if (self.index < self.bounded_index) {
        self.curr_slice = document[indexes[self.index]..].ptr;
        return self;
    }
    if (self.index == self.bounded_index) {
        self.shouldSwapSource = swapSource;
        self.curr_slice = document[indexes[self.index]..].ptr;
        return self;
    }
    self.shouldSwapSource = noSwapSource;
    if (self.index < indexes.len) {
        const index_ptr = @intFromPtr(document[indexes[self.index]..].ptr);
        const remaining_ptr = @intFromPtr(self.remaining_ptr);
        const offset_ptr = index_ptr - remaining_ptr;
        self.curr_slice = self.remaining[offset_ptr..].ptr;
        return self;
    }
    return null;
}

pub fn empty(self: Self) bool {
    return self.indexer.indexes.list.items.len == 0;
}

pub fn peek(self: Self) u8 {
    return self.curr_slice[0];
}

pub fn next(self: *Self) u8 {
    self.shouldSwapSource(self);
    defer self.curr_slice = self.curr_slice[1..];
    return self.peek();
}

pub fn peekNibble(self: *Self) *const [4]u8 {
    return self.curr_slice[0..4];
}

pub fn nextNibble(self: *Self) *const [4]u8 {
    self.shouldSwapSource(self);
    defer self.curr_slice = self.curr_slice[4..];
    return self.peekNibble();
}

pub fn peekMask(self: *Self) *const [8]u8 {
    return self.curr_slice[0..8];
}

pub fn nextMask(self: *Self) *const [8]u8 {
    self.shouldSwapSource(self);
    defer self.curr_slice = self.curr_slice[8..];
    return self.peekMask();
}

pub fn peekVector(self: *Self) *const [Vector.LEN_BYTES]u8 {
    return self.curr_slice[0..Vector.LEN_BYTES];
}

pub fn nextVector(self: *Self) *const [Vector.LEN_BYTES]u8 {
    self.shouldSwapSource(self);
    defer self.curr_slice = self.curr_slice[Vector.LEN_BYTES..];
    return self.peekVector();
}

pub fn nextVoid(self: *Self, n: usize) void {
    self.shouldSwapSource(self);
    self.curr_slice = self.curr_slice[n..];
}

fn swapSource(self: *Self) void {
    const index_ptr = @intFromPtr(self.curr_slice);
    const remaining_ptr = @intFromPtr(self.remaining_ptr);
    if (index_ptr >= remaining_ptr) {
        const offset_ptr = index_ptr - remaining_ptr;
        self.curr_slice = self.remaining[offset_ptr..].ptr;
        self.shouldSwapSource = noSwapSource;
    }
}

fn noSwapSource(_: *Self) void {}
