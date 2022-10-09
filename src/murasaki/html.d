module murasaki.html;

import murasaki.io;
import murasaki.xml;
import murasaki.css;
import murasaki.lexer;

public class HTMLDocument {
    public HTMLElement elements;
}

public class HTMLElement {
    /**same thing as inner text, only difference is that it re-invokes the XMLParser
    when assigned.*/
    public void innerHTML(string v) {
        //TODO revoke parser
        this.innerHTML = v;
    }  

    public CSSStylesheet style;
    
    public string innerHTML(){return innerText;}
    public string innerText;
}