const std = @import("std");

pub const Parsers = struct {
    simdjson: *std.Build.Step.Compile,
    yyjson: *std.Build.Step.Compile,
    rapidjson: *std.Build.Step.Compile,

    pub fn get(
        b: *std.Build,
        target: std.Build.ResolvedTarget,
        optimize: std.builtin.OptimizeMode,
    ) ?Parsers {
        const simdjson_dep = b.lazyDependency("simdjson", .{}) orelse return null;
        const simdjson = b.addLibrary(.{
            .linkage = .static,
            .name = "simdjson",
            .root_module = b.createModule(.{
                .root_source_file = null,
                .target = target,
                .optimize = optimize,
            }),
        });
        simdjson.linkLibCpp();
        simdjson.addCSourceFile(.{
            .file = simdjson_dep.path("singleheader/simdjson.cpp"),
            .flags = &.{
                "-DSIMDJSON_IMPLEMENTATION_ICELAKE=0", // https://github.com/ziglang/zig/issues/20414
            },
        });
        simdjson.installHeadersDirectory(simdjson_dep.path("singleheader"), "", .{});

        const yyjson_dep = b.lazyDependency("yyjson", .{}) orelse return null;
        const yyjson = b.addLibrary(.{
            .linkage = .static,
            .name = "yyjson",
            .root_module = b.createModule(.{
                .root_source_file = null,
                .target = target,
                .optimize = optimize,
            }),
        });
        yyjson.linkLibC();
        yyjson.addCSourceFile(.{ .file = yyjson_dep.path("src/yyjson.c") });
        yyjson.installHeadersDirectory(yyjson_dep.path("src"), "", .{});

        const rapidjson_dep = b.lazyDependency("rapidjson", .{}) orelse return null;
        const rapidjson = b.addLibrary(.{
            .linkage = .static,
            .name = "rapidjson",
            .root_module = b.createModule(.{
                .root_source_file = null,
                .target = target,
                .optimize = optimize,
            }),
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
