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
        mutex: std.Thread.Mutex = .{},

        wakened: std.Thread.ResetEvent = .{},
        killed: atomic.Value(bool) = .init(false),

        can_fetch: std.Thread.Semaphore = .{},
        can_index: std.Thread.Semaphore = .{ .permits = options.slots - 3 },

        breakpoint: [options.slots]usize align(atomic.cache_line) = @splat(0),
        break_head: usize = 0,
        break_tail: usize = 0,
        curr_break: usize = 0,

        head: Cursor = .init,
        tail: Cursor = .init,

        err: ?Error = null,

        const bogus_token = ' ';
        pub const init = std.mem.zeroInit(Self, .{});

        pub fn build(self: *Self, reader: options.Reader) Error!void {
            {
                self.mutex.lock();
                defer self.mutex.unlock();
                if (self.wakened.isSet()) self.wakened.reset();
                self.can_index.post();
                self.indexer = .init;
                self.reader = reader;
                self.can_fetch.permits = 0;
                self.can_index.permits = options.slots - 3;
                self.break_head = 0;
                self.break_tail = 0;
                self.curr_break = 0;
                self.head = .init;
                self.tail = .init;
                self.err = null;
                self.wakened.set();
            }
            if (self.worker == null) {
                self.document = try .init();
                self.indexes = try .init();
                self.worker = try std.Thread.spawn(.{}, startWorker, .{self});
            }
        }

        pub fn deinit(self: *Self) void {
            if (self.worker) |w| {
                self.killed.store(true, .release);
                self.can_index.post();
                self.wakened.set();
                w.join();
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

        pub inline fn peekChar(self: *Self) Error!u8 {
            const ptr = try self.peek();
            return ptr[0];
        }

        pub inline fn peek(self: *Self) Error![*]const u8 {
            return self.fetch(false);
        }

        inline fn fetch(self: *Self, comptime and_consume: bool) Error![*]const u8 {
            const tail = self.tail;
            if (tail.ixs == self.curr_break) {
                @branchHint(.unlikely);
                self.can_fetch.wait();
                self.mutex.lock();
                defer self.mutex.unlock();
                if (self.err) |err| {
                    self.wakened.reset();
                    return err;
                }
                defer self.can_index.post();
                const iter = self.break_tail & (options.slots - 1);
                self.break_tail += 1;
                self.curr_break = self.breakpoint[iter] - 1;
            }

            const doc_mask = self.document.mask(tail.doc);
            const ixs_mask = self.indexes.mask(tail.ixs);
            const docu_prefix = self.document.ptr()[doc_mask..];
            const curr_offset = self.indexes.ptr()[ixs_mask];
            // @prefetch(self.indexes.ptr()[ixs_mask + atomic.cache_line * 2 ..], .{ .locality = 2 });
            // @prefetch(self.document.ptr()[doc_mask + atomic.cache_line * 2 ..], .{ .locality = 2 });
            const ptr = docu_prefix[curr_offset..];
            if (and_consume) {
                self.tail.doc += curr_offset;
                self.tail.ixs += 1;
            }
            return ptr;
        }

        fn startWorker(self: *Self) void {
            sleeping: while (true) {
                self.wakened.wait();
                while (true) {
                    self.can_index.wait();
                    self.mutex.lock();
                    defer self.mutex.unlock();

                    if (self.killed.load(.acquire)) {
                        @branchHint(.cold);
                        return;
                    }
                    const index_status = self.index(self.head) catch |err| {
                        @branchHint(.unlikely);
                        self.err = err;
                        self.wakened.reset();
                        continue :sleeping;
                    };
                    defer self.can_fetch.post();

                    self.head.doc += chunk_len;
                    self.head.ixs += index_status.written;

                    self.breakpoint[self.break_head & (options.slots - 1)] = self.head.ixs;
                    self.break_head += 1;

                    if (index_status.finished) {
                        @branchHint(.unlikely);
                        self.wakened.reset();
                        self.can_fetch.post();
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
