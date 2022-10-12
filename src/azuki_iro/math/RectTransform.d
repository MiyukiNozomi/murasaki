module azuki_iro.math.RectTransform;

import azuki_iro.math.Mathf;

import azuki_iro.math.linalg;

public class RectTransform {
    public float2 position;
    public float2 scale;

    public this() {
        this.position = float2(0,0);
        this.scale = float2(1,1);
    }

    public mat4 GetTransformation() {
        return Mathf.GetTransformation(this.position, this.scale);
    }
}