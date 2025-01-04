const std = @import("std");
const builtin = @import("builtin");
const posix = std.posix;
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const native_os = builtin.os.tag;
const w = std.os.windows;

pub const default_chunk_length = if (native_os == .windows) 1024 * 64 else std.mem.page_size * 16;
const min_chunk_length = if (native_os == .windows) 1024 * 64 else std.mem.page_size;

pub fn RingBuffer(comptime T: type, comptime length: u32) type {
    const byte_len = @sizeOf(T) * length;
    assert(byte_len >= min_chunk_length and byte_len & (byte_len - 1) == 0); // Must be a power of 2

    return struct {
        const Self = @This();
        pub const capacity = length;

        base: switch (native_os) {
            .windows => {
                if (builtin.os.isAtLeast(native_os, .win10) orelse false)
                    WindowsBuffer
                else
                    @compileError("Windows 10 or later is required to create a memory-mapped ring buffer");
            },
            else => PosixBuffer,
        },
        head: u32,
        tail: u32,

        const PosixBuffer = struct {
            const Handle = std.fs.File.Handle;

            buffer: [*]u8,
            handle: Handle,

            pub fn init() !PosixBuffer {
                const handle = try posix.memfd_create("zimdjson_ringbuffer", posix.FD_CLOEXEC);
                errdefer posix.close(handle);
                try posix.ftruncate(handle, byte_len);

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
                    handle,
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
                    handle,
                    0,
                );
                if (mirror2.ptr != buffer.ptr + byte_len) return error.Mirror;

                return .{ .buffer = buffer, .handle = handle };
            }

            fn deinit(self: PosixBuffer) void {
                posix.munmap(self.buffer);
                posix.close(self.handle);
            }
        };

        const WindowsBuffer = struct {
            buffer: [*]u8,
            mirror: *anyopaque,

            // from https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualalloc2#examples
            pub fn init() !WindowsBuffer {
                const MEM_RESERVE = 0x00002000;
                const buffer = VirtualAlloc2(
                    null,
                    null,
                    byte_len * 2,
                    MEM_RESERVE | w.MEM_RESERVE_PLACEHOLDERS,
                    w.PAGE_NOACCESS,
                    null,
                    0,
                );
                if (buffer == null) return error.Mirror;
                errdefer w.VirtualFree(buffer, 0, w.MEM_RELEASE);

                const MEM_PRESERVE_PLACEHOLDER = 0x00000002;
                if (!w.kernel32.VirtualFree(
                    buffer,
                    byte_len,
                    w.MEM_RELEASE | MEM_PRESERVE_PLACEHOLDER,
                )) return error.Mirror;

                const section = CreateFileMappingW(
                    w.INVALID_HANDLE_VALUE,
                    null,
                    w.PAGE_READWRITE,
                    0,
                    byte_len,
                    null,
                );
                if (section == null) return error.Mirror;
                errdefer w.CloseHandle(section);

                const MEM_REPLACE_PLACEHOLDER = 0x00004000;
                const mirror1 = MapViewOfFile3(
                    section,
                    null,
                    buffer,
                    0,
                    byte_len,
                    MEM_REPLACE_PLACEHOLDER,
                    w.PAGE_READWRITE,
                    null,
                    0,
                );
                if (mirror1 == null) return error.Mirror;
                errdefer UnmapViewOfFileEx(mirror1, 0);

                const mirror2 = MapViewOfFile3(
                    section,
                    null,
                    buffer + byte_len,
                    0,
                    byte_len,
                    MEM_REPLACE_PLACEHOLDER,
                    w.PAGE_READWRITE,
                    null,
                    0,
                );
                if (mirror2 == null) return error.Mirror;
                errdefer UnmapViewOfFileEx(mirror2, 0);

                return .{ .buffer = buffer, .mirror = mirror2 };
            }

            fn deinit(self: WindowsBuffer) void {
                _ = UnmapViewOfFile(self.buffer);
                _ = UnmapViewOfFile(self.mirror);
            }
        };

        pub fn init() !Self {
            return .{
                .mirror = try .init(),
                .head = 0,
                .tail = 0,
            };
        }

        pub fn deinit(self: Self) void {
            self.base.deinit();
        }

        inline fn ptr(self: Self) [*]T {
            return @ptrCast(self.base.buffer);
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

extern "kernel32" fn VirtualAlloc2(
    Process: ?w.HANDLE,
    BaseAddress: ?w.PVOID,
    Size: w.SIZE_T,
    AllocationType: w.ULONG,
    PageProtection: w.ULONG,
    ExtendedParameters: ?*anyopaque,
    ParameterCount: w.ULONG,
) callconv(w.WINAPI) ?w.PVOID;

extern "kernel32" fn CreateFileMappingW(
    hFile: w.HANDLE,
    lpFileMappingAttributes: ?*const anyopaque,
    flProtect: w.DWORD,
    dwMaximumSizeHigh: w.DWORD,
    dwMaximumSizeLow: w.DWORD,
    lpName: ?w.LPCWSTR,
) callconv(w.WINAPI) ?w.HANDLE;

extern "kernel32" fn MapViewOfFile3(
    FileMapping: w.HANDLE,
    Process: w.HANDLE,
    BaseAddress: ?w.PVOID,
    Offset: w.ULONG64,
    ViewSize: w.SIZE_T,
    AllocationType: w.ULONG,
    PageProtection: w.ULONG,
    ExtendedParameters: ?*anyopaque,
    ParameterCount: w.ULONG,
) callconv(w.WINAPI) ?w.PVOID;

extern "kernel32" fn UnmapViewOfFileEx(
    BaseAddress: w.PVOID,
    UnmapFlags: w.ULONG,
) callconv(w.WINAPI) w.BOOL;

extern "kernel32" fn UnmapViewOfFile(
    lpBaseAddress: w.LPCVOID,
) callconv(w.WINAPI) w.BOOL;
