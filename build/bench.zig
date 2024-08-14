const std = @import("std");

const Benchmark = struct {
    module: *std.Build.Module,
    name: []const u8,
};

pub fn addZigBenchmark(
    runner: *std.Build.Step.Compile,
    comptime benchmark: []const u8,
    comptime name: []const u8,
    zimdjson: *std.Build.Module,
) Benchmark {
    const b = runner.step.owner;
    const target = runner.root_module.resolved_target.?;
    const optimize = runner.root_module.optimize.?;
    const identifier = benchmark ++ "/" ++ name;
    const lib = b.addStaticLibrary(.{
        .name = benchmark ++ "_" ++ name,
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("bench/" ++ identifier ++ ".zig"),
    });
    lib.installHeader(b.addWriteFiles().add(identifier, formatTemplateHeader(name)), identifier ++ ".h");
    lib.root_module.addImport("zimdjson", zimdjson);
    const mod = b.createModule(.{
        .root_source_file = b.addWriteFiles().add(identifier ++ ".zig", formatWrapper(identifier, name)),
    });
    mod.linkLibrary(lib);
    return .{ .module = mod, .name = identifier };
}

pub fn addCppBenchmark(
    runner: *std.Build.Step.Compile,
    comptime benchmark: []const u8,
    comptime name: []const u8,
    simdjson: *std.Build.Step.Compile,
    parser: *std.Build.Step.Compile,
) Benchmark {
    const b = runner.step.owner;
    const target = runner.root_module.resolved_target.?;
    const optimize = runner.root_module.optimize.?;
    const identifier = benchmark ++ "/" ++ name;
    const lib = b.addStaticLibrary(.{
        .name = benchmark ++ "_" ++ name,
        .target = target,
        .optimize = optimize,
    });
    lib.installHeader(b.addWriteFiles().add(identifier, formatTemplateHeader(name)), identifier ++ ".h");
    lib.addCSourceFile(.{ .file = b.path("bench/" ++ identifier ++ ".cpp") });
    lib.linkLibrary(simdjson);
    lib.linkLibrary(parser);
    const mod = b.createModule(.{
        .root_source_file = b.addWriteFiles().add(identifier ++ ".zig", formatWrapper(identifier, name)),
    });
    mod.linkLibrary(lib);
    return .{ .module = mod, .name = identifier };
}

pub fn addBenchmarkSuite(
    runner: *std.Build.Step.Compile,
    comptime benchmark: []const u8,
    benchs: []const Benchmark,
) void {
    const b = runner.step.owner;
    const target = runner.root_module.resolved_target.?;
    const optimize = runner.root_module.optimize.?;
    var buf = std.BoundedArray(u8, 1024).init(0) catch unreachable;
    const suite = formatWrappers(&buf, benchs);
    const mod = b.createModule(.{
        .root_source_file = b.addWriteFiles().add(benchmark ++ ".zig", suite),
        .target = target,
        .optimize = optimize,
    });
    for (benchs) |bench| {
        mod.addImport(bench.name, bench.module);
    }
    runner.root_module.addImport("benchmarks", mod);
}

inline fn formatTemplateHeader(comptime name: []const u8) []const u8 {
    return std.fmt.comptimePrint(
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
