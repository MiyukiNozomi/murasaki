import std.file : readText;

import helpers;

import azuki_iro.font;
import azuki_iro.shader;
import azuki_iro.window;
import azuki_iro.shaders.font;

import murasaki.io;
import murasaki.xml;
import murasaki.css;
import murasaki.html;
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

void PrintOut(CSSStylesheet sheet) {
    Printf("%s => [\n", sheet.href);

    foreach(ruleK ; sheet.rules.byKey) {
        auto rule = sheet.rules[ruleK];
        Printf("\t%s:%s ->", ruleK,rule.type);
        switch(rule.type) {
            case CSSPropertyValueType.Color: {
                float[4] c = rule.value.color;
                Printf("RGBA(%f, %f, %f, %f)", c[0], c[1], c[2], c[3]);
                break;
            }
            case CSSPropertyValueType.Number: {
                Printf("%f", rule.value.number);
                break;
            }
            default:
                Printf("%s", rule.value.text);
                break;
        }
        Printf(" IsImportant:%s\n", rule.important);
    }

    Printf("]\n");
}

void PrintOut(HTMLElement node, string indent = "") {
    if (node.tagname == "") {
        Printfln("%s%s",indent, node.innerText.text);
    } else {
        Printf("%s[%s",indent, node.tagname);
        foreach (string attr ; node.attributes.byKey()) {
            Printf(" %s=%s", attr, node.attributes[attr].data);
        }
        Printfln("]");

        foreach(HTMLElement ndr ; node.children) {
            PrintOut(ndr, indent~" ");
        }

        Printfln("[/%s]", node.tagname);
    }
}

void main() {

    Helpers.LoadLibraries();
/*
    CSSStylesheet[] sheets = new StylesheetProcessor(readText("test.css")).Generate();
    
    for (int i = 0; i < sheets.length; i++)
        PrintOut(sheets[i]);*/

    Window window = new Window("Murasaki Window");

    Font.Init();
    
    Shader.AddShader(new FontShader());
    HTMLParser parser = new HTMLParser(readText("test.html"));
    Printfln("Printing out parsed HTML");
    PrintOut(parser.rootNode);
    
    HTMLElement tree = parser.Parse();
    window.renderer.tree = tree;

    Printfln("Printing out HTMLTree");
    PrintOut(tree);

    window.LaunchWindow();

    
    Font.Release();
    Helpers.Release();
}