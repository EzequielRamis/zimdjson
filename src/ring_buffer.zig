const std = @import("std");
const builtin = @import("builtin");
const types = @import("types.zig");
const posix = std.posix;
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const native_os = builtin.os.tag;
const w = std.os.windows;

pub const default_chunk_length = 1024 * 64;
const min_chunk_length = if (native_os == .windows) 1024 * 64 else std.heap.page_size_min;

pub const Error =
    std.posix.MemFdCreateError ||
    std.posix.TruncateError ||
    std.posix.MMapError ||
    (if (native_os == .macos) std.posix.GetRandomError else error{});

pub fn RingBuffer(comptime T: type, comptime length: usize) type {
    const byte_len = @sizeOf(T) * length;
    assert(byte_len >= min_chunk_length and std.math.isPowerOfTwo(byte_len));
    assert(if (native_os == .macos) byte_len <= 1024 * 1024 * 4 else true);

    return struct {
        const Self = @This();
        pub const capacity = length;

        base: Buffer,

        const Buffer = struct {
            buffer: [*]align(std.heap.page_size_min) u8,
            handle: if (native_os == .windows) w.HANDLE else std.fs.File.Handle,

            pub fn init() Error!Buffer {
                switch (native_os) {
                    .windows => {
                        if (!(builtin.os.isAtLeast(native_os, .win10) orelse false))
                            @compileError("Streaming capabilities are supported on Windows 10 and later");

                        // from https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualalloc2#examples
                        const MEM_RESERVE = 0x02000;
                        const MEM_RESERVE_PLACEHOLDER = 0x40000;
                        const MEM_REPLACE_PLACEHOLDER = 0x04000;
                        const MEM_PRESERVE_PLACEHOLDER = 0x00002;

                        const buffer: [*]align(std.heap.page_size_min) u8 = @alignCast(@ptrCast(VirtualAlloc2(
                            null,
                            null,
                            byte_len * 2,
                            MEM_RESERVE | MEM_RESERVE_PLACEHOLDER,
                            w.PAGE_NOACCESS,
                            null,
                            0,
                        ) orelse switch (w.kernel32.GetLastError()) {
                            else => |err| return w.unexpectedError(err),
                        }));

                        var free_buffer = true;
                        defer if (free_buffer) w.VirtualFree(buffer, 0, w.MEM_RELEASE);

                        w.VirtualFree(buffer, byte_len, w.MEM_RELEASE | MEM_PRESERVE_PLACEHOLDER);

                        var free_mirror = true;
                        defer if (free_mirror) w.VirtualFree(buffer + byte_len, 0, w.MEM_RELEASE);

                        const handle = CreateFileMappingW(
                            w.INVALID_HANDLE_VALUE,
                            null,
                            w.PAGE_READWRITE,
                            0,
                            byte_len,
                            null,
                        ) orelse switch (w.kernel32.GetLastError()) {
                            else => |err| return w.unexpectedError(err),
                        };
                        errdefer w.CloseHandle(handle);

                        const mirror1 = MapViewOfFile3(
                            handle,
                            null,
                            buffer,
                            0,
                            byte_len,
                            MEM_REPLACE_PLACEHOLDER,
                            w.PAGE_READWRITE,
                            null,
                            0,
                        ) orelse switch (w.kernel32.GetLastError()) {
                            else => |err| return w.unexpectedError(err),
                        };
                        errdefer assert(0 != UnmapViewOfFileEx(mirror1, 0));
                        free_buffer = false;

                        const mirror2 = MapViewOfFile3(
                            handle,
                            null,
                            buffer + byte_len,
                            0,
                            byte_len,
                            MEM_REPLACE_PLACEHOLDER,
                            w.PAGE_READWRITE,
                            null,
                            0,
                        ) orelse switch (w.kernel32.GetLastError()) {
                            else => |err| return w.unexpectedError(err),
                        };
                        errdefer assert(0 != UnmapViewOfFileEx(mirror2, 0));
                        free_mirror = false;

                        return .{ .buffer = buffer, .handle = handle };
                    },
                    .macos => {
                        // taken from https://github.com/marler8997/zigx/blob/master/src/DoubleBuffer.zig

                        const pshmnamlen = 31;
                        const shm_prefix = "zimdrb_"; // 7
                        const base64_len = pshmnamlen - shm_prefix.len; // 24
                        const encoder: std.base64.Base64Encoder = comptime .init(std.base64.url_safe_alphabet_chars, '=');
                        var encoded_buffer: [pshmnamlen + 1]u8 = undefined;
                        @memcpy(encoded_buffer[0..shm_prefix.len], shm_prefix);
                        var rand_bytes: [18]u8 = undefined; // 18 is the required bytes for 24 base64 encoded bytes
                        try std.posix.getrandom(&rand_bytes);
                        const encoded = encoder.encode(encoded_buffer[shm_prefix.len..], &rand_bytes);
                        assert(encoded.len == base64_len);
                        encoded_buffer[pshmnamlen] = 0;
                        const name: [*:0]const u8 = @ptrCast(encoded_buffer[0 .. shm_prefix.len + encoded.len]);

                        const handle = std.c.shm_open(
                            name,
                            @bitCast(std.posix.O{
                                .ACCMODE = .RDWR,
                                .CREAT = true,
                                .EXCL = true,
                            }),
                            std.posix.S.IRUSR | std.posix.S.IWUSR,
                        );
                        if (handle == -1) switch (@as(std.posix.E, @enumFromInt(std.c._errno().*))) {
                            .EXIST => return error.PathAlreadyExists,
                            .NAMETOOLONG => return error.NameTooLong,
                            else => |err| return std.posix.unexpectedErrno(err),
                        };
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

                        _ = try posix.mmap(
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

                        _ = try posix.mmap(
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

                        return .{ .buffer = buffer.ptr, .handle = handle };
                    },
                    else => {
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

                        _ = try posix.mmap(
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

                        _ = try posix.mmap(
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

                        return .{ .buffer = buffer.ptr, .handle = handle };
                    },
                }
            }
            pub fn deinit(self: Buffer) void {
                switch (native_os) {
                    .windows => {
                        assert(0 != UnmapViewOfFile(self.buffer));
                        assert(0 != UnmapViewOfFile(self.buffer + byte_len));
                        w.CloseHandle(self.handle);
                    },
                    else => {
                        posix.munmap(self.buffer[0 .. byte_len * 2]);
                        posix.close(self.handle);
                    },
                }
            }
        };

        pub fn init() Error!Self {
            return .{
                .base = try .init(),
            };
        }

        pub fn deinit(self: Self) void {
            self.base.deinit();
        }

        pub inline fn ptr(self: Self) [*]T {
            return @ptrCast(self.base.buffer);
        }

        pub inline fn mask(_: Self, n: usize) usize {
            return n & (length - 1);
        }
    };
}

extern "api-ms-win-core-memory-l1-1-6" fn VirtualAlloc2(Process: ?w.HANDLE, BaseAddress: ?w.PVOID, Size: w.SIZE_T, AllocationType: w.ULONG, PageProtection: w.ULONG, ExtendedParameters: ?*anyopaque, ParameterCount: w.ULONG) callconv(w.WINAPI) ?w.PVOID;
extern "api-ms-win-core-memory-l1-1-6" fn CreateFileMappingW(hFile: w.HANDLE, lpFileMappingAttributes: ?*anyopaque, flProtect: w.DWORD, dwMaximumSizeHigh: w.DWORD, dwMaximumSizeLow: w.DWORD, lpName: ?w.LPCWSTR) callconv(w.WINAPI) ?w.HANDLE;
extern "api-ms-win-core-memory-l1-1-6" fn MapViewOfFile3(FileMapping: w.HANDLE, Process: ?w.HANDLE, BaseAddress: w.PVOID, Offset: w.ULONG64, ViewSize: w.SIZE_T, AllocationType: w.ULONG, PageProtection: w.ULONG, ExtendedParameters: ?*anyopaque, ParameterCount: w.ULONG) callconv(w.WINAPI) ?w.PVOID;
extern "api-ms-win-core-memory-l1-1-6" fn UnmapViewOfFileEx(BaseAddress: w.PVOID, UnmapFlags: w.ULONG) callconv(w.WINAPI) w.BOOL;
extern "api-ms-win-core-memory-l1-1-6" fn UnmapViewOfFile(lpBaseAddress: w.LPCVOID) callconv(w.WINAPI) w.BOOL;
