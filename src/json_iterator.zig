const std = @import("std");
const shared = @import("shared.zig");
const vector = std.vector;
const vector_size = std.vector_size;
const TokenIterator = @import("token_iterator.zig");
const Self = @This();

const Context = struct {
    is_array: bool,
    root: usize,
};

const State = std.MultiArrayList(Context);

var index: usize = 0;
iter: *TokenIterator,

pub fn init(iter: *TokenIterator) Self {
    return Self{
        .iter = iter,
    };
}

fn skipChild(self: *Self) !usize {
    var delta: isize = 1;
    while (self.iter.next()) |token| {
        switch (token.value()) {
            .open_bracket, .open_brace => {
                delta += 1;
            },
            .close_bracket, .close_brace => {
                delta -= 1;
                if (delta == 0) {
                    return self.iter.index;
                }
            },
            else => {},
        }
    }
    return error.NonTerminatedContainer;
}
