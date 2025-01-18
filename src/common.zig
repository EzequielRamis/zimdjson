const std = @import("std");
const builtin = @import("builtin");
const types = @import("types.zig");
const simd = std.simd;
const testing = std.testing;
const arch = builtin.cpu.arch;

pub const error_messages = struct {
    pub const stream_slice = "Parsing JSON from a slice is not supported when stream mode is enabled. Consider disabling stream mode or calling `parseFromFile` or `parseFromReader`.";
    pub const at_type = "A number or string must be provided for the `at` parameter.";
};

pub fn roundUp(comptime T: type, value: T, alignment: T) T {
    return (value + (alignment - 1)) & ~(alignment - 1);
}

pub fn roundDown(comptime T: type, value: T, alignment: T) T {
    return value & ~(alignment - 1);
}

pub const tables = struct {
    pub const is_structural: [256]bool = init: {
        var res: [256]bool = undefined;
        for (0..res.len) |i| {
            res[i] = switch (i) {
                '{', '}', ':', '[', ']', ',' => true,
                else => false,
            };
        }
        break :init res;
    };

    pub const is_whitespace: [256]bool = init: {
        var res: [256]bool = undefined;
        for (0..res.len) |i| {
            res[i] = switch (i) {
                0x20, 0x0a, 0x09, 0x0d => true,
                else => false,
            };
        }
        break :init res;
    };

    pub const is_structural_or_whitespace: [256]bool = init: {
        var res: [256]bool = undefined;
        for (0..res.len) |i| {
            res[i] = is_structural[i] or is_whitespace[i];
        }
        break :init res;
    };

    pub const is_structural_or_whitespace_negated: [256]bool = init: {
        var res: [256]bool = undefined;
        for (0..res.len) |i| {
            res[i] = !is_structural_or_whitespace[i];
        }
        break :init res;
    };

    pub const is_scalar: [256]bool = init: {
        var res: [256]bool = undefined;
        for (0..res.len) |i| {
            switch (i) {
                't', 'f', 'n', '"', '-', '0'...'9' => res[i] = true,
                else => res[i] = false,
            }
        }
        break :init res;
    };

    pub const is_not_scalar: [256]bool = init: {
        var res: [256]bool = undefined;
        for (0..res.len) |i| {
            res[i] = !is_scalar[i];
        }
        break :init res;
    };
};

pub inline fn isString(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .pointer => |info| switch (info.size) {
            .One => isString(info.child),
            .Many, .C, .Slice => info.child == u8,
        },
        .array => |info| info.child == u8,
        else => false,
    };
}

pub inline fn isIndex(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .int => |info| info.signedness == .unsigned and info.bits <= 32,
        .comptime_int => true,
        else => false,
    };
}

pub fn readAllArrayListAlignedRetainingCapacity(
    self: anytype,
    comptime alignment: ?u29,
    array_list: *std.ArrayListAligned(u8, alignment),
    max_append_size: usize,
) !void {
    try array_list.ensureTotalCapacity(@min(max_append_size, 4096));
    const original_len = array_list.items.len;
    var start_index: usize = original_len;
    while (true) {
        array_list.expandToCapacity();
        const dest_slice = array_list.items[start_index..];
        const bytes_read = try self.readAll(dest_slice);
        start_index += bytes_read;

        if (start_index - original_len > max_append_size) {
            array_list.shrinkRetainingCapacity(original_len + max_append_size);
            return error.StreamTooLong;
        }

        if (bytes_read != dest_slice.len) {
            array_list.shrinkRetainingCapacity(start_index);
            return;
        }

        // This will trigger ArrayList to expand superlinearly at whatever its growth rate is.
        try array_list.ensureTotalCapacity(start_index + 1);
    }
}
