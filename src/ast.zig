const std = @import("std");
const yash = @import("yash.zig");
const exec = @import("exec.zig");
const builtins = @import("builtins.zig");

pub const Ast = struct {
    statements: []Statement,

    pub const Statement = union(enum) {
        Command: Command,

        pub fn deinit(self: *Statement, alloc: std.mem.Allocator) void {
            switch (self.*) {
                .Command => |*cmd| cmd.deinit(alloc),
            }
        }
    };

    pub const Command = union(enum) {
        Simple: SimpleCommand,
        Group: GroupCommand,

        pub fn deinit(self: *Command, alloc: std.mem.Allocator) void {
            switch (self.*) {
                .Simple => |*simple| simple.deinit(alloc),
                .Group => |*group| group.deinit(alloc),
            }
        }
    };

    pub const SimpleCommand = struct {
        name: []const u8,
        args: []const []const u8,

        pub fn deinit(self: *SimpleCommand, alloc: std.mem.Allocator) void {
            alloc.free(self.args);
        }
    };

    pub const GroupCommand = struct {
        statements: []Statement,

        pub fn deinit(self: *GroupCommand, alloc: std.mem.Allocator) void {
            for (self.statements) |*statement| {
                statement.deinit(alloc);
            }
            alloc.free(self.statements);
        }
    };

    pub fn deinit(self: *Ast, alloc: std.mem.Allocator) void {
        for (self.statements) |*statement| {
            statement.deinit(alloc);
        }
        alloc.free(self.statements);
    }
};
