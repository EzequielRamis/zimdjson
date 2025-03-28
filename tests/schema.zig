const std = @import("std");
const zimdjson = @import("zimdjson");
const simdjson_data = @embedFile("simdjson-data");
const Parser = zimdjson.ondemand.FullParser(.default);
const allocator = std.testing.allocator;

// JSON examples taken from https://github.com/simdjson/simdjson-data

test "small/demo" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/demo.json", .{});
    defer file.close();
    const document = try parser.parseFromReader(allocator, file.reader().any());

    const Image = struct {
        pub const schema: Parser.schema.Infer(@This()) = .{
            .rename_all = .PascalCase,
            .fields = .{ .ids = .{ .rename = "IDs" } },
        };
        width: u16,
        height: u16,
        title: []const u8,
        thumbnail: struct {
            pub const schema: Parser.schema.Infer(@This()) = .{
                .rename_all = .PascalCase,
                .assume_ordering = true,
            };
            url: []const u8,
            height: u16,
            width: u16,
        },
        animated: bool,
        ids: []const u16,
    };

    const image = try document.at("Image").as(Image, allocator, .{});
    defer image.deinit();

    try std.testing.expectEqualDeep(Image{
        .width = 800,
        .height = 600,
        .title = "View from 15th Floor",
        .thumbnail = .{
            .url = "http://www.example.com/image/481989943",
            .height = 125,
            .width = 100,
        },
        .animated = false,
        .ids = &.{ 116, 943, 234, 38793 },
    }, image.value);
}

test "small/demo2" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\ {
        \\   "Image": {
        \\       "Width":  800,
        \\       "Height": 600,
        \\       "Title":  "View from 15th Floor",
        \\       "Thumbnail": {
        \\           "Url":    "http://www.example.com/image/481989943",
        \\           "Height": 125,
        \\           "Width":  100
        \\       },
        \\       "Animated" : false,
        \\       "IDs": [116, 943, 234, 38793]
        \\     }
        \\ }
    );

    const Image = struct {
        pub const schema: Parser.schema.Infer(@This()) = .{
            .rename_all = .PascalCase,
            .fields = .{ .ids = .{ .rename = "IDs" } },
        };
        width: u16,
        height: u16,
        title: []const u8,
        thumbnail: struct {
            pub const schema: Parser.schema.Infer(@This()) = .{
                .rename_all = .PascalCase,
            };
            url: []const u8,
            height: u16,
            width: u16,
        },
        animated: bool,
        ids: std.ArrayListUnmanaged(u16),
    };

    const image = try document.at("Image").as(Image, allocator, .{});
    defer image.deinit();

    const value = image.value;
    try std.testing.expectEqual(800, value.width);
    try std.testing.expectEqual(600, value.height);
    try std.testing.expectEqualStrings("View from 15th Floor", value.title);
    try std.testing.expectEqualStrings("http://www.example.com/image/481989943", value.thumbnail.url);
    try std.testing.expectEqual(125, value.thumbnail.height);
    try std.testing.expectEqual(100, value.thumbnail.width);
    try std.testing.expectEqual(false, value.animated);
    try std.testing.expectEqualSlices(u16, &.{ 116, 943, 234, 38793 }, value.ids.items);
}

test "small/adversarial" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/adversarial.json", .{});
    defer file.close();
    const document = try parser.parseFromReader(allocator, file.reader().any());

    const Schema = struct {
        @"\"Name rue": [1]struct {
            u8,
            []const u8,
            u8,
            []const u8,
            bool,
        },
    };

    const el = try document.asLeaky(Schema, null, .{});
    const tuple = el.@"\"Name rue"[0];

    try std.testing.expectEqualDeep(.{
        116,
        "\"",
        234,
        "true",
        false,
    }, tuple);
}

test "small/truenull" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/truenull.json", .{});
    defer file.close();
    const document = try parser.parseFromReader(allocator, file.reader().any());

    const arr = try document.as([]const ?bool, allocator, .{});
    defer arr.deinit();

    for (arr.value, 0..) |elem, i| {
        try std.testing.expectEqual(if (i % 2 == 0) true else null, elem);
    }
}

