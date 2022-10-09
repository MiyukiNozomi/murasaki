module helpers;

public class Helpers {
    private this() {}

    template Clamp(T) {
        public static T Clamp(T a, T min, T max) {
            if (a <= max && a >= min) return a;
            if (a < min) return min;
            else return max;
        }
    }
}