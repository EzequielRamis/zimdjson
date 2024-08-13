const std = @import("std");
const Command = @import("center.zig").Command;

pub const Parsers = struct {
    simdjson: *std.Build.Step.Compile,
    yyjson: *std.Build.Step.Compile,
    rapidjson: *std.Build.Step.Compile,
    nlohmann: *std.Build.Step.Compile,
    sajson: *std.Build.Step.Compile,
    boost: *std.Build.Step.Compile,
    glaze: *std.Build.Step.Compile,
    daw: *std.Build.Step.Compile,
    json_struct: *std.Build.Step.Compile,

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
        simdjson.addCSourceFile(.{ .file = simdjson_dep.path("singleheader/simdjson.cpp") });
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
        rapidjson.installHeadersDirectory(rapidjson_dep.path("include/rapidjson"), "", .{});

        const nlohmann_dep = com.with("nlohmann") orelse return null;
        const nlohmann = b.addStaticLibrary(.{
            .name = "nlohmann",
            .target = target,
            .optimize = optimize,
        });
        nlohmann.linkLibCpp();
        nlohmann.installHeadersDirectory(nlohmann_dep.path("include/nlohmann"), "", .{});

        const sajson_dep = com.with("sajson") orelse return null;
        const sajson = b.addStaticLibrary(.{
            .name = "sajson",
            .target = target,
            .optimize = optimize,
        });
        sajson.linkLibCpp();
        sajson.installHeadersDirectory(sajson_dep.path("include"), "", .{});

        const boost_dep = com.with("boost") orelse return null;
        const boost = b.addStaticLibrary(.{
            .name = "boost",
            .target = target,
            .optimize = optimize,
        });
        boost.linkLibCpp();
        boost.installHeadersDirectory(boost_dep.path("include/boost"), "", .{});

        const glaze_dep = com.with("glaze") orelse return null;
        const glaze = b.addStaticLibrary(.{
            .name = "glaze",
            .target = target,
            .optimize = optimize,
        });
        glaze.linkLibCpp();
        glaze.installHeadersDirectory(glaze_dep.path("include/glaze"), "", .{});

        const daw_dep = com.with("daw_json_link") orelse return null;
        const daw = b.addStaticLibrary(.{
            .name = "daw_json_link",
            .target = target,
            .optimize = optimize,
        });
        daw.linkLibCpp();
        daw.installHeadersDirectory(daw_dep.path("include/daw"), "", .{});

        const json_struct_dep = com.with("json_struct") orelse return null;
        const json_struct = b.addStaticLibrary(.{
            .name = "json_struct",
            .target = target,
            .optimize = optimize,
        });
        json_struct.linkLibCpp();
        json_struct.installHeadersDirectory(json_struct_dep.path("include/json_struct"), "", .{});

        return .{
            .simdjson = simdjson,
            .yyjson = yyjson,
            .rapidjson = rapidjson,
            .nlohmann = nlohmann,
            .sajson = sajson,
            .boost = boost,
            .glaze = glaze,
            .daw = daw,
            .json_struct = json_struct,
        };
    }
};
