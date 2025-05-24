const std = @import("std");

pub fn spawn(name: []const u8) !void {
    const argv = [_][]const u8{name};
    const alloc = std.heap.page_allocator;
    var child = std.process.Child.init(&argv, alloc);
    try child.spawn();
    const exit_code = child.wait() catch |e| {
        std.debug.print("process failed {}\n", .{e});
        return;
    };
    if (exit_code != .Exited) {
        std.debug.print("exit code not zero\n", .{});
    }
}




