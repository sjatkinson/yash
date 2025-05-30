const std = @import("std");

const BuiltinFn = *const fn ([]const []const u8) void;

const BuiltinCmds = struct {
    name: []const u8,
    func: BuiltinFn,
};

const builtin_cmds = [_]BuiltinCmds{
    .{ .name = "exit", .func = &doExit },
    .{ .name = "echo", .func = &doEcho },
};


pub fn findBuiltin(cmd: []const u8) ?BuiltinFn {
    for (builtin_cmds) |builtin| {
        if (std.mem.eql(u8, cmd, builtin.name)) {
            return builtin.func;
        }
    }
    return null;
}
fn doExit(args: []const []const u8) void {
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

fn doEcho(args: []const []const u8) void {
    const stdout = std.io.getStdOut().writer();
    for (args) |arg| {
        stdout.print("{s} ", .{arg}) catch {};
    }
    stdout.print("\n", .{}) catch {};
}
