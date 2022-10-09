module murasaki.xml;

import murasaki.io;
import murasaki.lexer;
import murasaki.parser;

public class Document {
    public Node nodeTree;

    public this(string file) {
        this.nodeTree = new XMLParser(file).Parse();
    }
}

public struct Attribute {
    Token name;
    Token value;
}

public class Node {
    public string tagname;
    public Node[] children;
    public Attribute[] attributes;

    public bool isTextNode;
    public Token[] innerText;

    public this(string name) {
        this.tagname = name;
    }
}

public class XMLParser : Parser{
    
    public this(string file) {
        super(file);
    }

    public Node Parse() {
        bool no;
        return ParseNode("", no);
    }

    public Node ParseNode(string parent, out bool isEnclosing) {
        Node nd = null;
        isEnclosing = false;

        if (parent != "" && current.type != TokenType.Less) {
            Node tx = new Node("");
            Token[] innerText;
            while(current.type != TokenType.EndOfFile && current.type != TokenType.Less) {
                innerText ~= Next();
            }
            if (innerText.length > 0) {
                tx.innerText = innerText;
                tx.isTextNode = true;
                return tx;
            }
        }

        Match([TokenType.Less]);
        if (current.type == TokenType.Divide) {
           Next();
           Token idname = Match([TokenType.Identifier], "Expected an identifier for tagname");
            if (idname.data == parent) {
                isEnclosing = true;
                Match([TokenType.Greater]);
                return null;
            }
        }
        nd = new Node(Match([TokenType.Identifier], "Expected an identifier for opening tag").data);

        if (current.type != TokenType.Greater) {
            do {
                Token attrValue;
                Token attrName = Match([TokenType.Identifier], "Expected an identifier to open attribute.");
                if (current.type == TokenType.Equals) {
                    Next();
                    attrValue = Match([TokenType.StringLiteral]);
                }

                Attribute attr = Attribute(attrName, attrValue);
                nd.attributes ~= attr;
            } while (current.type != TokenType.EndOfFile && current.type != TokenType.Greater);
            Match([TokenType.Greater]);
        } else {
            Match([TokenType.Greater]);
        }

        while (current.type != TokenType.EndOfFile) {
            bool encloding;
            Node child = ParseNode(nd.tagname, encloding);

            if (encloding || hadErrors)
                break;

            nd.children ~= child;
        }
        
        return nd;
    }
}