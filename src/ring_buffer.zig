const std = @import("std");
const posix = std.posix;
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

pub fn RingBuffer(comptime length: usize) type {
    return struct {
        const Self = @This();

        buffer: []align(std.mem.page_size) u8,
        fd: posix.fd_t,
        head: usize,
        tail: usize,

        pub fn init() !Self {
            assert(length % std.mem.page_size == 0);

            const fd = try posix.memfd_create("zimdjson_ringbuffer", posix.FD_CLOEXEC);
            errdefer posix.close(fd);
            try posix.ftruncate(fd, length);

            const buffer = try posix.mmap(
                null,
                length * 2,
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
                length,
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
                @alignCast(buffer.ptr + length),
                length,
                posix.PROT.READ | posix.PROT.WRITE,
                .{
                    .TYPE = .SHARED,
                    .FIXED = true,
                },
                fd,
                0,
            );
            if (mirror2.ptr != buffer.ptr + length) return error.Mirror;

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

        pub fn used(self: Self) usize {
            const wrap_offset = length * 2 * @intFromBool(self.head < self.tail);
            const head = self.head + wrap_offset;
            return head - self.tail;
        }

        pub fn unused(self: Self) usize {
            return length - self.used();
        }

        pub fn isEmpty(self: Self) bool {
            return self.head == self.tail;
        }

        pub fn isFull(self: Self) bool {
            return (self.head + length) % (length * 2) == self.tail;
        }

        pub fn slice(self: Self) []u8 {
            return self.buffer[self.tail % length ..][0..self.used()];
        }

        pub fn read(self: *Self) ?u8 {
            if (self.isEmpty()) return null;
            return self.readAssumeLength();
        }

        pub fn readAssumeLength(self: *Self) u8 {
            assert(!self.isEmpty());
            defer self.tail = (self.tail + 1) % (length * 2);
            return self.buffer[self.tail];
        }

        pub fn readAll(self: *Self) []const u8 {
            defer self.tail = self.head;
            return self.slice();
        }

        pub fn readFirst(self: *Self, bytes: usize) ![]const u8 {
            if (bytes > self.used()) return error.ReadLengthInvalid;
            return self.readFirstAssumeLength(bytes);
        }

        pub fn readFirstAssumeLength(self: *Self, bytes: usize) []const u8 {
            assert(bytes <= self.used());
            defer self.tail = (self.tail + bytes) % (length * 2);
            return self.buffer[self.tail..][0..bytes];
        }

        pub fn write(self: *Self, byte: u8) !void {
            if (self.isFull()) return error.Full;
            self.writeAssumeCapacity(byte);
        }

        pub fn writeAssumeCapacity(self: *Self, byte: u8) void {
            assert(!self.isFull());
            defer self.head = (self.head + 1) % (length * 2);
            self.buffer[self.head] = byte;
        }

        pub fn writeSlice(self: *Self, bytes: []const u8) !void {
            if (bytes.len > self.unused()) return error.Full;
            self.writeSliceAssumeCapacity(bytes);
        }

        pub fn writeSliceAssumeCapacity(self: *Self, bytes: []const u8) void {
            assert(bytes.len <= self.unused());
            defer self.head = (self.head + bytes.len) % (length * 2);
            @memcpy(self.buffer[self.head..][0..bytes.len], bytes);
        }

        pub fn reserve(self: *Self, bytes: usize) ![]u8 {
            if (bytes > self.unused()) return error.Full;
            return self.reserveAssumeCapacity(bytes);
        }

        pub fn reserveAssumeCapacity(self: *Self, bytes: usize) []u8 {
            assert(bytes <= self.unused());
            defer self.head = (self.head + bytes) % (length * 2);
            return self.buffer[self.head..][0..bytes];
        }

        pub fn reserveAll(self: *Self) []u8 {
            return self.reserveAssumeCapacity(self.unused());
        }

        pub fn consume(self: *Self, bytes: usize) !void {
            if (bytes > self.used()) return error.ReadLengthInvalid;
            self.consumeAssumeLength(bytes);
        }

        pub fn consumeAssumeLength(self: *Self, bytes: usize) void {
            assert(bytes <= self.used());
            self.tail = (self.tail + bytes) % (length * 2);
        }

        pub fn consumeAll(self: *Self) void {
            self.consumeAssumeLength(self.used());
        }

        pub fn shrink(self: *Self, bytes: usize) !void {
            if (bytes > self.used()) return error.ReadLengthInvalid;
            self.shrinkAssumeLength(bytes);
        }

        pub fn shrinkAssumeLength(self: *Self, bytes: usize) void {
            assert(bytes <= self.used());
            self.head = (self.head - bytes) % (length * 2);
        }
    };
}
