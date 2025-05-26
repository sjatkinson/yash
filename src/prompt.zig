const std = @import("std");

const default_prompt = "$ ";

pub fn display() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print(default_prompt, .{});
}
