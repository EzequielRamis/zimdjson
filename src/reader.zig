const std = @import("std");
const shared = @import("shared.zig");
const register_size = shared.register_size;
const ratio = shared.register_vector_ratio;
const vector = shared.vector;

const Self = @This();

pub const Block = struct {
    index: usize,
    value: *[ratio]vector,
};

index: usize = 0,
document: []const u8,
buffer: [ratio]vector = @bitCast(@as(std.meta.Int(std.builtin.Signedness.unsigned, register_size * 8), @intCast(0))),

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
        var last_buffer = [_]u8{' '} ** register_size;
        @memcpy((&last_buffer)[0..remaining], self.document[self.index..]);
        self.buffer = @bitCast(last_buffer);
        defer self.index += remaining;

        return Block{
            .index = self.index,
            .value = &self.buffer,
        };
    }
    self.buffer = @bitCast(self.document[self.index..][0..register_size].*);
    defer self.index += register_size;

    return Block{
        .index = self.index,
        .value = &self.buffer,
    };
}
