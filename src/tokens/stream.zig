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
            error{BatchOverflow} ||
            std.Thread.SpawnError;

        pub const Cursor = extern struct {
            pub const init = Cursor{};
            doc: usize = 0,
            ixs: usize = 0,
        };

        const IndexingResults = struct {
            written: usize,
            finished: bool,
        };

        reader: options.Reader,
        document: RingBuffer(u8, chunk_len * options.slots) = undefined,
        indexes: RingBuffer(index_type, chunk_len * options.slots) = undefined,
        indexer: Indexer = .init,

        worker: ?std.Thread = null,

        queue: Queue = .init,
        mutex: std.Thread.Mutex = .{},

        waken: std.Thread.ResetEvent = .{},
        killed: atomic.Value(bool) = .init(false),

        const Queue = struct {
            pub const init = Queue{};

            head: atomic.Value(std.meta.Int(.unsigned, @bitSizeOf(Cursor))) align(atomic.cache_line) = .init(0),
            tail: atomic.Value(std.meta.Int(.unsigned, @bitSizeOf(Cursor))) align(atomic.cache_line) = .init(0),

            head_cached: Cursor align(atomic.cache_line) = .init,
            tail_cached: Cursor align(atomic.cache_line) = .init,

            err: atomic.Value(std.meta.Int(.unsigned, @bitSizeOf(Error))) = .init(0),

            pub fn consume(self: *Queue, curr_offset: usize, tail: Cursor) void {
                const new_tail: Cursor = .{
                    .doc = tail.doc + curr_offset,
                    .ixs = tail.ixs + 1,
                };
                self.tail.store(@bitCast(new_tail), .release);
            }

            pub fn commit(self: *Queue, status: IndexingResults, head: Cursor) void {
                const new_head: Cursor = .{
                    .doc = head.doc + chunk_len,
                    .ixs = head.ixs + status.written,
                };
                self.head.store(@bitCast(new_head), .release);
            }

            pub fn canFetchIndex(self: *Queue, tail: Cursor) bool {
                if (!isFetchableIndex(self.head_cached, tail)) {
                    self.head_cached = @bitCast(self.head.load(.acquire));
                    if (!isFetchableIndex(self.head_cached, tail)) {
                        return false;
                    }
                }
                return true;
            }

            pub fn canIndexChunk(self: *Queue, head: Cursor) bool {
                if (!isIndexableChunk(head, self.tail_cached)) {
                    self.tail_cached = @bitCast(self.tail.load(.acquire));
                    if (!isIndexableChunk(head, self.tail_cached)) {
                        return false;
                    }
                }
                return true;
            }

            fn isFetchableIndex(head: Cursor, tail: Cursor) bool {
                return head.ixs - tail.ixs > 1;
            }

            fn isIndexableChunk(head: Cursor, tail: Cursor) bool {
                return head.doc - tail.doc < chunk_len * (options.slots - 1);
            }
        };

        const bogus_token = ' ';
        pub const init = std.mem.zeroInit(Self, .{});

        pub fn build(self: *Self, reader: options.Reader) Error!void {
            {
                self.mutex.lock();
                defer self.mutex.unlock();
                self.indexer = .init;
                self.reader = reader;
                self.queue = .init;
                self.waken.set();
            }
            if (self.worker == null) {
                self.document = try .init();
                self.indexes = try .init();
                self.worker = try std.Thread.spawn(.{}, startWorker, .{self});
            }
        }

        pub fn deinit(self: *Self) void {
            if (self.worker) |w| {
                self.killed.store(true, .monotonic);
                self.waken.set();
                w.join();
                self.document.deinit();
                self.indexes.deinit();
            }
        }

        pub inline fn position(self: Self) usize {
            const tail: Cursor = @bitCast(self.queue.tail.load(.monotonic));
            return tail.ixs;
        }

        pub inline fn offset(self: Self) usize {
            const tail: Cursor = @bitCast(self.queue.tail.load(.monotonic));
            return tail.doc;
        }

        pub inline fn next(self: *Self) Error![*]const u8 {
            return self.fetch(true);
        }

        pub inline fn peekChar(self: *Self) Error!u8 {
            const ptr = try self.peek();
            return ptr[0];
        }

        pub inline fn peek(self: *Self) Error![*]const u8 {
            return self.fetch(false);
        }

        inline fn fetch(self: *Self, comptime and_consume: bool) Error![*]const u8 {
            const tail: Cursor = @bitCast(self.queue.tail.load(.monotonic));
            while (!self.queue.canFetchIndex(tail)) {
                if (!self.waken.isSet()) break;
                atomic.spinLoopHint();
            }
            const err = self.queue.err.load(.acquire);
            if (err != 0) return @errorCast(@as(anyerror![*]const u8, @errorFromInt(err)));

            const curr_offset = self.indexes.ptr()[self.indexes.mask(tail.ixs)];
            const ptr = self.document.ptr()[self.document.mask(tail.doc)..][curr_offset..];
            if (and_consume) self.queue.consume(curr_offset, tail);
            return ptr;
        }

        fn startWorker(self: *Self) void {
            sleeping: while (true) {
                self.waken.wait();
                running: while (!self.killed.load(.monotonic)) {
                    @branchHint(.likely);

                    const head: Cursor = @bitCast(self.queue.head.load(.monotonic));
                    if (!self.queue.canIndexChunk(head)) {
                        if (!self.waken.isSet()) continue :sleeping;
                        atomic.spinLoopHint();
                        continue :running;
                    }
                    const index_status = self.index(head) catch |err| {
                        @branchHint(.unlikely);
                        self.queue.err.store(@intFromError(err), .release);
                        self.waken.reset();
                        continue :sleeping;
                    };

                    self.queue.commit(index_status, head);
                    if (index_status.finished) {
                        self.waken.reset();
                        continue :sleeping;
                    }
                }
                return;
            }
        }

        inline fn index(self: *Self, head: Cursor) Error!IndexingResults {
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

                    return .{
                        .written = written,
                        .finished = true,
                    };
                }
            }

            const chunk = buf;
            const indexes = self.indexes.ptr()[self.indexes.mask(head.ixs)..][0..chunk_len];
            const written = self.indexChunk(@alignCast(chunk), indexes.ptr);
            if (written == 0) return error.BatchOverflow;
            const first_offset = indexes[0];
            if (first_offset > chunk_len) return error.BatchOverflow;
            try self.indexer.validate();

            return .{
                .written = written,
                .finished = false,
            };
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
