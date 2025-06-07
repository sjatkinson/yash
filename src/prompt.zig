const yash = @import("yash.zig");

const default_prompt = "$ ";

pub fn display() void {
    yash.print(default_prompt, .{});
}
