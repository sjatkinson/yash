const std = @import("std");
const prompt = @import("prompt.zig");
const exec = @import("exec.zig");

const max_line_size = 1024;

pub fn run() !void {
    while (true) {
        try prompt.display();
        const u_input = try get_input_line();
        if (should_quit(u_input)) {
            break;
        }
        if (u_input) |input| {
            // TODO: split the line in args
            try exec.spawn(input);
        }
    }
}


// TODO: need a scanner and a parser
// first tokens supported likely  to be ';', "||", and "&&"
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

