const std = @import("std");
const yash = @import("yash.zig");
const token = @import("token.zig");

const TokenType = token.TokenType;
const Token = token.Token;

pub const LexerError = error{
    invalid,
    invalid_char,
};

pub const Lexer = struct {
    source: []const u8,
    pos: usize,

    pub fn init(src: []const u8) Lexer {
        return Lexer{
            .source = src,
            .pos = 0,
        };
    }

    pub fn nextToken(self: *Lexer) !Token {
        self.skipWhitespace();

        if (self.isAtEnd()) {
            return Token{ .kind = TokenType.eof, .lexeme = "" };
        }
        const c = self.peekChar();

        return switch (c) {
            ';' => self.lexToken(TokenType.semicolon),
            '0'...'9', 'a'...'z', 'A'...'Z', '.', '/', '_' => self.lexIdentifier(),
            else => LexerError.invalid,
        };
    }

    fn lexIdentifier(self: *Lexer) Token {
        // TODO: handle invalid chars
        const start = self.pos;
        while (!self.isAtEnd() and !std.ascii.isWhitespace(self.peekChar())) {
            self.pos += 1;
        }
        return Token{ .kind = TokenType.identifier, .lexeme = self.source[start..self.pos] };
    }

    fn lexToken(self: *Lexer, kind: TokenType) Token {
        const start = self.pos;
        self.pos += 1;
        return Token{ .kind = kind, .lexeme = self.source[start..self.pos] };
    }

    fn skipWhitespace(self: *Lexer) void {
        while (!self.isAtEnd() and std.ascii.isWhitespace(self.peekChar())) {
            self.pos += 1;
        }
    }

    fn peekChar(self: *Lexer) u8 {
        return self.source[self.pos];
    }

    fn isAtEnd(self: *Lexer) bool {
        return self.pos >= self.source.len;
    }
};

test "scan empty line" {
    var lexer = Lexer.init("");
    const result = try lexer.nextToken();
    try std.testing.expectEqual(TokenType.eof, result.kind);
}

test "single indentifier" {
    var lexer = Lexer.init("whatever");
    var result = try lexer.nextToken();
    try std.testing.expect(std.meta.eql(Token{ .kind = TokenType.identifier, .lexeme = "whatever" }, result));
    result = try lexer.nextToken();
    try std.testing.expectEqual(TokenType.eof, result.kind);
}

test "single semicolon" {
    var lexer = Lexer.init(";");
    var result = try lexer.nextToken();
    try std.testing.expectEqualDeep(Token{ .kind = TokenType.semicolon, .lexeme = ";" }, result);
    result = try lexer.nextToken();
    try std.testing.expectEqual(TokenType.eof, result.kind);
}

test "ids with semicolon" {
    var lexer = Lexer.init("ls foo ; blort");
    var result = try lexer.nextToken();
    try std.testing.expectEqualDeep(Token{ .kind = TokenType.identifier, .lexeme = "ls" }, result);

    result = try lexer.nextToken();
    try std.testing.expectEqualDeep(Token{ .kind = TokenType.identifier, .lexeme = "foo" }, result);

    result = try lexer.nextToken();
    try std.testing.expectEqualDeep(Token{ .kind = TokenType.semicolon, .lexeme = ";" }, result);

    result = try lexer.nextToken();
    try std.testing.expectEqualDeep(Token{ .kind = TokenType.identifier, .lexeme = "blort" }, result);

    result = try lexer.nextToken();
    try std.testing.expectEqual(TokenType.eof, result.kind);
}
