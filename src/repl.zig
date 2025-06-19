const std = @import("std");
const prompt = @import("prompt.zig");
const exec = @import("exec.zig");
const Ast = @import("ast.zig").Ast;
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
        var ast = parseLine(allocator, line ) catch {
            // TODO: handle specific errors
            std.debug.print("Error parsing input: \n", .{});
            prompt.display();
            continue;
        };
        defer ast.deinit(allocator);

        const exit_code: u8 = try executor.execute(&ast);
        // TODO: keep track of last error
        _ = exit_code;
        prompt.display();
    }
}

fn parseLine(allocator: std.mem.Allocator, line: [] const u8) !Ast {
    var lexer = Lexer.init(line);
    const MyParser = Parser(@TypeOf(lexer));
    var parser = try MyParser.init(allocator, &lexer);
    return try parser.parse();
}
