const std = @import("std");
const bench = @import("build/bench.zig");
const CommandCenter = @import("build/center.zig").CommandCenter;
const Parsers = @import("build/parsers.zig").Parsers;

pub fn build(b: *std.Build) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var center = try CommandCenter.init(allocator, b);
    defer center.deinit();

    const zimdjson = b.addModule("zimdjson", .{ .root_source_file = b.path("src/root.zig") });

    // -- Testing
    {
        var com = center.command("test", "Run all test suites");
        const com_generate = try com.sub("generate", "Generate automated tests", .{ .propagate = false });

        const debug_module = getDebugModule(b, .{
            .target = target,
            .optimize = optimize,
            .enable = com.isExecuted(),
        });
        zimdjson.addImport("debug", debug_module);

        {
            const com_float_parsing = try com.sub("float-parsing", "Run float parsing test suite", .{});
            const float_parsing = b.addTest(.{
                .root_source_file = b.path("tests/float_parsing.zig"),
                .target = target,
                .optimize = optimize,
            });
            if (com_float_parsing.with("parse_number_fxx")) |dep| {
                addEmbeddedPath(b, float_parsing, dep, "parse_number_fxx");
            }
            float_parsing.root_module.addImport("zimdjson", zimdjson);

            const run_float_parsing = b.addRunArtifact(float_parsing);
            com_float_parsing.dependOn(&run_float_parsing.step);
        }

        {
            const com_minefield = try com.sub("minefield", "Run minefield test suite", .{});
            const minefield_gen = b.addExecutable(.{
                .name = "minefield_gen",
                .root_source_file = b.path("tests/minefield_gen.zig"),
                .target = target,
            });
            const path = b.path("tests/minefield.zig");
            const run_minefield_gen = b.addRunArtifact(minefield_gen);
            run_minefield_gen.addArg(path.getPath(b));

            const minefield = b.addTest(.{
                .root_source_file = path,
                .target = target,
                .optimize = optimize,
            });
            if (com_minefield.with("simdjson-data")) |dep| {
                addEmbeddedPath(b, minefield, dep, "simdjson-data");
            }
            if (com_generate.with("simdjson-data")) |dep| {
                addEmbeddedPath(b, minefield_gen, dep, "simdjson-data");
            }
            minefield.root_module.addImport("zimdjson", zimdjson);

            const run_minefield = b.addRunArtifact(minefield);
            com_minefield.dependOn(&run_minefield.step);
            com_generate.dependOn(&run_minefield_gen.step);
        }

        {
            const com_adversarial = try com.sub("adversarial", "Run adversarial test suite", .{});
            const adversarial_gen = b.addExecutable(.{
                .name = "adversarial_gen",
                .root_source_file = b.path("tests/adversarial_gen.zig"),
                .target = target,
            });
            const path = b.path("tests/adversarial.zig");
            const run_adversarial_gen = b.addRunArtifact(adversarial_gen);
            run_adversarial_gen.addArg(path.getPath(b));

            const adversarial = b.addTest(.{
                .root_source_file = path,
                .target = target,
                .optimize = optimize,
            });
            if (com_adversarial.with("simdjson-data")) |dep| {
                addEmbeddedPath(b, adversarial, dep, "simdjson-data");
            }
            if (com_generate.with("simdjson-data")) |dep| {
                addEmbeddedPath(b, adversarial_gen, dep, "simdjson-data");
            }
            adversarial.root_module.addImport("zimdjson", zimdjson);

            const run_adversarial = b.addRunArtifact(adversarial);
            com_adversarial.dependOn(&run_adversarial.step);
            com_generate.dependOn(&run_adversarial_gen.step);
        }

        {
            const com_examples = try com.sub("examples", "Run examples test suite", .{});
            const examples_gen = b.addExecutable(.{
                .name = "examples_gen",
                .root_source_file = b.path("tests/examples_gen.zig"),
                .target = target,
            });
            const path = b.path("tests/examples.zig");
            const run_examples_gen = b.addRunArtifact(examples_gen);
            run_examples_gen.addArg(path.getPath(b));

            const examples = b.addTest(.{
                .root_source_file = path,
                .target = target,
                .optimize = optimize,
            });
            if (com_examples.with("simdjson-data")) |dep| {
                addEmbeddedPath(b, examples, dep, "simdjson-data");
            }
            if (com_generate.with("simdjson-data")) |dep| {
                addEmbeddedPath(b, examples_gen, dep, "simdjson-data");
            }
            examples.root_module.addImport("zimdjson", zimdjson);

            const run_examples = b.addRunArtifact(examples);
            com_examples.dependOn(&run_examples.step);
            com_generate.dependOn(&run_examples_gen.step);
        }
    }
    // --

    // -- Profiling
    {
        var com = center.command("profile", "Profile with Tracy");

        const tracy_module = getTracyModule(b, .{
            .target = target,
            .optimize = optimize,
            .enable = com.isExecuted(),
        });

        const profile = b.addExecutable(.{
            .name = "profile",
            .root_source_file = b.path("profile/main.zig"),
            .target = target,
            .optimize = optimize,
        });

        zimdjson.addImport("tracy", tracy_module);
        profile.root_module.addImport("zimdjson", zimdjson);
        profile.root_module.addImport("tracy", tracy_module);

        const run_profile = b.addRunArtifact(profile);
        if (b.args) |args| run_profile.addArgs(args);
        com.dependOn(&run_profile.step);
    }
    // --

    // -- Benchmarking
    {
        var com = center.command("bench", "Benchmark against simdjson");

        {
            const com_find_tweet = try com.sub("find-tweet", "Run find_tweet benchmark", .{});
            const runner = b.addExecutable(.{
                .name = com.step.name,
                .root_source_file = b.path("bench/runner.zig"),
                .target = target,
                .optimize = optimize,
            });
            if (Parsers.get(com, target, optimize)) |parsers| {
                bench.addBenchmarkSuite(runner, "indexer", &.{
                    bench.addZigBenchmark(runner, "indexer", "zimdjson", zimdjson),
                    bench.addCppBenchmark(runner, "indexer", "simdjson", parsers.simdjson, parsers.simdjson),
                });
                const run = b.addRunArtifact(runner);
                com_find_tweet.dependOn(&run.step);
            }
        }
    }
    // --
}

