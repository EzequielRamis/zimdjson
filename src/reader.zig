const std = @import("std");
const builtin = @import("builtin");
const types = @import("types.zig");
const arch = builtin.cpu.arch;
const Mask = types.Mask;

const Self = @This();

pub const MASKS_PER_ITER = if (arch.isX86()) 2 else 1;
const BLOCK_SIZE = Mask.LEN_BITS * MASKS_PER_ITER;

pub const block = [BLOCK_SIZE]u8;
const blank_buffer = [_]u8{' '} ** BLOCK_SIZE;

index: usize = 0,
last_partial_index: usize,
document: []const u8,
buffer: block = blank_buffer,

pub fn init(doc: []const u8) Self {
    const remaining = doc.len % BLOCK_SIZE;
    const last_partial_index = doc.len -| remaining;
    var self = Self{
        .document = doc,
        .last_partial_index = last_partial_index,
    };
    @memcpy(self.buffer[0..remaining], self.document[self.last_partial_index..]);
    return self;
}

pub fn next(self: *Self) ?*const block {
    if (self.index < self.last_partial_index) {
        defer self.index += BLOCK_SIZE;
        return self.document[self.index..][0..BLOCK_SIZE];
    }
    return null;
}

pub fn last(self: *Self) ?*const block {
    if (self.index == self.last_partial_index) {
        defer self.index += BLOCK_SIZE;
        return &self.buffer;
    }
    return null;
}
