//! This file is auto-generated with `zig build test/generate`

const std = @import("std");
const zimdjson = @import("zimdjson");
const Parser = zimdjson.dom.StreamParser(.default);
const simdjson_data = @embedFile("simdjson-data");

test "apache_builds" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/apache_builds.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "canada" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/canada.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "citm_catalog" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/citm_catalog.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "github_events" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/github_events.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "google_maps_api_compact_response" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/google_maps_api_compact_response.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "google_maps_api_response" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/google_maps_api_response.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "gsoc-2018" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/gsoc-2018.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "instruments" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/instruments.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "marine_ik" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/marine_ik.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "mesh" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/mesh.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "mesh.pretty" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/mesh.pretty.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "numbers" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/numbers.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "random" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/random.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "repeat" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/repeat.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "semanticscholar-corpus" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/semanticscholar-corpus.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "small/adversarial" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/adversarial.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "small/demo" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/demo.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "small/flatadversarial" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/flatadversarial.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "small/jsoniter_scala/che-1.geo" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/jsoniter_scala/che-1.geo.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "small/jsoniter_scala/che-2.geo" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/jsoniter_scala/che-2.geo.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "small/jsoniter_scala/che-3.geo" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/jsoniter_scala/che-3.geo.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "small/smalldemo" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/smalldemo.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "small/truenull" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/small/truenull.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "tree-pretty" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/tree-pretty.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "twitter" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/twitter.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "twitter_api_compact_response" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/twitter_api_compact_response.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "twitter_api_response" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/twitter_api_response.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "twitter_timeline" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/twitter_timeline.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "twitterescaped" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/twitterescaped.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

test "update-center" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonexamples/update-center.json", .{});
    defer file.close();
    _ = try parser.parseFromReader(allocator, file.reader().any());
}

