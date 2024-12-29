const std = @import("std");
const common = @import("common.zig");
const reader = @import("reader.zig");
const types = @import("types.zig");
const indexer = @import("indexer.zig");
const assert = std.debug.assert;
const Vector = types.Vector;
const Error = types.Error;
const RingBuffer = @import("ring_buffer.zig").RingBuffer;

const Options = struct {
    chunk_len: u32,
    aligned: bool,
};

pub fn Stream(comptime options: Options) type {
    const chunk_len = options.chunk_len;
    assert(chunk_len % std.mem.page_size == 0);

    return struct {
        const Self = @This();
        const Indexer = indexer.Indexer(.{ .aligned = options.aligned });
        const DocumentStream = RingBuffer(u8, chunk_len * 2);
        const IndexesStream = RingBuffer(u32, chunk_len);

        visited_last_chunk: bool,
        fd: std.posix.fd_t,
        document_stream: DocumentStream,
        indexes_stream: IndexesStream,
        indexer: Indexer,

        pub fn init(path: []const u8) Error!Self {
            const fd = std.posix.open(path, .{}, @intFromEnum(std.posix.ACCMODE.RDONLY)) catch return error.StreamError;
            return .{
                .visited_last_chunk = false,
                .fd = fd,
                .document_stream = DocumentStream.init() catch return error.StreamError,
                .indexes_stream = IndexesStream.init() catch return error.StreamError,
                .indexer = .init,
            };
        }

        pub fn initFromFd(fd: std.posix.fd_t) !Self {
            return .{
                .fd = fd,
                .document = DocumentStream.init() catch return error.StreamError,
                .indexes = IndexesStream.init() catch return error.StreamError,
            };
        }

        pub fn deinit(self: *Self) void {
            std.posix.close(self.fd);
            self.document_stream.deinit();
            self.indexes_stream.deinit();
        }

        pub fn next(self: *Self) ![*]const u8 {
            if (self.nextLocal()) |ptr| return ptr;
            if (!self.visited_last_chunk) {
                @branchHint(.likely);
                const written = try self.indexNextChunk();
                if (written == 0) return error.StreamChunkOverflow;
                // if (!self.indexes_stream.isEmpty()) {
                //     _ = try self.indexNextChunk();
                //     // const written = try self.indexNextChunk();
                //     // if (written == 0 //or self.indexes_stream.unsafeSlice()[0] > chunk_len
                //     // ) return error.StreamChunkOverflow;
                //     const index = self.indexes_stream.readAssumeLength();
                //     self.document_stream.consumeAssumeLength(index);
                //     return self.document_stream.unsafeSlice();
                // } else while (self.indexes_stream.isEmpty()) {
                //     if (self.visited_last_chunk) break;
                //     _ = try self.indexNextChunk();
                // }
            }

            const index = self.indexes_stream.readAssumeLength();
            self.document_stream.consumeAssumeLength(index);
            return self.document_stream.unsafeSlice();
        }

        pub fn nextLocal(self: *Self) ?[*]const u8 {
            if (self.indexes_stream.len() <= 1) {
                @branchHint(.unlikely);
                return null;
            }

            const index = self.indexes_stream.readAssumeLength();
            self.document_stream.consumeAssumeLength(index);
            return self.document_stream.unsafeSlice();
        }

        pub fn peek(self: Self) [*]const u8 {
            assert(self.indexes_stream.len() > 0);
            return self.document_stream.unsafeSlice()[self.indexes_stream.unsafeSlice()[0]..];
        }

        fn indexNextChunk(self: *Self) !u32 {
            std.debug.print("indexNextChunk\n", .{});
            const buf = self.document_stream.reserveAssumeCapacity(chunk_len);
            const read = std.posix.read(self.fd, buf) catch return error.StreamRead;
            if (read < chunk_len) {
                @branchHint(.unlikely);
                self.visited_last_chunk = true;

                self.document_stream.shrinkAssumeLength(chunk_len - read);
                const bogus_token = " $";
                const padding = bogus_token ++ (" " ** (reader.BLOCK_SIZE - bogus_token.len));
                self.document_stream.writeSliceAssumeCapacity(padding);

                const chunk = buf[0..common.roundUp(usize, read + bogus_token.len, reader.BLOCK_SIZE)];
                const indexes = self.indexes_stream.reserveAll();
                const written = try self.indexer.index(chunk, indexes.ptr);
                self.indexes_stream.shrinkAssumeLength(indexes.len - written);
                try self.indexer.validate();
                buf[read + bogus_token.len - 1] = ' '; // remove bogus token
                return written;
            } else {
                const chunk = buf[0..common.roundUp(usize, read, reader.BLOCK_SIZE)];
                const indexes = self.indexes_stream.reserveAll();
                const written = try self.indexer.index(chunk, indexes.ptr);
                self.indexes_stream.shrinkAssumeLength(indexes.len - written);
                return written;
            }
        }
    };
}
