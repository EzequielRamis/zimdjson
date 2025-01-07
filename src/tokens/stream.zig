const std = @import("std");
const tracy = @import("../tracy");
const common = @import("../common.zig");
const types = @import("../types.zig");
const indexer = @import("../indexer.zig");
const RingBuffer = @import("../ring_buffer.zig").RingBuffer;
const assert = std.debug.assert;
const Vector = types.Vector;
const Error = types.Error;
const File = std.fs.File;

const Options = struct {
    chunk_len: u32,
    aligned: bool,
};

pub fn Stream(comptime options: Options) type {
    const chunk_len = options.chunk_len;

    return struct {
        const Self = @This();
        const Aligned = types.Aligned(options.aligned);
        const Indexer = indexer.Indexer(.{
            .aligned = options.aligned,
            .relative = true,
        });
        const DocumentStream = RingBuffer(u8, chunk_len * 2);
        const IndexesStream = RingBuffer(u32, chunk_len * 2);

        file: File,
        document_stream: DocumentStream,
        indexes_stream: IndexesStream,
        indexer: Indexer = .init,
        built: bool = false,

        pub const init = std.mem.zeroInit(Self, .{});

        pub inline fn build(self: *Self, file: File) !void {
            self.* = .{
                .file = file,
                .document_stream = DocumentStream.init() catch return error.StreamError,
                .indexes_stream = IndexesStream.init() catch return error.StreamError,
            };
            try self.prefetch();
            self.built = true;
        }

        pub fn deinit(self: *Self) void {
            if (self.built) {
                self.file.close();
                self.document_stream.deinit();
                self.indexes_stream.deinit();
            }
        }

        inline fn prefetch(self: *Self) !void {
            const written = try self.indexNextChunk();
            if (written == 0) return error.StreamChunkOverflow;
        }

        pub inline fn next(self: *Self) ![*]const u8 {
            const offset = try self.fetchOffset();
            self.indexes_stream.consumeAssumeLength(1);
            self.document_stream.consumeAssumeLength(offset);
            return self.document_stream.unsafeSlice();
        }

        pub inline fn peek(self: *Self) !u8 {
            const offset = try self.fetchOffset();
            return self.document_stream.unsafeSlice()[offset];
        }

        inline fn fetchOffset(self: *Self) !u32 {
            if (self.indexes_stream.len() == 1) {
                const written = try self.indexNextChunk();
                if (written == 0) return error.StreamChunkOverflow;
                const first_offset = self.indexes_stream.unsafeSlice()[0];
                if (first_offset > chunk_len) return error.StreamChunkOverflow;
            }
            return self.fetchLocalOffset();
        }

        inline fn fetchLocalOffset(self: *Self) u32 {
            assert(self.indexes_stream.len() >= 1);
            const offset = self.indexes_stream.unsafeSlice()[0];
            return offset;
        }

        inline fn indexNextChunk(self: *Self) !u32 {
            const buf = self.document_stream.reserveAssumeCapacity(chunk_len);
            const read: u32 = @intCast(self.file.readAll(buf) catch return error.StreamRead);
            if (read < chunk_len) {
                @branchHint(.unlikely);

                self.document_stream.shrinkAssumeLength(chunk_len - read);
                const bogus_token = " $";
                const padding = bogus_token ++ (" " ** (types.block_len - bogus_token.len));
                self.document_stream.writeSliceAssumeCapacity(padding);

                const chunk = buf[0..common.roundUp(usize, read + bogus_token.len, types.block_len)];
                const indexes = self.indexes_stream.reserveAssumeCapacity(chunk_len);
                const written = try self.indexChunk(chunk, indexes.ptr);
                try self.indexer.validate();
                try self.indexer.validateEof();
                self.indexes_stream.shrinkAssumeLength(@as(u32, @intCast(indexes.len)) - written);
                buf[read + bogus_token.len - 1] = ' '; // remove bogus token
                return written;
            } else {
                const chunk = buf;
                const indexes = self.indexes_stream.reserveAssumeCapacity(chunk_len);
                const written = try self.indexChunk(chunk, indexes.ptr);
                try self.indexer.validate();
                self.indexes_stream.shrinkAssumeLength(chunk_len - written);
                return written;
            }
        }

        fn indexChunk(self: *Self, chunk: Aligned.slice, dest: [*]u32) u32 {
            var written: u32 = 0;
            for (0..chunk.len / types.block_len) |i| {
                const block: *align(Aligned.alignment) const types.block = @alignCast(chunk[i * types.block_len ..][0..types.block_len]);
                written += self.indexer.index(block.*, dest + written);
            }
            return written;
        }
    };
}
