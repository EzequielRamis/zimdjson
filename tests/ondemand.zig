const std = @import("std");
const zimdjson = @import("zimdjson");
const simdjson_data = @embedFile("simdjson-data");
const parserFromSlice = zimdjson.ondemand.parserFromSlice(.default);
const allocator = std.testing.allocator;
const Parser = parserFromSlice;

fn expectErrorAtObjectIteration(json: []const u8, exp: anyerror) !void {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator, json);

    const obj = document.asObject() catch |err| {
        try std.testing.expectEqual(exp, err);
        return;
    };
    while (obj.next() catch |err| {
        try std.testing.expectEqual(exp, err);
        return;
    }) |el| {
        _ = el.value.asAny() catch |err| {
            try std.testing.expectEqual(exp, err);
            return;
        };
    }
}

fn expectErrorAtObjectLookup(json: []const u8, key: []const u8, exp: anyerror) !void {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator, json);
    const lookup = document.at(key);
    if (lookup.err) |err| {
        try std.testing.expectEqual(exp, err);
        return;
    }
    _ = lookup.asAny() catch |err| {
        try std.testing.expectEqual(exp, err);
    };
}

fn expectErrorAtArrayIteration(json: []const u8, exp: anyerror) !void {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator, json);

    const arr = document.asArray() catch |err| {
        try std.testing.expectEqual(exp, err);
        return;
    };
    while (arr.next() catch |err| {
        try std.testing.expectEqual(exp, err);
        return;
    }) |el| {
        _ = el.asAny() catch |err| {
            try std.testing.expectEqual(exp, err);
            return;
        };
    }
}

test "object iterate error" {
    try expectErrorAtObjectIteration(
        \\{ "a"  1, "b": 2 }
    , error.ExpectedColon);
    try expectErrorAtObjectIteration(
        \\{    : 1, "b": 2 }
    , error.ExpectedKey);
    try expectErrorAtObjectIteration(
        \\{ "a":  , "b": 2 }
    , error.ExpectedValue);
    try expectErrorAtObjectIteration(
        \\{ "a": 1  "b": 2 }
    , error.ExpectedObjectCommaOrEnd);
}

test "object iterate wrong key type error" {
    try expectErrorAtObjectIteration(
        \\{ 1:     1, "b": 2 }
    , error.ExpectedKey);
    try expectErrorAtObjectIteration(
        \\{ true:  1, "b": 2 }
    , error.ExpectedKey);
    try expectErrorAtObjectIteration(
        \\{ false: 1, "b": 2 }
    , error.ExpectedKey);
    try expectErrorAtObjectIteration(
        \\{ null:  1, "b": 2 }
    , error.ExpectedKey);
    try expectErrorAtObjectIteration(
        \\{ []:    1, "b": 2 }
    , error.ExpectedKey);
    try expectErrorAtObjectIteration(
        \\{ {}:    1, "b": 2 }
    , error.ExpectedKey);
}

