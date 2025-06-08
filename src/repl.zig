const std = @import("std");
const prompt = @import("prompt.zig");
const exec = @import("exec.zig");
const yash = @import("ast.zig");
const Parser = @import("parser.zig").Parser;
const Lexer = @import("lexer.zig").Lexer;
const Executor = @import("executor.zig").Executor;

const max_line_size = 1024;

pub fn run(allocator: std.mem.Allocator) !void {
    var executor = Executor.init(allocator);

    var buf: [max_line_size]u8 = undefined;
    // We should pull this out somewhere so we
    // can reuse it when data is coming form stdin
    // The only difference in that case is we won't display
    // a prompt.
    prompt.display();
    const reader = std.io.getStdIn().reader();
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        std.debug.print("got line - {s}\n", .{line});
        var lexer = Lexer.init(line);
        const MyParser = Parser(@TypeOf(lexer));
        var parser = try MyParser.init(allocator, &lexer);
        var ast = try parser.parse();
        defer ast.deinit(allocator);

        const exit_code: u8 = try executor.execute(&ast);
        // TODO: keep track of last error
        _ = exit_code;
        prompt.display();
    }
}
