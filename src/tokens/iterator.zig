const std = @import("std");
const common = @import("../common.zig");
const types = @import("../types.zig");
const indexer = @import("../indexer.zig");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Vector = types.Vector;
const Error = types.Error;
const vector = types.vector;
const umask = types.umask;
const assert = std.debug.assert;

pub const Options = struct {
    aligned: bool,
};

pub fn Iterator(comptime options: Options) type {
    return struct {
        const Self = @This();
        const Aligned = types.Aligned(options.aligned);

        indexes: ArrayList(u32),
        padding: ArrayList(u8),
        indexer: indexer.Indexer(.{
            .aligned = options.aligned,
            .relative = false,
        }),
        document: Aligned.slice = undefined,
        padding_token: u32 = undefined,
        padding_offset: [*]const u8 = undefined,
        token: u32 = undefined,

        pub const bogus_token = ' ';

        pub fn init(allocator: Allocator) Self {
            return .{
                .indexer = .init,
                .indexes = .init(allocator),
                .padding = .init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.indexes.deinit();
            self.padding.deinit();
        }

        pub inline fn build(self: *Self, document: Aligned.slice) !void {
            {
                try self.indexes.ensureTotalCapacityPrecise(document.len + 1); // + 1 because of the bogus index
                self.indexer = .init;
                self.document = document;

                var written: usize = 0;
                const dest = self.indexes.items.ptr;
                const remaining = document.len % types.block_len;
                const last_full_index: u32 = @intCast(document.len -| remaining);
                var index_padding: [types.block_len]u8 align(Aligned.alignment) = @splat(' ');
                @memcpy(index_padding[0..remaining], self.document[last_full_index..]);

                var i: usize = 0;
                while (i < last_full_index) : (i += types.block_len) {
                    const block: Aligned.block = @alignCast(document[i..][0..types.block_len]);
                    written += self.indexer.index(block, dest + written);
                }
                if (i == last_full_index) {
                    written += self.indexer.index(&index_padding, dest + written);
                    i += types.block_len;
                }
                if (written == 0) return error.Empty;
                self.indexes.items.len = written;

                try self.indexer.validate();
                try self.indexer.validateEof();
            }

            const ixs = self.indexes.items;
            self.indexes.appendAssumeCapacity(@intCast(document.len)); // bogus index at document.len
            const padding_bound = document.len -| Vector.bytes_len;
            var padding_token: u32 = @intCast(ixs.len - 1);
            var rev = std.mem.reverseIterator(ixs);
            while (rev.next()) |t| : (padding_token -|= 1) {
                if (t <= padding_bound) break;
            }
            self.token = 0;
            self.padding_token = padding_token;
            const padding_index = ixs[padding_token];
            const padding_len = document.len - padding_index;
            try self.padding.ensureTotalCapacityPrecise(padding_len + Vector.bytes_len);
            self.padding.items.len = padding_len + Vector.bytes_len;
            @memcpy(self.padding.items[0..padding_len], document[padding_index..]);
            self.padding.items[padding_len] = bogus_token;
            self.padding_offset = self.padding.items.ptr - padding_index;
        }

        pub inline fn next(self: *Self) [*]const u8 {
            defer self.token += 1;
            return self.peek();
        }

        pub inline fn peekChar(self: Self) u8 {
            return self.peek()[0];
        }

        pub inline fn peek(self: Self) [*]const u8 {
            if (self.token < self.padding_token) {
                return self.document.ptr[self.indexes.items.ptr[self.token]..];
            } else {
                @branchHint(.unlikely);
                return self.padding_offset[self.indexes.items.ptr[self.token]..];
            }
        }

        pub inline fn revert(self: *Self, token: u32) void {
            assert(token <= self.token);
            self.token = token;
        }
    };
}