fn addEmbeddedPath(b: *std.Build, compile: *std.Build.Step.Compile, dep: *std.Build.Dependency, alias: []const u8) void {
    compile.root_module.addAnonymousImport(alias, .{
        .root_source_file = b.addWriteFiles().add(alias, dep.path(".").getPath(b)),
    });
}

fn getDebugModule(
    b: *std.Build,
    options: struct {
        target: std.Build.ResolvedTarget,
        optimize: std.builtin.OptimizeMode,
        enable: bool,
    },
) *std.Build.Module {
    const debug_options = b.addOptions();
    debug_options.addOption(bool, "enable_debug", options.enable);

    const debug_module = b.createModule(.{
        .root_source_file = b.path("src/debug.zig"),
        .target = options.target,
        .optimize = options.optimize,
    });
    debug_module.addImport("build_options", debug_options.createModule());
    if (!options.enable) return debug_module;

    return debug_module;
}

fn getTracyModule(
    b: *std.Build,
    options: struct {
        target: std.Build.ResolvedTarget,
        optimize: std.builtin.OptimizeMode,
        enable: bool,
    },
) *std.Build.Module {
    const tracy_options = b.addOptions();
    tracy_options.addOption(bool, "enable_tracy", options.enable);

    const tracy_module = b.createModule(.{
        .root_source_file = b.path("src/tracy.zig"),
        .target = options.target,
        .optimize = options.optimize,
    });
    tracy_module.addImport("build_options", tracy_options.createModule());
    if (!options.enable) return tracy_module;

    tracy_module.link_libc = true;
    tracy_module.linkSystemLibrary("TracyClient", .{});

    return tracy_module;
}