test "github_events" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/github_events.json", .{});
    defer file.close();
    const document = try parser.parseFromReader(allocator, file.reader().any());

    const Event = union(enum) {
        pub const schema: Parser.schema.Infer(@This()) = .{
            .representation = .{ .internally_tagged = "type" },
            .rename_all = .PascalCase,
        };
        const Body = struct {
            id: []const u8,
        };
        push_event: Body,
        create_event: Body,
        fork_event: Body,
        watch_event: Body,
        issue_comment_event: Body,
        issues_event: Body,
        gollum_event: Body,
    };

    const events = try document.as([]const Event, allocator, .{});
    defer events.deinit();

    try std.testing.expectEqualDeep(&.{
        Event{ .push_event = .{ .id = "1652857722" } },
        Event{ .create_event = .{ .id = "1652857721" } },
        Event{ .fork_event = .{ .id = "1652857715" } },
        Event{ .watch_event = .{ .id = "1652857714" } },
        Event{ .push_event = .{ .id = "1652857713" } },
        Event{ .push_event = .{ .id = "1652857711" } },
        Event{ .watch_event = .{ .id = "1652857705" } },
        Event{ .watch_event = .{ .id = "1652857702" } },
        Event{ .watch_event = .{ .id = "1652857701" } },
        Event{ .push_event = .{ .id = "1652857699" } },
        Event{ .issue_comment_event = .{ .id = "1652857697" } },
        Event{ .issues_event = .{ .id = "1652857694" } },
        Event{ .push_event = .{ .id = "1652857692" } },
        Event{ .push_event = .{ .id = "1652857690" } },
        Event{ .push_event = .{ .id = "1652857684" } },
        Event{ .push_event = .{ .id = "1652857682" } },
        Event{ .push_event = .{ .id = "1652857680" } },
        Event{ .watch_event = .{ .id = "1652857678" } },
        Event{ .push_event = .{ .id = "1652857675" } },
        Event{ .gollum_event = .{ .id = "1652857670" } },
        Event{ .watch_event = .{ .id = "1652857669" } },
        Event{ .create_event = .{ .id = "1652857668" } },
        Event{ .create_event = .{ .id = "1652857667" } },
        Event{ .issue_comment_event = .{ .id = "1652857665" } },
        Event{ .fork_event = .{ .id = "1652857660" } },
        Event{ .push_event = .{ .id = "1652857654" } },
        Event{ .push_event = .{ .id = "1652857652" } },
        Event{ .push_event = .{ .id = "1652857648" } },
        Event{ .gollum_event = .{ .id = "1652857651" } },
        Event{ .fork_event = .{ .id = "1652857642" } },
    }, events.value);
}

test "github_events untagged payload" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/github_events.json", .{});
    defer file.close();
    const document = try parser.parseFromReader(allocator, file.reader().any());

    const Payload = union(enum) {
        pub const schema: Parser.schema.Infer(@This()) = .{
            .representation = .untagged,
        };
        push: struct { push_id: usize },
        create: struct { description: []const u8 },
        fork: struct { forkee: struct { url: []const u8 } },

        watch: struct { action: enum { started } },

        // 'issue_comment' is weaker than 'issues' because of the additional field 'issue.id', so it is discarded if 'issues' succeeds
        issues: struct {
            action: []const u8,
            issue: struct { url: []const u8, id: usize },
        },
        issue_comment: struct {
            action: []const u8,
            issue: struct { url: []const u8 },
        },

        gollum: struct { pages: []const struct { page_name: []const u8 } },
    };
    const Event = struct { payload: Payload };

    const events = try document.as([]const Event, allocator, .{});
    defer events.deinit();

    try std.testing.expectEqualDeep(&.{
        Event{ .payload = .{ .push = .{ .push_id = 134107894 } } },
        Event{ .payload = .{ .create = .{ .description = "blog system" } } },
        Event{ .payload = .{ .fork = .{ .forkee = .{ .url = "https://api.github.com/repos/rtlong/digiusb.rb" } } } },
        Event{ .payload = .{ .watch = .{ .action = .started } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107891 } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107890 } } },
        Event{ .payload = .{ .watch = .{ .action = .started } } },
        Event{ .payload = .{ .watch = .{ .action = .started } } },
        Event{ .payload = .{ .watch = .{ .action = .started } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107888 } } },
        Event{ .payload = .{ .issues = .{ .action = "created", .issue = .{ .url = "https://api.github.com/repos/pat/thinking-sphinx/issues/415", .id = 9704821 } } } },
        Event{ .payload = .{ .issues = .{ .action = "opened", .issue = .{ .url = "https://api.github.com/repos/imsky/holder/issues/27", .id = 9833911 } } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107887 } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107885 } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107879 } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107876 } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107874 } } },
        Event{ .payload = .{ .watch = .{ .action = .started } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107873 } } },
        Event{ .payload = .{ .gollum = .{ .pages = &.{.{ .page_name = "Home" }} } } },
        Event{ .payload = .{ .watch = .{ .action = .started } } },
        Event{ .payload = .{ .create = .{ .description = "" } } },
        Event{ .payload = .{ .create = .{ .description = "Translation infrastructure work for colobot levels" } } },
        Event{ .payload = .{ .issues = .{ .action = "created", .issue = .{ .url = "https://api.github.com/repos/SynoCommunity/spksrc/issues/249", .id = 7071528 } } } },
        Event{ .payload = .{ .fork = .{ .forkee = .{ .url = "https://api.github.com/repos/slwchs/HandlerSocket-Plugin-for-MySQL" } } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107864 } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107863 } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107860 } } },
        Event{ .payload = .{ .gollum = .{ .pages = &.{.{ .page_name = "Sonar Plugin Development" }} } } },
        Event{ .payload = .{ .fork = .{ .forkee = .{ .url = "https://api.github.com/repos/vcovito/QtAV" } } } },
    }, events.value);
}

