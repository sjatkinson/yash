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
    
    while (true) {
        try prompt.display();
        const line = try get_input_line(allocator);
        defer allocator.free(line);

        var lexer = Lexer.init(line);
        const MyParser = Parser(@TypeOf(lexer));
        var parser = try MyParser.init(allocator, &lexer);
        var ast = try parser.parse();
        defer ast.deinit(allocator);

        const exit_code: u8 = try executor.execute(&ast);
        // TODO: keep track of last error
        _ = exit_code;
    }
}

// first tokens supported likely  to be ';', "||", and "&&"
fn get_input_line(allocator: std.mem.Allocator) ![]u8 {
    const stdin = std.io.getStdIn().reader();
    const line = try stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', max_line_size);
    if (line != null)
        return line.?;

    return "";
}
