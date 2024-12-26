const std = @import("std");
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

        pub fn init(path: []const u8) !Self {
            const fd = try std.posix.open(path, .{}, @intFromEnum(std.posix.ACCMODE.RDONLY));
            return .{
                .visited_last_chunk = false,
                .fd = fd,
                .document = try DocumentStream.init(),
                .indexes = try IndexesStream.init(),
            };
        }

        pub fn initFromFd(fd: std.posix.fd_t) !Self {
            return .{
                .fd = fd,
                .document = try DocumentStream.init(),
                .indexes = try IndexesStream.init(),
            };
        }

        pub fn deinit(self: *Self) void {
            std.posix.close(self.fd);
            self.document_stream.deinit();
            self.indexes_stream.deinit();
        }

        pub fn next(self: *Self) ![*]const u8 {
            if (self.nextLocal()) |ptr| return ptr;
            if (!self.indexes_stream.isEmpty()) {
                const written = try self.indexNextChunk();
                if (written == 0 or self.indexes_stream.unsafeSlice()[1] > chunk_len) return error.StreamChunkOverflow;
                const index = self.indexes_stream.readAssumeLength();
                self.document_stream.consumeAssumeLength(index);
                return self.document_stream.unsafeSlice().ptr;
            } else while (self.indexes_stream.isEmpty()) {
                if (self.visited_last_chunk) break;
                _ = try self.indexNextChunk();
            }

            const index = self.indexes_stream.readAssumeLength();
            self.document_stream.consumeAssumeLength(index);
            return self.document_stream.unsafeSlice().ptr;
        }

        pub fn nextLocal(self: *Self) ?[*]const u8 {
            if (self.indexes_stream.len() <= 1) return null;

            const index = self.indexes_stream.readAssumeLength();
            self.document_stream.consumeAssumeLength(index);
            return self.document_stream.unsafeSlice();
        }

        pub fn peek(self: Self) [*]const u8 {
            assert(self.indexes_stream.len() > 0);
            return self.document_stream.unsafeSlice()[self.indexes_stream.unsafeSlice()[0]..];
        }

        fn indexNextChunk(self: *Self) !u32 {
            const buf = self.document_stream.reserveAssumeCapacity(chunk_len);
            const read = try std.posix.read(self.fd, buf);
            if (read < chunk_len) {
                @branchHint(.unlikely);
                self.visited_last_chunk = true;
                self.document_stream.shrinkAssumeLength(chunk_len - read);
                self.document_stream.writeSliceAssumeCapacity(" " ** Vector.len_bytes);
            }
            const chunk = self.document_stream.unsafeSlice()[0..chunk_len];
            const indexes = self.indexes_stream.reserveAll();
            const written = try self.indexer.index(chunk, indexes.ptr);
            self.indexes_stream.shrinkAssumeLength(indexes.len - written);
            if (read < chunk_len) {
                @branchHint(.unlikely);
                const bogus_slice = self.indexes_stream.slice();
                const bogus_index = bogus_slice[bogus_slice.len - 1];
                self.indexes_stream.writeAssumeCapacity(bogus_index - self.indexer.prev_offset);
            }
            return written;
        }
    };
}
