const std = @import("std");
const assert = std.debug.assert;

pub const Limb = usize;
pub const limb_bits = @sizeOf(Limb) * 8;
const Self = @This();
pub const capacity = 58; // ceil(log2(10 ** (max_big_digits + -min_pow10)) / 64)
const Limbs = std.ArrayListUnmanaged(Limb);

limbs: Limbs,

pub fn init(buffer: []Limb) Self {
    return .{
        .limbs = Limbs.initBuffer(buffer),
    };
}

pub fn from(buffer: []Limb, value: u64) Self {
    var self = Self.init(buffer);
    self.limbs.appendAssumeCapacity(value);
    return self;
}

pub fn add(self: *Self, n: []const Limb) !void {
    return self.addFrom(n, 0);
}

pub fn addScalar(self: *Self, n: Limb) !void {
    return self.addScalarFrom(n, 0);
}

pub fn mul(self: *Self, n: []const Limb) !void {
    var m_buffer: [capacity]Limb = undefined;
    var m: Limbs = Limbs.initBuffer(&m_buffer);
    m.appendSliceAssumeCapacity(self.limbs.items);

    try self.mulScalar(n[0]);
    if (n.len == 1) return;

    var mi_buffer: [capacity]Limb = undefined;
    var mi = Self.init(&mi_buffer);

    for (n[1..], 1..) |limb, i| {
        if (limb != 0) {
            mi.limbs.items.len = 0;
            mi.limbs.appendSliceAssumeCapacity(m.items);
            try mi.mulScalar(limb);
            try self.addFrom(mi.limbs.items, i);
        }
    }
}

pub fn mulScalar(self: *Self, n: Limb) !void {
    var carry: Limb = 0;
    for (self.limbs.items) |*limb| {
        const wide = std.math.mulWide(Limb, limb.*, n) + carry;
        const res: Limb = @truncate(wide);
        limb.* = res;
        carry = @truncate(wide >> limb_bits);
    }

    if (carry != 0) return self.limbs.appendBounded(carry);
}

pub fn pow2(self: *Self, n: u32) !void {
    const rem = n % limb_bits;
    const div = n / limb_bits;
    if (rem != 0) try self.shlBits(@intCast(rem));
    if (div != 0) try self.shlLimbs(@intCast(div));
}

fn shlBits(self: *Self, n: u8) !void {
    assert(0 < n and n < limb_bits);
    const shl = n;
    const shr = limb_bits - shl;
    var prev: Limb = 0;
    for (self.limbs.items) |*m| {
        const p = m.*;
        m.* = (p << @intCast(shl)) | (prev >> @intCast(shr));
        prev = p;
    }
    const carry = prev >> @intCast(shr);
    if (carry != 0) return self.limbs.appendBounded(carry);
}

fn shlLimbs(self: *Self, n: u8) !void {
    assert(n > 0);
    if (n + self.len() > self.limbs.capacity) return error.Overflow;
    if (self.len() != 0) {
        @memmove(
            self.limbs.items.ptr[n..][0..self.len()],
            self.limbs.items.ptr,
        );
        @memset(self.limbs.items.ptr[0..n], 0);
        self.limbs.items.len += @intCast(n);
    }
}

pub fn pow5(self: *Self, n: u32) !void {
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

pub fn high64(self: Self) struct { bits: u64, truncated: bool } {
    if (self.len() == 0) return .{
        .bits = 0,
        .truncated = false,
    };
    if (self.len() == 1) {
        const r0 = self.limbs.items[0];
        return .{
            .bits = r0 << @intCast(@clz(r0)),
            .truncated = false,
        };
    }
    const r0 = self.limbs.items[self.len() - 1];
    const r1 = self.limbs.items[self.len() - 2];
    const shl = @clz(r0);
    var truncated: bool = undefined;
    var bits: Limb = undefined;
    if (shl == 0) {
        truncated = r1 != 0;
        bits = r0;
    } else {
        const shr = limb_bits - shl;
        truncated = (r1 << @intCast(shl)) != 0;
        bits = (r0 << @intCast(shl)) | (r1 >> @intCast(shr));
    }
    var nonzero = false;
    var i: usize = 2;
    while (i < self.len()) : (i += 1) {
        if (self.limbs.items[self.len() - 1 - i] != 0) {
            nonzero = true;
            break;
        }
    }
    truncated = truncated or nonzero;
    return .{
        .bits = bits,
        .truncated = truncated,
    };
}

pub fn clz(self: Self) u6 {
    if (self.len() == 0) return 0;
    return @intCast(@clz(self.limbs.items[self.len() - 1]));
}

pub fn bitsLen(self: Self) u16 {
    return std.math.mulWide(u8, limb_bits, self.len()) - self.clz();
}

pub fn order(self: Self, other: Self) std.math.Order {
    if (self.len() > other.len()) return .gt;
    if (self.len() < other.len()) return .lt;
    var i = self.len();
    while (i > 0) : (i -= 1) {
        const x = self.limbs.items[i - 1];
        const y = other.limbs.items[i - 1];
        if (x > y) return .gt;
        if (x < y) return .lt;
    }
    return .eq;
}

pub fn len(self: Self) u8 {
    return @intCast(self.limbs.items.len);
}

fn addScalarFrom(self: *Self, n: Limb, _i: usize) !void {
    var i: usize = _i;
    var carry: Limb = n;
    while (carry != 0 and i < self.len()) : (i += 1) {
        const res, const c = @addWithOverflow(self.limbs.items[i], carry);
        self.limbs.items[i] = res;
        carry = c;
    }

    if (carry != 0) return self.limbs.appendBounded(carry);
}

fn addFrom(self: *Self, n: []const Limb, i: usize) !void {
    if (self.len() < i or n.len > self.len() - i) {
        try self.resize(n.len + i, 0);
    }

    var carry = false;
    for (n, 0..) |d, j| {
        var c1: u1 = 0;
        var c2: u1 = 0;
        var res, c1 = @addWithOverflow(self.limbs.items[i + j], d);
        if (carry) {
            res, c2 = @addWithOverflow(res, 1);
        }
        self.limbs.items[i + j] = res;
        carry = @bitCast(c1 | c2);
    }

    if (carry) return self.addScalarFrom(1, n.len + i);
}

fn resize(self: *Self, n: usize, v: Limb) !void {
    const old_len = self.len();
    self.limbs.items.len = n;
    @memset(self.limbs.items[old_len..][0..n -| old_len], v);
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
