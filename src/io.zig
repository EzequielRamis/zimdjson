const std = @import("std");
const types = @import("types.zig");

pub const Options = struct {
    aligned: bool = true,
};

pub fn Reader(comptime options: Options) type {
    return struct {
        const Aligned = types.Aligned(options.aligned);
        pub const MaxBytes = std.math.maxInt(u32);

        pub fn readFileAlloc(allocator: std.mem.Allocator, dir: std.fs.Dir, file_path: []const u8) !Aligned.slice {
            return dir.readFileAllocOptions(allocator, file_path, MaxBytes, null, Aligned.alignment, null);
        }
    };
}
