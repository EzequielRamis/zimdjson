const std = @import("std");
const builtin = @import("builtin");
const wyhash = std.hash.Wyhash.hash;
const assert = std.debug.assert;

const Error = error{
    InvalidType,
    InvalidValue,
    InvalidLength,
    UnknownVariant,
    UnknownField,
    MissingField,
    DuplicateField,
};

const Element = union(enum) {
    null,
    unsigned: u64,
    signed: i64,
    float: f64,
    bool: bool,
    string: []const u8,
};

fn Default(comptime T: type) type {
    return struct {
        pub fn dispatch(el: Element) Error!T {
            const info = @typeInfo(T);
            return switch (info) {
                .Int => if (info.Int.signedness == .unsigned) unsigned(el) else signed(el),
                .Float => float(el),
                .Bool => boolean(el),
                .Optional => if (el == .null) null else Default(info.Optional.child).dispatch(el),
                else => unreachable,
            };
        }

        fn unsigned(el: Element) Error!T {
            if (el == .unsigned) {
                return std.math.cast(T, el.unsigned) orelse error.InvalidValue;
            }
            return error.InvalidType;
        }

        fn signed(el: Element) Error!T {
            if (el == .signed) {
                return std.math.cast(T, el.signed) orelse error.InvalidValue;
            }
            return error.InvalidType;
        }

        fn float(el: Element) Error!T {
            if (el == .float) return @floatCast(el.float);
            return error.InvalidType;
        }

        fn boolean(el: Element) Error!T {
            if (el == .bool) return el.bool;
            return error.InvalidType;
        }
    };
}

fn Writer(comptime T: type, comptime opt: Options) type {
    const info = @typeInfo(T);
    assert(info == .Struct);
    return struct {
        const Self = @This();
        const VTable = PHTable(T, opt);

        table: VTable = VTable.init(if (@hasDecl(T, "schema")) T.schema else .{}),
        written: VTable.Size = 0,

        pub fn write(self: *Self, to: *T, field: []const u8, el: Element) Error!void {
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

            try value.dispatch.?(el, to);
            self.table.visited[i] = true;
        }

        pub fn isMissingField(self: Self) bool {
            return self.written < info.Struct.fields.len;
        }
    };
}

const PHCaller = struct {
    dispatch: ?*const fn (el: Element, ptr: *anyopaque) Error!void = null,
};

const Options = struct {
    hash_comparison: bool = false,
    handle_unknown_field: bool = true,
    handle_duplicate_field: enum { First, Error, Last } = .Error,
};

fn PHTable(comptime T: type, comptime opt: Options) type {
    const info = @typeInfo(T);
    assert(info == .Struct);
    const fields = @typeInfo(T).Struct.fields;
    const hash_bits = std.math.log2_int_ceil(usize, fields.len);
    const index = std.meta.Int(.unsigned, hash_bits);
    const table_len = 1 << hash_bits;

    return struct {
        pub const Size = std.meta.Int(.unsigned, hash_bits + 1);

        seed: u64,
        callers: [table_len]PHCaller,
        visited: [table_len]bool,
        hashes: if (opt.hash_comparison) [table_len]u64 else void,
        aliases: if (!opt.hash_comparison) [table_len][]const u8 else void,

        const Self = @This();

        pub fn init(comptime schema: anytype) Self {
            comptime {
                const schema_ty = @TypeOf(schema);
                for (std.meta.fieldNames(schema_ty)) |field| {
                    assert(@hasField(T, field));
                }

                var seed: u64 = 0;
                while (true) : (seed += 1) {
                    var any_collision = false;
                    var callers = [_]PHCaller{.{}} ** table_len;
                    var hashes = [_]u64{0} ** table_len;
                    var aliases = [_][]const u8{""} ** table_len;
                    var collided = [_]bool{false} ** table_len;

                    for (fields) |field| {
                        var schema_field: Field(field.type) = .{ .rename = field.name };
                        if (@hasField(schema_ty, field.name)) {
                            schema_field = @field(schema, field.name);
                        }
                        const parse_with = schema_field.parse_with;
                        const field_aliases = [_][]const u8{schema_field.rename.?} ++ schema_field.aliases;
                        for (field_aliases) |alias| {
                            const h = wyhash(seed, alias);
                            const i: index = @truncate(h);
                            if (collided[i]) {
                                any_collision = true;
                            } else {
                                collided[i] = true;
                                callers[i] = .{
                                    .dispatch = struct {
                                        pub fn dispatch(el: Element, ptr: *anyopaque) Error!void {
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
                        return .{
                            .seed = seed,
                            .callers = callers,
                            .visited = [_]bool{false} ** table_len,
                            .hashes = if (opt.hash_comparison) hashes else {},
                            .aliases = if (!opt.hash_comparison) aliases else {},
                        };
                    }
                }
            }
            unreachable;
        }

        pub fn hash(self: Self, key: []const u8) u64 {
            return wyhash(self.seed, key);
        }

        pub fn location(h: u64) index {
            return @truncate(h);
        }
    };
}

fn Field(comptime T: type) type {
    return struct {
        rename: ?[]const u8 = null,
        aliases: [][]const u8 = &[0][]const u8{},
        parse_with: *const fn (Element) Error!T = Default(T).dispatch,
    };
}

pub fn plusOne(el: Element) Error!u16 {
    if (el == .unsigned) {
        return @intCast(el.unsigned + 1);
    }
    return error.InvalidType;
}

test "schema" {
    const S = packed struct {
        pub const schema = .{
            .foo = .{ .rename = "FOO", .parse_with = plusOne },
        };

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
