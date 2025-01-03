const std = @import("std");
const common = @import("../common.zig");
const types = @import("../types.zig");
const indexer = @import("../indexer.zig");
const io = @import("../io.zig");
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
        const Indexer = indexer.Indexer(.{ .aligned = options.aligned });
        const Aligned = types.Aligned(options.aligned);

        indexer: Indexer,
        ptr: [*]const u8 = undefined,
        padding: ArrayList(u8),
        padding_token: [*]const u32 = undefined,
        token: [*]const u32 = undefined,

        pub fn init(allocator: Allocator) Self {
            return .{
                .indexer = .init,
                .padding = ArrayList(u8).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.padding.deinit();
        }

        pub fn build(self: *Self, doc: Aligned.slice) !void {
            try self.indexer.index(doc);

            const ixs = self.indexes();
            self.indexer.indexes.appendAssumeCapacity(@intCast(self.indexer.reader.document.len)); // Sentinel index at ' '
            const padding_bound = doc.len -| Vector.len_bytes;
            var padding_token: u32 = @intCast(ixs.len - 1);
            var rev = std.mem.reverseIterator(ixs);
            while (rev.next()) |t| : (padding_token -|= 1) {
                if (t <= padding_bound) break;
            }
            if (self.document()[ixs[padding_token]] == '"') padding_token -|= 1;
            self.token = @ptrCast(&ixs[0]);
            self.padding_token = @ptrCast(&ixs[padding_token]);
            const padding_index = if (padding_token == 0) 0 else ixs[padding_token];
            const padding_len = doc.len - padding_index;
            try self.padding.ensureTotalCapacity(padding_len + Vector.len_bytes);
            self.padding.items.len = padding_len + Vector.len_bytes;
            @memcpy(self.padding.items[0..padding_len], doc[padding_index..]);
            self.padding.items[padding_len] = ' ';
            self.ptr = if (padding_token == 0) self.padding.items.ptr else doc.ptr;
        }

        pub inline fn indexes(self: Self) []const u32 {
            return self.indexer.indexes.items;
        }

        pub inline fn document(self: Self) Aligned.slice {
            return self.indexer.reader.document;
        }

        pub inline fn next(self: *Self) [*]const u8 {
            defer self.token += 1;
            return self.challengeSource(self.peek());
        }

        pub inline fn peek(self: Self) u8 {
            return self.ptr[self.token[0]][0];
        }

        pub fn revert(self: *Self, token: [*]const u32) void {
            assert(@intFromPtr(token) <= @intFromPtr(self.token));

            const doc = self.document();

            defer self.token = token;
            const i = token[0];
            const b = self.padding_token[0];

            if (@intFromPtr(token) < @intFromPtr(self.padding_token)) {
                @branchHint(.likely);
                self.ptr = doc[i..].ptr;
            } else {
                const index_ptr = @intFromPtr(doc[i..].ptr);
                const padding_ptr = @intFromPtr(doc[b..].ptr);
                const offset_ptr = index_ptr - padding_ptr;
                self.ptr = self.padding.items[offset_ptr..].ptr;
            }
        }

        inline fn challengeSource(self: *Self, ptr: [*]const u8) [*]const u8 {
            if (@intFromPtr(self.padding_token) <= @intFromPtr(self.token)) {
                @branchHint(.unlikely);
                if (self.padding_token == @as([*]const u32, @ptrCast(&self.indexes()[0]))) return ptr;
                const pad = @intFromPtr(self.padding.items.ptr);
                self.ptr = @ptrFromInt(pad -% self.padding_token[0]);
                return @ptrCast(&self.ptr[self.token[0]]);
            } else {
                return ptr;
            }
        }
    };
}
