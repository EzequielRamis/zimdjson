const std = @import("std");
const tracy = @import("tracy");
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
        const IndexesStream = RingBuffer(u32, chunk_len * 2);

        fd: std.posix.fd_t,
        document_stream: DocumentStream,
        indexes_stream: IndexesStream,
        indexer: Indexer,
        next_chunk_buffer: []u8 = undefined,
        next_chunk_len: u32 = undefined,
        last_chunk_visited: bool,

        pub fn init(path: []const u8) Error!Self {
            const fd = std.posix.open(path, .{}, @intFromEnum(std.posix.ACCMODE.RDONLY)) catch return error.StreamError;
            return .{
                .last_chunk_visited = false,
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

        pub inline fn prefetch(self: *Self) !void {
            try self.fetchNextChunk();
            self.indexes_stream.writeAssumeCapacity(0);
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
            if (self.last_chunk_visited) {
                @branchHint(.unlikely);
                return self.fetchLocalOffset();
            }
            if (self.indexes_stream.len() == 2) {
                @branchHint(.unlikely);
                try self.fetchNextChunk();
                const written = try self.indexNextChunk();
                if (written == 0) return error.StreamChunkOverflow;
            }
            return self.fetchLocalOffset();
        }

        inline fn fetchLocalOffset(self: *Self) !u32 {
            assert(self.indexes_stream.len() >= 2);

            const indexes = self.indexes_stream.unsafeSlice();
            const prev = indexes[0];
            const index = indexes[1];
            const wrap_offset = (@as(u64, 1) << 32) * @intFromBool(index < prev);
            const wrap_index = @as(u64, index) +% wrap_offset;
            const offset = wrap_index -% prev;
            if (offset > chunk_len) return error.StreamChunkOverflow;

            return @intCast(offset);
        }

        inline fn fetchNextChunk(self: *Self) !void {
            self.next_chunk_buffer = self.document_stream.reserveAssumeCapacity(chunk_len);
            self.next_chunk_len = @intCast(std.posix.read(self.fd, self.next_chunk_buffer) catch return error.StreamRead);
        }

        fn indexNextChunk(self: *Self) !u32 {
            const buf = self.next_chunk_buffer;
            const read = self.next_chunk_len;
            if (read < chunk_len) {
                @branchHint(.unlikely);
                self.last_chunk_visited = true;

                self.document_stream.shrinkAssumeLength(chunk_len - read);
                const bogus_token = " $";
                const padding = bogus_token ++ (" " ** (reader.BLOCK_SIZE - bogus_token.len));
                self.document_stream.writeSliceAssumeCapacity(padding);

                const chunk = buf[0..common.roundUp(usize, read + bogus_token.len, reader.BLOCK_SIZE)];
                const indexes = self.indexes_stream.reserveAssumeCapacity(chunk_len);
                const written = try self.indexer.index(chunk, indexes.ptr);
                self.indexes_stream.shrinkAssumeLength(@as(u32, @intCast(indexes.len)) - written);
                try self.indexer.validate();
                buf[read + bogus_token.len - 1] = ' '; // remove bogus token
                return written;
            } else {
                const chunk = buf;
                const indexes = self.indexes_stream.reserveAssumeCapacity(chunk_len);
                const written = try self.indexer.index(chunk, indexes.ptr);
                self.indexes_stream.shrinkAssumeLength(chunk_len - written);
                return written;
            }
        }
    };
}
