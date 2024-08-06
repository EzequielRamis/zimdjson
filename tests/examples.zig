//! This file is auto-generated with `zig build test/generate`

const std = @import("std");
const DOM = @import("zimdjson").DOM;
const Reader = @import("zimdjson").io.FileReader;
const SIMDJSON_DATA = @embedFile("simdjson-data");

test "apache_builds" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/apache_builds.json");
    _ = try parser.parse(file);
}

test "canada" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/canada.json");
    _ = try parser.parse(file);
}

test "citm_catalog" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/citm_catalog.json");
    _ = try parser.parse(file);
}

test "github_events" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/github_events.json");
    _ = try parser.parse(file);
}

test "google_maps_api_compact_response" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/google_maps_api_compact_response.json");
    _ = try parser.parse(file);
}

test "google_maps_api_response" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/google_maps_api_response.json");
    _ = try parser.parse(file);
}

test "gsoc-2018" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/gsoc-2018.json");
    _ = try parser.parse(file);
}

test "instruments" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/instruments.json");
    _ = try parser.parse(file);
}

test "marine_ik" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/marine_ik.json");
    _ = try parser.parse(file);
}

test "mesh" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/mesh.json");
    _ = try parser.parse(file);
}

test "mesh.pretty" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/mesh.pretty.json");
    _ = try parser.parse(file);
}

test "numbers" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/numbers.json");
    _ = try parser.parse(file);
}

test "random" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/random.json");
    _ = try parser.parse(file);
}

test "repeat" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/repeat.json");
    _ = try parser.parse(file);
}

test "semanticscholar-corpus" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/semanticscholar-corpus.json");
    _ = try parser.parse(file);
}

test "small/adversarial" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/small/adversarial.json");
    _ = try parser.parse(file);
}

test "small/demo" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/small/demo.json");
    _ = try parser.parse(file);
}

test "small/flatadversarial" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/small/flatadversarial.json");
    _ = try parser.parse(file);
}

test "small/jsoniter_scala/che-1.geo" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/small/jsoniter_scala/che-1.geo.json");
    _ = try parser.parse(file);
}

test "small/jsoniter_scala/che-2.geo" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/small/jsoniter_scala/che-2.geo.json");
    _ = try parser.parse(file);
}

test "small/jsoniter_scala/che-3.geo" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/small/jsoniter_scala/che-3.geo.json");
    _ = try parser.parse(file);
}

test "small/smalldemo" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/small/smalldemo.json");
    _ = try parser.parse(file);
}

test "small/truenull" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/small/truenull.json");
    _ = try parser.parse(file);
}

test "tree-pretty" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/tree-pretty.json");
    _ = try parser.parse(file);
}

test "twitter" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/twitter.json");
    _ = try parser.parse(file);
}

test "twitter_api_compact_response" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/twitter_api_compact_response.json");
    _ = try parser.parse(file);
}

test "twitter_api_response" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/twitter_api_response.json");
    _ = try parser.parse(file);
}

test "twitter_timeline" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/twitter_timeline.json");
    _ = try parser.parse(file);
}

test "twitterescaped" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/twitterescaped.json");
    _ = try parser.parse(file);
}

test "update-center" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser(.{}).init(allocator);
    defer parser.deinit();
    var reader = Reader.init(allocator);
    defer reader.deinit();
    const file = try reader.from(std.fs.cwd(), SIMDJSON_DATA ++ "/jsonexamples/update-center.json");
    _ = try parser.parse(file);
}

