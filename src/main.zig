const std = @import("std");
const yash = @import("yash.zig");

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    try yash.repl(allocator);
}
