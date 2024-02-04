const std = @import("std");
const shared = @import("shared.zig");
const vector_size = shared.vector_size;
const vector_size_bits = vector_size * 8;
const ratio = shared.register_vector_ratio;
const vector = shared.vector;

const Self = @This();

pub const block = [vector_size_bits]u8;
const blank_buffer = [_]u8{' '} ** vector_size_bits;

index: usize = 0,
last_partial_index: usize,
document: []const u8,
buffer: block align(vector_size) = blank_buffer,

pub fn init(doc: []const u8) Self {
    const remaining = doc.len % vector_size_bits;
    const last_partial_index = doc.len -| remaining;
    var self = Self{
        .document = doc,
        .last_partial_index = last_partial_index,
    };
    @memcpy(self.buffer[0..remaining], self.document[self.last_partial_index..]);
    return self;
}

pub fn next(self: *Self) ?*const block {
    if (self.index > self.last_partial_index) {
        return null;
    }
    defer self.index += vector_size_bits;
    if (self.index < self.last_partial_index) {
        return self.document[self.index..][0..vector_size_bits];
    }
    return &self.buffer;
}
