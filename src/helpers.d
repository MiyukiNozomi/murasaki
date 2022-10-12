module helpers;

import bindbc.glfw;
import bindbc.opengl;
import bindbc.freetype;

import azuki_iro.font;
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
        FTSupport ftRet = loadFreeType("lib/FreeType.dll");

        if (ftRet != ftSupport) {
            if (ftRet == FTSupport.badLibrary) {
                Printfln("Missing symbols in lib/FreeType.dll");
            } else if (ftRet == FTSupport.noLibrary) {
                Printfln("Missing lib/FreeType.dll");
            } else {
                Printfln("Unknown Error. Please recompile lib/FreeType.dll or reinstall murasaki.");
            }
        } else {
            Printfln("Successfully Loaded FreeType");
        }

        if (!glfwInit()) {
            Printfln("GLFW Failed to initialize!!");
        }
    }

    static void LoadGL() {
        GLSupport glRet = loadOpenGL();

        int major, minor;
        glGetIntegerv(GL_MAJOR_VERSION, &major);
        glGetIntegerv(GL_MINOR_VERSION, &minor);
        Printfln("Version Gotten was %d.%d",
                major, minor);

        if (glRet < GLSupport.gl33) {
            Printfln("Missing required version: OpenGL 3.0, but it's fine.");
        } else {
            Printfln("Got OpenGL 3.0");
        }
    }

    static void Release() {
        glfwTerminate();
    }
}