test "externally_tagged" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\[{ "foo": 1 }, { "bar": 5.0 }, { "baz": false }]
    );

    const Schema = union(enum) {
        pub const schema: Parser.schema.Infer(@This()) = .{
            .representation = .externally_tagged,
        };
        foo: u8,
        bar: f32,
        baz: bool,
    };

    const unions = try document.as([]const Schema, allocator, .{});
    defer unions.deinit();

    try std.testing.expectEqualDeep(&.{
        Schema{ .foo = 1 },
        Schema{ .bar = 5.0 },
        Schema{ .baz = false },
    }, unions.value);
}

test "adjacently_tagged" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\[{ "t": "foo", "c": 1 }, { "t": "bar", "c": 5.0 }, { "t": "baz", "c": false }]
    );

    const Schema = union(enum) {
        pub const schema: Parser.schema.Union(@This()) = .{
            .representation = .{ .adjacently_tagged = .{ .tag = "t", .content = "c" } },
        };
        foo: u8,
        bar: f32,
        baz: bool,
    };

    const unions = try document.as([]const Schema, allocator, .{});
    defer unions.deinit();

    try std.testing.expectEqualDeep(&.{
        Schema{ .foo = 1 },
        Schema{ .bar = 5.0 },
        Schema{ .baz = false },
    }, unions.value);
}

test "packed struct" {
    var parser = Parser.init;
    defer parser.deinit(allocator);

    // cursed
    const document = try parser.parseFromSlice(allocator,
        \\{
        \\    "address": 12345,
        \\    "available": 2,
        \\    "global": true,
        \\    "page_attribute_table": false,
        \\    "dirty": true,
        \\    "accessed": false,
        \\    "cache_disable": true,
        \\    "write_through": false,
        \\    "user": true,
        \\    "operation": "write",
        \\    "present": false
        \\}
    );

    const PageTableEntry = packed struct(u32) {
        address: u20,
        available: u3,
        global: bool,
        page_attribute_table: bool,
        dirty: bool,
        accessed: bool,
        cache_disable: bool,
        write_through: bool,
        user: bool,
        operation: enum(u1) { read, write },
        present: bool,
    };

    const pte = try document.asLeaky(PageTableEntry, null, .{});

    try std.testing.expectEqual(PageTableEntry{
        .address = 12345,
        .available = 2,
        .global = true,
        .page_attribute_table = false,
        .dirty = true,
        .accessed = false,
        .cache_disable = true,
        .write_through = false,
        .user = true,
        .operation = .write,
        .present = false,
    }, pte);
}

test "use first duplicate" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\{ "foo": 1, "foo": 2, "foo": 3, "bar": 4 }
    );

    const Schema = struct {
        pub const schema: Parser.schema.Infer(@This()) = .{
            .on_duplicate_field = .use_first,
        };
        bar: u8,
        foo: u8,
    };
    const s = try document.asLeaky(Schema, null, .{});

    try std.testing.expectEqual(Schema{ .foo = 1, .bar = 4 }, s);
}

test "use first duplicate, assuming ordering" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\{ "foo": 1, "foo": 2, "foo": 3, "bar": 4 }
    );

    const Schema = struct {
        pub const schema: Parser.schema.Infer(@This()) = .{
            .assume_ordering = true,
            .on_duplicate_field = .use_first,
        };
        foo: u8,
        bar: u8,
    };
    const s = try document.asLeaky(Schema, null, .{});

    try std.testing.expectEqual(Schema{ .foo = 1, .bar = 4 }, s);
}

