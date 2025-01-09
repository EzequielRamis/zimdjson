//! This file is auto-generated with `zig build test/generate`

const std = @import("std");
const dom = @import("zimdjson").dom;
const Reader = @import("zimdjson").io.Reader(.{});
const simdjson_data = @embedFile("simdjson-data");

test "apache_builds" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/apache_builds.json", .{});
    _ = try parser.load(file);
}

test "canada" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/canada.json", .{});
    _ = try parser.load(file);
}

test "citm_catalog" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/citm_catalog.json", .{});
    _ = try parser.load(file);
}

test "github_events" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/github_events.json", .{});
    _ = try parser.load(file);
}

test "google_maps_api_compact_response" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/google_maps_api_compact_response.json", .{});
    _ = try parser.load(file);
}

test "google_maps_api_response" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/google_maps_api_response.json", .{});
    _ = try parser.load(file);
}

test "gsoc-2018" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/gsoc-2018.json", .{});
    _ = try parser.load(file);
}

test "instruments" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/instruments.json", .{});
    _ = try parser.load(file);
}

test "marine_ik" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/marine_ik.json", .{});
    _ = try parser.load(file);
}

test "mesh" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/mesh.json", .{});
    _ = try parser.load(file);
}

test "mesh.pretty" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/mesh.pretty.json", .{});
    _ = try parser.load(file);
}

test "numbers" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/numbers.json", .{});
    _ = try parser.load(file);
}

test "random" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/random.json", .{});
    _ = try parser.load(file);
}

test "repeat" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/repeat.json", .{});
    _ = try parser.load(file);
}

test "semanticscholar-corpus" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/semanticscholar-corpus.json", .{});
    _ = try parser.load(file);
}

test "small/adversarial" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/adversarial.json", .{});
    _ = try parser.load(file);
}

test "small/demo" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/demo.json", .{});
    _ = try parser.load(file);
}

test "small/flatadversarial" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/flatadversarial.json", .{});
    _ = try parser.load(file);
}

test "small/jsoniter_scala/che-1.geo" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/jsoniter_scala/che-1.geo.json", .{});
    _ = try parser.load(file);
}

test "small/jsoniter_scala/che-2.geo" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/jsoniter_scala/che-2.geo.json", .{});
    _ = try parser.load(file);
}

test "small/jsoniter_scala/che-3.geo" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/jsoniter_scala/che-3.geo.json", .{});
    _ = try parser.load(file);
}

test "small/smalldemo" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/smalldemo.json", .{});
    _ = try parser.load(file);
}

test "small/truenull" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/truenull.json", .{});
    _ = try parser.load(file);
}

test "tree-pretty" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/tree-pretty.json", .{});
    _ = try parser.load(file);
}

test "twitter" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/twitter.json", .{});
    _ = try parser.load(file);
}

test "twitter_api_compact_response" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/twitter_api_compact_response.json", .{});
    _ = try parser.load(file);
}

test "twitter_api_response" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/twitter_api_response.json", .{});
    _ = try parser.load(file);
}

test "twitter_timeline" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/twitter_timeline.json", .{});
    _ = try parser.load(file);
}

test "twitterescaped" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/twitterescaped.json", .{});
    _ = try parser.load(file);
}

test "update-center" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.default).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/update-center.json", .{});
    _ = try parser.load(file);
}

