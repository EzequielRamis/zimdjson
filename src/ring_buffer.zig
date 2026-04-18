const std = @import("std");
const builtin = @import("builtin");
const posix = std.posix;
const assert = std.debug.assert;
const native_os = builtin.os.tag;
const w = std.os.windows;

const File = std.Io.File;
const Io = std.Io;

pub const default_chunk_length = 1024 * 64;
const min_chunk_length = if (native_os == .windows) 1024 * 64 else std.heap.page_size_min;

pub const Error =
    File.SetLengthError ||
    std.posix.MemFdCreateError ||
    std.posix.MMapError ||
    (if (native_os == .macos) std.posix.OpenError else error{});

pub fn RingBuffer(comptime T: type, comptime length: usize) type {
    const byte_len = @sizeOf(T) * length;
    assert(byte_len >= min_chunk_length and std.math.isPowerOfTwo(byte_len));

    return struct {
        const Self = @This();
        pub const capacity = length;

        base: Buffer,

        const Buffer = struct {
            buffer: [*]align(std.heap.page_size_min) u8,
            file: File,

            pub fn init(io: Io) Error!Buffer {
                switch (native_os) {
                    .windows => {
                        if (!(builtin.os.isAtLeast(.windows, .win10_rs4) orelse false))
                            @compileError("RingBuffer mirrored mapping requires Windows 10 version 1803 or later");

                        // from https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualalloc2#examples

                        const buffer_ptr = VirtualAlloc2(
                            null,
                            null,
                            byte_len * 2,
                            @bitCast(w.MEM.ALLOCATE{ .RESERVE = true, .RESERVE_PLACEHOLDER = true }),
                            @bitCast(w.PAGE{ .NOACCESS = true }),
                            null,
                            0,
                        ) orelse return w.unexpectedError(w.GetLastError());

                        const buffer: [*]align(std.heap.page_size_min) u8 = @ptrCast(@alignCast(buffer_ptr));

                        var free_buffer = true;
                        defer if (free_buffer) {
                            _ = VirtualFree(buffer, 0, @bitCast(w.MEM.FREE{ .RELEASE = true }));
                        };

                        if (VirtualFree(buffer, byte_len, @bitCast(w.MEM.FREE{ .RELEASE = true, .PRESERVE_PLACEHOLDER = true })) == .FALSE) {
                            return w.unexpectedError(w.GetLastError());
                        }

                        var free_mirror = true;
                        defer if (free_mirror) {
                            _ = VirtualFree(buffer + byte_len, 0, @bitCast(w.MEM.FREE{ .RELEASE = true }));
                        };

                        const page_rw: u32 = @bitCast(w.PAGE{ .READWRITE = true });
                        const handle = CreateFileMappingW(
                            w.INVALID_HANDLE_VALUE,
                            null,
                            page_rw,
                            0,
                            @intCast(byte_len),
                            null,
                        ) orelse return w.unexpectedError(w.GetLastError());

                        const file = File{ .handle = handle, .flags = .{ .nonblocking = false } };
                        errdefer file.close(io);

                        const map_flags: u32 = @bitCast(w.MEM.MAP{ .REPLACE_PLACEHOLDER = true });

                        _ = MapViewOfFile3(handle, null, buffer, 0, byte_len, map_flags, page_rw, null, 0) orelse return w.unexpectedError(w.GetLastError());
                        free_buffer = false;

                        _ = MapViewOfFile3(handle, null, buffer + byte_len, 0, byte_len, map_flags, page_rw, null, 0) orelse return w.unexpectedError(w.GetLastError());
                        free_mirror = false;

                        return .{ .buffer = buffer, .file = file };
                    },
                    .macos => {
                        // taken from https://github.com/marler8997/zigx/blob/master/src/DoubleBuffer.zig

                        const buffer = try posix.mmap(null, byte_len * 2, .{ .READ = true, .WRITE = true }, .{ .TYPE = .PRIVATE, .ANONYMOUS = true }, -1, 0);
                        errdefer posix.munmap(buffer);

                        const name = blk: {
                            const prefix = "zimdrb_";
                            @memcpy(buffer[0..prefix.len], prefix);
                            var rand_bytes: [12]u8 = undefined;
                            io.random(&rand_bytes);
                            _ = std.base64.url_safe_no_pad.Encoder.encode(buffer[prefix.len..], &rand_bytes);
                            buffer[31] = 0;
                            break :blk buffer[0..31 :0];
                        };

                        const handle = std.c.shm_open(name, @bitCast(std.posix.O{ .ACCMODE = .RDWR, .CREAT = true, .EXCL = true }), @as(std.c.mode_t, 0o600));
                        if (handle == -1) return error.SystemResources;

                        const file = File{ .handle = handle, .flags = .{ .nonblocking = false } };
                        errdefer file.close(io);

                        try file.setLength(io, byte_len);

                        _ = try posix.mmap(@alignCast(buffer.ptr), byte_len, .{ .READ = true, .WRITE = true }, .{ .TYPE = .SHARED, .FIXED = true }, handle, 0);
                        _ = try posix.mmap(@alignCast(buffer.ptr + byte_len), byte_len, .{ .READ = true, .WRITE = true }, .{ .TYPE = .SHARED, .FIXED = true }, handle, 0);

                        return .{ .buffer = buffer.ptr, .file = file };
                    },
                    else => {
                        const handle = try posix.memfd_create("zimdjson_ringbuffer", posix.MFD.CLOEXEC);
                        const file = File{ .handle = handle, .flags = .{ .nonblocking = false } };
                        errdefer file.close(io);

                        try file.setLength(io, byte_len);

                        const buffer = try posix.mmap(null, byte_len * 2, .{ .READ = true, .WRITE = true }, .{ .TYPE = .PRIVATE, .ANONYMOUS = true }, -1, 0);
                        errdefer posix.munmap(buffer);

                        _ = try posix.mmap(@alignCast(buffer.ptr), byte_len, .{ .READ = true, .WRITE = true }, .{ .TYPE = .SHARED, .FIXED = true }, handle, 0);
                        _ = try posix.mmap(@alignCast(buffer.ptr + byte_len), byte_len, .{ .READ = true, .WRITE = true }, .{ .TYPE = .SHARED, .FIXED = true }, handle, 0);

                        return .{ .buffer = buffer.ptr, .file = file };
                    },
                }
            }

            pub fn deinit(self: Buffer, io: Io) void {
                switch (native_os) {
                    .windows => {
                        _ = UnmapViewOfFile(self.buffer);
                        _ = UnmapViewOfFile(self.buffer + byte_len);
                        self.file.close(io);
                    },
                    else => {
                        posix.munmap(self.buffer[0 .. byte_len * 2]);
                        self.file.close(io);
                    },
                }
            }
        };

        pub fn init(io: Io) Error!Self {
            return .{ .base = try Buffer.init(io) };
        }

        pub fn deinit(self: Self, io: Io) void {
            self.base.deinit(io);
        }

        pub inline fn ptr(self: Self) [*]T {
            return @ptrCast(self.base.buffer);
        }

        pub inline fn mask(_: Self, n: usize) usize {
            return n & (length - 1);
        }
    };
}

