const std = @import("std");
const types = @import("types.zig");

pub const Options = struct {
    aligned: bool,
};

pub fn Reader(comptime options: Options) type {
    return struct {
        const Aligned = types.Aligned(options.aligned);
        pub const MaxBytes = std.math.maxInt(u32);

        const Self = @This();

        allocator: std.mem.Allocator,
        buffer: ?Aligned.Slice = null,

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{
                .allocator = allocator,
            };
        }

        pub fn deinit(self: Self) void {
            if (self.buffer) |b| self.allocator.free(b);
        }

        pub fn from(self: *Self, dir: std.fs.Dir, path: []const u8) !Aligned.Slice {
            self.buffer = try dir.readFileAllocOptions(self.allocator, path, MaxBytes, null, Aligned.Alignment, null);
            return self.buffer.?;
        }
    };
}

pub const FileReader = Reader(.{ .aligned = true });
