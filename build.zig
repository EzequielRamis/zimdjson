const std = @import("std");

pub fn build(b: *std.Build) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zimdjson = b.addModule("zimdjson", .{ .root_source_file = b.path("src/main.zig") });

    // -- Testing
    const test_step = b.step("test", "Run all unit tests");

    var lazy_simdjson_data: ?*std.Build.Dependency = null;
    var lazy_float_data: ?*std.Build.Dependency = null;

    var args = try std.process.argsWithAllocator(alloc);
    defer args.deinit();
    while (args.next()) |a| {
        if (std.mem.startsWith(u8, a, "test")) lazy_simdjson_data = b.lazyDependency("simdjson-data", .{});
        if (std.mem.eql(u8, a, "test") or
            std.mem.eql(u8, a, "test/float-parsing")) lazy_float_data = b.lazyDependency("parse_number_fxx", .{});
    }

    const minefield_gen = b.addExecutable(.{
        .name = "minefield_gen",
        .root_source_file = b.path("tests/minefield_gen.zig"),
        .target = b.host,
    });
    if (lazy_simdjson_data) |dep| addSimdjsonDataPath(b, &minefield_gen.root_module, dep);
    const run_minefield_gen = b.addRunArtifact(minefield_gen);
    _ = run_minefield_gen.addArg(b.path("tests/minefield.zig").getPath(b));

    inline for ([_]struct { step: []const u8, name: []const u8, path: []const u8 }{
        .{ .step = "test/minefield", .name = "Minefield", .path = "tests/minefield.zig" },
        .{ .step = "test/float-parsing", .name = "Float parsing", .path = "tests/parse_float.zig" },
    }) |t| {
        const unit_test = b.addTest(.{
            .root_source_file = b.path(t.path),
            .target = target,
            .optimize = optimize,
        });
        unit_test.root_module.addImport("zimdjson", zimdjson);

        if (lazy_simdjson_data) |dep| addSimdjsonDataPath(b, &unit_test.root_module, dep);

        if (lazy_float_data) |dep| {
            unit_test.root_module.addAnonymousImport("parse_number_fxx", .{
                .root_source_file = b.addWriteFiles().add(
                    "parse_number_fxx.txt",
                    dep.path(".").getPath(b),
                ),
            });
        }

        const run_test = b.addRunArtifact(unit_test);
        const run_test_step = b.step(t.step, "Run " ++ t.name ++ " unit tests");
        run_test_step.dependOn(&run_test.step);
        test_step.dependOn(&run_test.step);
        if (std.mem.eql(u8, t.step, "test/minefield")) {
            run_test.step.dependOn(&run_minefield_gen.step);
        }
    }
    // --

    // -- Benchmarking
    // const simdjson_dep = b.dependency("simdjson", .{});
    // const simdjson_cpp =
    //     simdjson_dep.path("singleheader/simdjson.cpp");
    // const simdjson_h = simdjson_dep.path("singleheader/simdjson.h");
    // const simdjson = b.addStaticLibrary(.{
    //     .name = "simdjson",
    //     .target = target,
    //     .optimize = .ReleaseFast,
    // });
    // simdjson.linkLibCpp();
    // simdjson.addCSourceFile(.{ .file = simdjson_cpp });
    // simdjson.installHeader(simdjson_h, "simdjson.h");
    // const bench_step = b.step("bench", "Benchmark against simdjson");
    // bench_step.dependOn(&simdjson.step);
    // --

    // -- C API
    // const lib = b.addStaticLibrary(.{
    //     .name = "zimdjson",
    //     .root_source_file = b.path("src/c.zig"),
    //     .target = target,
    //     .optimize = optimize,
    // });
    // b.installArtifact(lib);
    // --
}

fn addSimdjsonDataPath(b: *std.Build, module: *std.Build.Module, dep: *std.Build.Dependency) void {
    module.addAnonymousImport("simdjson-data", .{
        .root_source_file = b.addWriteFiles().add(
            "simdjson-data.txt",
            dep.path(".").getPath(b),
        ),
    });
}
