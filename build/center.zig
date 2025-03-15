const std = @import("std");

pub const CommandCenter = struct {
    b: *std.Build,
    allocator: std.mem.Allocator,
    names: std.ArrayList(u8),
    args: []const [:0]u8,
    enabled: bool,

    pub fn init(allocator: std.mem.Allocator, b: *std.Build, enabled: bool) !CommandCenter {
        const args = try std.process.argsAlloc(allocator);
        return .{
            .b = b,
            .allocator = allocator,
            .names = .init(allocator),
            .args = args,
            .enabled = enabled,
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
            .options = .{},
        };
    }
};

pub const Command = struct {
    pub const Options = struct {
        propagate: bool = true,
    };

    center: *CommandCenter,
    step: *std.Build.Step,
    parent: ?*const Command = null,
    options: Options,

    pub fn sub(self: *Command, name: []const u8, description: []const u8, options: Options) !Command {
        const ptr = self.center.names.items.len;
        try self.center.names.appendSlice(self.step.name);
        try self.center.names.append('/');
        try self.center.names.appendSlice(name);
        const len = self.center.names.items.len;
        return .{
            .center = self.center,
            .parent = self,
            .step = self.center.b.step(self.center.names.items[ptr..len], description),
            .options = options,
        };
    }

    pub fn isExecuted(self: Command) bool {
        args: for (self.center.args[1..]) |arg| {
            var prefix: ?*const Command = &self;
            while (prefix) |p| : (prefix = p.parent) {
                if (self.center.b.top_level_steps.contains(arg)) return true;
                if (!self.options.propagate) continue :args;
            }
        }
        return false;
    }

    pub fn with(self: Command, dependency: []const u8) ?*std.Build.Dependency {
        return if (self.center.enabled and self.isExecuted())
            self.center.b.lazyDependency(dependency, .{})
        else
            null;
    }

    pub fn dependOn(self: Command, step: *std.Build.Step) void {
        var prefix: ?*const Command = &self;
        while (prefix) |p| : (prefix = p.parent) {
            p.step.dependOn(step);
            if (!self.options.propagate) return;
        }
    }
};
