module azuki_iro.math.Mathf;

import std.math;
import std.random;
import std.stdint;
import std.digest : toHexString;
import std.conv : to;

import azuki_iro.math.linalg;

public class Mathf {

    public static float MinValue = -3.402823E+38;

    public static float3 AxisX = float3(1, 0, 0);
    public static float3 AxisY = float3(0, 1, 0);
    public static float3 AxisZ = float3(0, 0, 1);

    public static float4 Zero4f = float4(0, 0, 0, 0);
    public static float4 One4f = float4(1,1,1, 1);

    public static float3 Zero = float3(0, 0, 0);
    public static float3 One = float3(1, 1, 1);

    /** ratio of the circumference of a circle to its diameter*/
    public static float PI = 3.141592653589793f;
    /**shorthand for Mathf.PI * 2*/
    public static float TwoPi = 3.141592653589793f * 2;
    /**shorthand for Mathf.PI / 2*/
    public static float HalfPi = 3.141592653589793f * 2;
    /**Mathf.ToRadians() but better*/
    public static float ToRadians = 3.141592653589793f / 180;
    /**Mathf.ToDegress() but better*/
    public static float ToDegress = 180 / 3.141592653589793f;

    public static float PositiveInfinity =  float.infinity;
    public static float NegativeInfinity = -float.infinity;

    private this() {}

    public static float Major(float3 vec) {
        return Mathf.Max(Mathf.Max(vec.x, vec.y), vec.z);
    }

    public static float ToDegreesf(float d) {
        return cast(float) ToDegrees(d);
    }

    public static float Sqrt(float d) {
        return cast(float) sqrt(d);
    }    

    public static float Cos(float d) {
        return cast(float) cos(d);
    }
    
    public static float Sin(float d) {
        return cast(float) sin(d);
    }

    public static float ACos(float a) {
        return cast(float) acos(a);
    }

    public static float ASin(float a) {
        return cast(float) asin(a);
    }

    public static float SafeASin(float a) {
        if (a <= -1) return -HalfPi;
        if (a >= 1) return HalfPi;
        return ASin(a);
    }

    public static float SafeACos(float a) {
        if (a <= -1) return -PI;
        if (a >= 1) return 0;
        return ACos(a);
    }

    public static float Atan(float d) {
        return cast(float) atan(d);
    }

    public static float Tan(float a) {
        return cast(float)tan(a);
    }

    public static float Abs(float a) {
		return a > 0 ? a : -a;
    }

    public static float3 AbsF3(float3 ab) {
        return float3(
            Abs(ab.x),
            Abs(ab.y),
            Abs(ab.z)
        );
    }

    public static float ToRad(float ang) {
        return ang * (Mathf.PI / 180);
    }
    public static float3 ToRad(float3 angs) {
        return float3(
            ToRad(angs.x),
            ToRad(angs.y),
            ToRad(angs.z),
        );
    }

	public static float BarryCentric(float3 p1, float3 p2, float3 p3, float2 pos) {
		float det = (p2.z - p3.z) * (p1.x - p3.x) + (p3.x - p2.x) * (p1.z - p3.z);
		float l1 = ((p2.z - p3.z) * (pos.x - p3.x) + (p3.x - p2.x) * (pos.y - p3.z)) / det;
		float l2 = ((p3.z - p1.z) * (pos.x - p3.x) + (p1.x - p3.x) * (pos.y - p3.z)) / det;
		float l3 = 1.0f - l1 - l2;
		return l1 * p1.y + l2 * p2.y + l3 * p3.y;
	}

    public static float3 Lerp(float3 a, float3 b, float f) {
        return float3(
            Lerp(a.x, b.x, f),
            Lerp(a.y, b.y, f),
            Lerp(a.z, b.z, f)
        );
    }
    public static float Lerp(float a, float b, float f) {
        return a + f * (b - a);
    }

    public static mat4 GetProjection(int width, int height, float fov, float nearPlane, float farPlane) {
        mat4 projection = mat4.perspective(width, height, fov, nearPlane, farPlane);
        return projection;
    }

