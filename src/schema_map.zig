const std = @import("std");
const hash = std.hash.Wyhash.hash;

// this is a wrapper that creates the best possible schema map given the key-value pairs
// for now there is only one strategy
pub fn SchemaMap(comptime T: type, comptime kvs: []const struct { []const u8, T }) StaticHashTable(T, kvs.len) {
    const static_hash = StaticHashTable(T, kvs.len).init(kvs[0..kvs.len].*);
    return static_hash;
}

fn StaticHashTable(comptime T: type, comptime n: usize) type {
    std.debug.assert(n > 0);
    const layout = StaticLayout.from(n);
    const table = [layout.table_len][layout.collisions - 1]layout.index;

    return struct {
        const Self = @This();

        seed: usize,
        table: table,
        kvs: [n]struct { []const u8, T },

        pub fn init(comptime kvs: [n]struct { []const u8, T }) Self {
            @setEvalBranchQuota(4500 * n);
            var seed: usize = 0;
            new_seed: while (true) : (seed += 1) {
                var next_bucket: [layout.table_len]u8 = @splat(0);
                var result_table: table = std.mem.zeroes(table);
                for (kvs, 0..) |kv, i| {
                    const index: layout.index = @intCast(hash(seed, kv[0]) & (layout.table_len - 1));
                    if (next_bucket[index] == layout.collisions - 1) continue :new_seed;
                    result_table[index][next_bucket[index]] = i;
                    next_bucket[index] += 1;
                }
                return .{
                    .seed = seed,
                    .table = result_table,
                    .kvs = kvs,
                };
            }
            unreachable;
        }

        pub fn get(self: Self, key: []const u8) ?T {
            const index: layout.index = @intCast(hash(self.seed, key) & (layout.table_len - 1));
            const buckets = self.table[index];
            for (buckets) |offset| {
                const kv = self.kvs[offset];
                if (std.mem.eql(u8, key, kv[0])) {
                    return kv[1];
                }
            }
            return null;
        }

        pub fn getIndex(self: Self, key: []const u8) ?usize {
            const index: layout.index = @intCast(hash(self.seed, key) & (layout.table_len - 1));
            const buckets = self.table[index];
            for (buckets) |offset| {
                const kv = self.kvs[offset];
                if (std.mem.eql(u8, key, kv[0])) {
                    return offset;
                }
            }
            return null;
        }

        pub fn atIndex(self: Self, index: usize) T {
            return self.kvs[index][1];
        }
    };
}

const StaticLayout = struct {
    index: type,
    table_len: usize,
    collisions: usize,

    // I'll use an aproximation of the generalized birthday problem to calculate
    // the "best" hash table layout given n keys and a probability of collision p < 99%
    //
    // n: number of keys
    // d: number of buckets (must be power of two)
    // k: number of collisions
    // p: probability of collision
    //
    // ne^{-n/(dk)}=\left[d^{k-1}k!\ln(\frac{1}{1-p})\left(1-\frac{n}{d(k+1)}\right)\right]^{1/k}
    //
    // demo: https://www.desmos.com/calculator/04wrcehwf8
    // info: https://mathworld.wolfram.com/BirthdayProblem.html
    //
    // there may be some case where it's practically impossible to find a layout, even with a high @setEvalBranchQuota, because of wrong parameters
    // if that's the case, an issue it's welcome
    pub fn from(n: usize) StaticLayout {
        const table_len = std.math.log2_int_ceil(usize, n);
        return switch (n) {
            0...20 => .{
                .index = u8,
                .table_len = 1 << (table_len + 0),
                .collisions = 2,
            },
            21...27 => .{
                .index = u8,
                .table_len = 1 << (table_len + 1),
                .collisions = 2,
            },
            28...51 => .{
                .index = u8,
                .table_len = 1 << (table_len + 2),
                .collisions = 2,
            },
            52...60 => .{
                .index = u8,
                .table_len = 1 << (table_len + 0),
                .collisions = 3,
            },
            61...214 => .{
                .index = u8,
                .table_len = 1 << (table_len + 1),
                .collisions = 3,
            },
            215...251 => .{
                .index = u8,
                .table_len = 1 << (table_len + 0),
                .collisions = 4,
            },
            252...256 => .{
                .index = u8,
                .table_len = 1 << (table_len + 0),
                .collisions = 5,
            },
            257...407 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 4,
            },
            408...512 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 5,
            },
            513...667 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 4,
            },
            668...1024 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 5,
            },
            1025...1097 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 4,
            },
            1098...1823 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 5,
            },
            1824...2048 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 6,
            },
            2049...3108 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 5,
            },
            3109...4096 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 6,
            },
            4097...5316 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 5,
            },
            5317...8099 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 6,
            },
            8100...8192 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 7,
            },
            8193...9118 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 5,
            },
            9119...14187 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 6,
            },
            14188...16384 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 7,
            },
            16385...24907 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 6,
            },
            24908...32768 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 7,
            },
            32769...43814 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 6,
            },
            43815...63734 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 7,
            },
            63735...65536 => .{
                .index = u16,
                .table_len = 1 << (table_len + 0),
                .collisions = 8,
            },
            else => @compileError("Exceeded maximum number of reflected keys"),
        };
    }
};
