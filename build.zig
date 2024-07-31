const std = @import("std");

pub fn build(b: *std.Build) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zimdjson = b.addModule("zimdjson", .{ .root_source_file = b.path("src/root.zig") });

    // -- Testing
    const test_step = b.step("test", "Run all unit tests");

    var lazy_simdjson_data: ?*std.Build.Dependency = null;
    var lazy_float_data: ?*std.Build.Dependency = null;
    var enable_tracy = false;

    var args = try std.process.argsWithAllocator(alloc);
    defer args.deinit();
    while (args.next()) |a| {
        if (std.mem.startsWith(u8, a, "profile")) enable_tracy = true;
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
        .{ .step = "test/minefield", .name = "minefield", .path = "tests/minefield.zig" },
        .{ .step = "test/float-parsing", .name = "float parsing", .path = "tests/float_parsing.zig" },
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

    // -- Profiling
    const tracy_module = getTracyModule(b, .{
        .target = target,
        .optimize = optimize,
        .enable = enable_tracy,
    });
    zimdjson.addImport("tracy", tracy_module);
    const tracy_example = b.addExecutable(.{
        .name = "tracy_example",
        .root_source_file = b.path("profile/tracy_example.zig"),
        .target = b.host,
        .optimize = optimize,
    });
    tracy_example.root_module.addImport("zimdjson", zimdjson);
    tracy_example.root_module.addImport("tracy", tracy_module);
    const run_tracy_example = b.addRunArtifact(tracy_example);

    const tracy_step = b.step("profile", "Profile using tracy");
    tracy_step.dependOn(&tracy_example.step);
    tracy_step.dependOn(&run_tracy_example.step);
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

fn getTracyModule(
    b: *std.Build,
    options: struct {
        target: std.Build.ResolvedTarget,
        optimize: std.builtin.OptimizeMode,
        enable: bool,
    },
) *std.Build.Module {
    const tracy_options = b.addOptions();
    tracy_options.step.name = "tracy options";
    tracy_options.addOption(bool, "enable", options.enable);

    const tracy_module = b.addModule("tracy", .{
        .root_source_file = b.path("src/tracy.zig"),
        .target = options.target,
        .optimize = options.optimize,
    });
    tracy_module.addImport("options", tracy_options.createModule());
    if (!options.enable) return tracy_module;

    tracy_module.link_libc = true;
    tracy_module.linkSystemLibrary("TracyClient", .{});

    return tracy_module;
}
