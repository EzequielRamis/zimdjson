//! This file is auto-generated with `zig build tests/generate`

const std = @import("std");
const zimdjson = @import("zimdjson");
const Parser = zimdjson.dom.StreamParser(.default);
const data_path = @import("simdjson-data").path;

test "apache_builds" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/apache_builds.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "canada" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/canada.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "citm_catalog" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/citm_catalog.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "github_events" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/github_events.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "google_maps_api_compact_response" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/google_maps_api_compact_response.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "google_maps_api_response" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/google_maps_api_response.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "gsoc-2018" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/gsoc-2018.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "instruments" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/instruments.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "marine_ik" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/marine_ik.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "mesh" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/mesh.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "mesh.pretty" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/mesh.pretty.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "numbers" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/numbers.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "random" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/random.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "repeat" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/repeat.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "semanticscholar-corpus" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/semanticscholar-corpus.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "small/adversarial" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/small/adversarial.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "small/demo" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/small/demo.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "small/flatadversarial" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/small/flatadversarial.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "small/jsoniter_scala/che-1.geo" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/small/jsoniter_scala/che-1.geo.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "small/jsoniter_scala/che-2.geo" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/small/jsoniter_scala/che-2.geo.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "small/jsoniter_scala/che-3.geo" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/small/jsoniter_scala/che-3.geo.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "small/smalldemo" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/small/smalldemo.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "small/truenull" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/small/truenull.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "tree-pretty" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/tree-pretty.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "twitter" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/twitter.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "twitter_api_compact_response" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/twitter_api_compact_response.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "twitter_api_response" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/twitter_api_response.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "twitter_timeline" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/twitter_timeline.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "twitterescaped" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/twitterescaped.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}

test "update-center" {
    const allocator = std.testing.allocator;
    var parser = Parser.init;
    defer parser.deinit(std.testing.io, allocator);
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, data_path ++ "/jsonexamples/update-center.json", .{});
    defer file.close(std.testing.io);
    var reader = file.reader(std.testing.io, &.{});
    _ = try parser.parseFromReader(std.testing.io, allocator, &reader.interface);
}
