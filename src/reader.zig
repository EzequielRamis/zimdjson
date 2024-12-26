const std = @import("std");
const builtin = @import("builtin");
const types = @import("types.zig");
const arch = builtin.cpu.arch;
const Mask = types.Mask;

const Options = struct {
    aligned: bool,
};

pub const MASKS_PER_ITER = if (arch.isX86()) 2 else 1;
pub const BLOCK_SIZE = Mask.len_bits * MASKS_PER_ITER;
pub const Block = [BLOCK_SIZE]u8;

pub fn Reader(comptime options: Options) type {
    return struct {
        const Aligned = types.Aligned(options.aligned);

        const Self = @This();

        pub const MASKS_PER_ITER = if (arch.isX86()) 2 else 1;
        pub const BLOCK_SIZE = Mask.len_bits * MASKS_PER_ITER;
        pub const Block = [BLOCK_SIZE]u8;

        index: u32 = undefined,
        last_full_index: u32 = undefined,
        document: Aligned.slice = undefined,
        padding: Block align(Aligned.alignment) = undefined,

        pub fn read(self: *Self, doc: Aligned.slice) void {
            const remaining = doc.len % BLOCK_SIZE;
            const last_partial_index: u32 = @intCast(doc.len -| remaining);
            self.index = 0;
            self.document = doc;
            self.last_full_index = last_partial_index;
            @memset(&self.padding, ' ');
            @memcpy(self.padding[0..remaining], self.document[self.last_full_index..]);
        }

        pub fn next(self: *Self) ?Block {
            if (self.index < self.last_full_index) {
                defer self.index += BLOCK_SIZE;
                const block: *align(Aligned.alignment) const Block = @alignCast(self.document[self.index..][0..BLOCK_SIZE]);
                return block.*;
            }
            return null;
        }

        pub fn last(self: *Self) ?Block {
            if (self.index == self.last_full_index) {
                defer self.index += BLOCK_SIZE;
                return self.padding;
            }
            return null;
        }
    };
}
