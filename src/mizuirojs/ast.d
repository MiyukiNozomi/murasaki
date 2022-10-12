module mizuirojs.ast;

import murasaki.io;
import murasaki.lexer;
    

/**
    [4] [*] [2] [-] [2]
    
    precende = 0

    ParsePrimary = Wait for Song

    left = ParsePrimary;

    while true
        operator = curr;
        Next;
        precende = operator.precedance

        if (precende is 0 || precende < parentPrecende)
            break;

        right = ParseExpression();
        left = Binary(left, operator, right);


    OpBinary '-'
      /  \
     2  OpBinary '*' 
          /  \
          4  2

    OP_CONST 4
    OP_CONST 2
    OP_MUL
    OP_CONST 2
    OP_SUB
*/

public enum NodeType {
    BinaryOp,
    Literal,

    Var,
    Function,
}

public abstract class Node {
    public NodeType type;

    public this(NodeType type) {
        this.type = type;
    }

    /*Printout this node in console*/
    public abstract void PrintOut(string indent = "");
}

public class JSSyntaxTree {
    public Token eof;
    public Node[] nodes;
}

public class BinaryOp : Node {
    public Node left;
    public Token operator;
    public Node right;

    public this(Node left, Token operator, Node right) {
        super(NodeType.BinaryOp);
        this.left = left;
        this.operator = operator;
        this.right = right;
    }

    public override void PrintOut(string indent = "") {
        Printf("%sBinaryOp '%s'", indent, operator.data);
        left.PrintOut(indent ~ "   ");
        right.PrintOut(indent ~ "   ");
    }    

}

public class Literal : Node {
    public Token value;

    public this(Token value) {
        super(NodeType.Literal);
        this.value = value;
    }

    public override void PrintOut(string indent = "") {
        Printf("%sLiteral '%s'", indent, value.data);
    }
}

public class VarNode : Node {
    public Token name;
    public Node expr;

    public this(Token name, Node expr) {
        super(NodeType.Var);
        this.name = name;
        this.expr = expr;
    }

    public override void PrintOut(string indent = "") {
        Printf("%sVar '%s'", indent, name);
        if (expr !is null)
            expr.PrintOut(indent ~ "   ");
    }
}