const std = @import("std");
const shared = @import("shared.zig");
const vector = shared.vector;
const vector_size = shared.vector_size;

const Self = @This();

var last_full_block: usize = 0;

index: usize = 0,
document: []const u8,

pub fn init(doc: []const u8) Self {
    last_full_block = ((doc.len -| 1) / vector_size) * vector_size;
    return Self{
        .document = doc,
    };
}

pub fn next(self: *Self) ?vector {
    if (self.has_full_block()) {
        const buffer = self.document[self.index..][0..vector_size];
        self.i += vector_size;
        return buffer;
    }
    const remaining = self.document.len -| self.index;
    if (remaining == 0) {
        return null;
    }
    if (remaining < vector_size) {
        var last_buffer: [vector_size]u8 = [_]u8{' '} ** vector_size;
        @memcpy((&last_buffer)[0..remaining], self.document[self.i..]);
        self.i += remaining;
        return last_buffer;
    }
}

fn has_full_block(self: *Self) bool {
    return self.i <= last_full_block;
}
