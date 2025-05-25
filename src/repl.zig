const std = @import("std");
const prompt = @import("prompt.zig");
const exec = @import("exec.zig");
const yash = @import("ast.zig");
const parser = @import("parser.zig");

const max_line_size = 1024;

pub fn run() !void {
    const alloc = std.heap.page_allocator;
    while (true) {
        try prompt.display();
        const line = try get_input_line(alloc);
        defer alloc.free(line);

        //const alloc = std.heap.page_allocator;
        //const ast = parser.parse(alloc, u_input);
        _ = try parser.parse(line);

        // TODO: now parse the line to break it into a series of commands
        // what's the best way to handle &&, ||, subshells
        // should get back a tree to execute
        // TODO: how should we represent the commands
        // they can be built-in, alias, exec, shell command
        // have a struct for each type of command, the a union
        if (should_quit(line)) {
            break;
        }
        try exec.spawn(line);
    }
}


// TODO: need a scanner and a parser
// first tokens supported likely  to be ';', "||", and "&&"
fn get_input_line(alloc: std.mem.Allocator) ![] u8 {
    const stdin = std.io.getStdIn().reader();
    const line = try stdin.readUntilDelimiterOrEofAlloc(alloc, '\n', max_line_size);
    if (line != null)
        return line.?;

    return "";
}

fn should_quit(input: []u8) bool {
        if (!std.mem.eql(u8, input, "exit")) {
            return false;
        }
    return true;
}