test "use last duplicate" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\{ "foo": 1, "foo": 2, "foo": 3, "bar": 4 }
    );

    const Schema = struct {
        pub const schema: Parser.schema.Infer(@This()) = .{
            .on_duplicate_field = .use_last,
        };
        bar: u8,
        foo: u8,
    };
    const s = try document.asLeaky(Schema, null, .{});

    try std.testing.expectEqual(Schema{ .foo = 3, .bar = 4 }, s);
}

test "use last duplicate, assuming ordering" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\{ "foo": 1, "foo": 2, "foo": 3, "bar": 4 }
    );

    const Schema = struct {
        pub const schema: Parser.schema.Infer(@This()) = .{
            .assume_ordering = true,
            .on_duplicate_field = .use_last,
        };
        foo: u8,
        bar: u8,
    };
    const s = try document.asLeaky(Schema, null, .{});

    try std.testing.expectEqual(Schema{ .foo = 3, .bar = 4 }, s);
}

test "error because of duplicate" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\{ "foo": 1, "foo": 2, "foo": 3, "bar": 4 }
    );

    const Schema = struct {
        pub const schema: Parser.schema.Infer(@This()) = .{
            .on_duplicate_field = .@"error",
        };
        bar: u8,
        foo: u8,
    };

    try std.testing.expectError(error.DuplicateField, document.asLeaky(Schema, null, .{}));
}

test "error because of duplicate, assuming ordering" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\{ "foo": 1, "foo": 2, "foo": 3, "bar": 4 }
    );

    const Schema = struct {
        pub const schema: Parser.schema.Infer(@This()) = .{
            .assume_ordering = true,
            .on_duplicate_field = .@"error",
        };
        foo: u8,
        bar: u8,
    };

    try std.testing.expectError(error.DuplicateField, document.asLeaky(Schema, null, .{}));
}

test "missing field while handling duplicate" {
    var parser = Parser.init;
    defer parser.deinit(allocator);

    const document = try parser.parseFromSlice(allocator,
        \\{ "foo": 1, "foo": 2, "foo": 3 }
    );

    const Schema = struct {
        bar: u8,
        foo: u8,
    };

    try std.testing.expectError(error.MissingField, document.asLeaky(Schema, allocator, .{
        .schema = .{ .on_duplicate_field = .use_first },
    }));

    try std.testing.expectError(error.MissingField, document.asLeaky(Schema, allocator, .{
        .schema = .{ .on_duplicate_field = .use_last },
    }));
}

test "missing field while handling duplicate, assuming ordering" {
    var parser = Parser.init;
    defer parser.deinit(allocator);

    const document = try parser.parseFromSlice(allocator,
        \\{ "foo": 1, "foo": 2, "foo": 3 }
    );

    const Schema = struct {
        foo: u8,
        bar: u8,
    };

    try std.testing.expectError(error.MissingField, document.asLeaky(
        Schema,
        allocator,
        .{
            .schema = .{
                .assume_ordering = true,
                .on_duplicate_field = .use_first,
            },
        },
    ));

    try std.testing.expectError(error.MissingField, document.asLeaky(
        Schema,
        allocator,
        .{
            .schema = .{
                .assume_ordering = true,
                .on_duplicate_field = .use_last,
            },
        },
    ));
}

// test "std.BitStack" {
// //     var parser = Parser.init;
//     defer parser.deinit(allocator);
//     const document = try parser.parseFromSlice(allocator,
//         \\[ 0,1,1,1, 1,0,1,1, 1,0,1,1, 0,1,0,1 ]
//     );

//     var bits = try document.as(std.BitStack,.{});
//     defer bits.deinit();

//     try std.testing.expectEqual(bits.value.bit_len, 16);
//     try std.testing.expectEqualSlices(
//         u8,
//         @as([]const u8, &.{ 0xDE, 0xAD }),
//         bits.value.bytes.items,
//     );
// }

// test "std.BufMap" {
// //     var parser = Parser.init;
//     defer parser.deinit(allocator);
//     const document = try parser.parseFromSlice(allocator,
//         \\{
//         \\  "car": "blue",
//         \\  "bike": "red",
//         \\  "4x4": "green"
//         \\}
//     );

//     var map = try document.as(std.BufMap,.{});
//     defer map.deinit();

//     try std.testing.expectEqual(map.value.count(), 3);
//     try std.testing.expectEqualStrings("blue", map.value.get("car").?);
//     try std.testing.expectEqualStrings("red", map.value.get("bike").?);
//     try std.testing.expectEqualStrings("green", map.value.get("4x4").?);
// }

