pub const TokenType = enum {
    eof, // or eol
    identifier,
    semicolon,
};

pub const Token = struct {
    kind: TokenType,
    lexeme: []const u8,
};
