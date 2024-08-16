const std = @import("std");
const types = @import("types.zig");

pub const Options = struct {
    aligned: bool = true,
};

pub fn Reader(comptime options: Options) type {
    return struct {
        const Aligned = types.Aligned(options.aligned);
        pub const slice = Aligned.slice;
        pub const max_bytes = std.math.maxInt(u32);

        pub fn readFileAlloc(allocator: std.mem.Allocator, file_path: []const u8) !slice {
            return std.fs.cwd().readFileAllocOptions(allocator, file_path, max_bytes, null, Aligned.alignment, null);
        }
    };
}
