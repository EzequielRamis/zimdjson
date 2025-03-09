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
    var it = obj.iterator();
    while (it.next() catch |err| {
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
    var it = arr.iterator();
    while (it.next() catch |err| {
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
    var it = obj.iterator();
    while (try it.next()) |_| {}
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

        var arr = (try document.asArray()).iterator();
        var obj: Parser.Object = undefined;
        while (try arr.next()) |el| {
            obj = try el.asObject();
            var it = obj.iterator();
            while (try it.next()) |_| {}
        }
        try std.testing.expectEqual(error.OutOfOrderIteration, obj.at("x").err orelse return);
    }
    {
        var parser = Parser.init;
        defer parser.deinit(allocator);
        const document = try parser.parse(allocator, json);

        var arr = (try document.asArray()).iterator();
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
        var arr = (try document.asArray()).iterator();
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
        var arr = (try document.asArray()).iterator();
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

    var arr = (try document.at("coordinates").asArray()).iterator();
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

    var arr = (try document.at("coordinates").asArray()).iterator();
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

    var arr = (try document.at("coordinates").asArray()).iterator();
    while (try arr.next()) |point| {
        var obj = (try point.asObject()).iterator();
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

    var arr = (try document.at("coordinates").asArray()).iterator();
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

test "simdjson/issues/1588" {
    const json =
        \\{
        \\    "nodes" : [
        \\        {
        \\            "rotation" : [
        \\                0.16907575726509094,
        \\                0.7558803558349609,
        \\                -0.27217137813568115,
        \\                0.570947527885437
        \\            ],
        \\            "translation" : [
        \\                4.076245307922363,
        \\                5.903861999511719,
        \\                -1.0054539442062378
        \\            ]
        \\        },
        \\        {
        \\            "camera" : 0,
        \\            "rotation" : [
        \\                -0.7071067690849304,
        \\                0,
        \\                0,
        \\                0.7071067690849304
        \\            ]
        \\        },
        \\        {
        \\            "children" : [
        \\                1
        \\            ],
        \\            "translation" : [
        \\                7.358891487121582,
        \\                4.958309173583984,
        \\                6.925790786743164
        \\            ]
        \\        },
        \\        {
        \\            "mesh" : 1,
        \\            "scale" : [
        \\                4.7498908042907715,
        \\                4.7498908042907715,
        \\                4.7498908042907715
        \\            ]
        \\        }
        \\    ]
        \\}
    ;

    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator, json);

    const expected_value: []const [3]bool = &.{
        .{ true, false, true },
        .{ true, false, false },
        .{ false, false, true },
        .{ false, true, false },
    };

    var arr = (try document.at("nodes").asArray()).iterator();
    var i: usize = 0;
    while (try arr.next()) |value| : (i += 1) {
        const obj = try value.asObject();
        if (expected_value[i][0]) {
            _ = try obj.at("rotation").asArray();
        } else {
            try std.testing.expectError(error.MissingField, obj.at("rotation").asArray());
        }
        if (expected_value[i][1]) {
            _ = try obj.at("scale").asArray();
        } else {
            try std.testing.expectError(error.MissingField, obj.at("scale").asArray());
        }
        if (expected_value[i][2]) {
            _ = try obj.at("translation").asArray();
        } else {
            try std.testing.expectError(error.MissingField, obj.at("translation").asArray());
        }
    }
    try std.testing.expectEqual(4, i);
}

test "simdjson/issue/1876" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator, " [] ");

    const len = try document.getArraySize();
    var arr = (try document.asArray()).iterator();

    try std.testing.expectEqual(0, len);
    while (try arr.next()) |el| {
        _ = try el.asAny();
    }
}

test "iterate complex array count" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\{ "zero":[], "test":[ { "val1":1, "val2":2 }, { "val1":1, "val2":2 } ] }
    );

    const first_arr = try document.at("zero").asArray();
    try std.testing.expectEqual(0, try first_arr.getSize());
    var first_count: usize = 0;
    var first_it = first_arr.iterator();
    while (try first_it.next()) |_| first_count += 1;
    try std.testing.expectEqual(0, first_count);

    const second_arr = try document.at("test").asArray();
    try std.testing.expectEqual(2, try second_arr.getSize());
    var second_count: usize = 0;
    var second_it = second_arr.iterator();
    while (try second_it.next()) |_| second_count += 1;
    try std.testing.expectEqual(2, second_count);
}

