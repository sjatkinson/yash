const std = @import("std");
const yash = @import("yash.zig");
const exec = @import("exec.zig");

pub const Ast = struct {
    statements: [] Statement,

    pub const Statement = union(enum) {
        Command: CommandExpr,

        pub fn deinit(self: *Statement, alloc: std.mem.Allocator) void {
            switch (self.*) {
                .Command => |*cmd| cmd.deinit(alloc),
            }
        }

    };

    pub const CommandExpr = struct {
        name: []const u8,
        args: [] const [] const u8,

        pub fn deinit(self: *CommandExpr, alloc: std.mem.Allocator) void {
                alloc.free(self.args);
        }
    };

    pub fn deinit(self: *Ast, alloc: std.mem.Allocator) void {
        for (self.statements) |*statement| {
            statement.deinit(alloc);
        }
        alloc.free(self.statements);
    }

    pub fn execute(self: *Ast) !u8 {
        var last_exit_code: u8 = 0;
        for (self.statements) |stmt| {
            last_exit_code = try executeStatement(&stmt);
        }
        return last_exit_code;
    }

};
 fn executeStatement(statement: *const Ast.Statement) !u8 {
            return switch(statement.*) {
                .Command => |cmd| try executeCommand(cmd),
            };
}

 fn executeCommand(cmd: Ast.CommandExpr) !u8 {
     if (cmd.name.len == 0)
         return yash.ShellError.ParseError;  // TODO: fix this

     return try exec.spawn(cmd.name, cmd.args);
}