test "object iterate unclosed error" {
    try expectErrorAtObjectIteration(
        \\{ "a": 1,
    , error.ExpectedKey);
    try expectErrorAtObjectIteration(
        \\{ "a": 1
    , error.ExpectedObjectCommaOrEnd);
    try expectErrorAtObjectIteration(
        \\{ "a":
    , error.ExpectedValue);
    try expectErrorAtObjectIteration(
        \\{
    , error.ExpectedKey);
}

test "object iterate incomplete error" {
    try expectErrorAtObjectIteration(
        \\{ "x": { "a": 1, }
    , error.ExpectedObjectCommaOrEnd);
    try expectErrorAtObjectIteration(
        \\{ "x": { "a": 1  }
    , error.ExpectedObjectCommaOrEnd);
    try expectErrorAtObjectIteration(
        \\{ "x": { "a":    }
    , error.ExpectedObjectCommaOrEnd);
    try expectErrorAtObjectIteration(
        \\{ "x": {         }
    , error.ExpectedObjectCommaOrEnd);
}

test "object lookup error" {
    try expectErrorAtObjectLookup(
        \\{ "a"  1, "b": 2 }
    , "a", error.ExpectedColon);
    try expectErrorAtObjectLookup(
        \\{    : 1, "b": 2 }
    , "a", error.ExpectedKey);
    try expectErrorAtObjectLookup(
        \\{ "a":  , "b": 2 }
    , "a", error.ExpectedValue);
}

test "object lookup miss error" {
    try expectErrorAtObjectLookup(
        \\{ "a"  1, "b": 2 }
    , "b", error.ExpectedColon);
    try expectErrorAtObjectLookup(
        \\{    : 1, "b": 2 }
    , "b", error.ExpectedKey);
    // try expectErrorAtObjectLookup(
    //     \\{ "a":  , "b": 2 }
    // , "b", error.ExpectedObjectCommaOrEnd);
    try expectErrorAtObjectLookup(
        \\{ "a": 1  "b": 2 }
    , "b", error.ExpectedObjectCommaOrEnd);
}

test "object lookup miss wrong key type error" {
    try expectErrorAtObjectLookup(
        \\{ 1:     1, "b": 2 }
    , "b", error.ExpectedKey);
    try expectErrorAtObjectLookup(
        \\{ true:  1, "b": 2 }
    , "b", error.ExpectedKey);
    try expectErrorAtObjectLookup(
        \\{ false: 1, "b": 2 }
    , "b", error.ExpectedKey);
    try expectErrorAtObjectLookup(
        \\{ null:  1, "b": 2 }
    , "b", error.ExpectedKey);
    try expectErrorAtObjectLookup(
        \\{ []:    1, "b": 2 }
    , "b", error.ExpectedKey);
    try expectErrorAtObjectLookup(
        \\{ {}:    1, "b": 2 }
    , "b", error.ExpectedKey);
}

test "object lookup miss next error" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\{ "a": 1  "b": 2 }
    );
    const obj = try document.asObject();
    try std.testing.expectEqual(1, try obj.at("a").asUnsigned());
    try std.testing.expectEqual(error.ExpectedObjectCommaOrEnd, obj.at("b").err orelse return);
}

test "array iterate error" {
    try expectErrorAtArrayIteration(
        \\[1 1]
    , error.ExpectedArrayCommaOrEnd);
    try expectErrorAtArrayIteration(
        \\[1,,1]
    , error.ExpectedValue);
    try expectErrorAtArrayIteration(
        \\[,]
    , error.ExpectedValue);
    try expectErrorAtArrayIteration(
        \\[,,]
    , error.ExpectedValue);
}

test "array iterate unclosed error" {
    try expectErrorAtArrayIteration(
        \\[,
    , error.ExpectedValue);
    try expectErrorAtArrayIteration(
        \\[1
    , error.ExpectedArrayCommaOrEnd);
    try expectErrorAtArrayIteration(
        \\[,,
    , error.ExpectedValue);
    try expectErrorAtArrayIteration(
        \\[1
    , error.ExpectedArrayCommaOrEnd);
    try expectErrorAtArrayIteration(
        \\[
    , error.ExpectedValue);
}

test "simdjson/issues/2084" {
    const json =
        \\{"foo": "bar"}
    ;
    {
        var parser = Parser.init;
        defer parser.deinit(allocator);
        const document = try parser.parse(allocator, json);

        _ = try document.at("foo").asString().get();
        try std.testing.expectError(error.OutOfOrderIteration, document.asAny());
    }
    {
        var parser = Parser.init;
        defer parser.deinit(allocator);
        const document = try parser.parse(allocator, json);

        _ = try document.at("foo").asString().get();
        try document.reset();
        _ = try document.asAny();
    }
}

test "out of order top level object iteration error" {
    const json =
        \\{ "x": 1, "y": 2 }
    ;
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator, json);

    const obj = try document.asObject();
    while (try obj.next()) |_| {}
    try std.testing.expectError(error.OutOfOrderIteration, document.asObject());
}

test "out of order object index child error" {
    const json =
        \\[ { "x": 1, "y": 2 } ]
    ;
    {
        var parser = Parser.init;
        defer parser.deinit(allocator);
        const document = try parser.parse(allocator, json);

        const arr = try document.asArray();
        var obj: Parser.Object = undefined;
        while (try arr.next()) |el| {
            obj = try el.asObject();
            while (try obj.next()) |_| {}
        }
        try std.testing.expectEqual(error.OutOfOrderIteration, obj.at("x").err orelse return);
    }
    {
        var parser = Parser.init;
        defer parser.deinit(allocator);
        const document = try parser.parse(allocator, json);

        const arr = try document.asArray();
        var obj: Parser.Value = undefined;
        while (try arr.next()) |el| {
            obj = el;
            try std.testing.expectEqual(null, obj.at("x").err);
        }
        try std.testing.expectEqual(error.OutOfOrderIteration, obj.at("x").err orelse return);
    }
}

test "out of order object index sibling error" {
    const json =
        \\[ { "x": 0, "y": 2 }, { "x": 1, "y": 4 } ]
    ;
    {
        var parser = Parser.init;
        defer parser.deinit(allocator);
        const document = try parser.parse(allocator, json);

        var last_obj: Parser.Object = undefined;
        var i: u64 = 0;
        const arr = try document.asArray();
        while (try arr.next()) |el| : (i += 1) {
            const obj = try el.asObject();
            const x = try obj.at("x").asUnsigned();
            try std.testing.expectEqual(i, x);
            if (i > 0) {
                try std.testing.expectEqual(error.OutOfOrderIteration, last_obj.at("x").err orelse return);
                break;
            }
            last_obj = obj;
        }
    }
    {
        var parser = Parser.init;
        defer parser.deinit(allocator);
        const document = try parser.parse(allocator, json);

        var last_obj: Parser.Value = undefined;
        var i: u64 = 0;
        const arr = try document.asArray();
        while (try arr.next()) |el| : (i += 1) {
            const x = try el.at("x").asUnsigned();
            try std.testing.expectEqual(i, x);
            if (i > 0) {
                try std.testing.expectEqual(error.OutOfOrderIteration, last_obj.at("x").err orelse return);
                break;
            }
            last_obj = el;
        }
    }
}

test "in order object index" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\{ "coordinates": [{ "x": 1.1, "y": 2.2, "z": 3.3 }] }
    );

    var x: f64 = 0.0;
    var y: f64 = 0.0;
    var z: f64 = 0.0;

    const arr = try document.at("coordinates").asArray();
    while (try arr.next()) |point| {
        x += try point.at("x").asFloat();
        y += try point.at("y").asFloat();
        z += try point.at("z").asFloat();
    }

    try std.testing.expectEqual(1.1, x);
    try std.testing.expectEqual(2.2, y);
    try std.testing.expectEqual(3.3, z);
}

test "out of order object index" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\{ "coordinates": [{ "x": 1.1, "y": 2.2, "z": 3.3 }] }
    );

    var x: f64 = 0.0;
    var y: f64 = 0.0;
    var z: f64 = 0.0;

    const arr = try document.at("coordinates").asArray();
    while (try arr.next()) |point| {
        z += try point.at("z").asFloat();
        x += try point.at("x").asFloat();
        y += try point.at("y").asFloat();
    }

    try std.testing.expectEqual(1.1, x);
    try std.testing.expectEqual(2.2, y);
    try std.testing.expectEqual(3.3, z);
}

test "for each object field" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\{ "coordinates": [{ "x": 1.1, "y": 2.2, "z": 3.3 }] }
    );

    var x: f64 = 0.0;
    var y: f64 = 0.0;
    var z: f64 = 0.0;

    const arr = try document.at("coordinates").asArray();
    while (try arr.next()) |point| {
        const obj = try point.asObject();
        while (try obj.next()) |field| {
            if (std.mem.eql(u8, try field.key.get(), "z"))
                z += try field.value.asFloat()
            else if (std.mem.eql(u8, try field.key.get(), "x"))
                x += try field.value.asFloat()
            else if (std.mem.eql(u8, try field.key.get(), "y"))
                y += try field.value.asFloat();
        }
    }

    try std.testing.expectEqual(1.1, x);
    try std.testing.expectEqual(2.2, y);
    try std.testing.expectEqual(3.3, z);
}

test "use values out of order after array" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\{ "coordinates": [{ "x": 1.1, "y": 2.2, "z": 3.3 }] }
    );

    var x: Parser.Value = undefined;
    var y: Parser.Value = undefined;
    var z: Parser.Value = undefined;

    const arr = try document.at("coordinates").asArray();
    while (try arr.next()) |point| {
        x = point.at("x");
        y = point.at("y");
        z = point.at("z");
    }

    try std.testing.expectEqual(1.1, try x.asFloat());
    try std.testing.expectEqual(3.3, try z.asFloat());
    try std.testing.expectEqual(2.2, try y.asFloat());
}

test "use object multiple times out of order" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\{ "coordinates": { "x": 1.1, "y": 2.2, "z": 3.3 } }
    );

    var x: Parser.Value = undefined;
    var y: Parser.Value = undefined;
    var z: Parser.Value = undefined;

    x = document.at("coordinates").at("x");
    y = document.at("coordinates").at("y");
    z = document.at("coordinates").at("z");

    try std.testing.expectEqual(1.1, try x.asFloat());
    try std.testing.expectEqual(3.3, try z.asFloat());
    try std.testing.expectEqual(2.2, try y.asFloat());
}
