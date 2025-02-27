const std = @import("std");
const zimdjson = @import("zimdjson");
const simdjson_data = @embedFile("simdjson-data");

test "small/adversarial" {
    const Parser = zimdjson.ondemand.parserFromFile(.default);
    const allocator = std.testing.allocator;
    var parser = Parser.init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/adversarial.json", .{});
    defer file.close();
    const document = try parser.parse(file.reader());

    const Schema = struct {
        @"\"Name rue": [1]struct {
            u8,
            []const u8,
            u8,
            []const u8,
            bool,
        },
    };

    const el = try document.as(Schema);
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
    const Parser = zimdjson.ondemand.parserFromFile(.default);
    const allocator = std.testing.allocator;
    var parser = Parser.init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/demo.json", .{});
    defer file.close();
    const document = try parser.parse(file.reader());

    const Image = struct {
        pub const schema: Parser.schema.Auto(@This()) = .{
            .rename_all = .PascalCase,
            .fields = .{ .ids = .{ .alias = "IDs" } },
        };
        width: u16,
        height: u16,
        title: []const u8,
        thumbnail: struct {
            pub const schema: Parser.schema.Auto(@This()) = .{ .rename_all = .PascalCase };
            url: []const u8,
            height: u16,
            width: u16,
        },
        animated: bool,
        ids: []const u16,
    };

    const image = try document.at("Image").as(Image);
    defer allocator.free(image.ids);

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
    }, image);
}

test "small/truenull" {
    const Parser = zimdjson.ondemand.parserFromFile(.default);
    const allocator = std.testing.allocator;
    var parser = Parser.init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/truenull.json", .{});
    defer file.close();
    const document = try parser.parse(file.reader());

    const arr = try document.as([]const ?bool);
    defer allocator.free(arr);

    for (arr, 0..) |elem, i| {
        try std.testing.expectEqual(if (i % 2 == 0) true else null, elem);
    }
}

test "github_events" {
    const Parser = zimdjson.ondemand.parserFromFile(.default);
    const allocator = std.testing.allocator;
    var parser = Parser.init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/github_events.json", .{});
    defer file.close();
    const document = try parser.parse(file.reader());

    const Event = union(enum) {
        pub const schema: Parser.schema.Auto(@This()) = .{
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

    const events = try document.as([]const Event);
    defer allocator.free(events);

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
    }, events);
}

test "github_events untagged payload" {
    const Parser = zimdjson.ondemand.parserFromFile(.default);
    const allocator = std.testing.allocator;
    var parser = Parser.init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/github_events.json", .{});
    defer file.close();
    const document = try parser.parse(file.reader());

    const Payload = union(enum) {
        pub const schema: Parser.schema.Auto(@This()) = .{
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

    const events = try document.as([]const Event);
    defer {
        for (events) |e| switch (e.payload) {
            .gollum => |g| allocator.free(g.pages),
            else => {},
        };
        allocator.free(events);
    }

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
    }, events);
}

test "externally_tagged" {
    const Parser = zimdjson.ondemand.parserFromSlice(.default);
    const allocator = std.testing.allocator;
    var parser = Parser.init(allocator);
    defer parser.deinit();
    const document = try parser.parse(
        \\[{ "foo": 1 }, { "bar": 5.0 }, { "baz": false }]
    );

    const Schema = union(enum) {
        pub const schema: Parser.schema.Auto(@This()) = .{
            .representation = .externally_tagged,
        };
        foo: u8,
        bar: f32,
        baz: bool,
    };

    const unions = try document.as([]const Schema);
    defer allocator.free(unions);

    try std.testing.expectEqualDeep(&.{
        Schema{ .foo = 1 },
        Schema{ .bar = 5.0 },
        Schema{ .baz = false },
    }, unions);
}

