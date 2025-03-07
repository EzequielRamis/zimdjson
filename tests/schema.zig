const std = @import("std");
const zimdjson = @import("zimdjson");
const simdjson_data = @embedFile("simdjson-data");
const parserFromFile = zimdjson.ondemand.parserFromFile(.{ .stream = .default });
const parserFromSlice = zimdjson.ondemand.parserFromSlice(.default);
const allocator = std.testing.allocator;

test "small/adversarial" {
    const Parser = parserFromFile;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/adversarial.json", .{});
    defer file.close();
    const document = try parser.parse(allocator, file.reader());

    const Schema = struct {
        @"\"Name rue": [1]struct {
            u8,
            []const u8,
            u8,
            []const u8,
            bool,
        },
    };

    const el = try document.asLeaky(Schema, null);
    const tuple = el.@"\"Name rue"[0];

    try std.testing.expectEqualDeep(.{
        116,
        "\"",
        234,
        "true",
        false,
    }, tuple);
}

test "small/demo" {
    const Parser = parserFromFile;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/demo.json", .{});
    defer file.close();
    const document = try parser.parse(allocator, file.reader());

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

    const image = try document.at("Image").as(Image, allocator);
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

test "small/truenull" {
    const Parser = parserFromFile;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/truenull.json", .{});
    defer file.close();
    const document = try parser.parse(allocator, file.reader());

    const arr = try document.as([]const ?bool, allocator);
    defer arr.deinit();

    for (arr.value, 0..) |elem, i| {
        try std.testing.expectEqual(if (i % 2 == 0) true else null, elem);
    }
}

test "github_events" {
    const Parser = parserFromFile;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/github_events.json", .{});
    defer file.close();
    const document = try parser.parse(allocator, file.reader());

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

    const events = try document.as([]const Event, allocator);
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
    const Parser = parserFromFile;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/github_events.json", .{});
    defer file.close();
    const document = try parser.parse(allocator, file.reader());

    const Payload = union(enum) {
        pub const schema: Parser.schema.Infer(@This()) = .{
            .representation = .untagged,
        };
        push: struct { push_id: usize },
        create: struct { description: []const u8 },
        fork: struct { forkee: struct { url: []const u8 } },
        watch: struct { action: []const u8 },

        // 'issue_comment' is a subset of 'issues' so it is discarded if 'issues' succeeds
        issue_comment: struct { action: []const u8, issue: struct { url: []const u8 } },
        issues: struct { action: []const u8, issue: struct { url: []const u8, id: usize } },

        gollum: struct { pages: []const struct { page_name: []const u8 } },
    };
    const Event = struct { payload: Payload };

    const events = try document.as([]const Event, allocator);
    defer events.deinit();

    try std.testing.expectEqualDeep(&.{
        Event{ .payload = .{ .push = .{ .push_id = 134107894 } } },
        Event{ .payload = .{ .create = .{ .description = "blog system" } } },
        Event{ .payload = .{ .fork = .{ .forkee = .{ .url = "https://api.github.com/repos/rtlong/digiusb.rb" } } } },
        Event{ .payload = .{ .watch = .{ .action = "started" } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107891 } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107890 } } },
        Event{ .payload = .{ .watch = .{ .action = "started" } } },
        Event{ .payload = .{ .watch = .{ .action = "started" } } },
        Event{ .payload = .{ .watch = .{ .action = "started" } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107888 } } },
        Event{ .payload = .{ .issues = .{ .action = "created", .issue = .{ .url = "https://api.github.com/repos/pat/thinking-sphinx/issues/415", .id = 9704821 } } } },
        Event{ .payload = .{ .issues = .{ .action = "opened", .issue = .{ .url = "https://api.github.com/repos/imsky/holder/issues/27", .id = 9833911 } } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107887 } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107885 } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107879 } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107876 } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107874 } } },
        Event{ .payload = .{ .watch = .{ .action = "started" } } },
        Event{ .payload = .{ .push = .{ .push_id = 134107873 } } },
        Event{ .payload = .{ .gollum = .{ .pages = &.{.{ .page_name = "Home" }} } } },
        Event{ .payload = .{ .watch = .{ .action = "started" } } },
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
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
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

    const unions = try document.as([]const Schema, allocator);
    defer unions.deinit();

    try std.testing.expectEqualDeep(&.{
        Schema{ .foo = 1 },
        Schema{ .bar = 5.0 },
        Schema{ .baz = false },
    }, unions.value);
}

