const std = @import("std");
const builtin = @import("builtin");
const tracy = @import("../tracy");
const common = @import("../common.zig");
const types = @import("../types.zig");
const indexer = @import("../indexer.zig");
const ring_buffer = @import("../ring_buffer.zig");
const RingBuffer = ring_buffer.RingBuffer;
const assert = std.debug.assert;
const atomic = std.atomic;
const Vector = types.Vector;

const Options = struct {
    Reader: type,
    chunk_len: u32,
    aligned: bool,
    slots: usize,
};

pub fn Stream(comptime options: Options) type {
    assert(options.slots >= 2 and std.math.isPowerOfTwo(options.slots));
    const chunk_len = options.chunk_len;
    const index_type = if (chunk_len >= 1024 * 64) u32 else u16;

    return struct {
        const Self = @This();

        const Aligned = types.Aligned(options.aligned);
        const Indexer = indexer.Indexer(index_type, .{
            .aligned = options.aligned,
            .relative = true,
        });

        pub const Error =
            options.Reader.Error ||
            indexer.Error ||
            ring_buffer.Error ||
            error{BatchOverflow};

        const Cursor = struct {
            doc: usize = 0,
            ixs: usize = 0,
        };

        reader: options.Reader = undefined,
        document: RingBuffer(u8, chunk_len * options.slots) = undefined,
        indexes: RingBuffer(index_type, chunk_len * options.slots) = undefined,
        indexer: Indexer = .init,

        head: Cursor align(atomic.cache_line) = .{},
        tail: Cursor align(atomic.cache_line) = .{},

        built: bool,

        const bogus_token = ' ';
        pub const init = std.mem.zeroInit(Self, .{
            .built = false,
        });

        pub fn build(self: *Self, _: std.mem.Allocator, reader: options.Reader) Error!void {
            if (self.built) {
                const document = self.document;
                const indexes = self.indexes;
                self.* = .{
                    .built = true,
                };
                self.document = document;
                self.indexes = indexes;
            } else {
                self.* = .{ .built = false };
                self.document = try .init();
                self.indexes = try .init();
                self.built = true;
            }
            self.reader = reader;
            const written = try self.index(self.head);
            self.head.doc += chunk_len;
            self.head.ixs += written;
        }

        pub fn deinit(self: *Self, _: std.mem.Allocator) void {
            if (self.built) {
                self.document.deinit();
                self.indexes.deinit();
            }
        }

        pub inline fn position(self: Self) usize {
            return self.tail.ixs;
        }

        pub inline fn offset(self: Self) usize {
            return self.tail.doc;
        }

        pub inline fn next(self: *Self) Error![*]const u8 {
            return self.fetch(true);
        }

        pub inline fn peekChar(self: *Self) u8 {
            const tail = self.tail;
            const doc_prefix = self.document.ptr()[self.document.mask(tail.doc)..];
            const ixs_offset = self.indexes.ptr()[self.indexes.mask(tail.ixs)];
            return doc_prefix[ixs_offset];
        }

        pub inline fn peek(self: *Self) Error![*]const u8 {
            return self.fetch(false);
        }

        pub inline fn revert(self: *Self, pos: usize) Error!void {
            if (self.head.ixs - pos > chunk_len) return error.BatchOverflow;
            var revert_offset: usize = 0;
            for (pos..self.tail.ixs) |i| revert_offset += self.indexes.ptr()[self.indexes.mask(i)];
            self.tail.ixs = pos;
            self.tail.doc -= revert_offset;
        }

        inline fn fetch(self: *Self, comptime and_consume: bool) Error![*]const u8 {
            const tail = self.tail;
            if (self.head.ixs - tail.ixs == 1) {
                @branchHint(.unlikely);
                const written = try self.index(self.head);
                self.head.doc += chunk_len;
                self.head.ixs += written;
            }

            const doc_prefix = self.document.ptr()[self.document.mask(tail.doc)..];
            const ixs_offset = self.indexes.ptr()[self.indexes.mask(tail.ixs)];
            const ptr = doc_prefix[ixs_offset..];
            if (and_consume) {
                self.tail.doc += ixs_offset;
                self.tail.ixs += 1;
            }
            return ptr;
        }

        fn index(self: *Self, head: Cursor) Error!usize {
            const buf = self.document.ptr()[self.document.mask(head.doc)..][0..chunk_len];
            const read: u32 = @intCast(try self.reader.readAll(buf));

            if (read < chunk_len) {
                @branchHint(.unlikely);

                // here we'll insert not one, but two bogus tokens
                // this is because the fetch function always expects two available indexes
                const bogus_indexed_tokens = ",,"; // commas are always indexed
                if (read > chunk_len - bogus_indexed_tokens.len) {
                    // skip to the next slot
                    @memset(buf[read..chunk_len], ' ');
                } else {
                    const padding = bogus_indexed_tokens ++ (" " ** (types.block_len - bogus_indexed_tokens.len));
                    const len = @min(types.block_len, chunk_len - read);
                    @memcpy(buf[read..][0..len], padding[0..len]);

                    const chunk = buf[0..std.mem.alignForward(usize, read + bogus_indexed_tokens.len, types.block_len)];
                    const indexes = self.indexes.ptr()[self.indexes.mask(head.ixs)..][0..chunk_len];
                    const written = self.indexChunk(@alignCast(chunk), indexes.ptr);
                    if (written == 0) return error.BatchOverflow;
                    const first_offset = indexes[0];
                    if (first_offset > chunk_len) return error.BatchOverflow;
                    try self.indexer.validate();
                    try self.indexer.validateEof();
                    buf[read + bogus_indexed_tokens.len - 1] = bogus_token;
                    buf[read + bogus_indexed_tokens.len - 2] = bogus_token;

                    return written;
                }
            }

            const chunk = buf;
            const indexes = self.indexes.ptr()[self.indexes.mask(head.ixs)..][0..chunk_len];
            const written = self.indexChunk(@alignCast(chunk), indexes.ptr);
            if (written == 0) return error.BatchOverflow;
            const first_offset = indexes[0];
            if (first_offset > chunk_len) return error.BatchOverflow;
            try self.indexer.validate();

            return written;
        }

        inline fn indexChunk(self: *Self, chunk: Aligned.slice, dest: [*]index_type) u32 {
            var written: u32 = 0;
            for (0..chunk.len / types.block_len) |i| {
                const block: Aligned.block = @alignCast(chunk[i * types.block_len ..][0..types.block_len]);
                written += self.indexer.index(block, dest + written);
            }
            return written;
        }
    };
}