    public static mat4 GetView(float3 position, float3 rotation) {
        mat4 view = mat4.rotation(rotation.x, float3(1,0,0)) *
        mat4.rotation(rotation.y, float3(0,1,0)) *
        mat4.rotation(rotation.z, float3(0,0,1)) * mat4.translation(
            float3(-position.x, -position.y, -position.z)
        );
        return view;    
    }

    public static mat4 GetTransformation(float3 position, float3 rotation, float3 scale) {
		mat4 transformation = mat4.scaling(scale.x, scale.y, scale.z)
		* mat4.rotation(rotation.x, Mathf.AxisX)
		* mat4.rotation(rotation.y, Mathf.AxisY)
		* mat4.rotation(rotation.z, Mathf.AxisZ);
		transformation = transformation.translate(position);
        return transformation;
    }

    public static mat4 GetTransformation(float2 position, float2 scale) {
        mat4 transformation = mat4.scaling(scale.x, scale.y, 0);
        transformation.translate(position.x, position.y, 0);
        return transformation;
    }

    public static bool PointInRectangle(float pX, float pY, float2 position, float2 scale) {
        return  pX <= (position.x + (scale.x)) &&
                pX >= (position.x) &&
                pY <= (position.y + (scale.y)) &&
                pY >= (position.y);
    }

    public static float Max(float a, float b) {
        return (((a) > (b)) ? (a) : (b));
    }

    public static float Min(float a, float b) {
        return (((a) < (b)) ? (a) : (b));
    }

 /*   public static double ToRadians(double angdeg) {
        return angdeg / 180.0 * PI;
    }*/

    public static double ToDegrees(double angdeg) {
        return angdeg * 180.0 / PI;
    }

    public static int RandomInt(int min, int max) {
        return uniform(min, max);
    }

    public static double Random() {
        return cast(double) (uniform(0.0, 1.0));
    }
    
    public static float RandomFloat() {
        return cast(float) (uniform(0.0, 1.0));
    }

    public static float Clamp(float x, float min, float max) {
        return x < min ? min : x > max ? max : x;
    }

    public static int ClampI(int x, int min, int max) {
        return x < min ? min : x > max ? max : x;
    }

    public static float AssertNotNaN(float a) {
        return isNaN(a) ? 0 : a;
    }

    public static float3 Flip(float3 a) {
        return float3(
            a.x > 0.5 ? 0 : 1,
            a.y > 0.5 ? 0 : 1,
            a.z > 0.5 ? 0 : 1,
        );
    }

    public static bool IsNaN(float3 v) {
        return isNaN(v.x) || isNaN(v.y) || isNaN(v.z);
    }

    public static float3 AssertNotNaN(float3 a) {
        return float3(
            isNaN(a.x) ? 0 : a.x, 
            isNaN(a.y) ? 0 : a.y,
            isNaN(a.z) ? 0 : a.z
        );
    }

    public static float Distance(float3 pointA, float3 pointB) {
        float3 vecDistance = pointA - pointB;
        return Mathf.Sqrt(vecDistance.dot(vecDistance));
    }

    public static float LengthSquared(float3 v) {
        return v.x * v.x + v.y * v.y + v.z * v.z;
    }

    public static float DistanceSquared(float3 a, float3 b) {
        float dx = a.x - b.x;
        float dy = a.y - b.y;
        float dz = a.z - b.z;
        return dx * dx + dy * dy + dz * dz;
    }

    /*Half of a milimiter :D*/
    public static float VerySmallFloat = 0.0005f;

    /*float == float won't quite work because of floating point precision errors 
    so, we'll just check if they're close enough.*/
    public static bool NearlyEqual(float a, float b) {
        return Mathf.Abs(a - b) < VerySmallFloat;
    }

    public static bool NearlyEqual(float3 a, float3 b) {
        return NearlyEqual(a.x, b.x) && NearlyEqual(a.y, b.y) && NearlyEqual(a.z, b.z);
    }
}