test "adjacently_tagged" {
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\[{ "t": "foo", "c": 1 }, { "t": "bar", "c": 5.0 }, { "t": "baz", "c": false }]
    );

    const Schema = union(enum) {
        pub const schema: Parser.schema.Infer(@This()) = .{
            .representation = .{ .adjacently_tagged = .{ .tag = "t", .content = "c" } },
        };
        foo: u8,
        bar: f32,
        baz: bool,
    };

    const unions = try document.as([]const Schema, allocator);
    defer unions.deinit();

    try std.testing.expectEqualDeep(&.{
        Schema{ .foo = 1 },
        Schema{ .bar = 5.0 },
        Schema{ .baz = false },
    }, unions.value);
}

test "packed struct" {
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
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

    const pte = try document.asLeaky(PageTableEntry, null);

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
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\{ "foo": 1, "foo": 2, "foo": 3, "bar": 4 }
    );

    const Schema = struct {
        pub const schema: Parser.schema.Infer(@This()) = .{
            .on_duplicate_field = .use_first,
        };
        bar: u8,
        foo: u8,
    };
    const s = try document.asLeaky(Schema, null);

    try std.testing.expectEqual(Schema{ .foo = 1, .bar = 4 }, s);
}

test "use first duplicate, assuming ordering" {
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
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
    const s = try document.asLeaky(Schema, null);

    try std.testing.expectEqual(Schema{ .foo = 1, .bar = 4 }, s);
}

test "use last duplicate" {
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\{ "foo": 1, "foo": 2, "foo": 3, "bar": 4 }
    );

    const Schema = struct {
        pub const schema: Parser.schema.Infer(@This()) = .{
            .on_duplicate_field = .use_last,
        };
        bar: u8,
        foo: u8,
    };
    const s = try document.asLeaky(Schema, null);

    try std.testing.expectEqual(Schema{ .foo = 3, .bar = 4 }, s);
}

test "use last duplicate, assuming ordering" {
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
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
    const s = try document.asLeaky(Schema, null);

    try std.testing.expectEqual(Schema{ .foo = 3, .bar = 4 }, s);
}

test "error because of duplicate" {
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\{ "foo": 1, "foo": 2, "foo": 3, "bar": 4 }
    );

    const Schema = struct {
        pub const schema: Parser.schema.Infer(@This()) = .{
            .on_duplicate_field = .@"error",
        };
        bar: u8,
        foo: u8,
    };

    try std.testing.expectError(error.DuplicateField, document.asLeaky(Schema, null));
}

test "error because of duplicate, assuming ordering" {
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
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

    try std.testing.expectError(error.DuplicateField, document.asLeaky(Schema, null));
}

test "missing field while handling duplicate" {
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);

    const document = try parser.parse(allocator,
        \\{ "foo": 1, "foo": 2, "foo": 3 }
    );

    const Schema = struct {
        bar: u8,
        foo: u8,
    };

    try std.testing.expectError(error.MissingField, document.asAdvancedLeaky(
        Schema,
        .{
            .on_duplicate_field = .use_first,
        },
        allocator,
    ));

    try std.testing.expectError(error.MissingField, document.asAdvancedLeaky(
        Schema,
        .{
            .on_duplicate_field = .use_last,
        },
        allocator,
    ));
}

test "missing field while handling duplicate, assuming ordering" {
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);

    const document = try parser.parse(allocator,
        \\{ "foo": 1, "foo": 2, "foo": 3 }
    );

    const Schema = struct {
        foo: u8,
        bar: u8,
    };

    try std.testing.expectError(error.MissingField, document.asAdvancedLeaky(
        Schema,
        .{
            .assume_ordering = true,
            .on_duplicate_field = .use_first,
        },
        allocator,
    ));

    try std.testing.expectError(error.MissingField, document.asAdvancedLeaky(
        Schema,
        .{
            .assume_ordering = true,
            .on_duplicate_field = .use_last,
        },
        allocator,
    ));
}

// test "std.BitStack" {
//     const Parser = parserFromSlice;
//     var parser = Parser.init;
//     defer parser.deinit(allocator);
//     const document = try parser.parse(allocator,
//         \\[ 0,1,1,1, 1,0,1,1, 1,0,1,1, 0,1,0,1 ]
//     );

//     var bits = try document.as(std.BitStack);
//     defer bits.deinit();

