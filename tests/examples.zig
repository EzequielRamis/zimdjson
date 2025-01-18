//! This file is auto-generated with `zig build test/generate`

const std = @import("std");
const dom = @import("zimdjson").dom;
const Reader = @import("zimdjson").io.Reader(.{});
const simdjson_data = @embedFile("simdjson-data");

test "apache_builds" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/apache_builds.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "canada" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/canada.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "citm_catalog" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/citm_catalog.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "github_events" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/github_events.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "google_maps_api_compact_response" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/google_maps_api_compact_response.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "google_maps_api_response" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/google_maps_api_response.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "gsoc-2018" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/gsoc-2018.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "instruments" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/instruments.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "marine_ik" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/marine_ik.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "mesh" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/mesh.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "mesh.pretty" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/mesh.pretty.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "numbers" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/numbers.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "random" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/random.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "repeat" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/repeat.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "semanticscholar-corpus" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/semanticscholar-corpus.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "small/adversarial" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/adversarial.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "small/demo" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/demo.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "small/flatadversarial" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/flatadversarial.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "small/jsoniter_scala/che-1.geo" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/jsoniter_scala/che-1.geo.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "small/jsoniter_scala/che-2.geo" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/jsoniter_scala/che-2.geo.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "small/jsoniter_scala/che-3.geo" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/jsoniter_scala/che-3.geo.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "small/smalldemo" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/smalldemo.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "small/truenull" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/truenull.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "tree-pretty" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/tree-pretty.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "twitter" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/twitter.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "twitter_api_compact_response" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/twitter_api_compact_response.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "twitter_api_response" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/twitter_api_response.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "twitter_timeline" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/twitter_timeline.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "twitterescaped" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/twitterescaped.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

test "update-center" {
    const allocator = std.testing.allocator;
    var parser = dom.parserFromFile(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/update-center.json", .{});
    defer file.close();
    _ = try parser.parse(file.reader());
}

