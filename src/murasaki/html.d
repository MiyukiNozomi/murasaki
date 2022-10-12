module murasaki.html;

import azuki_iro.font;
import azuki_iro.math.linalg;

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

    public Text2D innerText;

    public this() {
        this.style = new CSSStylesheet();
        CSSValue defaultFontSize = CSSValue();
        defaultFontSize.number = 12;
        
        CSSProperty property = new CSSProperty();
        property.parentStylesheet = this.style;
        property.value = defaultFontSize;
        property.type = CSSPropertyValueType.Number;
        this.style.rules["font-size"] = property;
        innerText = new Text2D(0, 0, "", Font.loadedFonts["YaheiUI"], float3(0,0,0), 0.10);
    }

    /**same thing as inner text, only difference is that it re-invokes the XMLParser
    when assigned.*/
    public void innerHTML(string v) {
        //TODO revoke parser
    }  
    public string innerHTML(){return innerText.text;}
}

public class HTMLBodyElement : HTMLElement {
    public this() {
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

    public HTMLElement ElementFactory(string tagname) {
        HTMLElement elm;
        switch(tagname) {
            case "body":
                elm = new HTMLBodyElement();
                break;
            default:
                elm = new HTMLElement();
                break;
        }
        elm.tagname = tagname;
        return elm;
    }

    public HTMLElement ParseNode(HTMLElement parent, Node n) {
        HTMLElement elm = ElementFactory(n.tagname);
        elm.parent = parent;

        elm.innerText.text = TokenArrayToText(n.innerText);

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
            f ~= d.data ~ " ";
        }

        return f;
    }
}