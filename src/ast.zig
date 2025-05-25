const std = @import("std");

pub const Ast = struct {
    allocator: *std.mem.Allocator,

    pub const Node = union(enum) {
        Command: CommandNode,
        Sequence: SequenceNode,
    };

    pub const CommandNode = struct {
        program: []const u8,
        args: []Node,
    };

    pub const SequenceNode = struct {
        parts: []Node,
    };


};

