const std = @import("std");
const builtin = @import("builtin");
const types = @import("types.zig");
const OnDemand = @import("OnDemand.zig");
const Visitor = OnDemand.Visitor;
const Error = types.Error;
const wyhash = std.hash.Wyhash.hash;
const assert = std.debug.assert;

fn Common(comptime T: type) type {
    return struct {
        pub fn dispatch(v: *Visitor) Error!T {
            const info = @typeInfo(T);
            return switch (info) {
                .Int => if (info.Int.signedness == .unsigned) unsigned(v) else signed(v),
                .Float => float(v),
                .Bool => boolean(v),
                .Optional => if (v.isNull()) null else |_| Common(info.Optional.child).dispatch(v),
                else => unreachable,
            };
        }

        fn unsigned(v: *Visitor) Error!T {
            return std.math.cast(T, try v.getUnsigned()) orelse error.InvalidValue;
        }

        fn signed(v: *Visitor) Error!T {
            return std.math.cast(T, try v.getSigned()) orelse error.InvalidValue;
        }

        fn float(v: *Visitor) Error!T {
            return @floatCast(try v.getFloat());
        }

        fn boolean(v: *Visitor) Error!T {
            return v.getBool();
        }
    };
}

fn Writer(comptime T: type, comptime opt: Options) type {
    const info = @typeInfo(T);
    assert(info == .Struct);
    return struct {
        const Self = @This();
        const VTable = PHTable(T, opt);

        table: VTable = VTable{},
        written: VTable.Size = 0,

        pub fn write(self: *Self, to: *T, field: []const u8, v: *Visitor) Error!void {
            const h = self.table.hash(field);
            const i = PHTable(T, opt).location(h);

            const value: PHCaller = brk: {
                const p = self.table.callers[i];
                if (opt.hash_comparison) {
                    if (self.table.hashes[i] == h) break :brk p;
                } else {
                    if (std.mem.eql(u8, self.table.aliases[i], field)) break :brk p;
                }
                return if (opt.handle_unknown_field) error.UnknownField else {};
            };

            if (self.table.visited[i]) switch (opt.handle_duplicate_field) {
                .Error => return error.DuplicateField,
                .First => return,
                .Last => {},
            } else self.written += 1;

            try value.dispatch.?(v, to);
            self.table.visited[i] = true;
        }

        pub fn isMissingField(self: Self) bool {
            return self.written < info.Struct.fields.len;
        }
    };
}

const PHCaller = struct {
    dispatch: ?*const fn (v: *Visitor, ptr: *anyopaque) Error!void = null,
};

const Options = struct {
    hash_comparison: bool = false,
    handle_unknown_field: bool = true,
    handle_duplicate_field: enum { First, Error, Last } = .Error,
    comptime_quota: u32 = 100000,
    min_found_seed_probability: f32 = 0.01,
};

fn nCk(n: comptime_int, k: comptime_int) comptime_int {
    var res = 1;
    for (n - k + 1..n + 1) |i| res *= @as(comptime_int, i);
    for (2..k + 1) |i| res /= @as(comptime_int, i);
    return res;
}

fn factorial(n: comptime_int) comptime_int {
    var res = 1;
    for (1..n + 1) |i| res *= @as(comptime_int, i);
    return res;
}

fn pow(n: comptime_int, k: comptime_int) comptime_int {
    var res = 1;
    for (0..k) |_| res *= n;
    return res;
}

fn PHTable(comptime T: type, comptime opt: Options) type {
    @setEvalBranchQuota(opt.comptime_quota);
    const info = @typeInfo(T);
    assert(info == .Struct);
    const schema = if (@hasDecl(T, "schema")) T.schema else .{};
    const schema_ty = @TypeOf(schema);

    for (std.meta.fieldNames(schema_ty)) |field| {
        assert(@hasField(T, field));
    }
    const fields = @typeInfo(T).Struct.fields;
    var aliases_len: usize = 0;
    for (fields) |field| {
        aliases_len += 1;
        if (@hasField(schema_ty, field.name)) {
            const schema_field: Field(field.type) = @field(schema, field.name);
            aliases_len += schema_field.aliases.len;
        }
    }

    // Birthday paradox
    const aliases_bits = std.math.log2_int_ceil(usize, aliases_len);
    var extra_bits = 0;
    var prob: comptime_float = 0;
    while (prob < opt.min_found_seed_probability) : (extra_bits += 1) {
        const n = aliases_len;
        const d = 1 << (aliases_bits + extra_bits);
        const dcn = nCk(d, n);
        prob = @as(comptime_float, dcn * factorial(n) * 100) / @as(comptime_float, pow(d, n));
    }

    const hash_bits = aliases_bits + extra_bits - 1;
    const index = std.meta.Int(.unsigned, hash_bits);
    const table_len = 1 << hash_bits;

    comptime var seed: u64 = 0;
    while (true) : (seed += 1) {
        var any_collision = false;
        var collided = [_]bool{false} ** table_len;
        comptime var callers = [_]PHCaller{.{}} ** table_len;
        comptime var hashes = [_]u64{0} ** table_len;
        comptime var aliases = [_][]const u8{""} ** table_len;

        for (fields) |field| {
            comptime var schema_field: Field(field.type) = .{ .rename = field.name };
            if (@hasField(schema_ty, field.name)) {
                schema_field = @field(schema, field.name);
            }
            const field_aliases = [_][]const u8{schema_field.rename orelse field.name} ++ schema_field.aliases;
            const parse_with = schema_field.parse_with;
            for (field_aliases) |alias| {
                const h = wyhash(seed, alias);
                const i: index = @truncate(h);
                if (collided[i]) {
                    any_collision = true;
                } else {
                    collided[i] = true;
                    callers[i] = .{
                        .dispatch = struct {
                            pub fn dispatch(el: *Visitor, ptr: *anyopaque) Error!void {
                                const value: *T = @ptrCast(@alignCast(ptr));
                                @field(value, field.name) = try parse_with(el);
                            }
                        }.dispatch,
                    };
                    assert(!std.mem.eql(u8, aliases[i], alias));
                    hashes[i] = h;
                    aliases[i] = alias;
                }
            }
        }
        if (!any_collision) {
            return struct {
                const Self = @This();
                pub const Size = std.meta.Int(.unsigned, hash_bits + 1);

                comptime seed: u64 = seed,
                comptime callers: [table_len]PHCaller = callers,
                comptime hashes: if (opt.hash_comparison) [table_len]u64 else void = if (opt.hash_comparison) hashes else {},
                comptime aliases: if (!opt.hash_comparison) [table_len][]const u8 else void = if (!opt.hash_comparison) aliases else {},
                visited: [table_len]bool = [_]bool{false} ** table_len,

                pub fn hash(self: Self, key: []const u8) u64 {
                    return wyhash(self.seed, key);
                }

                pub fn location(h: u64) index {
                    return @truncate(h);
                }
            };
        }
    }

    unreachable;
}

fn Field(comptime T: type) type {
    return struct {
        rename: ?[]const u8 = null,
        aliases: []const []const u8 = &[_][]const u8{},
        dispatch: *const fn (*Visitor) Error!T = Common(T).dispatch,
    };
}

test "schema" {
    const S = packed struct {
        bar: u8,
        foo: u16,
    };
    var s: S = undefined;
    var w = Writer(S, .{}){};
    try w.write(&s, "FOO", .{ .unsigned = 4 });
    try w.write(&s, "bar", .{ .unsigned = 1 });
    assert(s.foo == 5);
    assert(s.bar == 1);
    assert(!w.isMissingField());
}
