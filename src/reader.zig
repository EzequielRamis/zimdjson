const std = @import("std");
const shared = @import("shared.zig");
const register_size = shared.register_size;
const ratio = shared.register_vector_ratio;
const vector = shared.vector;

const Self = @This();

pub const Block = struct {
    index: usize,
    value: *const [register_size]u8,
};

const blank_buffer = [_]u8{' '} ** register_size;
var last_buffer = blank_buffer;
index: usize = 0,
document: []const u8,
buffer: *[register_size]u8 = @constCast(&blank_buffer),

pub fn init(doc: []const u8) Self {
    return Self{
        .document = doc,
    };
}

pub fn next(self: *Self) ?Block {
    const remaining = self.document.len -| self.index;
    if (remaining == 0) {
        return null;
    }
    if (remaining < register_size) {
        self.buffer = &last_buffer;
        @memcpy(self.buffer[0..remaining], self.document[self.index..]);
        defer self.index += remaining;

        return Block{
            .index = self.index,
            .value = self.buffer,
        };
    }
    self.buffer = @constCast(self.document[self.index..][0..register_size]);
    defer self.index += register_size;

    return Block{
        .index = self.index,
        .value = self.buffer,
    };
}
