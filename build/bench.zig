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
        traced_alloc: ?*std.Build.Module = null,

        pub fn addZigBenchmark(
            self: *Self,
            comptime name: []const u8,
        ) Benchmark {
            const b = self.zimdjson.owner;
            const identifier = self.suite ++ "/" ++ name;
            const mod = b.createModule(.{
                .root_source_file = b.path("bench/" ++ identifier ++ ".zig"),
                .target = self.target,
                .optimize = self.optimize,
            });
            mod.addImport("zimdjson", self.zimdjson);
            if (self.traced_alloc) |t| {
                mod.addImport("TracedAllocator", t);
            } else {
                self.traced_alloc = b.createModule(.{
                    .root_source_file = b.path("bench/TracedAllocator.zig"),
                    .target = self.target,
                    .optimize = self.optimize,
                });
                mod.addImport("TracedAllocator", self.traced_alloc.?);
            }
            return .{ .module = mod, .name = identifier };
        }

        pub fn addCppBenchmark(
            self: Self,
            comptime name: []const u8,
            parser: *std.Build.Step.Compile,
        ) Benchmark {
            const b = self.zimdjson.owner;
            const identifier = self.suite ++ "/" ++ name;
            const lib = b.addSharedLibrary(.{
                .name = self.suite ++ "_" ++ name,
                .target = self.target,
                .optimize = self.optimize,
            });
            lib.installHeader(b.addWriteFiles().add(identifier, formatTemplateHeader(name)), identifier ++ ".h");
            lib.addCSourceFile(.{ .file = b.path("bench/" ++ identifier ++ ".cpp") });
            lib.linkLibrary(self.simdjson);
            lib.linkLibrary(parser);
            lib.addIncludePath(b.path("bench"));
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
            file_path: []const u8,
        ) *std.Build.Step.Run {
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
            const artifact = b.addRunArtifact(runner);
            artifact.addArg(file_path);
            return artifact;
        }
    };
}

inline fn formatTemplateHeader(comptime name: []const u8) []const u8 {
    return std.fmt.comptimePrint(
        \\#include <stddef.h>
        \\void {[id]s}__init(char *ptr, size_t len);
        \\void {[id]s}__prerun();
        \\void {[id]s}__run();
        \\void {[id]s}__postrun();
        \\void {[id]s}__deinit();
        \\size_t {[id]s}__memusage();
    , .{ .id = name });
}

inline fn formatWrapper(comptime header: []const u8, comptime name: []const u8) []const u8 {
    return std.fmt.comptimePrint(
        \\const c = @cImport({{ @cInclude("{[header]s}.h"); }});
        \\
        \\pub fn init(slice: []u8) void {{
        \\    return c.{[id]s}__init(@ptrCast(slice.ptr), slice.len);
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
        \\
        \\pub fn memusage() usize {{
        \\    return c.{[id]s}__memusage();
        \\}}
    , .{ .header = header, .id = name });
}

fn formatWrappers(content: *std.BoundedArray(u8, 1024), benchmarks: []const Benchmark) []const u8 {
    content.appendSliceAssumeCapacity("pub const wrappers = .{");
    for (benchmarks) |b| {
        content.appendSliceAssumeCapacity("@import(\"");
        content.appendSliceAssumeCapacity(b.name);
        content.appendSliceAssumeCapacity("\"),");
    }
    content.appendSliceAssumeCapacity("};");
    content.appendSliceAssumeCapacity("pub const names = .{");
    for (benchmarks) |b| {
        content.appendSliceAssumeCapacity("\"");
        content.appendSliceAssumeCapacity(b.name);
        content.appendSliceAssumeCapacity("\",");
    }
    content.appendSliceAssumeCapacity("};");
    return content.constSlice();
}
