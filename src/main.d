import std.file : readText;

import murasaki.io;
import murasaki.xml;
import murasaki.css;
import murasaki.lexer;

void PrintOut(Node node, string indent =  "") {
    if (node.isTextNode) {
        Printf("%s\"", indent);
        foreach(Token t ; node.innerText) {
            Printf("%s ", t.data);
        }
        Printf("\"\n");
    } else {
        Printf("%s<%s ",indent, node.tagname);

        foreach(Attribute attr ; node.attributes) {
            Printf("%s=%s ", attr.name.data, attr.value.data);
        }

        Printf(">\n");

        foreach (Node nd; node.children) {
            PrintOut(nd, indent ~ "   ");
        }

        Printf("%s</%s>\n", indent, node.tagname);
    }
}

void PrintOut(StyleNode node) {
    for (int i = 0; i < node.targets.length; i++) {
        Printf("%s, ", node.targets[i]);
    }

    Printf(" {\n");

    for (int d = 0; d < node.attributes.length; d++) {
        StyleAttrib attrib = node.attributes[d];
        string f = "";
        for(int k = 0; k < attrib.value.raw.length;k++) {
            f ~= attrib.value.raw[k].data;
        }
        Printf("\t%s: %s;\n", attrib.name,f);
    }

    Printf("}\n");
}

void main() {
    Document document = new Document(readText("test.ftml"));
    StyleNode[] nodes = new StylesheetParser(readText("test.css")).Parse();
    PrintOut(document.nodeTree);
    for (int i = 0; i < nodes.length; i++) {
        PrintOut(nodes[i]);
    }
}