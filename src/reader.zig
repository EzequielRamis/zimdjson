const std = @import("std");
const shared = @import("shared.zig");
const vector = shared.vector;
const vector_size = shared.vector_size;

const Self = @This();

const Block = struct {
    index: usize,
    value: vector,
};

index: usize = 0,
document: []const u8,

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
    if (remaining < vector_size) {
        var last_buffer = [_]u8{' '} ** vector_size;
        @memcpy((&last_buffer)[0..remaining], self.document[self.index..]);
        defer self.index += remaining;

        return Block{
            .index = self.index,
            .value = last_buffer,
        };
    }
    const buffer = self.document[self.index..][0..vector_size].*;
    defer self.index += vector_size;

    return Block{
        .index = self.index,
        .value = buffer,
    };
}
