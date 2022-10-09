module murasaki.parser;

import murasaki.io;
import murasaki.lexer;

public class Parser {
    public Lexer lexer;
    public Token current;

    public bool hadErrors = false;

    public this(string source) {
        this.lexer = new Lexer(source);
        this.Next();
    }

    public Token Next() {
        Token last = current;
        current = lexer.NextToken();
        return last;
    }

    public Token Match(TokenType[] types, string msg = "") {
        foreach (TokenType t; types) {
            if (current.type == t) {
                return Next();
            }
        }

        if (msg == "") {
            Printf("SyntaxError at line '%d', expected type '%s' not '%s'\n", current.line, types[0], current.data);
        } else {
            Printf("SyntaxError at line '%d'> %s\n", current.line, msg);
        }
        Next();

        hadErrors = true;
        return Token(types[0], current.line, "");
    } 

    void Error(Char, Args...)(int line, in Char[] fmt, Args args) {
        Printf("SyntaxError at line '%d'> %s\n", line, Format(fmt, args));
    }
}