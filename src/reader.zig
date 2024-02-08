const std = @import("std");
const types = @import("types.zig");
const Mask = types.Mask;

const Self = @This();

pub const block = [Mask.LEN_BITS]u8;
const blank_buffer = [_]u8{' '} ** Mask.LEN_BITS;

index: usize = 0,
last_partial_index: usize,
document: []const u8,
buffer: block = blank_buffer,

pub fn init(doc: []const u8) Self {
    const remaining = doc.len % Mask.LEN_BITS;
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
        defer self.index += Mask.LEN_BITS;
        return self.document[self.index..][0..Mask.LEN_BITS];
    }
    return null;
}

pub fn last(self: *Self) ?*const block {
    if (self.index == self.last_partial_index) {
        defer self.index += Mask.LEN_BITS;
        return &self.buffer;
    }
    return null;
}
