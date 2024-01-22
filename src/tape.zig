const std = @import("std");
const Indexer = @import("indexer.zig");

const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Self = @This();

tape: Tape,
string_escaped_values: ArrayList(u8),
indexer: *Indexer,

const NodeTag = enum {
    root,
    true_atom,
    false_atom,
    null_atom,
    unsigned,
    signed,
    float,
    big_int,
    string_key,
    string_value,
    string_escaped_key,
    string_escaped_value,
    object_begin,
    object_end,
    array_begin,
    array_end,
};

pub const Node = union(NodeTag) {
    root: usize,
    true_atom: void,
    false_atom: void,
    null_atom: void,
    unsigned: u64,
    signed: i64,
    float: f64,
    big_int: [:0]const u8,
    string_key: [:0]const u8,
    string_key_raw: [:0]const u8,
    string_value: [:0]const u8,
    string_value_raw: [:0]const u8,
    object_begin: usize,
    object_end: usize,
    array_begin: usize,
    array_end: usize,
};

pub const Tape = std.MultiArrayList(Node);

pub fn init(allocator: Allocator, document: []const u8) Self {
    return Self{
        .tape = Tape{},
        .string_escaped_values = ArrayList(u8).init(allocator),
        .indexer = Indexer.init(allocator, document),
    };
}

pub fn deinit(self: *Self) void {
    self.tape.deinit();
    self.string_escaped_values.deinit();
    self.indexer.deinit();
}
