pub const TokenType = enum {
    eof, // or eol
    identifier,
    semicolon,
    rparen,
    lparen,
};

pub const Token = struct {
    kind: TokenType,
    lexeme: []const u8,
};
