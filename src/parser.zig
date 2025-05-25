const std = @import("std");
const yash = @import("yash.zig");
const ast = @import("ast.zig");
const Lexer = @import("lexer.zig").Lexer;



//pub fn parse(allocator: *std.mem.Allocator, line : []u8) !yash.Ast.Node {
pub fn parse(line : [] u8) !ast.Ast.Node {
    var lexer = Lexer.init(line);
    while (true) {
        _ = lexer.nextToken() catch |err| {
            std.debug.print("failure {} parsing line {s}", .{err, line});
            return yash.ShellError.ParseError;
        };
        // TODO: build up an ast
        break;
    }
    return yash.ShellError.ParseError;
}

test "simple parse" {
    const alloc = std.testing.allocator;
    const line = "ls -la";

    const tree = parse(alloc, line);
    try std.testing.expectError(yash.ShellError.ParseError, tree);
}


