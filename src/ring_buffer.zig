const std = @import("std");
const posix = std.posix;
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

pub fn RingBuffer(comptime T: type, comptime length: usize) type {
    const byte_len = @sizeOf(T) * length;
    assert(byte_len % std.mem.page_size == 0);

    return struct {
        const Self = @This();
        pub const capacity = length;

        buffer: []align(std.mem.page_size) u8,
        fd: posix.fd_t,
        head: usize,
        tail: usize,

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

        fn ptr(self: Self) [*]T {
            return @ptrCast(self.buffer.ptr);
        }

        pub fn len(self: Self) usize {
            const wrap_offset = length * 2 * @intFromBool(self.head < self.tail);
            const head = self.head + wrap_offset;
            return head - self.tail;
        }

        pub fn unused(self: Self) usize {
            return length - self.len();
        }

        pub fn isEmpty(self: Self) bool {
            return self.head == self.tail;
        }

        pub fn isFull(self: Self) bool {
            return (self.head + length) % (length * 2) == self.tail;
        }

        pub fn slice(self: Self) []T {
            return self.ptr()[self.tail % length ..][0..self.len()];
        }

        pub fn unsafeSlice(self: Self) [*]T {
            return self.ptr()[self.tail % length ..];
        }

        pub fn read(self: *Self) ?T {
            if (self.isEmpty()) return null;
            return self.readAssumeLength();
        }

        pub fn readAssumeLength(self: *Self) T {
            assert(!self.isEmpty());
            defer self.tail = (self.tail + 1) % (length * 2);
            return self.ptr()[self.tail];
        }

        pub fn readAll(self: *Self) []const T {
            defer self.tail = self.head;
            return self.slice();
        }

        pub fn readFirst(self: *Self, count: usize) ![]const T {
            if (count > self.len()) return error.ReadLengthInvalid;
            return self.readFirstAssumeLength(count);
        }

        pub fn readFirstAssumeLength(self: *Self, count: usize) []const T {
            assert(count <= self.len());
            defer self.tail = (self.tail + count) % (length * 2);
            return self.ptr()[self.tail..][0..count];
        }

        pub fn write(self: *Self, el: T) !void {
            if (self.isFull()) return error.Full;
            self.writeAssumeCapacity(el);
        }

        pub fn writeAssumeCapacity(self: *Self, el: T) void {
            assert(!self.isFull());
            defer self.head = (self.head + 1) % (length * 2);
            self.ptr()[self.head] = el;
        }

        pub fn writeSlice(self: *Self, data: []const T) !void {
            if (data.len > self.unused()) return error.Full;
            self.writeSliceAssumeCapacity(data);
        }

        pub fn writeSliceAssumeCapacity(self: *Self, data: []const T) void {
            assert(data.len <= self.unused());
            defer self.head = (self.head + data.len) % (length * 2);
            @memcpy(self.ptr()[self.head..][0..data.len], data);
        }

        pub fn reserve(self: *Self, count: usize) ![]T {
            if (count > self.unused()) return error.Full;
            return self.reserveAssumeCapacity(count);
        }

        pub fn reserveAssumeCapacity(self: *Self, count: usize) []T {
            assert(count <= self.unused());
            defer self.head = (self.head + count) % (length * 2);
            return self.ptr()[self.head..][0..count];
        }

        pub fn reserveAll(self: *Self) []T {
            return self.reserveAssumeCapacity(self.unused());
        }

        pub fn consume(self: *Self, count: usize) !void {
            if (count > self.len()) return error.ReadLengthInvalid;
            self.consumeAssumeLength(count);
        }

        pub fn consumeAssumeLength(self: *Self, count: usize) void {
            assert(count <= self.len());
            self.tail = (self.tail + count) % (length * 2);
        }

        pub fn consumeAll(self: *Self) void {
            self.consumeAssumeLength(self.len());
        }

        pub fn shrink(self: *Self, count: usize) !void {
            if (count > self.len()) return error.ReadLengthInvalid;
            self.shrinkAssumeLength(count);
        }

        pub fn shrinkAssumeLength(self: *Self, count: usize) void {
            assert(count <= self.len());
            self.head = (self.head - count) % (length * 2);
        }
    };
}
