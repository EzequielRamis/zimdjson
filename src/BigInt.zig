const std = @import("std");
const debug = @import("debug.zig");
const assert = std.debug.assert;

const Self = @This();
pub const Limb = usize;
const len = std.math.log2_int_ceil(usize, std.math.pow(comptime_int, 10, 0x300 + 342)) / 64;
const Limbs = std.BoundedArray(Limb, len);
const limb_bits = @sizeOf(Limb) * 8;

limbs: Limbs,

pub fn init() Self {
    return .{ .buffer = Limbs.init(0) orelse unreachable };
}

pub fn add(self: *Self, n: []Limb) !void {
    return self.addFrom(n, 0);
}

pub fn addScalar(self: *Self, n: Limb) !void {
    return self.addScalarFrom(n, 0);
}

pub fn mul(self: *Self, n: []Limb) !void {
    @setRuntimeSafety(debug.is_set);

    try self.mulScalar(n[0]);
    if (n.len == 1) return;

    const m = Limbs.fromSlice(self.limbs.slice()) catch unreachable;
    const ms = m.slice();

    var mi = Self.init();

    for (n[1..], 1) |y, i| {
        if (y != 0) {
            mi.limbs.len = 0;
            mi.limbs.appendSliceAssumeCapacity(ms);
            try mi.mulScalar(y);
            try self.addFrom(mi.limbs.slice(), i);
        }
    }

    self.normalize();
}

pub fn mulScalar(self: *Self, n: Limb) !void {
    @setRuntimeSafety(debug.is_set);

    var carry: Limb = 0;
    for (self.limbs.slice()) |*limb| {
        const wide = std.math.mulWide(Limb, limb, n) + carry;
        const res: Limb = @truncate(wide);
        limb = res;
        carry = @truncate(wide >> 64);
    }

    if (carry != 0) return self.limbs.append(carry);
}

pub fn pow2(self: *Self, n: u32) !void {
    @setRuntimeSafety(debug.is_set);
    assert(n != 0);

    const rem = n % 64;
    const div = n / 64;
    if (rem != 0) {
        assert(n < limb_bits);

        const shl = n;
        const shr = limb_bits - shl;
        var prev: Limb = 0;
        for (self.limbs.slice()) |*m| {
            m = (m << shl) | (prev >> shr);
            prev = m;
        }
        const carry = prev >> shr;
        if (carry != 0) try self.limbs.append(carry);
    }
    if (div != 0) {
        if (n + self.limbs.len > self.limbs.capacity()) return error.Overflow;
        if (self.limbs.len != 0) {
            std.mem.copyBackwards(
                Limb,
                self.limbs.slice()[n..][0..self.limbs.len],
                self.limbs.slice()[0..self.limbs.len],
            );
            @memset(self.limbs.slice()[0..n], 0);
            self.limbs.len += n;
        }
    }
}

pub fn pow5(self: *Self, n: u32) !void {
    @setRuntimeSafety(debug.is_set);

    var exp = n;
    const large_step = 135;
    while (exp >= large_step) {
        try self.mul(&power_of_five_large);
        exp -= large_step;
    }
    const small_step = 27;
    const max_native = std.math.pow(Limb, 5, 27);
    while (exp >= small_step) {
        try self.mulScalar(max_native);
        exp -= small_step;
    }
    if (exp != 0) try self.mulScalar(power_of_five_smalls[exp]);
}

pub fn pow10(self: *Self, n: u32) !void {
    try self.pow5(n);
    try self.pow2(n);
}

fn addScalarFrom(self: *Self, n: Limb, _i: usize) !void {
    @setRuntimeSafety(debug.is_set);
    assert(_i < self.limbs.len);

    var i: usize = _i;
    var carry: Limb = n;
    while (carry != 0 and i < self.limbs.len) : (i += 1) {
        const res, const c = @addWithOverflow(self.limbs.buffer[i], carry);
        self.limbs.buffer[i] = res;
        carry = c;
    }

    if (carry != 0) return self.limbs.append(carry);
}

fn addFrom(self: *Self, n: []Limb, i: usize) !void {
    @setRuntimeSafety(debug.is_set);
    assert(i < self.limbs.len);

    var carry = false;
    for (n, 0) |d, j| {
        var c1 = false;
        var c2 = false;
        var res, c1 = @addWithOverflow(self.limbs.buffer[i + j], d);
        if (carry) {
            res, c2 = @addWithOverflow(res, 1);
        }
        self.limbs.buffer[i + j] = res;
        carry = c1 | c2 == 0;
    }

    if (carry) return self.addScalarFrom(1, n.len + i);
}

fn normalize(self: *Self) void {
    @setRuntimeSafety(debug.is_set);

    while (self.limbs.len > 0 and self.limbs.get(self.limbs.len - 1) == 0) {
        self.limbs.len -= 1;
    }
}

const power_of_five_smalls: [28]u64 = brk: {
    var res: [28]u64 = undefined;
    for (&res, 0..) |*r, i| {
        r.* = std.math.pow(u64, 5, i);
    }
    break :brk res;
};

const power_of_five_large: [5]u64 = brk: {
    const pow_5_135 = std.math.pow(u320, 5, 135);
    break :brk @bitCast(pow_5_135);
};