test "adjacently_tagged" {
    const Parser = zimdjson.ondemand.parserFromSlice(.default);
    const allocator = std.testing.allocator;
    var parser = Parser.init(allocator);
    defer parser.deinit();
    const document = try parser.parse(
        \\[{ "t": "foo", "c": 1 }, { "t": "bar", "c": 5.0 }, { "t": "baz", "c": false }]
    );

    const Schema = union(enum) {
        pub const schema: Parser.schema.Auto(@This()) = .{
            .representation = .{ .adjacently_tagged = .{ .tag = "t", .content = "c" } },
        };
        foo: u8,
        bar: f32,
        baz: bool,
    };

    const unions = try document.as([]const Schema);
    defer allocator.free(unions);

    try std.testing.expectEqualDeep(&.{
        Schema{ .foo = 1 },
        Schema{ .bar = 5.0 },
        Schema{ .baz = false },
    }, unions);
}

test "packed struct" {
    const Parser = zimdjson.ondemand.parserFromSlice(.default);
    const allocator = std.testing.allocator;
    var parser = Parser.init(allocator);
    defer parser.deinit();
    const document = try parser.parse(
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

    const pte = try document.as(PageTableEntry);

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

test "with std data structure" {
    const Parser = zimdjson.ondemand.parserFromSlice(.default);
    const allocator = std.testing.allocator;
    var parser = Parser.init(allocator);
    defer parser.deinit();
    const document = try parser.parse(
        \\[
        \\    { "x": 1, "y": 2, "z": 3 },
        \\    { "x": 4, "y": 5, "z": 6 },
        \\    { "x": 7, "y": 8, "z": 9 }
        \\]
    );

    const Coordinate = struct { x: i32, y: i32, z: i32 };
    var coords = try document.asAdvanced(
        std.MultiArrayList(Coordinate),
        .{ .parse_with = Parser.schema.std.MultiArrayList(Coordinate) },
        allocator,
    );
    defer coords.deinit(allocator);

    try std.testing.expectEqual(Coordinate{ .x = 1, .y = 2, .z = 3 }, coords.get(0));
    try std.testing.expectEqual(Coordinate{ .x = 4, .y = 5, .z = 6 }, coords.get(1));
    try std.testing.expectEqual(Coordinate{ .x = 7, .y = 8, .z = 9 }, coords.get(2));
}

test "use first duplicate" {
    const Parser = zimdjson.ondemand.parserFromSlice(.default);
    const allocator = std.testing.allocator;
    var parser = Parser.init(allocator);
    defer parser.deinit();
    const document = try parser.parse(
        \\{ "foo": 1, "foo": 2, "foo": 3, "bar": 4 }
    );

    const Schema = struct {
        pub const schema: Parser.schema.Auto(@This()) = .{
            .duplicate_field_behavior = .use_first,
        };
        bar: u8,
        foo: u8,
    };
    const s = try document.as(Schema);

    try std.testing.expectEqual(Schema{ .foo = 1, .bar = 4 }, s);
}

test "use first duplicate, assuming ordering" {
    const Parser = zimdjson.ondemand.parserFromSlice(.default);
    const allocator = std.testing.allocator;
    var parser = Parser.init(allocator);
    defer parser.deinit();
    const document = try parser.parse(
        \\{ "foo": 1, "foo": 2, "foo": 3, "bar": 4 }
    );

    const Schema = struct {
        pub const schema: Parser.schema.Auto(@This()) = .{
            .assume_ordering = true,
            .duplicate_field_behavior = .use_first,
        };
        foo: u8,
        bar: u8,
    };
    const s = try document.as(Schema);

    try std.testing.expectEqual(Schema{ .foo = 1, .bar = 4 }, s);
}

test "use last duplicate" {
    const Parser = zimdjson.ondemand.parserFromSlice(.default);
    const allocator = std.testing.allocator;
    var parser = Parser.init(allocator);
    defer parser.deinit();
    const document = try parser.parse(
        \\{ "foo": 1, "foo": 2, "foo": 3, "bar": 4 }
    );

    const Schema = struct {
        pub const schema: Parser.schema.Auto(@This()) = .{
            .duplicate_field_behavior = .use_last,
        };
        bar: u8,
        foo: u8,
    };
    const s = try document.as(Schema);

    try std.testing.expectEqual(Schema{ .foo = 3, .bar = 4 }, s);
}

test "use last duplicate, assuming ordering" {
    const Parser = zimdjson.ondemand.parserFromSlice(.default);
    const allocator = std.testing.allocator;
    var parser = Parser.init(allocator);
    defer parser.deinit();
    const document = try parser.parse(
        \\{ "foo": 1, "foo": 2, "foo": 3, "bar": 4 }
    );

    const Schema = struct {
        pub const schema: Parser.schema.Auto(@This()) = .{
            .assume_ordering = true,
            .duplicate_field_behavior = .use_last,
        };
        foo: u8,
        bar: u8,
    };
    const s = try document.as(Schema);

    try std.testing.expectEqual(Schema{ .foo = 3, .bar = 4 }, s);
}

test "error because of duplicate" {
    const Parser = zimdjson.ondemand.parserFromSlice(.default);
    const allocator = std.testing.allocator;
    var parser = Parser.init(allocator);
    defer parser.deinit();
    const document = try parser.parse(
        \\{ "foo": 1, "foo": 2, "foo": 3, "bar": 4 }
    );

    const Schema = struct {
        pub const schema: Parser.schema.Auto(@This()) = .{
            .duplicate_field_behavior = .@"error",
        };
        bar: u8,
        foo: u8,
    };

    try std.testing.expectError(error.DuplicateField, document.as(Schema));
}

test "error because of duplicate, assuming ordering" {
    const Parser = zimdjson.ondemand.parserFromSlice(.default);
    const allocator = std.testing.allocator;
    var parser = Parser.init(allocator);
    defer parser.deinit();
    const document = try parser.parse(
        \\{ "foo": 1, "foo": 2, "foo": 3, "bar": 4 }
    );

    const Schema = struct {
        pub const schema: Parser.schema.Auto(@This()) = .{
            .assume_ordering = true,
            .duplicate_field_behavior = .@"error",
        };
        foo: u8,
        bar: u8,
    };

    try std.testing.expectError(error.DuplicateField, document.as(Schema));
}

test "missing field while handling duplicate" {
    const Parser = zimdjson.ondemand.parserFromSlice(.default);
    const allocator = std.testing.allocator;
    var parser = Parser.init(allocator);
    defer parser.deinit();

    const document = try parser.parse(
        \\{ "foo": 1, "foo": 2, "foo": 3 }
    );

    const Schema = struct {
        bar: u8,
        foo: u8,
    };

    try std.testing.expectError(error.MissingField, document.asAdvanced(Schema, .{
        .duplicate_field_behavior = .use_first,
    }, allocator));

    try std.testing.expectError(error.MissingField, document.asAdvanced(Schema, .{
        .duplicate_field_behavior = .use_last,
    }, allocator));
}

test "missing field while handling duplicate, assuming ordering" {
    const Parser = zimdjson.ondemand.parserFromSlice(.default);
    const allocator = std.testing.allocator;
    var parser = Parser.init(allocator);
    defer parser.deinit();

    const document = try parser.parse(
        \\{ "foo": 1, "foo": 2, "foo": 3 }
    );

    const Schema = struct {
        foo: u8,
        bar: u8,
    };

    try std.testing.expectError(error.MissingField, document.asAdvanced(Schema, .{
        .assume_ordering = true,
        .duplicate_field_behavior = .use_first,
    }, allocator));

    try std.testing.expectError(error.MissingField, document.asAdvanced(Schema, .{
        .assume_ordering = true,
        .duplicate_field_behavior = .use_last,
    }, allocator));
}
