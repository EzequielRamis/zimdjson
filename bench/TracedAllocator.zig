const std = @import("std");

const Self = @This();

wrapped: std.mem.Allocator,
total: usize = 0,

pub fn allocator(self: *Self) std.mem.Allocator {
    return .{
        .ptr = self,
        .vtable = &.{
            .alloc = alloc,
            .resize = resize,
            .free = free,
            .remap = remap,
        },
    };
}

pub fn alloc(ctx: *anyopaque, len: usize, log2_ptr_align: std.mem.Alignment, ret_addr: usize) ?[*]u8 {
    const self: *Self = @ptrCast(@alignCast(ctx));
    self.total += len;
    return self.wrapped.rawAlloc(len, log2_ptr_align, ret_addr);
}

pub fn resize(
    ctx: *anyopaque,
    old_mem: []u8,
    log2_old_align_u8: std.mem.Alignment,
    new_size: usize,
    ret_addr: usize,
) bool {
    const self: *Self = @ptrCast(@alignCast(ctx));
    if (old_mem.len < new_size) {
        self.total += new_size - old_mem.len;
    } else {
        self.total -= old_mem.len - new_size;
    }
    return self.wrapped.rawResize(old_mem, log2_old_align_u8, new_size, ret_addr);
}

pub fn free(
    ctx: *anyopaque,
    old_mem: []u8,
    log2_old_align_u8: std.mem.Alignment,
    ret_addr: usize,
) void {
    const self: *Self = @ptrCast(@alignCast(ctx));
    self.total -= old_mem.len;
    return self.wrapped.rawFree(old_mem, log2_old_align_u8, ret_addr);
}

pub fn remap(ptr: *anyopaque, buf: []u8, buf_align: std.mem.Alignment, new_len: usize, ret_addr: usize) ?[*]u8 {
    return if (resize(ptr, buf, buf_align, new_len, ret_addr)) buf.ptr else null;
}
