const std = @import("std");
const shared = @import("shared.zig");
const vector = shared.vector;
const vector_size = shared.vector_size;
const Indexer = @import("indexer.zig");

const Self = @This();

index: usize = 0,
indexer: *Indexer,

const Value = enum {
    object,
    object_end,
    array,
    array_end,
    colon,
    comma,
    string,
    tru,
    fal,
    nul,
    number,
    unknown,
};

const Prefix = struct {
    tokens: []const u8,
    pub fn value(self: *@This()) Value {
        switch (self.tokens[0]) {
            '{' => return .object,
            '}' => return .object_end,
            '[' => return .array,
            ']' => return .array_end,
            ':' => return .colon,
            ',' => return .comma,
            '"' => return .string,
            't' => return .tru,
            'f' => return .fal,
            'n' => return .nul,
            '-', '0'...'9' => return .number,
            _ => return .unknown,
        }
    }
};

pub fn init(indexer: *Indexer) Self {
    return Self{
        .indexer = indexer,
    };
}

pub fn next(self: *Self) ?Prefix {
    if (!self.eof()) {
        return null;
    }
    const res = Prefix{ .tokens = self.indexer.tokens.items(.index)[self.index..] };
    self.index += 1;
    return res;
}

fn eof(self: *Self) bool {
    return self.index < self.indexer.tokens.len;
}
