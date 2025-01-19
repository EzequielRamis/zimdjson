const std = @import("std");
const tracy = @import("../tracy");
const common = @import("../common.zig");
const types = @import("../types.zig");
const indexer = @import("../indexer.zig");
const ring_buffer = @import("../ring_buffer.zig");
const RingBuffer = ring_buffer.RingBuffer;
const assert = std.debug.assert;
const Vector = types.Vector;

const Options = struct {
    Reader: type,
    chunk_len: u32,
    aligned: bool,
    slots: usize,
};

pub fn Stream(comptime options: Options) type {
    assert(options.slots >= 2 and options.slots & (options.slots - 1) == 0); // Must be a power of 2
    const chunk_len = options.chunk_len;
    assert(chunk_len < 1024 * 1024 * 1024 * 4);
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

        reader: options.Reader,
        document: RingBuffer(u8, chunk_len * options.slots) = undefined,
        indexes: RingBuffer(index_type, chunk_len * options.slots) = undefined,
        indexer: Indexer = .init,
        built: bool = false,
        first_chunk_visited: bool = false,
        last_chunk_visited: bool = false,

        const bogus_token = ' ';
        pub const init = std.mem.zeroInit(Self, .{});

        pub fn build(self: *Self, reader: options.Reader) Error!void {
            self.* = .{
                .reader = reader,
                .document = try .init(),
                .indexes = try .init(),
            };
            try self.prefetch();
            self.built = true;
        }

        pub fn deinit(self: Self) void {
            if (self.built) {
                self.document.deinit();
                self.indexes.deinit();
            }
        }

        inline fn prefetch(self: *Self) Error!void {
            const written = try self.indexNextChunk();
            if (written == 0) return error.BatchOverflow;
            self.first_chunk_visited = true;
        }

        pub inline fn next(self: *Self) Error![*]const u8 {
            const offset = try self.fetchOffset();
            self.indexes.consumeAssumeLength(1);
            self.document.consumeAssumeLength(offset);
            return self.document.unsafeSlice();
        }

        pub inline fn peekChar(self: *Self) u8 {
            const offset = self.fetchLocalOffset();
            return self.document.unsafeSlice()[offset];
        }

        pub inline fn peek(self: *Self) Error![*]const u8 {
            const offset = try self.fetchOffset();
            return self.document.unsafeSlice()[offset..];
        }

        pub inline fn fetchOffset(self: *Self) Error!u32 {
            if (self.indexes.len() == 1) {
                const written = try self.indexNextChunk();
                if (written == 0) return error.BatchOverflow;
                const first_offset = self.indexes.unsafeSlice()[0];
                if (first_offset > chunk_len) return error.BatchOverflow;
            }
            return self.fetchLocalOffset();
        }

        pub inline fn fetchLocalOffset(self: *Self) u32 {
            assert(self.indexes.len() >= 1);
            const offset = self.indexes.unsafeSlice()[0];
            return offset;
        }

        fn indexNextChunk(self: *Self) Error!u32 {
            if (self.last_chunk_visited) {
                @branchHint(.unlikely);
                return 1;
            }
            const buf = self.document.reserveAssumeCapacity(chunk_len);
            const read: u32 = @intCast(try self.reader.readAll(buf));
            if (read < chunk_len) {
                @branchHint(.unlikely);

                self.last_chunk_visited = true;
                self.document.shrinkAssumeLength(chunk_len - read);
                const bogus_indexed_token = " $";
                const padding = bogus_indexed_token ++ (" " ** (types.block_len - bogus_indexed_token.len));
                self.document.writeSliceAssumeCapacity(padding);

                const chunk = buf[0..std.mem.alignForward(usize, read + bogus_indexed_token.len, types.block_len)];
                const indexes = self.indexes.reserveAssumeCapacity(chunk_len);
                const written = self.indexChunk(@alignCast(chunk), indexes.ptr);
                if (written == 0 and !self.first_chunk_visited) return error.Empty;
                try self.indexer.validate();
                try self.indexer.validateEof();
                self.indexes.shrinkAssumeLength(@as(u32, @intCast(indexes.len)) - written);
                buf[read + bogus_indexed_token.len - 1] = bogus_token;
                return written;
            } else {
                const chunk = buf;
                const indexes = self.indexes.reserveAssumeCapacity(chunk_len);
                const written = self.indexChunk(@alignCast(chunk), indexes.ptr);
                try self.indexer.validate();
                self.indexes.shrinkAssumeLength(chunk_len - written);
                return written;
            }
        }

        fn indexChunk(self: *Self, chunk: Aligned.slice, dest: [*]index_type) u32 {
            var written: u32 = 0;
            for (0..chunk.len / types.block_len) |i| {
                const block: Aligned.block = @alignCast(chunk[i * types.block_len ..][0..types.block_len]);
                written += self.indexer.index(block, dest + written);
            }
            return written;
        }
    };
}
