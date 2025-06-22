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
    while (true) {
        const result = getLine(&buf) catch |err| {
            std.debug.print("Error getting input: {}\n", .{err});
            continue;
        };
        if (result) |line| {
            var ast = parseLine(allocator, line) catch |e| {
                // TODO: handle specific errors
                std.debug.print("Error parsing input: {}\n", .{e});
                continue;
            };
            defer ast.deinit(allocator);

            const exit_code: u8 = executor.execute(&ast) catch |err| {
                // TODO: handle specific errors
                std.debug.print("Error parsing input: {}\n", .{err});
                continue;
            };
            // TODO: keep track of last error
            _ = exit_code;
        } else {
            break;
        }
    }
}

fn parseLine(allocator: std.mem.Allocator, line: []const u8) !Ast {
    var lexer = Lexer.init(line);
    const MyParser = Parser(@TypeOf(lexer));
    var parser = try MyParser.init(allocator, &lexer);
    return try parser.parse();
}

fn getLine(buffer: []u8) !?[]u8 {
    prompt.display();
    const reader = std.io.getStdIn().reader();
    return try reader.readUntilDelimiterOrEof(buffer, '\n');
}
