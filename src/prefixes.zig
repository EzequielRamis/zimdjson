const std = @import("std");
const shared = @import("shared.zig");
const vector = shared.vector;
const vector_size = shared.vector_size;
const Indexer = @import("indexer.zig");

const Self = @This();

pub const Prefix = struct {
    slice: []const u8,

    pub fn from(slice: []const u8) @This() {
        return @This(){
            .slice = slice,
        };
    }

    pub fn next(self: @This()) ?@This() {
        if (self.slice.len < 1) {
            return null;
        }
        return @This(){
            .slice = self.slice[1..],
        };
    }

    pub fn value(self: @This()) u8 {
        return self.slice[0];
    }
};

index: usize = 0,
indexer: Indexer,

pub fn init(indexer: Indexer) Self {
    return Self{
        .indexer = indexer,
    };
}

pub fn next(self: *Self) ?Prefix {
    const indexes = self.indexer.indexes.items;
    if (self.index < indexes.len) {
        defer self.index += 1;
        return Prefix.from(self.indexer.reader.document[indexes[self.index]..]);
    }
    return null;
}
