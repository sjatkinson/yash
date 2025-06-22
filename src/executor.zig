const std = @import("std");
const yash = @import("yash.zig");
const exec = @import("exec.zig");
const builtins = @import("builtins.zig");
const Ast = @import("ast.zig").Ast;

pub const Executor = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Executor {
        return Executor{
            .allocator = allocator,
        };
    }

    pub fn execute(self: *Executor, ast: *const Ast) !u8 {
        var last_exit_code: u8 = 0;
        for (ast.statements) |stmt| {
            last_exit_code = try self.executeStatement(&stmt);
        }
        return last_exit_code;
    }

    fn executeStatement(self: *Executor, statement: *const Ast.Statement) !u8 {
        return switch (statement.*) {
            .Command => |cmd| try self.executeCommand(cmd),
        };
    }

    fn executeCommand(self: *Executor, cmd: Ast.Command) !u8 {
        switch (cmd) {
            .Simple => |simple| {
                if (simple.name.len == 0)
                    return yash.ShellError.ParseError; // TODO: fix this

                const maybeBuiltin = builtins.findBuiltin(simple.name);
                if (maybeBuiltin) |func| {
                    func(self.allocator, simple.args);
                    return 0;
                }
                // TODO: is it an alias, or a built-in

                return try exec.execute(self.allocator, simple.name, simple.args);
            },
            .Group => |_| {
                return yash.ShellError.NotImplemented;
            },
        }
    }
};
