const std = @import("std");
const builtin = @import("builtin");
const io = @import("io.zig");
const types = @import("types.zig");
const arch = builtin.cpu.arch;
const Mask = types.Mask;

pub fn Reader(comptime options: io.Options) type {
    return struct {
        const IO = io.Reader(options);
        const Aligned = types.Aligned(options.aligned);

        const Self = @This();

        pub const MASKS_PER_ITER = if (arch.isX86()) 2 else 1;
        pub const BLOCK_SIZE = Mask.LEN_BITS * MASKS_PER_ITER;
        pub const Block = [BLOCK_SIZE]u8;

        index: u32 = undefined,
        last_partial_index: u32 = undefined,
        document: Aligned.Slice = undefined,
        padding: Block align(Aligned.Alignment) = undefined,

        pub fn init() Self {
            return Self{};
        }

        pub fn read(self: *Self, doc: Aligned.Slice) void {
            const remaining = doc.len % BLOCK_SIZE;
            const last_partial_index: u32 = @intCast(doc.len -| remaining);
            self.index = 0;
            self.document = doc;
            self.last_partial_index = last_partial_index;
            @memset(&self.padding, ' ');
            @memcpy(self.padding[0..remaining], self.document[self.last_partial_index..]);
        }

        pub fn next(self: *Self) ?Block {
            if (self.index < self.last_partial_index) {
                defer self.index += BLOCK_SIZE;
                const offset: Aligned.Slice = @alignCast(self.document[self.index..]);
                const block: *align(Aligned.Alignment) const Block = offset[0..BLOCK_SIZE];
                return block.*;
            }
            return null;
        }

        pub fn last(self: *Self) ?Block {
            @setCold(true);
            if (self.index == self.last_partial_index) {
                defer self.index += BLOCK_SIZE;
                return self.padding;
            }
            return null;
        }
    };
}
