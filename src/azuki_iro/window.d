module azuki_iro.window;

import std.string : toStringz;

import helpers;
import murasaki.io;
import azuki_iro.renderer;

import bindbc.glfw;
import bindbc.opengl;

extern(C)
void SizeCallback(GLFWwindow* wnd, int width, int height) nothrow {
    Window.sizeUpdated = true;
    glViewport(0, 0, width, height);
}

public class Window {

    public GLFWwindow* window;
    public Renderer renderer;

    public static bool sizeUpdated = true;
    public int width, height;

    public this(string title) {
        glfwWindowHint(GLFW_VERSION_MAJOR, 3);
        glfwWindowHint(GLFW_VERSION_MINOR, 2);

        this.window = glfwCreateWindow(800, 600, title.toStringz(), null, null);

        glfwMakeContextCurrent(window);

        glfwSetWindowSizeCallback(window, &SizeCallback);

        Helpers.LoadGL();

        this.renderer = new Renderer();
        this.renderer.targetWindow = this;

    }

    public void LaunchWindow() {
        glfwSwapInterval(1);
        while(!glfwWindowShouldClose(window)) {
            if (sizeUpdated) {
                glfwGetWindowSize(this.window, &width, &height);
                sizeUpdated = false;
            }


            renderer.Render();
        
            glfwPollEvents();
            glfwSwapBuffers(window);
        }
    }
}