test "iterate sub array count" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\ { "test":[ 1,2,3], "joe": [1,2] }
    );

    _ = try document.asObject();
    var v = document.at("test");
    var count = try v.getArraySize();
    try std.testing.expectEqual(3, count);
    v = document.at("joe");
    count = try v.getArraySize();
    try std.testing.expectEqual(2, count);
}

test "iterate array count" {
    const json =
        \\[ 1, 10, 100 ]
    ;
    const expected_value: []const u64 = &.{ 1, 10, 100 };

    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator, json);
    try std.testing.expectEqual(.array, try document.getType());
    const arr = try document.asArray();
    const count = try arr.getSize();
    try std.testing.expectEqual(expected_value.len, count);

    var i: usize = 0;
    var it = arr.iterator();
    while (try it.next()) |el| : (i += 1) {
        try std.testing.expectEqual(expected_value[i], try el.asUnsigned());
    }
    try std.testing.expectEqual(expected_value.len, i);
}

test "iterate bad array count" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\[ 1, 10 100 ]
    );

    try std.testing.expectEqual(.array, try document.getType());
    try std.testing.expectError(error.ExpectedArrayCommaOrEnd, document.getArraySize());
}

test "iterate document array count" {
    {
        var parser = Parser.init;
        defer parser.deinit(allocator);
        const document = try parser.parse(allocator,
            \\[]
        );

        try std.testing.expectEqual(.array, try document.getType());
        const count = try document.getArraySize();
        try std.testing.expectEqual(0, count);
    }
    {
        var parser = Parser.init;
        defer parser.deinit(allocator);
        const document = try parser.parse(allocator,
            \\ [-1.234, 100000000000000, null, [1,2,3], {"t":true, "f":false}]
        );

        try std.testing.expectEqual(.array, try document.getType());
        const count = try document.getArraySize();
        try std.testing.expectEqual(5, count);
    }
}

test "iterate bad document array count" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\ [1.23, 2.34
    );

    try std.testing.expectEqual(.array, try document.getType());
    try std.testing.expectError(error.ExpectedArrayCommaOrEnd, document.getArraySize());
}

test "iterate document array" {
    const json =
        \\[ 1, 10, 100 ]
    ;
    const expected_value: []const u64 = &.{ 1, 10, 100 };

    {
        var parser = Parser.init;
        defer parser.deinit(allocator);
        const document = try parser.parse(allocator, json);

        try std.testing.expectEqual(.array, try document.getType());
        const arr = try document.asArray();

        var i: usize = 0;
        var it = arr.iterator();
        while (try it.next()) |el| : (i += 1) {
            try std.testing.expectEqual(expected_value[i], try el.asUnsigned());
        }
        try std.testing.expectEqual(expected_value.len, i);
    }

    {
        var parser = Parser.init;
        defer parser.deinit(allocator);
        const document = try parser.parse(allocator, json);

        try std.testing.expectEqual(.array, try document.getType());
        var arr = try document.asArray();

        var i: usize = 0;
        var it = arr.iterator();
        while (try it.next()) |_| i += 1;
        try std.testing.expectEqual(expected_value.len, i);

        try document.reset();

        try std.testing.expectEqual(.array, try document.getType());
        arr = try document.asArray();

        i = 0;
        it = arr.iterator();
        while (try it.next()) |el| : (i += 1) {
            try std.testing.expectEqual(expected_value[i], try el.asUnsigned());
        }
        try std.testing.expectEqual(expected_value.len, i);
    }

    {
        var parser = Parser.init;
        defer parser.deinit(allocator);
        const document = try parser.parse(allocator, json);

        try std.testing.expectEqual(.array, try document.getType());
        const arr = try document.asArray();

        var i: usize = 0;
        var it = arr.iterator();
        while (try it.next()) |_| i += 1;
        try std.testing.expectEqual(expected_value.len, i);

        try arr.reset();

        i = 0;
        it = arr.iterator();
        while (try it.next()) |el| : (i += 1) {
            try std.testing.expectEqual(expected_value[i], try el.asUnsigned());
        }
        try std.testing.expectEqual(expected_value.len, i);
    }
}

