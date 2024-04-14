const std = @import("std");
const array = @import("types.zig").array;
const Vector = @import("types.zig").Vector;
const Allocator = std.mem.Allocator;

pub fn BoundedArrayList(comptime T: type) type {
    return struct {
        const Self = @This();
        len: usize = 0,
        list: std.ArrayList(T),

        pub fn init(alloc: std.mem.Allocator) Self {
            return .{
                .list = std.ArrayList(T).init(alloc),
            };
        }

        pub fn deinit(self: Self) void {
            self.list.deinit();
        }

        pub fn withCapacity(self: *Self, size: usize) Allocator.Error!void {
            try self.list.resize(size);
        }

        pub fn append(self: *Self, item: T) void {
            self.list.items[self.len] = item;
            self.len += 1;
        }

        pub fn appendSlice(self: *Self, items: *const array, len: usize) void {
            @memcpy(self.list.items[self.len..][0..Vector.LEN_BYTES], items);
            self.len += len;
        }

        pub fn clear(self: *Self) void {
            self.list.shrinkAndFree(self.len);
        }

        pub fn getLast(self: Self) T {
            return self.list.items[self.len - 1];
        }

        pub fn addManyAsSlice(self: *Self, n: usize) []T {
            defer self.len += n;
            return self.list.items[self.len..][0..n];
        }

        pub fn pop(self: *Self) T {
            self.len -= 1;
            return self.list.items[self.len];
        }
    };
}
