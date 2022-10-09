module helpers;

import bindbc.glfw;
import bindbc.opengl;

import murasaki.io;

public class Helpers {
    private this() {}

    template Clamp(T) {
        public static T Clamp(T a, T min, T max) {
            if (a <= max && a >= min) return a;
            if (a < min) return min;
            else return max;
        }
    }

    static void LoadLibraries() {
        GLFWSupport glfwRet = loadGLFW("lib/glfw3.dll");

        if (glfwRet != glfwSupport) {
            Printf("Error! error!\n");   
            if (glfwRet == GLFWSupport.noLibrary) { 
                Printf("missing binary/glfw3.dll\n");
            } else if (GLFWSupport.badLibrary) {
                 Printf("binary/glfw3.dll is missing required symbols.\n");
            } else {
                Printf("Unknown Error, please reinstall murasaki or recompile GLFW version 3.0\n");
            }
        } else {
            Printf("Successfully Loaded GLFW!\n");
        }

        glfwInit();
    }

    static void LoadGL() {
        GLSupport glRet = loadOpenGL();

        if (glRet < GLSupport.gl33) {
            Printf("Missing required version: OpenGL 3.0, but it's fine.");
        } else {
            Printf("Got OpenGL 3.0");
        }
    }

    static void Release() {
        glfwTerminate();
    }
}