test "empty rewind" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator, "[]");

    const arr = try document.asArray();
    var it = arr.iterator();
    while (try it.next()) |_| unreachable;

    try arr.reset();

    it = arr.iterator();
    while (try it.next()) |_| unreachable;
}

test "count rewind" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator, "[]");

    const arr = try document.asArray();
    try std.testing.expectEqual(0, try arr.getSize());
    try std.testing.expect(try arr.isEmpty());
}

test "simdjson/issues/1742" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\{
        \\  "code": 0,
        \\  "method": "subscribe",
        \\  "result": {
        \\    "instrument_name": "DAI_USDC",
        \\    "subscription": "trade.DAI_USDC",
        \\    "channel": "trade",
        \\    "data": [
        \\      [1,2,3,4]
        \\    ]
        \\  }
        \\}
    );

    const data = try document.at("result").at("data").asArray();
    var it = data.iterator();
    while (try it.next()) |d| {
        const arr = try d.asArray();
        try std.testing.expectEqual(4, try arr.getSize());
    }
}

test "iterate array partial children" {
    var parser = Parser.init;
    defer parser.deinit(allocator);
    const document = try parser.parse(allocator,
        \\[
        \\  0,
        \\  [],
        \\  {},
        \\  { "x": 3, "y": 33 },
        \\  { "x": 4, "y": 44 },
        \\  { "x": 5, "y": 55 },
        \\  { "x": 6, "y": 66 },
        \\  [ 7, 77, 777 ],
        \\  [ 8, 88, 888 ],
        \\  { "a": [ { "b": [ 9, 99 ], "c": 999 }, 9999 ], "d": 99999 },
        \\  10
        \\]
    );

    var i: usize = 0;
    var arr = (try document.asArray()).iterator();
    while (try arr.next()) |value| : (i += 1) {
        switch (i) {
            // After ignoring value
            0, 1, 2 => {},

            // Break after using first value in child object
            3 => {
                const obj = try value.asObject();
                var it = obj.iterator();
                while (try it.next()) |field| {
                    try std.testing.expectEqualStrings("x", try field.key.get());
                    try std.testing.expectEqual(3, try field.value.asUnsigned());
                    break;
                }
            },

            // Break without using first value in child object
            4 => {
                const obj = try value.asObject();
                var it = obj.iterator();
                while (try it.next()) |field| {
                    try std.testing.expectEqualStrings("x", try field.key.get());
                    break;
                }
            },

            // Only look up one field in child object
            5 => {
                const obj = try value.asObject();
                try std.testing.expectEqual(5, try obj.at("x").asUnsigned());
            },

            // Only look up one field in child object, but don't use it
            6 => {
                const obj = try value.asObject();
                try std.testing.expectEqual(null, obj.at("x").err);
            },

            // Break after first value in child array
            7 => {
                var child = (try value.asArray()).iterator();
                while (try child.next()) |el| {
                    try std.testing.expectEqual(7, try el.asUnsigned());
                    break;
                }
            },

            // Break without using first value in child array
            8 => {
                var child = (try value.asArray()).iterator();
                while (try child.next()) |el| {
                    try std.testing.expectEqual(null, el.err);
                    break;
                }
            },

            // Break out of multiple child loops
            9 => {
                var child1 = (try value.asObject()).iterator();
                while (try child1.next()) |c1| {
                    var child2 = (try c1.value.asArray()).iterator();
                    while (try child2.next()) |c2| {
                        var child3 = (try c2.asObject()).iterator();
                        while (try child3.next()) |c3| {
                            var child4 = (try c3.value.asArray()).iterator();
                            while (try child4.next()) |c4| {
                                try std.testing.expectEqual(9, try c4.asUnsigned());
                                break;
                            }
                            break;
                        }
                        break;
                    }
                    break;
                }
            },

            // Test the actual value
            10 => {
                try std.testing.expectEqual(10, try value.asUnsigned());
            },

            else => unreachable,
        }
    }
    try std.testing.expectEqual(11, i);
}
