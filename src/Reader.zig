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

index: usize = undefined,
last_partial_index: usize = undefined,
document: []const u8 = undefined,
buffer: block = undefined,

pub fn init() Self {
    return Self{};
}

pub fn read(self: *Self, doc: []const u8) void {
    const remaining = doc.len % BLOCK_SIZE;
    const last_partial_index = doc.len -| remaining;
    self.index = 0;
    self.document = doc;
    self.last_partial_index = last_partial_index;
    @memcpy(&self.buffer, &blank_buffer);
    @memcpy(self.buffer[0..remaining], self.document[self.last_partial_index..]);
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
