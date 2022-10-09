module murasaki.html;

import murasaki.io;
import murasaki.xml;
import murasaki.css;
import murasaki.lexer;

public class HTMLDocument {
    public HTMLElement elements;
}

public class HTMLElement {
    public Token[string] attributes;
    public string tagname;

    public HTMLElement parent;
    public HTMLElement[] children;
    public CSSStylesheet style;

    public string innerText;

    /**same thing as inner text, only difference is that it re-invokes the XMLParser
    when assigned.*/
    public void innerHTML(string v) {
        //TODO revoke parser
        this.innerHTML = v;
    }  
    public string innerHTML(){return innerText;}
}

public class HTMLBodyElement : HTMLElement {
    public this() {
        this.style = new CSSStylesheet();

        // body { margin; 12px; }
        CSSValue defaultMargin = CSSValue();
        defaultMargin.number = 12;
        
        CSSProperty property = new CSSProperty();
        property.parentStylesheet = this.style;
        property.value = defaultMargin;
        property.type = CSSPropertyValueType.Number;

        this.style.rules["margin-top"] = property;
        this.style.rules["margin-left"] = property;
    }
}

public class HTMLParser {
    
    public Node rootNode;

    public this(string file) {
        XMLParser parser = new XMLParser(file);
        rootNode = parser.Parse();
    }

    public HTMLElement Parse() {
        return ParseNode(null, rootNode);
    }

    public HTMLElement ParseNode(HTMLElement parent, Node n) {
        HTMLElement elm = new HTMLElement();
        elm.parent = parent;

        elm.tagname = n.tagname;
        elm.innerText = TokenArrayToText(n.innerText);

        foreach(Attribute attr ; n.attributes) {
            elm.attributes[attr.name.data] = attr.value;
        }

        foreach(Node ndr ; n.children) {
            elm.children ~= ParseNode(elm,ndr);
        }
        return elm;
    }

    public string TokenArrayToText(Token[] a) {
        string f = "";
        
        foreach(Token d ; a) {
            f ~= d.data;
        }

        return f;
    }
}