extern "api-ms-win-core-memory-l1-1-6" fn VirtualAlloc2(Process: ?w.HANDLE, BaseAddress: ?w.PVOID, Size: w.SIZE_T, AllocationType: w.ULONG, PageProtection: w.ULONG, ExtendedParameters: ?*anyopaque, ParameterCount: w.ULONG) callconv(.winapi) ?w.PVOID;
extern "api-ms-win-core-memory-l1-1-6" fn VirtualFree(lpAddress: w.LPVOID, dwSize: w.SIZE_T, dwFreeType: w.DWORD) callconv(.winapi) w.BOOL;
extern "api-ms-win-core-memory-l1-1-6" fn CreateFileMappingW(hFile: w.HANDLE, lpFileMappingAttributes: ?*anyopaque, flProtect: w.DWORD, dwMaximumSizeHigh: w.DWORD, dwMaximumSizeLow: w.DWORD, lpName: ?w.LPCWSTR) callconv(.winapi) ?w.HANDLE;
extern "api-ms-win-core-memory-l1-1-6" fn MapViewOfFile3(FileMapping: w.HANDLE, Process: ?w.HANDLE, BaseAddress: w.PVOID, Offset: w.ULONG64, ViewSize: w.SIZE_T, AllocationType: w.ULONG, PageProtection: w.ULONG, ExtendedParameters: ?*anyopaque, ParameterCount: w.ULONG) callconv(.winapi) ?w.PVOID;
extern "api-ms-win-core-memory-l1-1-6" fn UnmapViewOfFile(lpBaseAddress: w.LPCVOID) callconv(.winapi) w.BOOL;