// test "std.BufSet" {
// //     var parser = Parser.init;
//     defer parser.deinit(allocator);
//     const document = try parser.parseFromSlice(allocator,
//         \\[
//         \\  "car", "blue",
//         \\  "bike", "red",
//         \\  "4x4", "green"
//         \\]
//     );

//     var set = try document.as(std.BufSet,.{});
//     defer set.deinit();

//     try std.testing.expectEqual(set.value.count(), 6);
//     var expected = std.StringHashMap(bool).init(allocator);
//     defer expected.deinit();

//     try expected.put("car", false);
//     try expected.put("blue", false);
//     try expected.put("bike", false);
//     try expected.put("red", false);
//     try expected.put("4x4", false);
//     try expected.put("green", false);

//     var it = set.value.iterator();

//     while (it.next()) |item| {
//         const visited = expected.fetchPutAssumeCapacity(item.*, true);
//         try std.testing.expectEqual(visited.?.value, false);
//     }
// }

test "std.ArrayListUnmanaged" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\[
        \\    { "x": 1, "y": 2, "z": 3 },
        \\    { "x": 4, "y": 5, "z": 6 },
        \\    { "x": 7, "y": 8, "z": 9 }
        \\]
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.ArrayListUnmanaged(Coordinate), allocator, .{});
    defer coords.deinit();

    try std.testing.expectEqual(coords.value.items.len, 3);
    try std.testing.expectEqual(Coordinate{ .x = 1, .y = 2, .z = 3 }, coords.value.items[0]);
    try std.testing.expectEqual(Coordinate{ .x = 4, .y = 5, .z = 6 }, coords.value.items[1]);
    try std.testing.expectEqual(Coordinate{ .x = 7, .y = 8, .z = 9 }, coords.value.items[2]);
}

test "std.ArrayListAlignedUnmanaged" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\[
        \\    { "x": 1, "y": 2, "z": 3 },
        \\    { "x": 4, "y": 5, "z": 6 },
        \\    { "x": 7, "y": 8, "z": 9 }
        \\]
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.ArrayListAlignedUnmanaged(Coordinate, 32), allocator, .{});
    defer coords.deinit();

    try std.testing.expectEqual(coords.value.items.len, 3);
    try std.testing.expectEqual(Coordinate{ .x = 1, .y = 2, .z = 3 }, coords.value.items[0]);
    try std.testing.expectEqual(Coordinate{ .x = 4, .y = 5, .z = 6 }, coords.value.items[1]);
    try std.testing.expectEqual(Coordinate{ .x = 7, .y = 8, .z = 9 }, coords.value.items[2]);
}

test "std.SinglyLinkedList" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\[
        \\    { "x": 1, "y": 2, "z": 3 },
        \\    { "x": 4, "y": 5, "z": 6 },
        \\    { "x": 7, "y": 8, "z": 9 }
        \\]
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.SinglyLinkedList(Coordinate), allocator, .{});
    defer coords.deinit();

    var it = coords.value.first;
    try std.testing.expectEqual(Coordinate{ .x = 1, .y = 2, .z = 3 }, it.?.data);
    it = it.?.next;
    try std.testing.expectEqual(Coordinate{ .x = 4, .y = 5, .z = 6 }, it.?.data);
    it = it.?.next;
    try std.testing.expectEqual(Coordinate{ .x = 7, .y = 8, .z = 9 }, it.?.data);
    it = it.?.next;
    try std.testing.expectEqual(null, it);
}

test "std.DoublyLinkedList" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\[
        \\    { "x": 1, "y": 2, "z": 3 },
        \\    { "x": 4, "y": 5, "z": 6 },
        \\    { "x": 7, "y": 8, "z": 9 }
        \\]
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.DoublyLinkedList(Coordinate), allocator, .{});
    defer coords.deinit();

    var it = coords.value.first;
    try std.testing.expectEqual(Coordinate{ .x = 1, .y = 2, .z = 3 }, it.?.data);
    it = it.?.next;
    try std.testing.expectEqual(Coordinate{ .x = 4, .y = 5, .z = 6 }, it.?.data);
    it = it.?.next;
    try std.testing.expectEqual(Coordinate{ .x = 7, .y = 8, .z = 9 }, it.?.data);
    it = it.?.next;
    try std.testing.expectEqual(null, it);
}

