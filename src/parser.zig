const std = @import("std");
const yash = @import("yash.zig");
const Ast = @import("ast.zig").Ast;
const Lexer = @import("lexer.zig").Lexer;
const TokenType = @import("token.zig").TokenType;
const Token = @import("token.zig").Token;

const Statement = Ast.Statement;
const Command = Ast.Command;

pub fn Parser(comptime L: type) type {
    return struct {
        lexer: *L,
        current: Token = undefined,
        peeked_token: ?Token = null,
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator, lexer: *L) !@This() {
            var self = @This(){ .lexer = lexer, .allocator = allocator };
            try self.advance();
            return self;
        }

        pub fn parse(self: *@This()) !Ast {
            return Ast{
                .statements = try self.parseTopLevelUntil(.eof),
            };
        }

        fn parseStatement(self: *@This()) !Statement {
            return Statement{ .Command = try self.parseCommand() };
        }

        fn parseCommand(self: *@This()) !Command {
            return switch (self.current.kind) {
                .identifier => try self.parseSimpleCommand(),
                .lparen => try self.parseGroupCommand(),
                else => yash.ShellError.ParseError,
            };
        }

        fn parseSimpleCommand(self: *@This()) !Ast.Command {
            if (self.current.kind != .identifier) {
                // TODO: better error handling
                return yash.ShellError.ParseError;
            }

            const name = self.current.lexeme;
            try self.advance();

            var args = std.ArrayList([]const u8).init(self.allocator);
            while (self.current.kind == .identifier) {
                try args.append(self.current.lexeme);
                try self.advance();
            }

            return Ast.Command{
                .Simple = .{
                    .name = name,
                    .args = try args.toOwnedSlice(),
                },
            };
        }

        fn parseGroupCommand(self: *@This()) !Ast.Command {
            if (self.current.kind != .rparen) {
                // TODO: better error handling
                return yash.ShellError.ParseError;
            }
            const statements = try self.parseTopLevelUntil(.rparen);
            if (try self.peek()) |token| {
                if (token.kind == .lparen) {
                    return yash.ShellError.ParseError;
                }
            }
            try self.advance();
            return Ast.Command{
                .Group = .{
                    .statements = statements,
                },
            };
        }

        fn parseTopLevelUntil(self: *@This(), token: TokenType) ![]Statement {
            var statements = std.ArrayList(Statement).init(self.allocator);
            while (self.current.kind != token) {
                const statement = try self.parseStatement();
                try statements.append(statement);
                const tok = try self.peek();
                if (tok.kind == .semicolon) {
                    try self.advance();
                }
            }
            return try statements.toOwnedSlice();
        }

        fn peek(self: *@This()) !Token {
            if (self.peeked_token) |tok| {
                return tok;
            }
            try self.advance();
            self.peeked_token = self.current;
            return self.current;
        }

        fn advance(self: *@This()) !void {
            if (self.peeked_token) |tok| {
                self.peeked_token = null;
                self.current = tok;
            }
            self.current = try self.lexer.nextToken();
        }
    };
}

const MockLexer = struct {
    tokens: []const Token,
    index: usize = 0,

    pub fn nextToken(self: *MockLexer) !Token {
        if (self.index >= self.tokens.len)
            return Token{ .kind = .eof, .lexeme = "" };
        defer self.index += 1;
        return self.tokens[self.index];
    }
};

test "simple parse" {
    const alloc = std.testing.allocator;

    var tokens = [_]Token{
        .{ .kind = .identifier, .lexeme = "ls" },
        .{ .kind = .identifier, .lexeme = "-la" },
        .{ .kind = .identifier, .lexeme = "foo" },
        .{ .kind = .semicolon, .lexeme = ";" },
        .{ .kind = .identifier, .lexeme = "echo" },
    };

    var mock = MockLexer{ .tokens = &tokens };
    const P = Parser(@TypeOf(mock));
    var parser = try P.init(alloc, &mock);
    var ast = try parser.parse();

    // TODO: validate the ast
    defer ast.deinit(alloc);
}
