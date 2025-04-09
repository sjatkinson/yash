//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const max_line_size = 1024;
const default_prompt = "$ ";

pub fn main() !void {
    try do_repl();
}

fn spawn(name: []const u8) !void {
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

fn display_prompt() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print(default_prompt, .{});
}

fn get_input_line() !?[]u8 {
    const stdin = std.io.getStdIn().reader();
    const alloc = std.heap.page_allocator;
    const u_input = try stdin.readUntilDelimiterOrEofAlloc(alloc, '\n', max_line_size);

    return u_input;
}

fn should_quit(input: ?[]u8) bool {
    if (input) |value| {
        if (!std.mem.eql(u8, value, "exit")) {
            return false;
        }
    }
    return true;
}

fn do_repl() !void {
    while (true) {
        try display_prompt();
        const u_input = try get_input_line();
        if (should_quit(u_input)) {
            break;
        }
        if (u_input) |input| {
            // TODO: split the line in args
            try spawn(input);
        }
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "use other module" {
    try std.testing.expectEqual(@as(i32, 150), lib.add(100, 50));
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}

const std = @import("std");

/// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
const lib = @import("yash_lib");
