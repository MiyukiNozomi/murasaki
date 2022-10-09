module murasaki.css;

import std.conv : to;
import std.algorithm;

import helpers;

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

public enum CSSPropertyValueType {
    Color,
    Number,
    Text,
}

public union CSSValue {
    float[4] color;
    float number;
    string text;
}

public class CSSStylesheet {
    public string href;
    public string cssText;
    public CSSProperty[string] rules;
}

public class CSSProperty {
    CSSStylesheet parentStylesheet;
    CSSProperty parentRule;
    CSSPropertyValueType type;
    CSSValue value;
    bool important;
}

public class StylesheetProcessor {

    public StyleNode[] styleTree;
    public string cssText;

    public this(string cssText) {
        this.styleTree = new StylesheetParser(cssText).Parse();
        this.cssText = cssText;
    }

    public CSSStylesheet[] Generate() {
        CSSStylesheet[] sheets;

        foreach(StyleNode nd ; styleTree) {
            sheets ~= ParseRule(nd);
        }

        return sheets;
    }

    public CSSStylesheet ParseRule(StyleNode nd) {
        CSSStylesheet sheet = new CSSStylesheet();
        sheet.href = nd.targets[0];
        
        //TODO store text representation of each StyleSheet
        sheet.cssText = ""; 

        foreach (StyleAttrib attr ; nd.attributes) {
            CSSProperty property = new CSSProperty();
            property.parentRule = null;

            Token tt = attr.value.raw[0];

            if (tt.type == TokenType.KeywordRGB || tt.type == TokenType.KeywordRGBA) {
                property.type = CSSPropertyValueType.Color;
                tt = attr.value.raw[1];
                Match(tt, [TokenType.LeftParen]);
                float r = AssureColorComponent(attr.value.raw[2]);  

                tt = attr.value.raw[3];
                Match(tt, [TokenType.Comma]);  
                float g = AssureColorComponent(attr.value.raw[4]);  

                tt = attr.value.raw[5];
                Match(tt, [TokenType.Comma]);  
                float b = AssureColorComponent(attr.value.raw[6]);    

                float a = 1;
                if (tt.type == TokenType.KeywordRGBA) {
                    tt = attr.value.raw[7];
                    Match(tt, [TokenType.Comma]);  
                    a = AssureColorComponent(attr.value.raw[8]);  
                    tt = attr.value.raw[9];
                    Match(tt, [TokenType.RightParen]);  
                } else {
                    tt = attr.value.raw[7];
                    Match(tt, [TokenType.RightParen]);
                }
                property.value.color = [r, g, b, a];
            } else if (tt.type == TokenType.IntegerLiteral || tt.type == TokenType.FloatLiteral) {
                property.type = CSSPropertyValueType.Number;
                property.value.number = tt.data.to!float;
            } else {
                property.type = CSSPropertyValueType.Text;
                property.value.text = tt.data;
            }
            sheet.rules[attr.name] = property;
        }

        return sheet;
    }

    public float AssureColorComponent(Token r) {
        if (r.type == TokenType.IntegerLiteral) {
            return ((r.data.to!int & 0xff) / 255f);
        } else if (r.type == TokenType.DoubleLiteral) {
            return Helpers.Clamp!float(r.data.to!float, 0f, 1f);
        } else {
            Error(r.line, "This should definitally be a number :P");
            return 0;
        }
    }
    
    public bool Match(Token current, TokenType[] types, string msg = "") {
        foreach (TokenType t; types) {
            if (current.type == t) {
                return true;
            }
        }

        if (msg == "") {
            Printf("SyntaxError at line '%d', expected type '%s' not '%s'\n", current.line, types[0], current.data);
        } else {
            Printf("SyntaxError at line '%d'> %s\n", current.line, msg);
        }
        return false;
    } 

    void Error(Char, Args...)(int line, in Char[] fmt, Args args) {
        Printf("SyntaxError at line '%d'> %s\n", line, Format(fmt, args));
    }
}

public class StylesheetParser : Parser {

    public this(string file) {
        super(file, LexerMode.CSS);
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