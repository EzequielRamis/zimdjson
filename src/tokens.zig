const std = @import("std");
const stream = @import("tokens/stream.zig");
const ring_buffer = @import("ring_buffer.zig");
const iterator = @import("tokens/iterator.zig");
const types = @import("types.zig");
const Allocator = std.mem.Allocator;

pub const Options = struct {
    aligned: bool,
    stream: ?StreamOptions,
};

pub const StreamOptions = struct {
    pub const default: StreamOptions = .{};

    chunk_length: u32 = ring_buffer.default_chunk_length,
};

pub fn Tokens(comptime options: Options) type {
    return struct {
        const Self = @This();
        const Aligned = types.Aligned(options.stream != null or options.aligned);
        const Iterator = if (options.stream) |s|
            stream.Stream(.{
                .aligned = true,
                .chunk_len = s.chunk_length,
            })
        else
            iterator.Iterator(.{
                .aligned = options.aligned,
            });

        iter: Iterator,

        pub fn init(
            allocator: if (options.stream) |_| void else Allocator,
        ) Self {
            return .{ .iter = if (options.stream) |_| .init else .init(allocator) };
        }

        pub fn deinit(self: *Self) void {
            self.iter.deinit();
        }

        pub fn build(
            self: *Self,
            document: if (options.stream) |_| std.fs.File else Aligned.slice,
        ) !void {
            return self.iter.build(document);
        }

        pub inline fn next(self: *Self) ![*]const u8 {
            return self.iter.next();
        }

        pub inline fn peek(self: *Self) !u8 {
            return self.iter.peek();
        }

        pub inline fn revert(self: *Self) void {
            return self.iter.revert();
        }
    };
}
