const std = @import("std");
const bench = @import("build/bench.zig");
const cc = @import("build/center.zig");
const CommandCenter = cc.CommandCenter;
const Parsers = @import("build/parsers.zig").Parsers;

pub fn build(b: *std.Build) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var center = try CommandCenter.init(allocator, b);
    defer center.deinit();

    const zimdjson = getZimdjsonModule(b, .{
        .target = target,
        .optimize = optimize,
    });
    b.modules.put(b.dupe("zimdjson"), zimdjson) catch @panic("OOM");

    // -- Testing
    {
        var com = center.command("test", "Run all test suites");
        const com_generate = try com.sub("generate", "Generate automated tests", .{ .propagate = false });

        const debugged_zimdjson = getZimdjsonModule(b, .{
            .target = target,
            .optimize = optimize,
            .enable_debug = true,
        });

        {
            const com_float_parsing = try com.sub("float-parsing", "Run 'float parsing' test suite", .{});
            const float_parsing = b.addTest(.{
                .root_source_file = b.path("tests/float_parsing.zig"),
                .target = target,
                .optimize = optimize,
            });
            if (com_float_parsing.with("parse_number_fxx")) |dep| {
                addEmbeddedPath(b, float_parsing, dep, "parse_number_fxx");
            }
            float_parsing.root_module.addImport("zimdjson", debugged_zimdjson);

            const run_float_parsing = b.addRunArtifact(float_parsing);
            com_float_parsing.dependOn(&run_float_parsing.step);
        }

        {
            const com_minefield = try com.sub("minefield", "Run 'minefield' test suite", .{});
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
            minefield.root_module.addImport("zimdjson", debugged_zimdjson);

            const run_minefield = b.addRunArtifact(minefield);
            com_minefield.dependOn(&run_minefield.step);
            com_generate.dependOn(&run_minefield_gen.step);
        }

        {
            const com_adversarial = try com.sub("adversarial", "Run 'adversarial' test suite", .{});
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
            adversarial.root_module.addImport("zimdjson", debugged_zimdjson);

            const run_adversarial = b.addRunArtifact(adversarial);
            com_adversarial.dependOn(&run_adversarial.step);
            com_generate.dependOn(&run_adversarial_gen.step);
        }

        {
            const com_examples = try com.sub("examples", "Run 'examples' test suite", .{});
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
            examples.root_module.addImport("zimdjson", debugged_zimdjson);

            const run_examples = b.addRunArtifact(examples);
            com_examples.dependOn(&run_examples.step);
            com_generate.dependOn(&run_examples_gen.step);
        }
    }
    // --

    const use_cwd = b.option(bool, "use-cwd",
        \\Prefix the file path with the current directory instead
        \\                               of simdjson/simdjson-data (default: no)
    ) orelse false;
    var path_buf: [1024]u8 = undefined;

    // -- Benchmarking
    {
        {
            const com = center.command("bench/indexer", "Run 'indexer' benchmark");
            const parsers = Parsers.get(com, target, optimize);
            const file_path = try getProvidedPath(com, &path_buf, use_cwd);

            if (parsers) |p| {
                // var suite_ondemand = bench.Suite("indexer"){ .zimdjson = zimdjson, .simdjson = p.simdjson, .target = target, .optimize = optimize };
                // const runner_ondemand = suite_ondemand.create(
                //     &.{
                //         suite_ondemand.addZigBenchmark("zimdjson_ondemand"),
                //         suite_ondemand.addCppBenchmark("simdjson_ondemand", p.simdjson),
                //     },
                //     file_path,
                // );
                var suite_dom = bench.Suite("indexer"){ .zimdjson = zimdjson, .simdjson = p.simdjson, .target = target, .optimize = optimize };
                const runner_dom = suite_dom.create(
                    &.{
                        suite_dom.addZigBenchmark("zimdjson_dom"),
                        suite_dom.addCppBenchmark("simdjson_dom", p.simdjson),
                    },
                    file_path,
                );
                // runner_dom.step.dependOn(&runner_ondemand.step);
                com.dependOn(&runner_dom.step);
            }
        }

        {
            const com = center.command("bench/find-tweet", "Run 'find tweet' benchmark");
            const parsers = Parsers.get(com, target, optimize);
            const file_path = path: {
                if (com.with("simdjson-data")) |dep| {
                    break :path dep.path("jsonexamples/twitter.json").getPath(b);
                } else break :path "";
            };

            if (parsers) |p| {
                var suite = bench.Suite("find_tweet"){
                    .zimdjson = zimdjson,
                    .simdjson = p.simdjson,
                    .target = target,
                    .optimize = optimize,
                };
                const runner = suite.create(
                    &.{
                        suite.addZigBenchmark("zimdjson_ondemand"),
                        suite.addCppBenchmark("simdjson_ondemand", p.simdjson),
                        suite.addZigBenchmark("zimdjson_dom"),
                        suite.addCppBenchmark("simdjson_dom", p.simdjson),
                    },
                    file_path,
                );
                com.dependOn(&runner.step);
            }
        }
    }
    // --

    // -- Profiling
    {
        var com = center.command("profile", "Profile with Tracy");
        const file_path = try getProvidedPath(com, &path_buf, use_cwd);

        const traced_zimdjson = getZimdjsonModule(b, .{
            .target = target,
            .optimize = optimize,
            .enable_tracy = true,
        });

        const profile = b.addExecutable(.{
            .name = "profile",
            .root_source_file = b.path("profile/main.zig"),
            .target = target,
            .optimize = optimize,
        });

        profile.root_module.addImport("zimdjson", traced_zimdjson);
        profile.root_module.addImport("tracy", traced_zimdjson.import_table.get("tracy").?);

        const run_profile = b.addRunArtifact(profile);
        run_profile.addArg(file_path);
        com.dependOn(&run_profile.step);
    }
    // --
}

fn addEmbeddedPath(b: *std.Build, compile: *std.Build.Step.Compile, dep: *std.Build.Dependency, alias: []const u8) void {
    compile.root_module.addAnonymousImport(alias, .{
        .root_source_file = b.addWriteFiles().add(alias, dep.path(".").getPath(b)),
    });
}

fn getProvidedPath(com: cc.Command, buf: []u8, use_cwd: bool) ![]const u8 {
    const b = com.step.owner;
    const json_path = if (b.args) |args| args[0] else "";
    if (use_cwd) {
        return try std.fs.cwd().realpath(json_path, buf);
    } else if (com.with("simdjson-data")) |dep| {
        return b.pathJoin(&.{ dep.path("jsonexamples").getPath(b), json_path });
    } else return "";
}

fn getZimdjsonModule(
    b: *std.Build,
    options: struct {
        target: std.Build.ResolvedTarget,
        optimize: std.builtin.OptimizeMode,
        enable_tracy: bool = false,
        enable_debug: bool = false,
    },
) *std.Build.Module {
    const module = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
    });
    module.addImport("debug", getDebugModule(b, .{
        .target = options.target,
        .optimize = options.optimize,
        .enable = options.enable_debug,
    }));
    module.addImport("tracy", getTracyModule(b, .{
        .target = options.target,
        .optimize = options.optimize,
        .enable = options.enable_tracy,
    }));
    return module;
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
