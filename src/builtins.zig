const std = @import("std");

const BuiltinFn = *const fn (allocator: std.mem.Allocator, []const []const u8) void;

const BuiltinCmds = struct {
    name: []const u8,
    func: BuiltinFn,
};

const builtin_cmds = [_]BuiltinCmds{
    .{ .name = "exit", .func = &doExit },
    .{ .name = "echo", .func = &doEcho },
    .{ .name = "type", .func = &doType },
};

fn isExecutable(path: []const u8) bool {
    _ = path;
    // TODO:implement this
    return true;
}

pub fn findBuiltin(cmd: []const u8) ?BuiltinFn {
    for (builtin_cmds) |builtin| {
        if (std.mem.eql(u8, cmd, builtin.name)) {
            return builtin.func;
        }
    }
    return null;
}

pub fn findExecutableInPath(allocator: std.mem.Allocator, exe: []const u8) ?[]u8 {
    const path_env = std.process.getEnvVarOwned(allocator, "PATH") catch {
        return null;
    };
    defer allocator.free(path_env);

    var it = std.mem.tokenizeScalar(u8, path_env, ':');
    while (it.next()) |dir| {
        const parts = [_][]const u8{ dir, exe };
        const full_path = std.fs.path.join(allocator, &parts) catch {
            continue;
        };
        if (std.fs.cwd().access(full_path, .{})) {
            return allocator.dupe(u8, full_path) catch {
                // TOdO: need to return an error here?
                std.debug.print("Memory allocation failed", .{});
                continue;
            };
        } else |_| {}
    }
    return null;
}

fn doExit(_: std.mem.Allocator, args: []const []const u8) void {
    if (args.len > 1) {
        std.debug.print("exit: too many arguments\n", .{});
        return;
    }
    if (args.len == 0) {
        std.process.exit(0);
    }
    const code: u8 = std.fmt.parseInt(u8, args[0], 10) catch {
        std.debug.print("exit: numeric argument required\n", .{});
        return;
    };
    std.process.exit(code);
}

fn doEcho(_: std.mem.Allocator, args: []const []const u8) void {
    const stdout = std.io.getStdOut().writer();
    for (args) |arg| {
        stdout.print("{s} ", .{arg}) catch {};
    }
    stdout.print("\n", .{}) catch {};
}

fn doType(allocator: std.mem.Allocator, args: []const []const u8) void {
    const stdout = std.io.getStdOut().writer();
    for (args) |arg| {
        const func = findBuiltin(arg);
        if (func) |_| {
            stdout.print("{s} is a shell builtin", .{arg}) catch {};
        } else {
            if (findExecutableInPath(allocator, arg)) |p| {
                stdout.print("{s} is {s}", .{ arg, p }) catch {};
            } else stdout.print("{s} not found", .{arg}) catch {};
        }
    }
    stdout.print("\n", .{}) catch {};
}
