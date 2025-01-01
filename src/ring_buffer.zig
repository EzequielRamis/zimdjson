const std = @import("std");
const posix = std.posix;
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

pub fn RingBuffer(comptime T: type, comptime length: u32) type {
    const byte_len = @sizeOf(T) * length;
    assert(byte_len >= std.mem.page_size and byte_len & (byte_len - 1) == 0); // Must be a power of 2

    return struct {
        const Self = @This();
        pub const capacity = length;

        buffer: []align(std.mem.page_size) u8,
        fd: posix.fd_t,
        head: u32,
        tail: u32,

        pub fn init() !Self {
            const fd = try posix.memfd_create("zimdjson_ringbuffer", posix.FD_CLOEXEC);
            errdefer posix.close(fd);
            try posix.ftruncate(fd, byte_len);

            const buffer = try posix.mmap(
                null,
                byte_len * 2,
                posix.PROT.READ | posix.PROT.WRITE,
                .{
                    .TYPE = .PRIVATE,
                    .ANONYMOUS = true,
                },
                -1,
                0,
            );
            errdefer posix.munmap(buffer);

            const mirror1 = try posix.mmap(
                @alignCast(buffer.ptr),
                byte_len,
                posix.PROT.READ | posix.PROT.WRITE,
                .{
                    .TYPE = .SHARED,
                    .FIXED = true,
                },
                fd,
                0,
            );
            if (mirror1.ptr != buffer.ptr) return error.Mirror;

            const mirror2 = try posix.mmap(
                @alignCast(buffer.ptr + byte_len),
                byte_len,
                posix.PROT.READ | posix.PROT.WRITE,
                .{
                    .TYPE = .SHARED,
                    .FIXED = true,
                },
                fd,
                0,
            );
            if (mirror2.ptr != buffer.ptr + byte_len) return error.Mirror;

            return .{
                .buffer = buffer,
                .fd = fd,
                .head = 0,
                .tail = 0,
            };
        }

        pub fn deinit(self: Self) void {
            posix.munmap(self.buffer);
            posix.close(self.fd);
        }

        inline fn ptr(self: Self) [*]T {
            return @ptrCast(self.buffer.ptr);
        }

        pub fn len(self: Self) u32 {
            const wrap_offset = length * 2 * @intFromBool(self.head < self.tail);
            const head = self.head +% wrap_offset;
            return head -% self.tail;
        }

        pub inline fn unused(self: Self) u32 {
            return length - self.len();
        }

        pub inline fn isEmpty(self: Self) bool {
            return self.head == self.tail;
        }

        pub inline fn isFull(self: Self) bool {
            return self.len() == length;
        }

        pub inline fn slice(self: Self) []T {
            return self.ptr()[mask(self.tail)..][0..self.len()];
        }

        pub inline fn unsafeSlice(self: Self) [*]T {
            return self.ptr()[mask(self.tail)..];
        }

        pub inline fn read(self: *Self) ?T {
            if (self.isEmpty()) return null;
            return self.readAssumeLength();
        }

        pub inline fn readAssumeLength(self: *Self) T {
            assert(!self.isEmpty());
            defer self.tail +%= 1;
            return self.ptr()[mask(self.tail)];
        }

        pub inline fn readAll(self: *Self) []const T {
            defer self.tail = self.head;
            return self.slice();
        }

        pub inline fn readFirst(self: *Self, count: u32) ![]const T {
            if (count > self.len()) return error.ReadLengthInvalid;
            return self.readFirstAssumeLength(count);
        }

        pub inline fn readFirstAssumeLength(self: *Self, count: u32) []const T {
            assert(count <= self.len());
            defer self.tail +%= count;
            return self.ptr()[mask(self.tail)..][0..count];
        }

        pub inline fn write(self: *Self, el: T) !void {
            if (self.isFull()) return error.Full;
            self.writeAssumeCapacity(el);
        }

        pub inline fn writeAssumeCapacity(self: *Self, el: T) void {
            assert(!self.isFull());
            defer self.head +%= 1;
            self.ptr()[mask(self.head)] = el;
        }

        pub inline fn writeSlice(self: *Self, data: []const T) !void {
            if (data.len > self.unused()) return error.Full;
            self.writeSliceAssumeCapacity(data);
        }

        pub inline fn writeSliceAssumeCapacity(self: *Self, data: []const T) void {
            assert(data.len <= self.unused());
            defer self.head +%= data.len;
            @memcpy(self.ptr()[mask(self.head)..][0..data.len], data);
        }

        pub inline fn reserve(self: *Self, count: u32) ![]T {
            if (count > self.unused()) return error.Full;
            return self.reserveAssumeCapacity(count);
        }

        pub inline fn reserveAssumeCapacity(self: *Self, count: u32) []T {
            assert(count <= self.unused());
            defer self.head +%= count;
            return self.ptr()[mask(self.head)..][0..count];
        }

        pub inline fn reserveAll(self: *Self) []T {
            return self.reserveAssumeCapacity(self.unused());
        }

        pub inline fn consume(self: *Self, count: u32) !void {
            if (count > self.len()) return error.ReadLengthInvalid;
            self.consumeAssumeLength(count);
        }

        pub inline fn consumeAssumeLength(self: *Self, count: u32) void {
            assert(count <= self.len());
            self.tail +%= count;
        }

        pub inline fn consumeAll(self: *Self) void {
            self.consumeAssumeLength(self.len());
        }

        pub inline fn shrink(self: *Self, count: u32) !void {
            if (count > self.len()) return error.ReadLengthInvalid;
            self.shrinkAssumeLength(count);
        }

        pub inline fn shrinkAssumeLength(self: *Self, count: u32) void {
            assert(count <= self.len());
            self.head -%= count;
        }

        inline fn mask(n: u32) u32 {
            return n & (length - 1);
        }
    };
}
