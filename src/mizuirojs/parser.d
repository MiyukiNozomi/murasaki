module mizuirojs.parser;

import murasaki.io;
import murasaki.lexer;
import murasaki.parser;

import mizuirojs.ast;

public class JSParser : Parser {

    public this(string file) {
        super(file, LexerMode.JavaScript);

        /*
            var a = true;
            var b = 0;
            var c = "";

            var d = function() {

            }

            function name() {

            }
        */

        this.current = Token();

        this.Error(120, "%s");
        this.Match([TokenType.IntegerLiteral], "dddddddddd");
    }

    public JSSyntaxTree Parse() {
        JSSyntaxTree tree = new JSSyntaxTree();

        while (current.type != TokenType.EndOfFile) {
            tree.nodes ~= ParseStatement();
        }

        tree.eof = current;
        return tree;
    }

    public Node ParseStatement() {
        if (current.type == TokenType.KeywordVar) {
            return ParseVar();
        } else {
            return ParseExpression();
        }
    }

    public Node ParseVar() {
        // skips 'var'
        Next();
        // grabs name, throw error
        Token name = Match([TokenType.Identifier], "Expected an identifier");
        
        Node expr = null;

        if (current.type == TokenType.Equals) {
            Next();
            expr = ParseExpression();
        }
        
        if (current.type == TokenType.Semicolon) {
            Next();
        }

        return new VarNode(name, expr);
    }

    public Node ParseExpression(int parentPrecende = 0) {
        Node left = ParsePrimary();

        while (true) {
            int precedance = current.type.BinaryOperatorPrecedence();

            if (precedance == 0 || precedance <= parentPrecende)
                break;

            Token operator = Next();
            Node right = ParseExpression(precedance);
            left = new BinaryOp(left, operator, right);
        }

        return left;
    }

    public Node ParsePrimary() {
        if (current.type == TokenType.LeftParen) {
            Next();
            Node nd = ParseExpression();
            Match([TokenType.RightBrace]);
            return nd;
        }
        return new Literal(Match([TokenType.IntegerLiteral,
            TokenType.DoubleLiteral, TokenType.FloatLiteral], "Expected a number"));
    }
}