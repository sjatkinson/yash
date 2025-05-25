const yash_repl  = @import("repl.zig");

pub const repl = yash_repl.run;

pub const ShellError = error {
    ParseError,
};
