//! This file is auto-generated with `zig build test/generate`

const std = @import("std");
const DOM = @import("zimdjson").DOM;
const SIMDJSON_DATA = @embedFile("simdjson-data");

test "apache_builds" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/apache_builds.json");
}

test "canada" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/canada.json");
}

test "citm_catalog" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/citm_catalog.json");
}

test "github_events" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/github_events.json");
}

test "google_maps_api_compact_response" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/google_maps_api_compact_response.json");
}

test "google_maps_api_response" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/google_maps_api_response.json");
}

test "gsoc-2018" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/gsoc-2018.json");
}

test "instruments" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/instruments.json");
}

test "marine_ik" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/marine_ik.json");
}

test "mesh" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/mesh.json");
}

test "mesh.pretty" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/mesh.pretty.json");
}

test "numbers" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/numbers.json");
}

test "random" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/random.json");
}

test "repeat" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/repeat.json");
}

test "semanticscholar-corpus" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/semanticscholar-corpus.json");
}

test "small/adversarial" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/small/adversarial.json");
}

test "small/demo" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/small/demo.json");
}

test "small/flatadversarial" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/small/flatadversarial.json");
}

test "small/jsoniter_scala/che-1.geo" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/small/jsoniter_scala/che-1.geo.json");
}

test "small/jsoniter_scala/che-2.geo" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/small/jsoniter_scala/che-2.geo.json");
}

test "small/jsoniter_scala/che-3.geo" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/small/jsoniter_scala/che-3.geo.json");
}

test "small/smalldemo" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/small/smalldemo.json");
}

test "small/truenull" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/small/truenull.json");
}

test "tree-pretty" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/tree-pretty.json");
}

test "twitter" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/twitter.json");
}

test "twitter_api_compact_response" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/twitter_api_compact_response.json");
}

test "twitter_api_response" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/twitter_api_response.json");
}

test "twitter_timeline" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/twitter_timeline.json");
}

test "twitterescaped" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/twitterescaped.json");
}

test "update-center" {
    const allocator = std.testing.allocator;
    var parser = DOM.Parser.init(allocator);
    defer parser.deinit();
    _ = try parser.load(SIMDJSON_DATA ++ "/jsonexamples/update-center.json");
}

