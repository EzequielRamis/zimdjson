const std = @import("std");
const Command = @import("center.zig").Command;

pub const Parsers = struct {
    simdjson: *std.Build.Step.Compile,
    yyjson: *std.Build.Step.Compile,
    rapidjson: *std.Build.Step.Compile,

    pub fn get(
        command: Command,
        target: std.Build.ResolvedTarget,
        optimize: std.builtin.OptimizeMode,
    ) ?Parsers {
        const com = command;
        const b = com.step.owner;

        const simdjson_dep = com.with("simdjson") orelse return null;
        const simdjson = b.addStaticLibrary(.{
            .name = "simdjson",
            .target = target,
            .optimize = optimize,
        });
        simdjson.linkLibCpp();
        simdjson.addCSourceFile(.{
            .file = simdjson_dep.path("singleheader/simdjson.cpp"),
            .flags = &.{
                "-DSIMDJSON_IMPLEMENTATION_ICELAKE=0", // https://github.com/ziglang/zig/issues/20414
            },
        });
        simdjson.installHeadersDirectory(simdjson_dep.path("singleheader"), "", .{});

        const yyjson_dep = com.with("yyjson") orelse return null;
        const yyjson = b.addStaticLibrary(.{
            .name = "yyjson",
            .target = target,
            .optimize = optimize,
        });
        yyjson.linkLibC();
        yyjson.addCSourceFile(.{ .file = yyjson_dep.path("src/yyjson.c") });
        yyjson.installHeadersDirectory(yyjson_dep.path("src"), "", .{});

        const rapidjson_dep = com.with("rapidjson") orelse return null;
        const rapidjson = b.addStaticLibrary(.{
            .name = "rapidjson",
            .target = target,
            .optimize = optimize,
        });
        rapidjson.linkLibCpp();
        rapidjson.addCSourceFile(.{ .file = rapidjson_dep.path("include/rapidjson.cpp") });
        rapidjson.installHeadersDirectory(rapidjson_dep.path("include"), "", .{});

        return .{
            .simdjson = simdjson,
            .yyjson = yyjson,
            .rapidjson = rapidjson,
        };
    }
};
