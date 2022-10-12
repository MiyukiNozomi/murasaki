module azuki_iro.math.Time;

import bindbc.glfw;

public final class Time {

    private this() {}

    public static float Delta, LastFrame;
    public static float PhysicsStepTime;

    public static void Init() {
        Delta = 0.0f;
        LastFrame = 0.0f;
    }

    public static auto GetTime() {return glfwGetTime();}

    public static void Tick() {
        Delta = glfwGetTime() - LastFrame;
        LastFrame = glfwGetTime();
    }
}