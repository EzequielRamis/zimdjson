const std = @import("std");
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
            doc: usize,
            ixs: usize,
        };

        reader: options.Reader,
        document: RingBuffer(u8, chunk_len * options.slots) = undefined,
        indexes: RingBuffer(index_type, chunk_len * options.slots) = undefined,
        indexer: Indexer = .init,
        worker: ?std.Thread = null,

        head: atomic.Value(std.meta.Int(.unsigned, @bitSizeOf(Cursor))) align(atomic.cache_line) = .init(0),
        tail: atomic.Value(std.meta.Int(.unsigned, @bitSizeOf(Cursor))) align(atomic.cache_line) = .init(0),

        // there is no need to cache the other values
        ixs_head_cached: usize align(atomic.cache_line) = 0,
        doc_tail_cached: usize align(atomic.cache_line) = 0,

        err: atomic.Value(std.meta.Int(.unsigned, @bitSizeOf(Error))) = .init(0),
        status: atomic.Value(enum(u8) { sleeping, starting, running, killed }) = .init(.sleeping),

        // local worker variable
        work: bool = false,

        const bogus_token = ' ';
        pub const init = std.mem.zeroInit(Self, .{});

        pub fn build(self: *Self, reader: options.Reader) Error!void {
            if (self.status.load(.acquire) == .sleeping) {
                self.document = try .init();
                self.indexes = try .init();
            }
            self.reader = reader;
            self.ixs_head_cached = 0;
            self.tail.store(0, .release);
            self.status.store(.starting, .release);
            if (self.worker == null) self.worker = try std.Thread.spawn(.{}, startWorker, .{self});
        }

        pub fn deinit(self: *Self) void {
            const status = self.status.load(.acquire);
            self.status.store(.killed, .release);
            if (self.worker) |w| w.join();
            if (status != .sleeping) {
                self.document.deinit();
                self.indexes.deinit();
            }
        }

        pub inline fn next(self: *Self) Error![*]const u8 {
            return self.fetch(true);
        }

        pub inline fn peekChar(self: *Self) u8 {
            const tail: Cursor = @bitCast(self.tail.load(.acquire));
            const offset = self.indexes.ptr()[self.indexes.mask(tail.ixs)];
            const ptr = self.document.ptr()[self.document.mask(tail.doc)..][offset..];
            return ptr[0];
        }

        pub inline fn peek(self: *Self) Error![*]const u8 {
            return self.fetch(false);
        }

        inline fn isFetchable(l: usize) bool {
            return l > 1; // two indexes must be present to check chunk bounds
        }

        inline fn fetch(self: *Self, comptime then_add: bool) Error![*]const u8 {
            var tail: Cursor = undefined;
            while (true) {
                tail = @bitCast(self.tail.load(.monotonic));
                if (!isFetchable(self.ixs_head_cached - tail.ixs)) {
                    self.ixs_head_cached = @as(Cursor, @bitCast(self.head.load(.acquire))).ixs;
                    if (!isFetchable(self.ixs_head_cached - tail.ixs)) {
                        const err = self.err.load(.acquire);
                        if (err != 0) return @errorCast(@as(anyerror![*]const u8, @errorFromInt(err)));
                        std.atomic.spinLoopHint();
                        continue;
                    }
                }
                break;
            }
            const offset = self.indexes.ptr()[self.indexes.mask(tail.ixs)];
            const ptr = self.document.ptr()[self.document.mask(tail.doc)..][offset..];
            if (then_add) {
                self.tail.store(@bitCast(Cursor{
                    .doc = tail.doc + offset,
                    .ixs = tail.ixs + 1,
                }), .release);
            }
            return ptr;
        }

        fn startWorker(self: *Self) void {
            while (true) {
                const status = self.status.load(.acquire);
                if (status == .running) {
                    @branchHint(.likely);
                    if (self.work) {
                        while (self.canIndex() catch |err| {
                            self.work = false;
                            self.err.store(@intFromError(err), .release);
                            break;
                        }) {}
                    }
                } else if (status == .starting) {
                    self.work = true;
                    self.doc_tail_cached = 0;
                    self.err.store(0, .release);
                    self.head.store(0, .release);
                    self.status.store(.running, .release);
                } else if (status == .killed) {
                    @branchHint(.unlikely);
                    return;
                }
                std.atomic.spinLoopHint();
            }
        }

        inline fn isIndexable(l: usize) bool {
            return l < chunk_len * (options.slots - 1); // a special slot must be preserved so the revert feature can work
        }

        inline fn canIndex(self: *Self) Error!bool {
            if (!self.work) return false;

            // check whether there are slots available to index
            const head: Cursor = @bitCast(self.head.load(.monotonic));

            if (!isIndexable(head.doc - self.doc_tail_cached)) {
                self.doc_tail_cached = @as(Cursor, @bitCast(self.tail.load(.acquire))).doc;
                if (!isIndexable(head.doc - self.doc_tail_cached)) {
                    return false;
                }
            }

            // a slot can be indexed
            const buf = self.document.ptr()[self.document.mask(head.doc)..][0..chunk_len];
            const read: u32 = @intCast(try self.reader.readAll(buf));
            if (read < chunk_len) {
                @branchHint(.unlikely);

                const bogus_indexed_tokens = " $ $";
                // here we'll insert not one, but two bogus tokens
                // this is because the fetch function always expects two available indexes
                if (read >= chunk_len - bogus_indexed_tokens.len) {
                    @branchHint(.unlikely);
                    // it is not possible to insert the bogus tokens without a whitespace prefix and pretend the indexing is correct
                    // a solution to this is to insert those at another slot, knowing that the next readAll returns 0
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
                    buf[read + bogus_indexed_tokens.len - 3] = bogus_token;

                    self.work = false;
                    self.head.store(@bitCast(Cursor{
                        .doc = head.doc + read,
                        .ixs = head.ixs + written,
                    }), .release);
                    return false;
                }
            }

            const chunk = buf;
            const indexes = self.indexes.ptr()[self.indexes.mask(head.ixs)..][0..chunk_len];
            const written = self.indexChunk(@alignCast(chunk), indexes.ptr);
            if (written == 0) return error.BatchOverflow;
            const first_offset = indexes[0];
            if (first_offset > chunk_len) return error.BatchOverflow;
            try self.indexer.validate();

            self.head.store(@bitCast(Cursor{
                .doc = head.doc + chunk_len,
                .ixs = head.ixs + written,
            }), .release);
            return true;
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
