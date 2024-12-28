//! This file is auto-generated with `zig build test/generate`

const std = @import("std");
const dom = @import("zimdjson").dom;
const Reader = @import("zimdjson").io.Reader(.{});
const simdjson_data = @embedFile("simdjson-data");

test "apache_builds" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/apache_builds.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "canada" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/canada.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "citm_catalog" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/citm_catalog.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "github_events" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/github_events.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "google_maps_api_compact_response" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/google_maps_api_compact_response.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "google_maps_api_response" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/google_maps_api_response.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "gsoc-2018" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/gsoc-2018.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "instruments" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/instruments.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "marine_ik" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/marine_ik.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "mesh" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/mesh.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "mesh.pretty" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/mesh.pretty.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "numbers" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/numbers.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "random" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/random.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "repeat" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/repeat.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "semanticscholar-corpus" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/semanticscholar-corpus.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "small/adversarial" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/small/adversarial.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "small/demo" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/small/demo.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "small/flatadversarial" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/small/flatadversarial.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "small/jsoniter_scala/che-1.geo" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/small/jsoniter_scala/che-1.geo.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "small/jsoniter_scala/che-2.geo" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/small/jsoniter_scala/che-2.geo.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "small/jsoniter_scala/che-3.geo" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/small/jsoniter_scala/che-3.geo.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "small/smalldemo" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/small/smalldemo.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "small/truenull" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/small/truenull.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "tree-pretty" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/tree-pretty.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "twitter" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/twitter.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "twitter_api_compact_response" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/twitter_api_compact_response.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "twitter_api_response" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/twitter_api_response.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "twitter_timeline" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/twitter_timeline.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "twitterescaped" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/twitterescaped.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

test "update-center" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const path = try std.fs.cwd().realpathAlloc(allocator, simdjson_data ++ "/jsonexamples/update-center.json");
    defer allocator.free(path);
    _ = try parser.parse(path);
}

