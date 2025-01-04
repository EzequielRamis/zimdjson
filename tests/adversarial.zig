//! This file is auto-generated with `zig build test/generate`

const std = @import("std");
const dom = @import("zimdjson").dom;
const Reader = @import("zimdjson").io.Reader(.{});
const simdjson_data = @embedFile("simdjson-data");

test "1" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "10" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/10.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "100" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/100.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1000" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1000.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1001" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1001.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1002" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1002.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1003" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1003.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1004" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1004.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1005" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1005.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1006" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1006.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1007" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1007.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1008" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1008.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1009" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1009.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "101" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/101.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1010" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1010.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1011" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1011.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1012" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1012.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1013" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1013.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1014" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1014.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1015" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1015.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1016" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1016.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1017" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1017.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1018" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1018.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1019" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1019.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "102" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/102.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1020" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1020.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1021" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1021.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1022" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1022.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1023" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1023.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1024" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1024.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1025" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1025.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1026" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1026.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1027" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1027.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1028" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1028.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1029" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1029.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "103" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/103.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1030" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1030.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1031" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1031.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1032" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1032.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1033" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1033.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1034" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1034.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1035" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1035.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1036" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1036.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1037" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1037.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1038" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1038.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1039" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1039.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "104" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/104.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1040" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1040.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1041" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1041.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1042" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1042.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1043" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1043.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1044" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1044.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1045" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1045.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1046" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1046.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1047" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1047.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1048" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1048.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1049" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1049.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "105" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/105.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1050" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1050.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1051" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1051.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1052" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1052.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1053" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1053.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1054" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1054.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1055" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1055.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1056" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1056.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1057" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1057.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1058" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1058.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1059" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1059.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "106" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/106.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1060" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1060.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1061" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1061.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1062" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1062.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1063" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1063.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1064" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1064.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1065" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1065.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1066" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1066.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1067" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1067.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1068" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1068.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1069" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1069.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "107" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/107.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1070" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1070.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1071" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1071.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1072" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1072.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1073" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1073.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1074" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1074.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1075" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1075.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1076" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1076.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1077" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1077.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1078" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1078.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1079" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1079.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "108" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/108.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1080" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1080.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1081" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1081.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1082" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1082.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1083" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1083.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1084" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1084.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1085" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1085.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1086" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1086.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1087" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1087.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1088" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1088.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1089" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1089.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "109" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/109.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1090" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1090.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1091" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1091.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1092" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1092.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1093" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1093.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1094" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1094.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1095" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1095.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1096" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1096.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1097" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1097.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1098" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1098.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1099" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1099.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "11" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/11.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "110" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/110.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1100" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1100.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1101" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1101.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1102" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1102.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1103" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1103.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1104" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1104.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1105" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1105.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1106" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1106.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1107" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1107.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1108" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1108.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1109" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1109.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "111" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/111.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1110" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1110.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1111" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1111.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1112" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1112.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1113" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1113.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1114" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1114.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1115" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1115.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1116" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1116.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1117" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1117.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1118" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1118.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1119" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1119.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "112" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/112.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1120" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1120.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1121" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1121.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1122" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1122.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1123" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1123.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1124" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1124.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1125" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1125.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1126" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1126.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1127" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1127.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1128" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1128.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1129" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1129.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "113" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/113.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1130" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1130.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1131" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1131.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1132" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1132.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1133" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1133.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1134" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1134.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1135" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1135.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1136" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1136.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1137" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1137.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1138" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1138.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1139" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1139.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "114" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/114.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1140" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1140.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1141" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1141.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1142" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1142.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1143" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1143.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1144" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1144.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1145" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1145.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1146" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1146.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1147" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1147.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1148" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1148.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1149" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1149.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "115" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/115.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1150" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1150.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1151" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1151.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1152" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1152.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1153" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1153.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1154" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1154.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1155" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1155.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1156" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1156.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1157" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1157.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1158" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1158.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1159" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1159.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "116" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/116.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1160" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1160.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1161" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1161.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1162" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1162.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1163" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1163.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1164" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1164.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1165" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1165.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1166" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1166.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1167" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1167.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1168" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1168.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1169" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1169.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "117" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/117.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1170" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1170.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1171" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1171.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1172" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1172.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1173" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1173.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1174" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1174.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1175" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1175.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1176" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1176.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1177" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1177.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1178" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1178.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1179" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1179.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "118" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/118.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1180" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1180.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1181" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1181.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1182" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1182.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1183" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1183.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1184" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1184.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1185" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1185.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1186" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1186.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1187" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1187.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1188" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1188.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1189" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1189.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "119" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/119.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1190" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1190.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1191" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1191.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1192" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1192.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1193" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1193.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1194" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1194.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1195" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1195.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1196" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1196.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1197" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1197.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1198" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1198.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1199" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1199.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "12" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/12.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "120" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/120.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1200" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1200.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1201" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1201.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1202" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1202.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1203" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1203.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1204" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1204.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1205" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1205.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1206" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1206.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1207" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1207.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1208" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1208.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1209" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1209.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "121" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/121.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1210" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1210.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1211" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1211.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1212" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1212.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1213" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1213.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1214" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1214.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1215" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1215.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1216" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1216.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1217" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1217.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1218" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1218.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1219" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1219.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "122" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/122.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1220" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1220.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1221" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1221.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1222" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1222.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1223" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1223.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1224" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1224.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1225" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1225.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1226" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1226.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1227" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1227.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1228" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1228.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1229" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1229.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "123" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/123.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1230" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1230.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1231" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1231.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1232" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1232.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1233" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1233.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1234" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1234.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1235" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1235.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1236" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1236.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1237" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1237.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1238" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1238.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1239" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1239.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "124" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/124.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1240" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1240.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1241" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1241.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1242" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1242.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1243" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1243.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1244" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1244.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1245" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1245.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1246" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1246.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1247" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1247.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1248" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1248.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1249" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1249.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "125" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/125.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1250" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1250.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1251" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1251.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1252" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1252.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1253" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1253.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1254" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1254.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1255" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1255.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1256" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1256.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1257" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1257.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1258" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1258.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1259" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1259.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "126" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/126.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1260" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1260.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1261" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1261.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1262" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1262.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1263" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1263.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1264" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1264.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1265" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1265.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1266" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1266.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1267" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1267.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1268" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1268.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1269" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1269.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "127" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/127.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1270" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1270.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1271" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1271.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1272" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1272.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1273" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1273.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1274" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1274.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1275" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1275.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1276" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1276.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1277" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1277.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1278" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1278.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1279" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1279.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "128" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/128.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1280" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1280.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1281" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1281.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1282" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1282.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1283" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1283.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1284" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1284.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1285" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1285.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1286" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1286.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1287" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1287.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1288" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1288.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1289" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1289.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "129" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/129.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1290" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1290.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1291" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1291.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1292" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1292.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1293" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1293.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1294" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1294.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1295" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1295.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1296" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1296.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1297" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1297.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1298" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1298.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1299" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1299.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "13" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/13.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "130" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/130.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1300" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1300.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1301" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1301.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1302" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1302.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1303" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1303.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1304" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1304.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1305" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1305.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1306" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1306.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1307" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1307.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1308" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1308.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1309" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1309.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "131" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/131.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1310" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1310.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1311" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1311.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1312" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1312.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1313" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1313.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1314" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1314.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1315" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1315.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1316" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1316.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1317" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1317.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1318" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1318.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1319" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1319.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "132" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/132.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1320" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1320.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1321" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1321.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1322" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1322.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1323" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1323.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1324" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1324.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1325" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1325.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1326" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1326.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1327" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1327.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1328" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1328.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1329" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1329.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "133" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/133.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1330" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1330.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1331" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1331.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1332" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1332.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1333" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1333.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1334" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1334.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1335" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1335.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1336" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1336.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1337" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1337.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1338" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1338.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1339" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1339.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "134" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/134.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1340" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1340.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1341" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1341.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1342" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1342.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1343" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1343.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1344" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1344.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1345" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1345.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1346" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1346.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1347" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1347.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1348" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1348.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1349" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1349.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "135" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/135.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1350" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1350.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1351" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1351.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1352" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1352.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1353" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1353.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1354" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1354.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1355" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1355.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1356" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1356.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1357" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1357.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1358" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1358.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1359" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1359.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "136" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/136.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1360" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1360.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1361" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1361.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1362" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1362.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1363" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1363.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1364" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1364.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1365" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1365.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1366" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1366.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1367" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1367.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1368" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1368.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1369" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1369.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "137" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/137.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1370" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1370.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1371" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1371.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1372" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1372.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1373" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1373.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1374" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1374.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1375" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1375.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1376" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1376.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1377" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1377.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1378" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1378.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1379" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1379.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "138" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/138.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1380" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1380.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1381" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1381.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1382" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1382.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1383" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1383.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1384" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1384.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1385" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1385.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1386" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1386.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1387" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1387.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1388" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1388.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1389" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1389.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "139" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/139.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1390" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1390.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1391" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1391.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1392" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1392.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1393" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1393.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1394" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1394.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1395" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1395.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1396" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1396.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1397" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1397.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1398" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1398.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1399" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1399.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "14" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/14.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "140" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/140.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1400" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1400.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1401" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1401.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1402" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1402.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1403" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1403.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1404" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1404.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1405" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1405.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1406" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1406.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1407" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1407.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1408" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1408.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1409" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1409.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "141" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/141.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1410" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1410.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1411" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1411.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1412" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1412.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1413" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1413.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1414" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1414.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1415" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1415.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1416" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1416.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1417" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1417.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1418" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1418.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1419" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1419.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "142" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/142.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1420" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1420.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1421" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1421.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1422" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1422.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1423" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1423.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1424" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1424.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1425" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1425.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1426" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1426.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1427" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1427.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1428" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1428.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1429" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1429.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "143" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/143.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1430" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1430.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1431" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1431.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1432" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1432.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1433" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1433.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1434" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1434.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1435" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1435.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1436" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1436.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1437" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1437.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1438" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1438.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1439" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1439.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "144" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/144.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1440" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1440.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1441" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1441.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1442" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1442.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1443" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1443.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1444" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1444.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1445" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1445.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1446" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1446.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1447" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1447.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1448" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1448.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1449" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1449.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "145" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/145.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1450" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1450.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1451" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1451.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1452" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1452.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1453" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1453.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1454" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1454.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1455" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1455.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1456" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1456.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "1457" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/1457.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "146" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/146.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "147" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/147.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "148" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/148.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "149" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/149.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "15" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/15.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "150" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/150.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "151" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/151.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "152" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/152.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "153" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/153.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "154" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/154.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "155" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/155.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "156" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/156.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "157" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/157.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "158" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/158.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "159" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/159.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "16" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/16.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "160" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/160.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "161" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/161.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "162" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/162.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "163" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/163.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "164" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/164.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "165" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/165.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "166" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/166.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "167" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/167.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "168" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/168.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "169" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/169.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "17" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/17.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "170" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/170.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "171" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/171.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "172" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/172.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "173" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/173.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "174" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/174.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "175" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/175.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "176" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/176.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "177" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/177.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "178" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/178.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "179" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/179.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "18" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/18.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "180" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/180.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "181" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/181.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "182" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/182.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "183" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/183.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "184" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/184.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "185" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/185.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "186" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/186.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "187" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/187.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "188" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/188.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "189" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/189.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "19" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/19.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "190" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/190.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "191" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/191.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "192" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/192.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "193" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/193.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "194" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/194.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "195" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/195.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "196" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/196.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "197" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/197.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "198" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/198.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "199" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/199.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "2" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/2.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "20" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/20.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "200" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/200.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "201" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/201.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "202" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/202.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "203" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/203.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "204" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/204.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "205" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/205.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "206" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/206.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "207" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/207.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "208" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/208.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "209" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/209.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "21" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/21.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "210" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/210.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "211" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/211.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "212" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/212.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "213" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/213.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "214" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/214.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "215" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/215.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "216" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/216.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "217" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/217.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "218" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/218.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "219" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/219.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "22" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/22.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "220" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/220.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "221" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/221.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "222" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/222.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "223" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/223.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "224" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/224.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "225" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/225.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "226" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/226.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "227" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/227.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "228" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/228.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "229" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/229.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "23" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/23.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "230" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/230.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "231" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/231.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "232" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/232.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "233" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/233.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "234" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/234.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "235" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/235.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "236" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/236.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "237" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/237.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "238" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/238.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "239" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/239.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "24" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/24.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "240" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/240.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "241" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/241.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "242" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/242.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "243" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/243.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "244" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/244.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "245" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/245.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "246" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/246.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "247" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/247.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "248" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/248.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "249" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/249.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "25" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/25.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "250" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/250.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "251" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/251.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "252" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/252.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "253" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/253.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "254" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/254.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "255" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/255.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "256" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/256.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "257" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/257.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "258" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/258.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "259" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/259.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "26" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/26.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "260" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/260.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "261" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/261.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "262" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/262.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "263" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/263.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "264" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/264.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "265" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/265.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "266" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/266.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "267" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/267.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "268" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/268.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "269" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/269.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "27" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/27.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "270" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/270.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "271" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/271.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "272" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/272.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "273" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/273.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "274" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/274.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "275" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/275.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "276" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/276.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "277" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/277.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "278" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/278.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "279" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/279.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "28" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/28.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "280" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/280.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "281" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/281.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "282" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/282.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "283" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/283.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "284" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/284.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "285" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/285.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "286" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/286.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "287" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/287.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "288" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/288.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "289" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/289.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "29" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/29.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "290" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/290.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "291" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/291.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "292" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/292.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "293" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/293.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "294" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/294.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "295" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/295.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "296" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/296.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "297" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/297.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "298" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/298.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "299" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/299.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "3" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/3.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "30" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/30.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "300" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/300.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "301" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/301.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "302" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/302.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "303" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/303.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "304" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/304.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "305" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/305.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "306" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/306.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "307" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/307.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "308" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/308.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "309" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/309.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "31" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/31.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "310" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/310.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "311" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/311.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "312" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/312.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "313" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/313.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "314" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/314.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "315" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/315.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "316" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/316.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "317" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/317.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "318" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/318.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "319" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/319.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "32" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/32.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "320" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/320.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "321" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/321.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "322" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/322.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "323" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/323.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "324" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/324.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "325" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/325.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "326" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/326.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "327" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/327.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "328" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/328.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "329" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/329.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "33" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/33.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "330" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/330.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "331" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/331.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "332" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/332.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "333" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/333.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "334" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/334.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "335" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/335.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "336" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/336.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "337" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/337.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "338" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/338.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "339" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/339.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "34" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/34.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "340" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/340.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "341" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/341.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "342" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/342.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "343" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/343.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "344" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/344.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "345" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/345.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "346" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/346.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "347" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/347.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "348" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/348.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "349" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/349.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "35" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/35.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "350" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/350.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "351" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/351.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "352" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/352.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "353" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/353.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "354" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/354.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "355" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/355.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "356" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/356.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "357" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/357.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "358" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/358.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "359" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/359.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "36" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/36.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "360" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/360.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "361" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/361.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "362" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/362.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "363" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/363.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "364" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/364.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "365" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/365.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "366" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/366.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "367" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/367.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "368" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/368.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "369" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/369.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "37" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/37.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "370" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/370.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "371" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/371.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "372" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/372.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "373" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/373.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "374" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/374.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "375" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/375.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "376" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/376.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "377" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/377.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "378" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/378.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "379" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/379.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "38" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/38.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "380" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/380.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "381" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/381.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "382" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/382.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "383" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/383.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "384" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/384.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "385" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/385.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "386" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/386.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "387" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/387.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "388" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/388.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "389" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/389.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "39" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/39.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "390" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/390.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "391" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/391.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "392" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/392.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "393" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/393.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "394" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/394.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "395" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/395.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "396" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/396.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "397" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/397.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "398" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/398.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "399" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/399.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "4" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/4.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "40" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/40.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "400" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/400.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "401" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/401.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "402" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/402.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "403" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/403.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "404" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/404.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "405" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/405.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "406" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/406.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "407" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/407.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "408" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/408.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "409" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/409.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "41" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/41.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "410" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/410.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "411" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/411.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "412" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/412.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "413" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/413.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "414" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/414.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "415" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/415.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "416" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/416.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "417" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/417.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "418" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/418.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "419" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/419.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "42" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/42.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "420" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/420.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "421" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/421.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "422" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/422.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "423" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/423.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "424" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/424.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "425" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/425.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "426" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/426.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "427" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/427.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "428" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/428.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "429" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/429.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "43" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/43.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "430" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/430.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "431" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/431.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "432" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/432.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "433" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/433.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "434" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/434.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "435" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/435.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "436" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/436.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "437" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/437.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "438" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/438.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "439" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/439.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "44" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/44.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "440" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/440.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "441" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/441.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "442" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/442.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "443" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/443.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "444" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/444.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "445" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/445.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "446" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/446.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "447" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/447.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "448" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/448.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "449" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/449.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "45" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/45.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "450" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/450.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "451" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/451.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "452" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/452.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "453" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/453.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "454" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/454.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "455" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/455.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "456" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/456.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "457" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/457.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "458" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/458.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "459" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/459.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "46" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/46.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "460" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/460.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "461" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/461.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "462" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/462.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "463" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/463.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "464" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/464.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "465" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/465.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "466" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/466.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "467" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/467.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "468" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/468.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "469" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/469.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "47" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/47.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "470" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/470.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "471" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/471.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "472" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/472.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "473" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/473.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "474" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/474.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "475" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/475.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "476" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/476.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "477" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/477.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "478" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/478.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "479" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/479.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "48" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/48.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "480" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/480.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "481" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/481.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "482" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/482.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "483" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/483.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "484" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/484.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "485" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/485.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "486" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/486.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "487" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/487.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "488" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/488.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "489" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/489.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "49" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/49.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "490" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/490.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "491" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/491.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "492" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/492.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "493" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/493.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "494" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/494.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "495" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/495.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "496" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/496.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "497" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/497.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "498" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/498.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "499" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/499.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "5" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/5.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "50" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/50.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "500" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/500.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "501" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/501.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "502" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/502.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "503" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/503.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "504" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/504.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "505" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/505.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "506" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/506.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "507" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/507.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "508" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/508.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "509" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/509.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "51" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/51.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "510" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/510.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "511" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/511.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "512" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/512.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "513" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/513.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "514" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/514.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "515" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/515.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "516" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/516.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "517" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/517.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "518" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/518.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "519" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/519.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "52" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/52.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "520" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/520.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "521" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/521.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "522" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/522.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "523" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/523.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "524" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/524.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "525" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/525.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "526" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/526.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "527" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/527.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "528" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/528.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "529" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/529.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "53" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/53.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "530" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/530.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "531" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/531.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "532" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/532.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "533" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/533.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "534" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/534.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "535" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/535.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "536" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/536.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "537" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/537.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "538" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/538.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "539" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/539.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "54" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/54.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "540" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/540.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "541" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/541.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "542" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/542.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "543" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/543.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "544" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/544.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "545" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/545.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "546" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/546.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "547" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/547.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "548" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/548.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "549" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/549.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "55" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/55.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "550" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/550.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "551" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/551.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "552" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/552.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "553" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/553.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "554" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/554.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "555" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/555.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "556" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/556.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "557" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/557.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "558" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/558.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "559" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/559.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "56" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/56.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "560" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/560.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "561" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/561.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "562" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/562.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "563" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/563.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "564" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/564.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "565" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/565.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "566" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/566.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "567" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/567.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "568" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/568.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "569" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/569.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "57" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/57.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "570" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/570.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "571" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/571.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "572" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/572.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "573" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/573.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "574" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/574.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "575" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/575.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "576" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/576.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "577" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/577.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "578" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/578.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "579" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/579.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "58" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/58.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "580" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/580.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "581" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/581.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "582" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/582.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "583" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/583.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "584" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/584.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "585" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/585.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "586" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/586.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "587" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/587.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "588" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/588.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "589" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/589.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "59" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/59.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "590" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/590.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "591" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/591.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "592" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/592.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "593" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/593.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "594" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/594.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "595" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/595.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "596" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/596.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "597" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/597.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "598" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/598.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "599" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/599.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "6" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/6.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "60" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/60.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "600" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/600.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "601" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/601.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "602" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/602.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "603" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/603.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "604" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/604.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "605" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/605.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "606" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/606.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "607" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/607.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "608" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/608.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "609" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/609.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "61" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/61.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "610" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/610.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "611" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/611.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "612" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/612.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "613" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/613.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "614" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/614.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "615" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/615.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "616" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/616.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "617" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/617.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "618" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/618.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "619" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/619.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "62" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/62.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "620" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/620.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "621" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/621.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "622" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/622.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "623" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/623.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "624" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/624.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "625" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/625.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "626" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/626.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "627" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/627.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "628" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/628.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "629" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/629.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "63" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/63.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "630" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/630.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "631" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/631.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "632" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/632.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "633" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/633.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "634" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/634.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "635" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/635.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "636" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/636.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "637" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/637.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "638" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/638.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "639" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/639.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "64" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/64.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "640" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/640.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "641" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/641.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "642" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/642.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "643" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/643.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "644" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/644.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "645" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/645.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "646" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/646.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "647" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/647.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "648" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/648.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "649" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/649.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "65" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/65.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "650" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/650.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "651" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/651.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "652" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/652.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "653" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/653.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "654" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/654.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "655" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/655.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "656" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/656.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "657" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/657.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "658" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/658.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "659" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/659.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "66" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/66.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "660" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/660.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "661" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/661.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "662" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/662.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "663" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/663.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "664" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/664.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "665" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/665.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "666" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/666.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "667" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/667.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "668" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/668.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "669" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/669.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "67" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/67.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "670" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/670.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "671" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/671.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "672" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/672.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "673" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/673.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "674" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/674.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "675" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/675.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "676" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/676.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "677" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/677.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "678" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/678.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "679" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/679.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "68" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/68.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "680" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/680.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "681" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/681.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "682" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/682.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "683" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/683.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "684" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/684.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "685" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/685.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "686" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/686.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "687" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/687.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "688" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/688.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "689" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/689.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "69" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/69.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "690" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/690.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "691" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/691.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "692" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/692.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "693" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/693.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "694" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/694.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "695" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/695.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "696" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/696.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "697" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/697.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "698" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/698.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "699" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/699.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "7" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/7.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "70" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/70.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "700" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/700.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "701" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/701.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "702" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/702.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "703" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/703.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "704" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/704.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "705" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/705.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "706" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/706.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "707" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/707.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "708" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/708.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "709" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/709.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "71" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/71.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "710" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/710.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "711" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/711.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "712" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/712.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "713" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/713.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "714" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/714.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "715" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/715.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "716" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/716.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "717" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/717.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "718" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/718.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "719" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/719.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "72" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/72.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "720" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/720.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "721" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/721.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "722" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/722.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "723" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/723.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "724" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/724.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "725" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/725.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "726" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/726.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "727" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/727.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "728" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/728.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "729" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/729.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "73" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/73.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "730" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/730.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "731" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/731.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "732" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/732.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "733" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/733.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "734" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/734.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "735" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/735.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "736" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/736.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "737" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/737.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "738" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/738.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "739" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/739.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "74" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/74.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "740" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/740.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "741" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/741.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "742" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/742.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "743" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/743.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "744" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/744.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "745" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/745.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "746" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/746.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "747" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/747.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "748" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/748.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "749" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/749.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "75" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/75.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "750" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/750.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "751" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/751.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "752" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/752.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "753" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/753.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "754" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/754.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "755" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/755.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "756" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/756.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "757" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/757.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "758" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/758.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "759" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/759.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "76" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/76.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "760" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/760.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "761" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/761.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "762" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/762.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "763" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/763.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "764" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/764.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "765" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/765.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "766" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/766.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "767" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/767.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "768" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/768.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "769" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/769.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "77" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/77.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "770" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/770.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "771" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/771.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "772" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/772.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "773" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/773.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "774" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/774.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "775" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/775.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "776" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/776.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "777" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/777.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "778" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/778.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "779" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/779.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "78" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/78.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "780" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/780.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "781" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/781.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "782" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/782.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "783" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/783.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "784" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/784.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "785" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/785.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "786" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/786.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "787" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/787.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "788" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/788.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "789" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/789.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "79" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/79.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "790" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/790.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "791" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/791.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "792" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/792.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "793" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/793.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "794" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/794.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "795" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/795.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "796" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/796.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "797" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/797.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "798" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/798.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "799" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/799.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "8" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/8.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "80" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/80.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "800" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/800.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "801" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/801.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "802" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/802.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "803" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/803.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "804" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/804.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "805" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/805.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "806" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/806.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "807" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/807.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "808" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/808.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "809" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/809.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "81" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/81.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "810" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/810.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "811" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/811.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "812" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/812.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "813" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/813.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "814" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/814.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "815" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/815.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "816" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/816.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "817" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/817.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "818" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/818.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "819" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/819.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "82" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/82.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "820" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/820.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "821" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/821.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "822" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/822.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "823" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/823.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "824" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/824.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "825" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/825.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "826" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/826.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "827" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/827.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "828" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/828.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "829" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/829.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "83" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/83.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "830" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/830.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "831" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/831.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "832" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/832.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "833" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/833.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "834" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/834.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "835" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/835.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "836" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/836.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "837" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/837.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "838" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/838.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "839" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/839.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "84" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/84.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "840" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/840.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "841" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/841.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "842" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/842.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "843" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/843.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "844" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/844.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "845" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/845.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "846" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/846.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "847" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/847.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "848" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/848.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "849" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/849.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "85" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/85.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "850" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/850.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "851" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/851.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "852" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/852.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "853" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/853.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "854" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/854.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "855" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/855.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "856" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/856.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "857" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/857.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "858" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/858.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "859" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/859.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "86" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/86.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "860" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/860.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "861" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/861.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "862" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/862.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "863" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/863.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "864" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/864.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "865" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/865.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "866" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/866.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "867" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/867.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "868" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/868.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "869" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/869.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "87" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/87.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "870" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/870.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "871" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/871.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "872" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/872.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "873" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/873.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "874" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/874.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "875" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/875.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "876" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/876.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "877" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/877.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "878" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/878.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "879" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/879.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "88" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/88.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "880" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/880.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "881" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/881.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "882" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/882.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "883" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/883.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "884" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/884.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "885" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/885.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "886" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/886.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "887" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/887.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "888" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/888.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "889" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/889.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "89" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/89.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "890" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/890.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "891" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/891.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "892" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/892.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "893" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/893.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "894" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/894.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "895" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/895.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "896" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/896.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "897" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/897.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "898" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/898.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "899" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/899.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "9" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/9.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "90" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/90.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "900" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/900.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "901" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/901.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "902" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/902.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "903" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/903.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "904" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/904.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "905" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/905.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "906" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/906.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "907" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/907.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "908" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/908.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "909" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/909.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "91" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/91.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "910" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/910.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "911" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/911.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "912" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/912.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "913" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/913.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "914" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/914.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "915" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/915.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "916" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/916.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "917" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/917.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "918" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/918.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "919" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/919.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "92" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/92.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "920" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/920.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "921" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/921.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "922" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/922.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "923" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/923.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "924" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/924.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "925" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/925.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "926" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/926.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "927" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/927.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "928" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/928.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "929" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/929.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "93" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/93.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "930" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/930.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "931" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/931.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "932" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/932.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "933" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/933.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "934" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/934.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "935" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/935.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "936" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/936.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "937" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/937.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "938" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/938.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "939" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/939.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "94" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/94.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "940" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/940.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "941" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/941.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "942" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/942.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "943" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/943.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "944" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/944.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "945" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/945.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "946" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/946.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "947" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/947.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "948" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/948.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "949" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/949.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "95" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/95.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "950" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/950.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "951" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/951.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "952" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/952.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "953" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/953.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "954" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/954.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "955" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/955.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "956" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/956.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "957" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/957.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "958" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/958.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "959" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/959.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "96" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/96.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "960" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/960.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "961" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/961.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "962" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/962.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "963" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/963.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "964" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/964.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "965" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/965.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "966" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/966.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "967" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/967.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "968" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/968.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "969" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/969.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "97" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/97.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "970" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/970.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "971" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/971.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "972" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/972.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "973" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/973.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "974" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/974.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "975" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/975.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "976" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/976.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "977" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/977.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "978" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/978.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "979" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/979.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "98" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/98.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "980" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/980.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "981" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/981.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "982" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/982.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "983" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/983.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "984" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/984.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "985" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/985.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "986" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/986.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "987" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/987.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "988" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/988.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "989" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/989.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "99" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/99.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "990" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/990.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "991" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/991.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "992" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/992.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "993" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/993.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "994" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/994.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "995" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/995.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "996" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/996.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "997" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/997.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "998" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/998.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

test "999" {
    const allocator = std.testing.allocator;
    var parser = dom.Parser(.{}).init(allocator);
    defer parser.deinit();
    const file = try std.fs.cwd().openFile(simdjson_data ++ "/jsonchecker/adversarial/issue150/999.json", .{});
    _ = parser.load(file) catch return;
    return error.MustHaveFailed;
}

