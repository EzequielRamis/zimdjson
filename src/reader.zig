const std = @import("std");
const shared = @import("shared.zig");
const register_size = shared.register_size;
const ratio = shared.register_vector_ratio;
const vector = shared.vector;

const Self = @This();

pub const block = [register_size]u8;
const blank_buffer = [_]u8{' '} ** register_size;

index: usize = 0,
document: []const u8,
buffer: block = blank_buffer,

pub fn init(doc: []const u8) Self {
    return Self{
        .document = doc,
    };
}

pub fn next(self: *Self) ?*const block {
    const remaining = self.document.len -| self.index;
    if (remaining == 0) {
        return null;
    }
    if (remaining < register_size) {
        @memcpy(self.buffer[0..remaining], self.document[self.index..]);
        defer self.index += remaining;
        return &self.buffer;
    }
    defer self.index += register_size;
    return self.document[self.index..][0..register_size];
}
