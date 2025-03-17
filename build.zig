const std = @import("std");
const bench = @import("build/bench.zig");
const Parsers = @import("build/parsers.zig").Parsers;

pub fn build(b: *std.Build) !void {
    const is_root = std.mem.eql(u8, "", b.pkg_hash);

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zimdjson = b.addModule("zimdjson", .{
        .root_source_file = b.path("src/zimdjson.zig"),
        .target = target,
        .optimize = optimize,
    });

    const is_dev_mode = b.option(bool, "dev_mode", "Enable zimdjson development mode (default: true)") orelse is_root;
    const build_options = b.addOptions();
    build_options.addOption(bool, "is_dev_mode", is_dev_mode);
    zimdjson.addImport("build_options", build_options.createModule());

    if (is_root) {
        const use_cwd = b.option(bool, "use-cwd",
            \\Prefix the file path with the current directory instead
            \\                               of simdjson/simdjson-data (default: no)
        ) orelse false;
        var path_buf: [1024]u8 = undefined;

        {
            const docs = b.step("docs", "Generate documentation");

            const obj = b.addObject(.{
                .name = "zimdjson",
                .root_module = zimdjson,
            });

            const install_docs = b.addInstallDirectory(.{
                .source_dir = obj.getEmittedDocs(),
                .install_dir = .prefix,
                .install_subdir = "docs",
            });

            docs.dependOn(&install_docs.step);
        }

        // -- Testing
        {
            const tests = b.step("tests", "Run all test suites");
            const tests_generate = b.step("tests/generate", "Generate compliant tests");

            {
                const float_parsing_step = b.step("tests/float-parsing", "Run test suite 'float parsing'");
                const float_parsing = b.addTest(.{
                    .root_module = b.createModule(.{
                        .root_source_file = b.path("tests/float_parsing.zig"),
                        .target = target,
                        .optimize = optimize,
                    }),
                });
                if (b.lazyDependency("parse_number_fxx", .{})) |dep| {
                    addEmbeddedPath(b, float_parsing, dep, "parse_number_fxx");
                }

                float_parsing.root_module.addImport("zimdjson", zimdjson);

                const run_float_parsing = b.addRunArtifact(float_parsing);
                float_parsing_step.dependOn(&run_float_parsing.step);
                tests.dependOn(float_parsing_step);
            }
            {
                const minefield_step = b.step("tests/minefield", "Run test suite 'minefield'");
                const minefield_gen = b.addExecutable(.{
                    .name = "minefield_gen",
                    .root_module = b.createModule(.{
                        .root_source_file = b.path("tests/minefield_gen.zig"),
                        .target = target,
                    }),
                });
                const path = b.path("tests/minefield.zig");
                const run_minefield_gen = b.addRunArtifact(minefield_gen);
                run_minefield_gen.addArg(path.getPath(b));

                const minefield = b.addTest(.{
                    .root_module = b.createModule(.{
                        .root_source_file = path,
                        .target = target,
                        .optimize = optimize,
                    }),
                });
                if (b.lazyDependency("simdjson-data", .{})) |dep| {
                    addEmbeddedPath(b, minefield, dep, "simdjson-data");
                    addEmbeddedPath(b, minefield_gen, dep, "simdjson-data");
                }
                minefield.root_module.addImport("zimdjson", zimdjson);

                const run_minefield = b.addRunArtifact(minefield);
                minefield_step.dependOn(&run_minefield.step);
                tests_generate.dependOn(&run_minefield_gen.step);
                tests.dependOn(minefield_step);
            }
            {
                const adversarial_step = b.step("tests/adversarial", "Run test suite 'adversarial'");
                const adversarial_gen = b.addExecutable(.{
                    .name = "adversarial_gen",
                    .root_source_file = b.path("tests/adversarial_gen.zig"),
                    .target = target,
                });
                const path = b.path("tests/adversarial.zig");
                const run_adversarial_gen = b.addRunArtifact(adversarial_gen);
                run_adversarial_gen.addArg(path.getPath(b));

                const adversarial = b.addTest(.{
                    .root_module = b.createModule(.{
                        .root_source_file = path,
                        .target = target,
                        .optimize = optimize,
                    }),
                });
                if (b.lazyDependency("simdjson-data", .{})) |dep| {
                    addEmbeddedPath(b, adversarial, dep, "simdjson-data");
                    addEmbeddedPath(b, adversarial_gen, dep, "simdjson-data");
                }
                adversarial.root_module.addImport("zimdjson", zimdjson);

                const run_adversarial = b.addRunArtifact(adversarial);
                adversarial_step.dependOn(&run_adversarial.step);
                tests_generate.dependOn(&run_adversarial_gen.step);
                tests.dependOn(adversarial_step);
            }
            {
                const examples_step = b.step("tests/examples", "Run test suite 'examples'");
                const examples_gen = b.addExecutable(.{
                    .name = "examples_gen",
                    .root_source_file = b.path("tests/examples_gen.zig"),
                    .target = target,
                });
                const path = b.path("tests/examples.zig");
                const run_examples_gen = b.addRunArtifact(examples_gen);
                run_examples_gen.addArg(path.getPath(b));

                const examples = b.addTest(.{
                    .root_module = b.createModule(.{
                        .root_source_file = path,
                        .target = target,
                        .optimize = optimize,
                    }),
                });
                if (target.result.os.tag == .macos) {
                    examples.linkLibC();
                }
                if (b.lazyDependency("simdjson-data", .{})) |dep| {
                    addEmbeddedPath(b, examples, dep, "simdjson-data");
                    addEmbeddedPath(b, examples_gen, dep, "simdjson-data");
                }
                examples.root_module.addImport("zimdjson", zimdjson);

                const run_examples = b.addRunArtifact(examples);
                examples_step.dependOn(&run_examples.step);
                tests_generate.dependOn(&run_examples_gen.step);
                tests.dependOn(examples_step);
            }
            {
                const ondemand_step = b.step("tests/ondemand", "Run test suite 'ondemand'");
                const ondemand = b.addTest(.{
                    .root_module = b.createModule(.{
                        .root_source_file = b.path("tests/ondemand.zig"),
                        .target = target,
                        .optimize = optimize,
                    }),
                });
                if (b.lazyDependency("simdjson-data", .{})) |dep| {
                    addEmbeddedPath(b, ondemand, dep, "simdjson-data");
                }
                ondemand.root_module.addImport("zimdjson", zimdjson);

                const run_ondemand = b.addRunArtifact(ondemand);
                ondemand_step.dependOn(&run_ondemand.step);
                tests.dependOn(ondemand_step);
            }
            {
                const schema_step = b.step("tests/schema", "Run test suite 'schema'");
                const schema = b.addTest(.{
                    .root_module = b.createModule(.{
                        .root_source_file = b.path("tests/schema.zig"),
                        .target = target,
                        .optimize = optimize,
                    }),
                });
                if (b.lazyDependency("simdjson-data", .{})) |dep| {
                    addEmbeddedPath(b, schema, dep, "simdjson-data");
                }
                schema.root_module.addImport("zimdjson", zimdjson);

                const run_schema = b.addRunArtifact(schema);
                schema_step.dependOn(&run_schema.step);
                tests.dependOn(schema_step);
            }
        }
        // --

        // -- Benchmarking
        {
            {
                const name = "index";
                const bench_step = b.step("bench/" ++ name, "Run benchmark 'SIMD indexer'");
                const parsers = Parsers.get(b, target, optimize);
                const file_path = try getProvidedPath(b, &path_buf, use_cwd);

                if (parsers) |p| {
                    var suite_dom = bench.Suite(name){ .zimdjson = zimdjson, .simdjson = p.simdjson, .target = target, .optimize = optimize };
                    const runner_dom = suite_dom.create(
                        &.{
                            suite_dom.addZigBenchmark("zimdjson_ondemand"),
                            suite_dom.addCppBenchmark("simdjson_ondemand", p.simdjson),
                        },
                        file_path,
                    );
                    bench_step.dependOn(&runner_dom.step);
                }
            }
            {
                const name = "dom";
                const bench_step = b.step("bench/" ++ name, "Run benchmark 'DOM parsing'");
                const parsers = Parsers.get(b, target, optimize);
                const file_path = try getProvidedPath(b, &path_buf, use_cwd);

                if (parsers) |p| {
                    var suite_dom = bench.Suite(name){ .zimdjson = zimdjson, .simdjson = p.simdjson, .target = target, .optimize = optimize };
                    const runner_dom = suite_dom.create(
                        &.{
                            suite_dom.addZigBenchmark("zimdjson_dom"),
                            suite_dom.addZigBenchmark("zimdjson_padless_dom"),
                            suite_dom.addCppBenchmark("simdjson_dom", p.simdjson),
                            suite_dom.addCppBenchmark("yyjson", p.yyjson),
                            suite_dom.addCppBenchmark("rapidjson_dom", p.rapidjson),
                        },
                        file_path,
                    );
                    bench_step.dependOn(&runner_dom.step);
                }
            }
            {
                const name = "streaming";
                const bench_step = b.step("bench/" ++ name, "Run benchmark 'streaming'");
                const parsers = Parsers.get(b, target, optimize);
                const file_path = try getProvidedPath(b, &path_buf, use_cwd);

                if (parsers) |p| {
                    var suite_dom = bench.Suite(name){ .zimdjson = zimdjson, .simdjson = p.simdjson, .target = target, .optimize = optimize };
                    const runner_dom = suite_dom.create(
                        &.{
                            suite_dom.addZigBenchmark("zimdjson_stream_dom"),
                            suite_dom.addZigBenchmark("zimdjson_dom"),
                            suite_dom.addCppBenchmark("simdjson_dom", p.simdjson),
                            suite_dom.addCppBenchmark("yyjson", p.yyjson),
                            suite_dom.addCppBenchmark("rapidjson_stream", p.rapidjson),
                        },
                        file_path,
                    );
                    bench_step.dependOn(&runner_dom.step);
                }
            }
            {
                const name = "find-tweet";
                const bench_step = b.step("bench/" ++ name, "Run benchmark 'find tweet'");
                const parsers = Parsers.get(b, target, optimize);
                const file_path = path: {
                    if (b.lazyDependency("simdjson-data", .{})) |dep| {
                        break :path dep.path("jsonexamples/twitter.json").getPath(b);
                    } else break :path "";
                };

                if (parsers) |p| {
                    var suite = bench.Suite(name){
                        .zimdjson = zimdjson,
                        .simdjson = p.simdjson,
                        .target = target,
                        .optimize = optimize,
                    };
                    const runner = suite.create(
                        &.{
                            suite.addZigBenchmark("zimdjson_ondemand"),
                            suite.addZigBenchmark("zimdjson_stream_ondemand"),
                            suite.addCppBenchmark("simdjson_ondemand", p.simdjson),
                            suite.addZigBenchmark("zimdjson_dom"),
                            suite.addZigBenchmark("zimdjson_stream_dom"),
                            suite.addCppBenchmark("simdjson_dom", p.simdjson),
                            suite.addCppBenchmark("yyjson", p.yyjson),
                        },
                        file_path,
                    );
                    bench_step.dependOn(&runner.step);
                }
            }
            {
                const name = "top-tweet";
                const bench_step = b.step("bench/" ++ name, "Run benchmark 'top tweet'");
                const parsers = Parsers.get(b, target, optimize);
                const file_path = path: {
                    if (b.lazyDependency("simdjson-data", .{})) |dep| {
                        break :path dep.path("jsonexamples/twitter.json").getPath(b);
                    } else break :path "";
                };

                if (parsers) |p| {
                    var suite = bench.Suite(name){
                        .zimdjson = zimdjson,
                        .simdjson = p.simdjson,
                        .target = target,
                        .optimize = optimize,
                    };
                    const runner = suite.create(
                        &.{
                            suite.addZigBenchmark("zimdjson_ondemand"),
                            suite.addZigBenchmark("zimdjson_stream_ondemand"),
                            suite.addCppBenchmark("simdjson_ondemand", p.simdjson),
                            suite.addZigBenchmark("zimdjson_dom"),
                            suite.addZigBenchmark("zimdjson_stream_dom"),
                            suite.addCppBenchmark("simdjson_dom", p.simdjson),
                            suite.addCppBenchmark("yyjson", p.yyjson),
                        },
                        file_path,
                    );
                    bench_step.dependOn(&runner.step);
                }
            }
            {
                const name = "partial-tweets";
                const bench_step = b.step("bench/" ++ name, "Run benchmark 'partial tweets'");
                const parsers = Parsers.get(b, target, optimize);
                const file_path = path: {
                    if (b.lazyDependency("simdjson-data", .{})) |dep| {
                        break :path dep.path("jsonexamples/twitter.json").getPath(b);
                    } else break :path "";
                };

                if (parsers) |p| {
                    var suite = bench.Suite(name){
                        .zimdjson = zimdjson,
                        .simdjson = p.simdjson,
                        .target = target,
                        .optimize = optimize,
                    };
                    const runner = suite.create(
                        &.{
                            suite.addZigBenchmark("zimdjson_ondemand"),
                            suite.addZigBenchmark("zimdjson_stream_ondemand"),
                            suite.addCppBenchmark("simdjson_ondemand", p.simdjson),
                            suite.addZigBenchmark("zimdjson_dom"),
                            suite.addZigBenchmark("zimdjson_stream_dom"),
                            suite.addCppBenchmark("simdjson_dom", p.simdjson),
                            suite.addCppBenchmark("yyjson", p.yyjson),
                        },
                        file_path,
                    );
                    bench_step.dependOn(&runner.step);
                }
            }
            {
                const name = "distinct-user-id";
                const bench_step = b.step("bench/" ++ name, "Run benchmark 'distinct user id'");
                const parsers = Parsers.get(b, target, optimize);
                const file_path = path: {
                    if (b.lazyDependency("simdjson-data", .{})) |dep| {
                        break :path dep.path("jsonexamples/twitter.json").getPath(b);
                    } else break :path "";
                };

                if (parsers) |p| {
                    var suite = bench.Suite(name){
                        .zimdjson = zimdjson,
                        .simdjson = p.simdjson,
                        .target = target,
                        .optimize = optimize,
                    };
                    const runner = suite.create(
                        &.{
                            suite.addZigBenchmark("zimdjson_ondemand"),
                            suite.addZigBenchmark("zimdjson_stream_ondemand"),
                            suite.addCppBenchmark("simdjson_ondemand", p.simdjson),
                            suite.addZigBenchmark("zimdjson_dom"),
                            suite.addZigBenchmark("zimdjson_stream_dom"),
                            suite.addCppBenchmark("simdjson_dom", p.simdjson),
                            suite.addCppBenchmark("yyjson", p.yyjson),
                        },
                        file_path,
                    );
                    bench_step.dependOn(&runner.step);
                }
            }
            {
                const name = "find-system";
                const bench_step = b.step("bench/" ++ name, "Run benchmark 'find system'");
                const parsers = Parsers.get(b, target, optimize);
                const file_path = try getProvidedPath(b, &path_buf, use_cwd);

                if (parsers) |p| {
                    var suite = bench.Suite(name){
                        .zimdjson = zimdjson,
                        .simdjson = p.simdjson,
                        .target = target,
                        .optimize = optimize,
                    };
                    const runner = suite.create(
                        &.{
                            suite.addZigBenchmark("zimdjson_ondemand"),
                            suite.addZigBenchmark("zimdjson_stream_ondemand"),
                            suite.addCppBenchmark("simdjson_ondemand", p.simdjson),
                            suite.addZigBenchmark("zimdjson_dom"),
                            suite.addZigBenchmark("zimdjson_stream_dom"),
                            suite.addCppBenchmark("simdjson_dom", p.simdjson),
                            suite.addCppBenchmark("yyjson", p.yyjson),
                        },
                        file_path,
                    );
                    bench_step.dependOn(&runner.step);
                }
            }
            {
                const name = "top-factions";
                const bench_step = b.step("bench/" ++ name, "Run benchmark 'top factions'");
                const parsers = Parsers.get(b, target, optimize);
                const file_path = try getProvidedPath(b, &path_buf, use_cwd);

                if (parsers) |p| {
                    var suite = bench.Suite(name){
                        .zimdjson = zimdjson,
                        .simdjson = p.simdjson,
                        .target = target,
                        .optimize = optimize,
                    };
                    const runner = suite.create(
                        &.{
                            suite.addZigBenchmark("zimdjson_ondemand"),
                            suite.addZigBenchmark("zimdjson_stream_ondemand"),
                            suite.addCppBenchmark("simdjson_ondemand", p.simdjson),
                            suite.addZigBenchmark("zimdjson_dom"),
                            suite.addZigBenchmark("zimdjson_stream_dom"),
                            suite.addCppBenchmark("simdjson_dom", p.simdjson),
                            suite.addCppBenchmark("yyjson", p.yyjson),
                        },
                        file_path,
                    );
                    bench_step.dependOn(&runner.step);
                }
            }
            {
                const name = "coordinates";
                const bench_step = b.step("bench/" ++ name, "Run benchmark 'coordinates'");
                const parsers = Parsers.get(b, target, optimize);
                const file_path = try getProvidedPath(b, &path_buf, use_cwd);

                if (parsers) |p| {
                    var suite = bench.Suite(name){
                        .zimdjson = zimdjson,
                        .simdjson = p.simdjson,
                        .target = target,
                        .optimize = optimize,
                    };
                    const runner = suite.create(
                        &.{
                            suite.addZigBenchmark("zimdjson_ondemand"),
                            suite.addZigBenchmark("zimdjson_stream_ondemand"),
                            suite.addCppBenchmark("simdjson_ondemand", p.simdjson),
                            suite.addZigBenchmark("zimdjson_dom"),
                            suite.addZigBenchmark("zimdjson_stream_dom"),
                            suite.addCppBenchmark("simdjson_dom", p.simdjson),
                            suite.addCppBenchmark("yyjson", p.yyjson),
                        },
                        file_path,
                    );
                    bench_step.dependOn(&runner.step);
                }
            }
            {
                const name = "schema";
                const bench_step = b.step("bench/" ++ name, "Run benchmark 'schema'");
                const parsers = Parsers.get(b, target, optimize);
                const file_path = path: {
                    if (b.lazyDependency("simdjson-data", .{})) |dep| {
                        break :path dep.path("jsonexamples/twitter.json").getPath(b);
                    } else break :path "";
                };

                if (parsers) |p| {
                    var suite = bench.Suite(name){
                        .zimdjson = zimdjson,
                        .simdjson = p.simdjson,
                        .target = target,
                        .optimize = optimize,
                    };
                    const runner = suite.create(
                        &.{
                            suite.addZigBenchmark("zimdjson_ondemand"),
                            suite.addZigBenchmark("zimdjson_ondemand_unordered"),
                            suite.addZigBenchmark("stream_zimdjson_ondemand"),
                            suite.addZigBenchmark("stream_zimdjson_ondemand_unordered"),
                            suite.addZigBenchmark("zimdjson_schema"),
                            suite.addZigBenchmark("zimdjson_schema_ordered"),
                            suite.addZigBenchmark("stream_zimdjson_schema"),
                            suite.addZigBenchmark("stream_zimdjson_schema_ordered"),
                            suite.addZigBenchmark("std_json"),
                            suite.addZigBenchmark("stream_std_json"),
                            suite.addRustBenchmark("serde"),
                            suite.addRustBenchmark("stream_serde"),
                        },
                        file_path,
                    );
                    bench_step.dependOn(&runner.step);
                }
            }
        }
        // // --

        // // -- Tools
        {
            // {
            //     const emit_step = b.step("tools/emit", "Build a Zig program including low-level artifacts");

            //     const traced_zimdjson = b.addModule("zimdjson", .{
            //         .root_source_file = b.path("src/zimdjson.zig"),
            //         .target = target,
            //         .optimize = optimize,
            //     });

            //     traced_zimdjson.addImport("tracy", getTracyModule(b, .{
            //         .target = target,
            //         .optimize = optimize,
            //         .enable = true,
            //     }));

            //     const exe = b.addExecutable(.{
            //         .name = "exe",
            //         .root_source_file = b.path("tools/exe.zig"),
            //         .target = target,
            //         .optimize = optimize,
            //     });

            //     exe.root_module.addImport("zimdjson", traced_zimdjson);

            //     const build_exe = b.addInstallArtifact(exe, .{});
            //     const write_asm = b.addInstallFile(exe.getEmittedAsm(), "exe.s");
            //     const write_ir = b.addInstallFile(exe.getEmittedLlvmIr(), "exe.ir");
            //     com.dependOn(&build_exe.step);
            //     com.dependOn(&write_asm.step);
            //     com.dependOn(&write_ir.step);
            // }
            // {
            //     var com = center.command("tools/emit-cpp", "Build a C++ program including low-level artifacts");
            //     const parsers = Parsers.get(b, target, optimize);

            //     if (parsers) |p| {
            //         const exe = b.addExecutable(.{
            //             .name = "exe-cpp",
            //             .root_source_file = null,
            //             .target = target,
            //             .optimize = optimize,
            //         });

            //         exe.addCSourceFile(.{ .file = b.path("tools/exe.cpp") });
            //         exe.linkLibrary(p.simdjson);
            //         exe.linkLibrary(p.yyjson);

            //         const build_exe = b.addInstallArtifact(exe, .{});
            //         // const write_asm = b.addInstallFile(exe.getEmittedAsm(), "exe-cpp.s");
            //         // const write_ir = b.addInstallFile(exe.getEmittedLlvmIr(), "exe-cpp.ir");
            //         com.dependOn(&build_exe.step);
            //         // com.dependOn(&write_asm.step);
            //         // com.dependOn(&write_ir.step);
            //     }
            // }
            {
                const profile_step = b.step("tools/profile", "Profile a Zig program with Tracy");
                const file_path = try getProvidedPath(b, &path_buf, use_cwd);

                const traced_zimdjson = b.createModule(.{
                    .root_source_file = b.path("src/zimdjson.zig"),
                    .target = target,
                    .optimize = optimize,
                });

                const tracy_options = b.addOptions();
                tracy_options.addOption(bool, "enable_tracy", true);

                const tracy_module = b.createModule(.{
                    .root_source_file = b.path("src/tracy.zig"),
                    .target = target,
                    .optimize = optimize,
                });
                tracy_module.addImport("build_options", tracy_options.createModule());

                tracy_module.link_libc = true;
                tracy_module.linkSystemLibrary("TracyClient", .{});

                traced_zimdjson.addImport("tracy", tracy_module);

                const profile = b.addExecutable(.{
                    .name = "profile",
                    .root_module = b.createModule(.{
                        .root_source_file = b.path("tools/profile.zig"),
                        .target = target,
                        .optimize = optimize,
                    }),
                });

                profile.root_module.addImport("zimdjson", traced_zimdjson);
                profile.root_module.addImport("tracy", tracy_module);

                const run_profile = b.addRunArtifact(profile);
                run_profile.addArg(file_path);
                profile_step.dependOn(&run_profile.step);
            }
            {
                const profile_step = b.step("tools/profile-cpp", "Profile a C++ program with Tracy");
                const parsers = Parsers.get(b, target, optimize);
                const file_path = try getProvidedPath(b, &path_buf, use_cwd);

                if (parsers) |p| {
                    const profile = b.addExecutable(.{
                        .name = "profile-cpp",
                        .root_module = b.createModule(.{
                            .root_source_file = null,
                            .target = target,
                            .optimize = optimize,
                        }),
                    });

                    profile.addCSourceFile(.{ .file = b.path("tools/profile.cpp"), .flags = &.{"-DTRACY_ENABLE"} });
                    profile.linkSystemLibrary("TracyClient");
                    profile.linkLibrary(p.simdjson);
                    profile.linkLibrary(p.yyjson);

                    const run_profile = b.addRunArtifact(profile);
                    run_profile.addArg(file_path);
                    profile_step.dependOn(&run_profile.step);
                }
            }
            {
                const print_step = b.step("tools/print", "Print a parsed JSON file");
                const file_path = try getProvidedPath(b, &path_buf, use_cwd);

                const exe = b.addExecutable(.{
                    .name = "print",
                    .root_module = b.createModule(.{
                        .root_source_file = b.path("tools/print.zig"),
                        .target = target,
                        .optimize = optimize,
                    }),
                });

                exe.root_module.addImport("zimdjson", zimdjson);

                const run_profile = b.addRunArtifact(exe);
                run_profile.addArg(file_path);
                print_step.dependOn(&run_profile.step);
            }
        }
        // --
    }
}

fn addEmbeddedPath(b: *std.Build, compile: *std.Build.Step.Compile, dep: *std.Build.Dependency, alias: []const u8) void {
    compile.root_module.addAnonymousImport(alias, .{
        .root_source_file = b.addWriteFiles().add(alias, dep.path(".").getPath(b)),
    });
}

fn getProvidedPath(b: *std.Build, buf: []u8, use_cwd: bool) ![]const u8 {
    const json_path = if (b.args) |args| args[0] else "";
    if (use_cwd) {
        return try std.fs.cwd().realpath(json_path, buf);
    } else if (b.lazyDependency("simdjson-data", .{})) |dep| {
        return b.pathJoin(&.{ dep.path("jsonexamples").getPath(b), json_path });
    } else return "";
}