//     try std.testing.expectEqual(bits.value.bit_len, 16);
//     try std.testing.expectEqualSlices(
//         u8,
//         @as([]const u8, &.{ 0xDE, 0xAD }),
//         bits.value.bytes.items,
//     );
// }

// test "std.BufMap" {
//     const Parser = parserFromSlice;
//     var parser = Parser.init;
//     defer parser.deinit(allocator);
//     const document = try parser.parse(allocator,
//         \\{
//         \\  "car": "blue",
//         \\  "bike": "red",
//         \\  "4x4": "green"
//         \\}
//     );

//     var map = try document.as(std.BufMap);
//     defer map.deinit();

//     try std.testing.expectEqual(map.value.count(), 3);
//     try std.testing.expectEqualStrings("blue", map.value.get("car").?);
//     try std.testing.expectEqualStrings("red", map.value.get("bike").?);
//     try std.testing.expectEqualStrings("green", map.value.get("4x4").?);
// }

// test "std.BufSet" {
//     const Parser = parserFromSlice;
//     var parser = Parser.init;
//     defer parser.deinit(allocator);
//     const document = try parser.parse(allocator,
//         \\[
//         \\  "car", "blue",
//         \\  "bike", "red",
//         \\  "4x4", "green"
//         \\]
//     );

//     var set = try document.as(std.BufSet);
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
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\[
        \\    { "x": 1, "y": 2, "z": 3 },
        \\    { "x": 4, "y": 5, "z": 6 },
        \\    { "x": 7, "y": 8, "z": 9 }
        \\]
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.ArrayListUnmanaged(Coordinate), allocator);
    defer coords.deinit();

    try std.testing.expectEqual(coords.value.items.len, 3);
    try std.testing.expectEqual(Coordinate{ .x = 1, .y = 2, .z = 3 }, coords.value.items[0]);
    try std.testing.expectEqual(Coordinate{ .x = 4, .y = 5, .z = 6 }, coords.value.items[1]);
    try std.testing.expectEqual(Coordinate{ .x = 7, .y = 8, .z = 9 }, coords.value.items[2]);
}

test "std.ArrayListAlignedUnmanaged" {
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\[
        \\    { "x": 1, "y": 2, "z": 3 },
        \\    { "x": 4, "y": 5, "z": 6 },
        \\    { "x": 7, "y": 8, "z": 9 }
        \\]
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.ArrayListAlignedUnmanaged(Coordinate, 32), allocator);
    defer coords.deinit();

    try std.testing.expectEqual(coords.value.items.len, 3);
    try std.testing.expectEqual(Coordinate{ .x = 1, .y = 2, .z = 3 }, coords.value.items[0]);
    try std.testing.expectEqual(Coordinate{ .x = 4, .y = 5, .z = 6 }, coords.value.items[1]);
    try std.testing.expectEqual(Coordinate{ .x = 7, .y = 8, .z = 9 }, coords.value.items[2]);
}

test "std.SinglyLinkedList" {
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\[
        \\    { "x": 1, "y": 2, "z": 3 },
        \\    { "x": 4, "y": 5, "z": 6 },
        \\    { "x": 7, "y": 8, "z": 9 }
        \\]
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.SinglyLinkedList(Coordinate), allocator);
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
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\[
        \\    { "x": 1, "y": 2, "z": 3 },
        \\    { "x": 4, "y": 5, "z": 6 },
        \\    { "x": 7, "y": 8, "z": 9 }
        \\]
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.DoublyLinkedList(Coordinate), allocator);
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
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\{
        \\  "car": { "x": 1, "y": 2, "z": 3 },
        \\  "bike": { "x": 4, "y": 5, "z": 6 },
        \\  "4x4": { "x": 7, "y": 8, "z": 9 }
        \\}
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.StringArrayHashMapUnmanaged(Coordinate), allocator);
    defer coords.deinit();

    try std.testing.expectEqual(coords.value.count(), 3);
    try std.testing.expectEqual(Coordinate{ .x = 1, .y = 2, .z = 3 }, coords.value.get("car").?);
    try std.testing.expectEqual(Coordinate{ .x = 4, .y = 5, .z = 6 }, coords.value.get("bike").?);
    try std.testing.expectEqual(Coordinate{ .x = 7, .y = 8, .z = 9 }, coords.value.get("4x4").?);
}

