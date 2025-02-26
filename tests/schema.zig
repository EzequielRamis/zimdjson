const std = @import("std");
const zimdjson = @import("zimdjson");
const Parser = zimdjson.ondemand.parserFromFile(.default);
const simdjson_data = @embedFile("simdjson-data");

test "small/adversarial" {
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
