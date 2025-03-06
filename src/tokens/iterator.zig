const std = @import("std");
const common = @import("../common.zig");
const types = @import("../types.zig");
const indexer = @import("../indexer.zig");
const Vector = types.Vector;
const vector = types.vector;
const umask = types.umask;
const assert = std.debug.assert;
const ArrayList = std.ArrayListUnmanaged;
const Allocator = std.mem.Allocator;

pub const Options = struct {
    aligned: bool,
    assume_padding: bool,
};

pub fn Iterator(comptime options: Options) type {
    return struct {
        const Self = @This();
        const Aligned = types.Aligned(options.aligned);

        pub const Error = indexer.Error || std.mem.Allocator.Error;

        indexes: ArrayList(u32),
        indexer: indexer.Indexer(u32, .{
            .aligned = options.aligned,
            .relative = false,
        }),
        document: Aligned.slice = undefined,
        token: [*]const u32 = undefined,

        padding: if (!options.assume_padding) ArrayList(u8) else void,
        padding_token: if (!options.assume_padding) [*]const u32 else void = undefined,
        padding_offset: if (!options.assume_padding) [*]const u8 else void = undefined,

        const bogus_token = ' ';

        pub const init: Self = .{
            .indexer = .init,
            .indexes = .empty,
            .padding = if (!options.assume_padding) .empty else {},
        };

        pub fn deinit(self: *Self, allocator: Allocator) void {
            self.indexes.deinit(allocator);
            if (!options.assume_padding) self.padding.deinit(allocator);
        }

        pub fn ensureTotalCapacity(self: *Self, allocator: Allocator, capacity: usize) !void {
            try self.indexes.ensureTotalCapacity(allocator, capacity + 1); // + 1 because of the bogus index
        }

        pub inline fn position(self: Self) usize {
            return @intFromPtr(self.token);
        }

        pub inline fn offset(self: Self) usize {
            return self.token[0];
        }

        pub inline fn build(self: *Self, allocator: Allocator, document: Aligned.slice) Error!void {
            {
                self.indexer = .init;
                self.document = document;

                var written: usize = 0;
                const remaining = document.len % types.block_len;
                const last_full_index: u32 = @intCast(document.len -| remaining);
                var index_padding: [types.block_len]u8 align(Aligned.alignment) = @splat(' ');
                @memcpy(index_padding[0..remaining], self.document[last_full_index..]);

                var i: usize = 0;
                while (i < last_full_index) : (i += types.block_len) {
                    const block: Aligned.block = @alignCast(document[i..][0..types.block_len]);
                    written += self.indexer.index(block, self.indexes.items.ptr[written..]);
                }
                if (i == last_full_index) {
                    written += self.indexer.index(&index_padding, self.indexes.items.ptr[written..]);
                    i += types.block_len;
                }
                if (written == 0) return error.Empty;
                self.indexes.items.len = written;

                try self.indexer.validate();
                try self.indexer.validateEof();
            }

            const ixs = self.indexes.items;
            self.indexes.appendAssumeCapacity(@intCast(document.len)); // bogus index at document.len
            self.token = self.indexes.items.ptr;
            if (!options.assume_padding) {
                const padding_bound = document.len -| Vector.bytes_len;
                var padding_token: u32 = @intCast(ixs.len - 1);
                var rev = std.mem.reverseIterator(ixs);
                while (rev.next()) |t| : (padding_token -|= 1) {
                    if (t <= padding_bound) break;
                }
                self.padding_token = ixs[padding_token..].ptr;
                const padding_index = ixs[padding_token];
                const padding_len = document.len - padding_index;
                try self.padding.ensureTotalCapacity(allocator, padding_len + Vector.bytes_len);
                self.padding.items.len = padding_len + Vector.bytes_len;
                @memcpy(self.padding.items[0..padding_len], document[padding_index..]);
                self.padding.items[padding_len] = bogus_token;
                self.padding_offset = self.padding.items.ptr - padding_index;
            }
        }

        pub inline fn next(self: *Self) ![*]const u8 { // there is no error but to be consistent with the streaming iterator
            defer self.token += 1;
            return self.peek();
        }

        pub inline fn peekChar(self: Self) u8 {
            return (self.peek() catch unreachable)[0];
        }

        pub inline fn peek(self: Self) ![*]const u8 {
            if (options.assume_padding) {
                return self.document.ptr[self.offset()..];
            } else {
                const curr_source = brk: {
                    if (@intFromPtr(self.token) < @intFromPtr(self.padding_token)) {
                        break :brk self.document.ptr;
                    } else {
                        @branchHint(.unlikely);
                        break :brk self.padding_offset;
                    }
                };
                return curr_source[self.offset()..];
            }
        }

        pub inline fn revert(self: *Self, pos: usize) !void {
            self.token = @ptrFromInt(pos);
        }
    };
}
