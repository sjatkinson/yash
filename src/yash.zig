const std = @import("std");
const yash_repl = @import("repl.zig");

pub const repl = yash_repl.run;

pub const ShellError = error{
    ParseError,
    NotImplemented,
};

/// Print to stdout. Panics on failure.
pub fn print(comptime fmt: []const u8, args: anytype) void {
    const stdout = std.io.getStdOut().writer();
    stdout.print(fmt, args) catch |err| {
        std.debug.print("yash: fatal error writing to stdout: {}\n", .{err});
        std.debug.panic("stdout failure is unrecoverable for a shell\n", .{});
    };
}

fn isExecutable(path: []const u8) bool {
    _ = path;
    // TODO:implement this
    return true;
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
                // TODO: need to return an error here?
                std.debug.print("yash: memory allocation failed\n", .{});
                continue;
            };
        } else |_| {}
    }
    return null;
}