test "std.StringHashMapUnmanaged" {
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\{
        \\  "car": { "x": 1, "y": 2, "z": 3 },
        \\  "bike": { "x": 4, "y": 5, "z": 6 },
        \\  "4x4": { "x": 7, "y": 8, "z": 9 }
        \\}
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.StringHashMapUnmanaged(Coordinate), allocator);
    defer coords.deinit();

    try std.testing.expectEqual(coords.value.count(), 3);
    try std.testing.expectEqual(Coordinate{ .x = 1, .y = 2, .z = 3 }, coords.value.get("car").?);
    try std.testing.expectEqual(Coordinate{ .x = 4, .y = 5, .z = 6 }, coords.value.get("bike").?);
    try std.testing.expectEqual(Coordinate{ .x = 7, .y = 8, .z = 9 }, coords.value.get("4x4").?);
}

test "std.BoundedArray" {
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\[
        \\    { "x": 1, "y": 2, "z": 3 },
        \\    { "x": 4, "y": 5, "z": 6 },
        \\    { "x": 7, "y": 8, "z": 9 }
        \\]
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.BoundedArray(Coordinate, 3), allocator);
    defer coords.deinit();

    try std.testing.expectEqual(coords.value.len, 3);
    try std.testing.expectEqual(Coordinate{ .x = 1, .y = 2, .z = 3 }, coords.value.get(0));
    try std.testing.expectEqual(Coordinate{ .x = 4, .y = 5, .z = 6 }, coords.value.get(1));
    try std.testing.expectEqual(Coordinate{ .x = 7, .y = 8, .z = 9 }, coords.value.get(2));
}

test "std.BoundedArrayAligned" {
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\[
        \\    { "x": 1, "y": 2, "z": 3 },
        \\    { "x": 4, "y": 5, "z": 6 },
        \\    { "x": 7, "y": 8, "z": 9 }
        \\]
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.BoundedArrayAligned(Coordinate, 32, 4), allocator);
    defer coords.deinit();

    try std.testing.expectEqual(coords.value.len, 3);
    try std.testing.expectEqual(Coordinate{ .x = 1, .y = 2, .z = 3 }, coords.value.get(0));
    try std.testing.expectEqual(Coordinate{ .x = 4, .y = 5, .z = 6 }, coords.value.get(1));
    try std.testing.expectEqual(Coordinate{ .x = 7, .y = 8, .z = 9 }, coords.value.get(2));
}

test "std.EnumMap" {
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\{
        \\  "car": "blue",
        \\  "bike": "red",
        \\  "4x4": "green"
        \\}
    );

    const map = try document.asLeaky(std.EnumMap(enum { car, bike, @"4x4" }, []const u8), null);

    try std.testing.expectEqual(map.count(), 3);
    try std.testing.expectEqualStrings("blue", map.get(.car).?);
    try std.testing.expectEqualStrings("red", map.get(.bike).?);
    try std.testing.expectEqualStrings("green", map.get(.@"4x4").?);
}

test "std.SegmentedList" {
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\[
        \\    { "x": 1, "y": 2, "z": 3 },
        \\    { "x": 4, "y": 5, "z": 6 },
        \\    { "x": 7, "y": 8, "z": 9 }
        \\]
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.SegmentedList(Coordinate, 0), allocator);
    defer coords.deinit();

    try std.testing.expectEqual(coords.value.len, 3);
    try std.testing.expectEqual(Coordinate{ .x = 1, .y = 2, .z = 3 }, coords.value.at(0).*);
    try std.testing.expectEqual(Coordinate{ .x = 4, .y = 5, .z = 6 }, coords.value.at(1).*);
    try std.testing.expectEqual(Coordinate{ .x = 7, .y = 8, .z = 9 }, coords.value.at(2).*);
}

test "std.MultiArrayList" {
    const Parser = parserFromSlice;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\[
        \\    { "x": 1, "y": 2, "z": 3 },
        \\    { "x": 4, "y": 5, "z": 6 },
        \\    { "x": 7, "y": 8, "z": 9 }
        \\]
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.as(std.MultiArrayList(Coordinate), allocator);
    defer coords.deinit();

    try std.testing.expectEqual(coords.value.len, 3);
    try std.testing.expectEqual(Coordinate{ .x = 1, .y = 2, .z = 3 }, coords.value.get(0));
    try std.testing.expectEqual(Coordinate{ .x = 4, .y = 5, .z = 6 }, coords.value.get(1));
    try std.testing.expectEqual(Coordinate{ .x = 7, .y = 8, .z = 9 }, coords.value.get(2));
}
