const std = @import("std");

const Benchmark = struct {
    module: *std.Build.Module,
    name: []const u8,
};

pub fn Suite(comptime suite: []const u8) type {
    return struct {
        const Self = @This();

        comptime suite: []const u8 = suite,
        zimdjson: *std.Build.Module,
        simdjson: *std.Build.Step.Compile,
        target: std.Build.ResolvedTarget,
        optimize: std.builtin.OptimizeMode,

        pub fn addZigBenchmark(
            self: Self,
            comptime name: []const u8,
        ) Benchmark {
            const b = self.zimdjson.owner;
            const identifier = self.suite ++ "/" ++ name;
            const lib = b.addStaticLibrary(.{
                .name = self.suite ++ "_" ++ name,
                .target = self.target,
                .optimize = self.optimize,
                .root_source_file = b.path("bench/" ++ identifier ++ ".zig"),
            });
            lib.installHeader(b.addWriteFiles().add(identifier, formatTemplateHeader(name)), identifier ++ ".h");
            lib.root_module.addImport("zimdjson", self.zimdjson);
            const mod = b.createModule(.{
                .root_source_file = b.addWriteFiles().add(identifier ++ ".zig", formatWrapper(identifier, name)),
                .target = self.target,
                .optimize = self.optimize,
            });
            mod.linkLibrary(lib);
            return .{ .module = mod, .name = identifier };
        }

        pub fn addCppBenchmark(
            self: Self,
            comptime name: []const u8,
            parser: *std.Build.Step.Compile,
        ) Benchmark {
            const b = self.zimdjson.owner;
            const identifier = self.suite ++ "/" ++ name;
            const lib = b.addStaticLibrary(.{
                .name = self.suite ++ "_" ++ name,
                .target = self.target,
                .optimize = self.optimize,
            });
            lib.installHeader(b.addWriteFiles().add(identifier, formatTemplateHeader(name)), identifier ++ ".h");
            lib.addCSourceFile(.{ .file = b.path("bench/" ++ identifier ++ ".cpp") });
            lib.linkLibrary(self.simdjson);
            lib.linkLibrary(parser);
            const mod = b.createModule(.{
                .root_source_file = b.addWriteFiles().add(identifier ++ ".zig", formatWrapper(identifier, name)),
                .target = self.target,
                .optimize = self.optimize,
            });
            mod.linkLibrary(lib);
            return .{ .module = mod, .name = identifier };
        }

        pub fn create(
            self: Self,
            benchs: []const Benchmark,
        ) *std.Build.Step.Compile {
            const b = self.zimdjson.owner;
            var buf = std.BoundedArray(u8, 1024).init(0) catch unreachable;
            const wrappers = formatWrappers(&buf, benchs);
            const mod = b.createModule(.{
                .root_source_file = b.addWriteFiles().add(self.suite ++ ".zig", wrappers),
                .target = self.target,
                .optimize = self.optimize,
            });
            for (benchs) |bench| {
                mod.addImport(bench.name, bench.module);
            }
            const runner = b.addExecutable(.{
                .name = self.suite,
                .root_source_file = b.path("bench/runner.zig"),
                .target = self.target,
                .optimize = self.optimize,
            });
            runner.root_module.addImport("benchmarks", mod);
            return runner;
        }
    };
}

inline fn formatTemplateHeader(comptime name: []const u8) []const u8 {
    return std.fmt.comptimePrint(
        \\#include <stddef.h>
        \\void {[id]s}__load(char *ptr, size_t len);
        \\void {[id]s}__init();
        \\void {[id]s}__prerun();
        \\void {[id]s}__run();
        \\void {[id]s}__postrun();
        \\void {[id]s}__deinit();
    , .{ .id = name });
}

inline fn formatWrapper(comptime header: []const u8, comptime name: []const u8) []const u8 {
    return std.fmt.comptimePrint(
        \\const c = @cImport({{ @cInclude("{[header]s}.h"); }});
        \\
        \\pub const name = "{[header]s}";
        \\
        \\pub fn load(slice: []u8) void {{
        \\    return c.{[id]s}__load(@ptrCast(slice.ptr), slice.len);
        \\}}
        \\
        \\pub fn init() void {{
        \\    return c.{[id]s}__init();
        \\}}
        \\
        \\pub fn prerun() void {{
        \\    return c.{[id]s}__prerun();
        \\}}
        \\
        \\pub fn run() void {{
        \\    return c.{[id]s}__run();
        \\}}
        \\
        \\pub fn postrun() void {{
        \\    return c.{[id]s}__postrun();
        \\}}
        \\
        \\pub fn deinit() void {{
        \\    return c.{[id]s}__deinit();
        \\}}
    , .{ .header = header, .id = name });
}

fn formatWrappers(content: *std.BoundedArray(u8, 1024), benchmarks: []const Benchmark) []const u8 {
    content.appendSliceAssumeCapacity("pub const tuple = .{\n");
    for (benchmarks) |b| {
        content.appendSliceAssumeCapacity("    @import(\"");
        content.appendSliceAssumeCapacity(b.name);
        content.appendSliceAssumeCapacity("\"),\n");
    }
    content.appendSliceAssumeCapacity("};");
    return content.constSlice();
}
