const std = @import("std");
const yash_repl = @import("repl.zig");

pub const repl = yash_repl.run;

pub const ShellError = error{
    ParseError,
};

/// Print to stdout with immediate flush. Panics on failure.
pub fn print(comptime fmt: []const u8, args: anytype) void {
    const stdout = std.io.getStdOut().writer();
    stdout.print(fmt, args) catch |err| {
        std.debug.print("yash: fatal error writing to stdout: {}\n", .{err});
        std.debug.panic("stdout failure is unrecoverable for a shell\n", .{});
    };
    std.io.getStdOut().sync() catch |err| {
        std.debug.print("yash: fatal error flushing stdout: {}\n", .{err});
        std.debug.panic("stdout failure is unrecoverable for a shell\n", .{});
    };
}
