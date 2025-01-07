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
        ptr: [*]const u8 = undefined,
        padding_token: [*]const u32 = undefined,
        token: [*]const u32 = undefined,

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
                try self.indexes.ensureTotalCapacity(document.len + 1);
                self.indexer = .init;
                self.document = document;

                var written: usize = 0;
                const dest = self.indexes.items.ptr;
                const remaining = document.len % types.block_len;
                const last_full_index: u32 = @intCast(document.len -| remaining);
                var index_padding: types.block align(Aligned.alignment) = @splat(' ');
                @memcpy(index_padding[0..remaining], self.document[last_full_index..]);

                var i: usize = 0;
                while (i < last_full_index) : (i += types.block_len) {
                    const block: *align(Aligned.alignment) const types.block = @alignCast(document[i..][0..types.block_len]);
                    written += self.indexer.index(block.*, dest + written);
                }
                if (i == last_full_index) {
                    written += self.indexer.index(index_padding, dest + written);
                    i += types.block_len;
                }
                if (written == 0) return error.Empty;
                self.indexes.items.len = written;

                try self.indexer.validate();
                try self.indexer.validateEof();
            }

            const ixs = self.indexes.items;
            self.indexes.appendAssumeCapacity(@intCast(document.len)); // Sentinel index at ' '
            const padding_bound = document.len -| Vector.bytes_len;
            var padding_token: u32 = @intCast(ixs.len - 1);
            var rev = std.mem.reverseIterator(ixs);
            while (rev.next()) |t| : (padding_token -|= 1) {
                if (t <= padding_bound) break;
            }
            if (document[ixs[padding_token]] == '"') padding_token -|= 1;
            self.token = @ptrCast(&ixs[0]);
            self.padding_token = @ptrCast(&ixs[padding_token]);
            const padding_index = if (padding_token == 0) 0 else ixs[padding_token];
            const padding_len = document.len - padding_index;
            try self.padding.ensureTotalCapacity(padding_len + Vector.bytes_len);
            self.padding.items.len = padding_len + Vector.bytes_len;
            @memcpy(self.padding.items[0..padding_len], document[padding_index..]);
            self.padding.items[padding_len] = ' ';
            self.ptr = if (padding_token == 0) self.padding.items.ptr else document.ptr;
        }

        pub inline fn next(self: *Self) [*]const u8 {
            defer self.token += 1;
            return self.challengeSource(self.ptr[self.token[0]..]);
        }

        pub inline fn peek(self: Self) u8 {
            return self.ptr[self.token[0]];
        }

        pub inline fn revert(self: *Self, token: [*]const u32) void {
            assert(@intFromPtr(token) <= @intFromPtr(self.token));

            const document = self.document;
            defer self.token = token;
            const i = token[0];
            const b = self.padding_token[0];

            if (@intFromPtr(token) < @intFromPtr(self.padding_token)) {
                @branchHint(.likely);
                self.ptr = document[i..].ptr;
            } else {
                const index_ptr = @intFromPtr(document[i..].ptr);
                const padding_ptr = @intFromPtr(document[b..].ptr);
                const offset_ptr = index_ptr - padding_ptr;
                self.ptr = self.padding.items[offset_ptr..].ptr;
            }
        }

        inline fn challengeSource(self: *Self, ptr: [*]const u8) [*]const u8 {
            if (@intFromPtr(self.padding_token) <= @intFromPtr(self.token)) {
                @branchHint(.unlikely);
                if (self.padding_token == @as([*]const u32, @ptrCast(&self.indexes.items[0]))) return ptr;
                const pad = @intFromPtr(self.padding.items.ptr);
                self.ptr = @ptrFromInt(pad -% self.padding_token[0]);
                return @ptrCast(&self.ptr[self.token[0]]);
            } else {
                return ptr;
            }
        }
    };
}