test "std.StringArrayHashMapUnmanaged" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\{
        \\  "car": { "x": 1, "y": 2, "z": 3 },
        \\  "bike": { "x": 4, "y": 5, "z": 6 },
        \\  "4x4": { "x": 7, "y": 8, "z": 9 }
        \\}
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.StringArrayHashMapUnmanaged(Coordinate), allocator, .{});
    defer coords.deinit();

    try std.testing.expectEqual(coords.value.count(), 3);
    try std.testing.expectEqual(Coordinate{ .x = 1, .y = 2, .z = 3 }, coords.value.get("car").?);
    try std.testing.expectEqual(Coordinate{ .x = 4, .y = 5, .z = 6 }, coords.value.get("bike").?);
    try std.testing.expectEqual(Coordinate{ .x = 7, .y = 8, .z = 9 }, coords.value.get("4x4").?);
}

test "std.StringHashMapUnmanaged" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\{
        \\  "car": { "x": 1, "y": 2, "z": 3 },
        \\  "bike": { "x": 4, "y": 5, "z": 6 },
        \\  "4x4": { "x": 7, "y": 8, "z": 9 }
        \\}
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.StringHashMapUnmanaged(Coordinate), allocator, .{});
    defer coords.deinit();

    try std.testing.expectEqual(coords.value.count(), 3);
    try std.testing.expectEqual(Coordinate{ .x = 1, .y = 2, .z = 3 }, coords.value.get("car").?);
    try std.testing.expectEqual(Coordinate{ .x = 4, .y = 5, .z = 6 }, coords.value.get("bike").?);
    try std.testing.expectEqual(Coordinate{ .x = 7, .y = 8, .z = 9 }, coords.value.get("4x4").?);
}

test "std.BoundedArray" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\[
        \\    { "x": 1, "y": 2, "z": 3 },
        \\    { "x": 4, "y": 5, "z": 6 },
        \\    { "x": 7, "y": 8, "z": 9 }
        \\]
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.BoundedArray(Coordinate, 3), allocator, .{});
    defer coords.deinit();

    try std.testing.expectEqual(coords.value.len, 3);
    try std.testing.expectEqual(Coordinate{ .x = 1, .y = 2, .z = 3 }, coords.value.get(0));
    try std.testing.expectEqual(Coordinate{ .x = 4, .y = 5, .z = 6 }, coords.value.get(1));
    try std.testing.expectEqual(Coordinate{ .x = 7, .y = 8, .z = 9 }, coords.value.get(2));
}

test "std.BoundedArrayAligned" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\[
        \\    { "x": 1, "y": 2, "z": 3 },
        \\    { "x": 4, "y": 5, "z": 6 },
        \\    { "x": 7, "y": 8, "z": 9 }
        \\]
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.BoundedArrayAligned(Coordinate, 32, 4), allocator, .{});
    defer coords.deinit();

    try std.testing.expectEqual(coords.value.len, 3);
    try std.testing.expectEqual(Coordinate{ .x = 1, .y = 2, .z = 3 }, coords.value.get(0));
    try std.testing.expectEqual(Coordinate{ .x = 4, .y = 5, .z = 6 }, coords.value.get(1));
    try std.testing.expectEqual(Coordinate{ .x = 7, .y = 8, .z = 9 }, coords.value.get(2));
}

test "std.EnumMap" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\{
        \\  "car": "blue",
        \\  "bike": "red",
        \\  "4x4": "green"
        \\}
    );

    const map = try document.asLeaky(std.EnumMap(enum { car, bike, @"4x4" }, []const u8), null, .{});

    try std.testing.expectEqual(map.count(), 3);
    try std.testing.expectEqualStrings("blue", map.get(.car).?);
    try std.testing.expectEqualStrings("red", map.get(.bike).?);
    try std.testing.expectEqualStrings("green", map.get(.@"4x4").?);
}

test "std.SegmentedList" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\[
        \\    { "x": 1, "y": 2, "z": 3 },
        \\    { "x": 4, "y": 5, "z": 6 },
        \\    { "x": 7, "y": 8, "z": 9 }
        \\]
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.SegmentedList(Coordinate, 0), allocator, .{});
    defer coords.deinit();

    try std.testing.expectEqual(coords.value.len, 3);
    try std.testing.expectEqual(Coordinate{ .x = 1, .y = 2, .z = 3 }, coords.value.at(0).*);
    try std.testing.expectEqual(Coordinate{ .x = 4, .y = 5, .z = 6 }, coords.value.at(1).*);
    try std.testing.expectEqual(Coordinate{ .x = 7, .y = 8, .z = 9 }, coords.value.at(2).*);
}

