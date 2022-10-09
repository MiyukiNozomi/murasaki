module azuki_iro.window;

import std.string : toStringz;

import helpers;
import murasaki.io;

import bindbc.glfw;
import bindbc.opengl;

extern(C)
void SizeCallback(GLFWwindow* wnd, int width, int height) nothrow {
    glViewport(0, 0, width, height);
}

public class Window {

    public GLFWwindow* window;

    public this(string title) {
        glfwWindowHint(GLFW_VERSION_MAJOR, 3);
        glfwWindowHint(GLFW_VERSION_MINOR, 2);

        this.window = glfwCreateWindow(800, 600, title.toStringz(), null, null);

        glfwMakeContextCurrent(window);

        glfwSetWindowSizeCallback(window, &SizeCallback);

        Helpers.LoadGL();
    }

    public void LaunchWindow() {
        while(!glfwWindowShouldClose(window)) {
            glfwPollEvents();
            glfwSwapBuffers(window);
        }
    }
}