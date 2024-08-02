const std = @import("std");

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
        var com = center.command("test", "Run test suites");

        {
            const com_minefield = try com.sub("minefield", "Run minefield test suite");
            const minefield_gen = b.addExecutable(.{
                .name = "minefield_gen",
                .root_source_file = b.path("tests/minefield_gen.zig"),
                .target = b.host,
            });
            const run_minefield_gen = b.addRunArtifact(minefield_gen);
            _ = run_minefield_gen.addArg(b.path("tests/minefield.zig").getPath(b));

            const minefield = b.addTest(.{
                .root_source_file = b.path("tests/minefield.zig"),
                .target = target,
                .optimize = optimize,
            });
            if (com_minefield.with("simdjson-data")) |dep| {
                addEmbeddedPath(b, minefield_gen, dep, "simdjson-data");
                addEmbeddedPath(b, minefield, dep, "simdjson-data");
            }
            minefield.root_module.addImport("zimdjson", zimdjson);

            const run_minefield = b.addRunArtifact(minefield);
            run_minefield.step.dependOn(&run_minefield_gen.step);
            com_minefield.dependOn(&run_minefield.step);
        }

        {
            const com_float_parsing = try com.sub("float-parsing", "Run float parsing test suite");
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
    }
    // --

    // -- Profiling
    {
        var com = center.command("profile", "Profile using tracy");
        var enable_tracy = false;
        if (com.isExecuted()) enable_tracy = true;

        const tracy_module = getTracyModule(b, .{
            .target = target,
            .optimize = optimize,
            .enable = enable_tracy,
        });
        const profile = b.addExecutable(.{
            .name = "tracy_example",
            .root_source_file = b.path("profile/tracy_example.zig"),
            .target = b.host,
            .optimize = optimize,
        });

        zimdjson.addImport("tracy", tracy_module);
        profile.root_module.addImport("zimdjson", zimdjson);
        profile.root_module.addImport("tracy", tracy_module);

        const run_profile = b.addRunArtifact(profile);
        com.dependOn(&run_profile.step);
    }
    // --
}

fn addEmbeddedPath(b: *std.Build, compile: *std.Build.Step.Compile, dep: *std.Build.Dependency, alias: []const u8) void {
    compile.root_module.addAnonymousImport(alias, .{
        .root_source_file = b.addWriteFiles().add(alias, dep.path(".").getPath(b)),
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

const CommandCenter = struct {
    b: *std.Build,
    allocator: std.mem.Allocator,
    names: std.ArrayList(u8),
    args: []const [:0]u8,

    pub fn init(allocator: std.mem.Allocator, b: *std.Build) !CommandCenter {
        const args = try std.process.argsAlloc(allocator);
        return .{
            .b = b,
            .allocator = allocator,
            .names = std.ArrayList(u8).init(allocator),
            .args = args,
        };
    }

    pub fn deinit(self: *CommandCenter) void {
        self.names.deinit();
        std.process.argsFree(self.allocator, self.args);
    }

    pub fn command(self: *CommandCenter, name: []const u8, description: []const u8) Command {
        return .{
            .center = self,
            .step = self.b.step(name, description),
        };
    }
};

const Command = struct {
    center: *CommandCenter,
    step: *std.Build.Step,
    parent: ?*const Command = null,

    pub fn sub(self: *Command, name: []const u8, description: []const u8) !Command {
        const name_ptr = self.center.names.items.len;
        try self.center.names.appendSlice(self.step.name);
        try self.center.names.append('/');
        try self.center.names.appendSlice(name);
        const name_len = self.step.name.len + 1 + name.len;
        return .{
            .center = self.center,
            .parent = self,
            .step = self.center.b.step(self.center.names.items[name_ptr..][0..name_len], description),
        };
    }

    pub fn isExecuted(self: Command) bool {
        for (self.center.args) |arg| {
            var prefix: ?*const Command = &self;
            while (prefix) |p| : (prefix = p.parent) {
                if (std.mem.eql(u8, arg, p.step.name)) return true;
            }
        }
        return false;
    }

    pub fn with(self: Command, dependency: []const u8) ?*std.Build.Dependency {
        return if (self.isExecuted())
            self.center.b.lazyDependency(dependency, .{})
        else
            null;
    }

    pub fn dependOn(self: Command, step: *std.Build.Step) void {
        var prefix: ?*const Command = &self;
        while (prefix) |p| : (prefix = p.parent) {
            p.step.dependOn(step);
        }
    }
};
