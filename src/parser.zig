const std = @import("std");
const yash = @import("yash.zig");
const Ast = @import("ast.zig").Ast;
const Lexer = @import("lexer.zig").Lexer;
const TokenType = @import("token.zig").Token.TokenType;
const Token = @import("token.zig").Token;

const Statement = Ast.Statement;


pub fn Parser(comptime L: type) type {
    return struct {
        lexer: *L,
        current: Token = undefined,
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator, lexer: *L) !@This() {
            var self = @This() {
                .lexer = lexer,
                .allocator = allocator
            };
            try self.advance();
            return self;
        }

        fn advance(self: *@This()) !void {
            self.current = try self.lexer.nextToken();
        }

        pub fn parse(self: *@This()) !Ast {
            var statements = std.ArrayList(Statement).init(self.allocator);
            while (self.current.kind != .eof) {
                if (self.current.kind == .semicolon) {
                    try self.advance();
                    continue;
                }
                else if (self.current.kind == .identifier) {
                    const statement = try self.parseStatement();
                    try statements.append(statement);
                }
            }
            return Ast{ .statements = try  statements.toOwnedSlice() };
        }

        fn parseStatement(self: *@This()) !Statement {
            if (self.current.kind != .identifier) {
                return yash.ShellError.ParseError;
            }

            const name = self.current.lexeme;
            try self.advance();

            var args = std.ArrayList([]const u8).init(self.allocator);
            while (self.current.kind == .identifier) {
                try args.append(self.current.lexeme);
                try  self.advance();
            }

            return Statement{
                .Command = Ast.CommandExpr{
                    .name = name,
                    .args = try args.toOwnedSlice(),
                },
            };
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
        .{ .kind = .identifier, .lexeme = "ls"},
        .{ .kind = .identifier, .lexeme = "-la"},
        .{ .kind = .identifier, .lexeme = "foo"},
        .{ .kind = .semicolon, .lexeme = ";"},
        .{ .kind = .identifier, .lexeme = "echo"},
    };

    var mock = MockLexer{ .tokens = &tokens };
    const P = Parser(@TypeOf(mock));
    var parser = try P.init(alloc, &mock);
    var ast = try parser.parse();

    // TODO: validate the ast
    defer ast.deinit(alloc);
}


