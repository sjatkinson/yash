const yash = @import("yash.zig");
const std = @import("std");

const default_prompt = "$ ";

pub fn display() void {
    const stdin = std.io.getStdIn();
    if (stdin.isTty()) {
        yash.print(default_prompt, .{});
    }
}