test "std.MultiArrayList" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\[
        \\    { "x": 1, "y": 2, "z": 3 },
        \\    { "x": 4, "y": 5, "z": 6 },
        \\    { "x": 7, "y": 8, "z": 9 }
        \\]
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.MultiArrayList(Coordinate), allocator, .{});
    defer coords.deinit();

    try std.testing.expectEqual(coords.value.len, 3);
    try std.testing.expectEqual(Coordinate{ .x = 1, .y = 2, .z = 3 }, coords.value.get(0));
    try std.testing.expectEqual(Coordinate{ .x = 4, .y = 5, .z = 6 }, coords.value.get(1));
    try std.testing.expectEqual(Coordinate{ .x = 7, .y = 8, .z = 9 }, coords.value.get(2));
}

test "handle unknown field" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\{
        \\  "id": "49824073-979f-4814-be10-5ea416ee1c2f",
        \\  "username": "john_doe",
        \\  "mascot": "Ziggy the Ziguana"
        \\}
    );

    const User = struct {
        pub const schema: Parser.schema.Infer(@This()) = .{
            .fields = .{ .extra = .{ .skip = true } },
            .on_unknown_field = .{ .handle = @This().handleUnknownField },
        };

        id: []const u8,
        username: []const u8,

        extra: std.StringHashMapUnmanaged(Parser.AnyValue),

        pub fn handleUnknownField(self: *@This(), alloc: ?std.mem.Allocator, key: []const u8, value: Parser.Value) Parser.schema.Error!void {
            const gpa = alloc orelse return error.ExpectedAllocator;
            return self.extra.put(gpa, key, try value.asAny());
        }
    };

    const user = try document.as(User, allocator, .{});
    defer user.deinit();

    try std.testing.expectEqualStrings("49824073-979f-4814-be10-5ea416ee1c2f", user.value.id);
    try std.testing.expectEqualStrings("john_doe", user.value.username);
    try std.testing.expectEqualStrings("Ziggy the Ziguana", try user.value.extra.get("mascot").?.string.get());
}

test "handle duplicate field" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\{
        \\  "id": "49824073-979f-4814-be10-5ea416ee1c2f",
        \\  "username": "john_doe",
        \\  "mascot": "Zero the Ziguana",
        \\  "mascot": "Carmen the Allocgator"
        \\}
    );

    const User = struct {
        pub const schema: Parser.schema.Infer(@This()) = .{
            .fields = .{ .duplicate = .{ .skip = true } },
            .on_duplicate_field = .{ .handle = @This().handleDuplicateField },
        };

        id: []const u8,
        username: []const u8,
        mascot: []const u8,

        duplicate: std.StringHashMapUnmanaged(Parser.AnyValue),

        pub fn handleDuplicateField(self: *@This(), alloc: ?std.mem.Allocator, key: []const u8, value: Parser.Value) Parser.schema.Error!void {
            const gpa = alloc orelse return error.ExpectedAllocator;
            return self.duplicate.put(gpa, key, try value.asAny());
        }
    };

    const user = try document.as(User, allocator, .{});
    defer user.deinit();

    try std.testing.expectEqualStrings("49824073-979f-4814-be10-5ea416ee1c2f", user.value.id);
    try std.testing.expectEqualStrings("john_doe", user.value.username);
    try std.testing.expectEqualStrings("Zero the Ziguana", user.value.mascot);
    try std.testing.expectEqualStrings("Carmen the Allocgator", try user.value.duplicate.get("mascot").?.string.get());
}

test "zig/issues/19356" {
    // https://discord.com/developers/docs/topics/permissions#role-object-role-tags-structure

    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\{
        \\    "bot_id": "123456789012345678",
        \\    "integration_id": "987654321098765432",
        \\    "premium_subscriber": null,
        \\    "subscription_listing_id": "111222333444555666",
        \\    "guild_connections": null
        \\}
    );

    const RoleTags = struct {
        bot_id: ?[]const u8,
        integration_id: ?[]const u8,
        premium_subscriber: ?void = {},
        subscription_listing_id: ?[]const u8,
        available_for_purchase: ?void = {}, // if present, the value is null, otherwise it's void
        guild_connections: ?void = {},
    };

    const role_tags = try document.as(RoleTags, allocator, .{});
    defer role_tags.deinit();

    try std.testing.expectEqualStrings("123456789012345678", role_tags.value.bot_id.?);
    try std.testing.expectEqualStrings("987654321098765432", role_tags.value.integration_id.?);
    try std.testing.expectEqualStrings("111222333444555666", role_tags.value.subscription_listing_id.?);

    try std.testing.expectEqual(null, role_tags.value.premium_subscriber);
    try std.testing.expectEqual({}, role_tags.value.available_for_purchase);
    try std.testing.expectEqual(null, role_tags.value.guild_connections);
}

