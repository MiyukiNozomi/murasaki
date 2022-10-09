module murasaki.css;

import murasaki.io;
import murasaki.lexer;
import murasaki.parser;

public struct StyleValue {
    Token[] raw;
}

public struct StyleAttrib {
    string name;
    StyleValue value;
}

public class StyleNode {
    StyleAttrib[] attributes;
    string[] targets; 
}

public class StylesheetParser : Parser {

    public this(string file) {
        super(file);
    }

    public StyleNode[] Parse() {
        StyleNode[] nodes;

        while (current.type != TokenType.EndOfFile) {
            nodes ~= ParseNode();
        }

        return nodes;
    }   

    public string ParseTarget() {
        string target;
        if (current.type == TokenType.Dot ||
            current.type == TokenType.Hashtag) {
            target = Next().data ~ Match([TokenType.Identifier], "").data;
        } else if (current.type == TokenType.Multiply) {
            target = "*";
        } else {
            target = Match([TokenType.Identifier], "").data;
        }
        return target;
    }

    public StyleNode ParseNode() {
        StyleNode node = new StyleNode();
        do {
            if (current.type == TokenType.Comma && node.targets.length > 0)
                Next();
            node.targets ~= ParseTarget();
        } while (current.type == TokenType.Comma && current.type != TokenType.EndOfFile);

        if (node.targets.length == 0) {
            Error(current.line, "Missing Selectors");
            return node;
        }

        Match([TokenType.LeftBrace]);

        while (current.type != TokenType.RightBrace && current.type != TokenType.EndOfFile) {
            string attributeName = Match([TokenType.Identifier]).data;
            Match([TokenType.DoubleDot], "Expected a : to inform property value.");
            Token[] rawValue;

            while (current.type != TokenType.Semicolon && current.type != TokenType.EndOfFile) {
                rawValue ~= Next();
            }
            Match([TokenType.Semicolon]);
            node.attributes ~= StyleAttrib(attributeName, StyleValue(rawValue));
        }

        Match([TokenType.RightBrace]);
        return node;
    }
}