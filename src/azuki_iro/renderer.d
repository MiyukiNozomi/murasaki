module azuki_iro.renderer;

import bindbc.opengl;

import murasaki.io;
import murasaki.css;
import murasaki.html;

import azuki_iro.window;
import azuki_iro.math.linalg;

public class Renderer {

    public Window targetWindow;
    public HTMLElement tree;

    public float2 totalMargin;
    public mat4 ortho2DProjection;

    public void Render() {
        ortho2DProjection = mat4.orthographic(0.0f, targetWindow.width, 0.0f,
                                              targetWindow.height, -0.20, 10);
        totalMargin = float2(0, 0);
        lastHeight = 0;
        glClear(GL_COLOR_BUFFER_BIT);
        glClearColor(1,1,1,1);

        RenderNode(tree);
    }

    float lastHeight = 0;
    public void RenderNode(HTMLElement node) {
        if (("margin-left" in node.style.rules) !is null) {
            this.totalMargin.x += node.style.rules["margin-left"].value.number;
        }
        if (("margin-top" in node.style.rules) !is null) {
            this.totalMargin.y += node.style.rules["margin-top"].value.number;
        }

        if (("font-size" in node.style.rules) !is null) {
            node.innerText.scale = node.style.rules["font-size"].value.number / 12;
        }
        node.innerText.Render(this.ortho2DProjection, this.totalMargin, targetWindow.height - lastHeight);
        lastHeight += node.innerText.maxMarginY;

        for (size_t i = 0; i < node.children.length; i++) {
            RenderNode(node.children[i]);
        }
    }
}