test "rgb" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\{
        \\  "color_name": "violet",
        \\  "rgb": [160, 37, 232]
        \\}
    );

    const Color = struct {
        color_name: []const u8,
        rgb: struct { u8, u8, u8 },
    };

    const rgb = try document.as(Color, allocator, .{});
    defer rgb.deinit();

    try std.testing.expectEqualDeep(Color{
        .color_name = "violet",
        .rgb = .{ 160, 37, 232 },
    }, rgb.value);
}

test "rgb2" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\{
        \\  "color_name": "violet",
        \\  "rgb": [160, 37, 232]
        \\}
    );

    const Color = struct {
        color_name: []const u8,
        rgb: []const u8,
    };

    const rgb = try document.as(Color, allocator, .{
        .schema = .{ .fields = .{ .rgb = .{ .schema = .{ .bytes_as_string = false } } } },
    });
    defer rgb.deinit();

    try std.testing.expectEqualDeep(Color{
        .color_name = "violet",
        .rgb = &.{ 160, 37, 232 },
    }, rgb.value);
}

test "iso code" {
    // zig fmt: off
    const Iso3166 = enum {
        af, ax, al, dz, as, ad, ao, ai, aq, ag,
        ar, am, aw, au, at, az, bs, bh, bd, bb,
        by, be, bz, bj, bm, bt, bo, ba, bw, bv,
        br, io, vg, bn, bg, bf, bi, kh, cm, ca,
        cv, bq, ky, cf, td, cl, cn, cx, cc, co,
        km, cg, cd, ck, cr, ci, hr, cu, cw, cy,
        cz, dk, dj, dm, do, ec, eg, sv, gq, er,
        ee, sz, et, fk, fo, fj, fi, fr, gf, pf,
        tf, ga, gm, ge, de, gh, gi, gr, gl, gd,
        gp, gu, gt, gg, gn, gw, gy, ht, hm, hn,
        hk, hu, is, in, id, ir, iq, ie, im, il,
        it, jm, jp, je, jo, kz, ke, ki, kw, kg,
        la, lv, lb, ls, lr, ly, li, lt, lu, mo,
        mg, mw, my, mv, ml, mt, mh, mq, mr, mu,
        yt, mx, fm, md, mc, mn, me, ms, ma, mz,
        mm, na, nr, np, nl, nc, nz, ni, ne, ng,
        nu, nf, kp, mk, mp, no, om, pk, pw, ps,
        pa, pg, py, pe, ph, pn, pl, pt, pr, qa,
        re, ro, ru, rw, ws, sm, st, sa, sn, rs,
        sc, sl, sg, sx, sk, si, sb, so, za, gs,
        kr, ss, es, lk, bl, sh, kn, lc, mf, pm,
        vc, sd, sr, sj, se, ch, sy, tw, tj, tz,
        th, tl, tg, tk, to, tt, tn, tr, tm, tc,
        tv, um, vi, ug, ua, ae, gb, us, uy, uz,
        vu, va, ve, vn, wf, eh, ye, zm, zw
    };
    // zig fmt: on

    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator, "\"ES\"");

    const code = try document.asLeaky(Iso3166, null, .{ .schema = .{ .rename_all = .UPPERCASE } });
    try std.testing.expectEqual(Iso3166.es, code);
}

test "CustomParser, lossyCast" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parseFromSlice(allocator,
        \\{
        \\  "x": 243,
        \\  "y": -20.0
        \\}
    );

    const Position = struct {
        const Self = @This();
        pub const schema: Parser.schema.Infer(Self) = .{
            .parse_with = Self.customParser(),
        };

        x: i16,
        y: i16,

        fn customParser() Parser.schema.CustomParser(Self) {
            const Custom = struct {
                pub const init: Self = undefined;

                pub fn parse(self: *Self, alloc: ?std.mem.Allocator, value: Parser.Value) Parser.schema.Error!void {
                    const helper = try value.asLeaky(
                        struct {
                            x: zimdjson.Number,
                            y: zimdjson.Number,
                        },
                        alloc,
                        .{},
                    );

                    self.* = .{
                        .x = helper.x.lossyCast(i16),
                        .y = helper.y.lossyCast(i16),
                    };
                }
            };
            return .{
                .init = Custom.init,
                .parse = Custom.parse,
            };
        }
    };

    const pos = try document.asLeaky(Position, allocator, .{});

    try std.testing.expectEqual(Position{
        .x = 243,
        .y = -20,
    }, pos);
}
