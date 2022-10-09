module murasaki.lexer;

import std.ascii;

public enum LexerMode {
    CSS,
    JavaScript,
    HTML,
}

public enum TokenType {
    Invalid,

    // Identifiers and Keywords
    Identifier,
    
    // Literals
    DoubleLiteral,
    FloatLiteral,
    IntegerLiteral,
    StringLiteral,

    // Operators
    Equals,
    EqualsEquals,
    Greater, Less,
    GreaterEquals, LessEquals,
    And,
    Or,
    Plus,
    Minus,
    Divide,
    Module,
    Multiply,

    Comma,
    Dot,
    DoubleDot,
    Hashtag,

    PlusPlus,
    MinusMinus,

    Not,
    NotEquals,

    // Block Start and Closing
    LeftParen,
    RightParen,
    LeftBrace,
    RightBrace,

    // CSS Keywords
    KeywordRGBA,
    KeywordRGB,

    KeywordPrint,
    // Symbols
    Semicolon,

    // EOF, just to know when the source string ends
    EndOfFile
}

public struct Token {
    TokenType type;
    int line;
    string data;
}

public class Lexer {

    public string content;
    public int position, currentLine;

    public char current;
    public LexerMode mode;

    public this(string content, LexerMode mode = LexerMode.HTML) {
        this.content = content;
        this.position = 0;
        this.currentLine = 1;
        this.Next();
        this.mode = mode;
    }

    public char Next() {
        char last = current;
        if (position >= content.length) {
            current = '\0';
        } else {
            current = content[position++];    
            if (current == '\n')
                currentLine++;
        }
        return last;
    }

    public Token NextToken() {
        if (current == '\0')
            return Token(TokenType.EndOfFile, currentLine, "");
        while (isWhite(current) && current != '\0') {
            Next();
        }

        // Floats and Integers
        if (isDigit(current)) {
            string number = "";
            TokenType type = TokenType.IntegerLiteral;

            while ((current == '.' || current == 'f' || isDigit(current)) && current != '\0') {
                if (current == '.')
                    type = TokenType.DoubleLiteral;
                if (current == 'f') {
                    type = TokenType.FloatLiteral;
                    Next();
                    break;
                }
                number ~= Next();
            }

            return Token(type, currentLine, number);
        }

        // Identifiers and Keywords
        if (isAlpha(current) || current == '_') {
            string identifier = "";

            while ((isAlpha(current) || current == '_' || current == '-' || isDigit(current)) && current != '\0') {
                identifier ~= Next();
            }

            return Token(TypeForString(this.mode, identifier), currentLine, identifier);
        }

        if (current == '"') {
            // We don't need the " on our final string.
            Next();

            string value = "";
            
            while (true) {
                if (current == '"' || current == '\0')
                    break;
                value ~= Next();
            }
            Next();

            return Token(TokenType.StringLiteral, currentLine, value);
        }

        // now for the operators
        // simpler to just make a macro to add all the if-bullshitery

        mixin(DoubleSymbolMatch!('+', '+', "Plus", "PlusPlus"));
        mixin(DoubleSymbolMatch!('-', '-', "Minus", "MinusMinus"));
        mixin(DoubleSymbolMatch!('&', '&', "And", "And"));
        mixin(DoubleSymbolMatch!('|', '|', "Or", "Or"));
        
        mixin(Symbol!('/', "Divide"));
        mixin(Symbol!('%', "Module"));
        mixin(Symbol!('*', "Multiply"));
        mixin(Symbol!('(', "LeftParen"));
        mixin(Symbol!(')', "RightParen"));
        mixin(Symbol!('{', "LeftBrace"));
        mixin(Symbol!('}', "RightBrace"));
        mixin(Symbol!(',', "Comma"));
        mixin(Symbol!('.', "Dot"));
        mixin(Symbol!(':', "DoubleDot"));
        mixin(Symbol!('#', "Hashtag"));

        mixin(Symbol!(';', "Semicolon"));

        // Operators like ==, +=, and -=
        mixin(DoubleSymbolMatch!('=', '=', "Equals", "EqualsEquals"));
        mixin(DoubleSymbolMatch!('>', '=', "Greater", "GreaterEquals"));
        mixin(DoubleSymbolMatch!('<', '=', "Less", "LessEquals"));
        mixin(DoubleSymbolMatch!('!', '=', "Not", "NotEquals"));

        mixin(Symbol!('<', "Less"));

        return Token(TokenType.Invalid, currentLine, ""~Next());
    }
}

// Simpler way to add symbols
template Symbol(char symbol, string type) {
    const char[] Symbol = "
        if (current == '"~ symbol~"') {
            return Token(TokenType." ~type~", currentLine, \"\" ~ Next());
        }
    ";
}

template DoubleSymbolMatch(char symbol, char additional, string singleType, string additionalType) {
    const char[] DoubleSymbolMatch = "
        if (current == '"~ symbol~"') {
            Next();
            if (current == '" ~additional~"') {
                Next();
                return Token(TokenType." ~ additionalType~", currentLine, \""~symbol ~ additional~"\");
            }
            return Token(TokenType." ~singleType~", currentLine, \"" ~symbol~"\");
        }
    ";
}


// Identify the types of words.
auto TypeForString(LexerMode mode, string identifier) {
    if (mode == LexerMode.CSS) {
        if (identifier == "rgba") {
            return TokenType.KeywordRGBA;
        } else if (identifier == "rgb") {
            return TokenType.KeywordRGB;
        }
    }
    return TokenType.Identifier;
}

// Precedence for Operators, the higher the value
// the highter the priority of the operator it will be.
auto BinaryOperatorPrecedence(TokenType type) {
    switch(type) {
        case TokenType.Multiply:
        case TokenType.Divide:
        case TokenType.Module:
            return 4;
        case TokenType.Plus:
        case TokenType.Minus:
            return 3;
        case TokenType.Less:
        case TokenType.Greater:
        case TokenType.LessEquals:
        case TokenType.GreaterEquals:
        case TokenType.EqualsEquals:
        case TokenType.NotEquals:
            return 2;
        case TokenType.Or:
        case TokenType.And:
            return 1;
        default:
            return 0;
    }
}

// Precedence of Unary Operators
// doesn't really has a purpose other than saying if its a unary operator or not.
auto UnaryOperatorPrecedence(TokenType type) {
    switch(type) {
        case TokenType.Not:
        case TokenType.Minus:
        case TokenType.PlusPlus:
        case TokenType.MinusMinus:
            return 1;
        default:
            return 0;
    }
}