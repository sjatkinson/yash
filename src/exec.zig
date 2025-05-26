const std = @import("std");

pub fn spawn(name: []const u8, args: []const []const u8) !u8 {
    // TODO: pass in the allocator
    const alloc = std.heap.page_allocator;
    const args_count = 1 + args.len;
    var argv = try alloc.alloc([]const u8, args_count);
    defer alloc.free(argv);

    argv[0] = name;
    for (args, 1..) |arg, i| {
        argv[i] = arg;
    }
    var child = std.process.Child.init(argv, alloc);
    try child.spawn();
    const exit_code = child.wait() catch |e| {
        std.debug.print("process failed {}\n", .{e});
        return 255;
    };
    if (exit_code != .Exited) {
        std.debug.print("exit code not zero\n", .{});
    }
    // TOD: get the actual code
    return 0;
}
