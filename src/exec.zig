const std = @import("std");
const yash = @import("yash.zig");

pub fn spawn(allocator: std.mem.Allocator, name: []const u8, args: []const []const u8) !u8 {
    const args_count = 1 + args.len;
    var argv = try allocator.alloc([]const u8, args_count);
    defer allocator.free(argv);

    argv[0] = name;
    for (args, 1..) |arg, i| {
        argv[i] = arg;
    }
    var child = std.process.Child.init(argv, allocator);
    try child.spawn();
    const exit_code = child.wait() catch |e| {
        std.debug.print("yash: process failed {}\n", .{e});
        return 255;
    };
    if (exit_code != .Exited) {
        std.debug.print("yash: exit code not zero\n", .{});
    }
    // TOD: get the actual code
    return 0;
}
