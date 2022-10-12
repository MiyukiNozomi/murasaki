module azuki_iro.math.Transform;

import azuki_iro.math.Mathf;
import azuki_iro.math.linalg;

public class Transform {
    public float3 position;
    public float3 rotation;
    public float3 scale;

    public float3 oldPosition;
    public float3 oldRotation;
    public float3 oldScale;

    public bool transformUpdated = true;

    public this() {
        this(0,0,0);
    }

    public this(float x, float y, float z) {
        this.position = float3(x,y,z);
        this.rotation = float3(0,0,0);
        this.scale = float3(1,1,1);
    }

    public void Translate(float3 newPos) {
        Translate(newPos.x, newPos.y, newPos.z);
    }

    public void Translate(float x, float y, float z) {
        this.position.x += x;
        this.position.y += y;
        this.position.z += z;
    }

    public void Rotate(float3 newRos) {
        Rotate(newRos.x, newRos.y, newRos.z);
    }

    public void Rotate(float x, float y, float z) {
        this.rotation.x += x;
        this.rotation.y += y;
        this.rotation.z += z;
    }

    public mat4 GetWorldMatrix() {
        mat4 translationMat = mat4.translation(position);
        mat4 rotationMat =  mat4.rotation(rotation.x, Mathf.AxisX) * 
                            mat4.rotation(rotation.y, Mathf.AxisY) * 
                            mat4.rotation(rotation.z, Mathf.AxisZ);
        mat4 scalingMat = mat4.scaling(scale.x, scale.y, scale.z);
        return translationMat * scalingMat * rotationMat;
    }

    public mat4 GetModelMatrix() {
        mat4 rotationMat = mat4.rotation(rotation.x, Mathf.AxisX) * 
        mat4.rotation(rotation.y, Mathf.AxisY) * 
        mat4.rotation(rotation.z, Mathf.AxisZ);
        return rotationMat;
    }

    public mat4 GetTransformation() {
        if (position != oldPosition ||
            rotation != oldRotation ||
            scale != oldScale) {
            oldPosition = position;
            oldRotation = rotation;
            oldScale = scale;
            transformUpdated = true;
        } else {
            transformUpdated = false;
        }
		mat4 transformation = mat4.scaling(scale.x, scale.y, scale.z)
		* mat4.rotation(rotation.x, Mathf.AxisX)
		* mat4.rotation(rotation.y, Mathf.AxisY)
		* mat4.rotation(rotation.z, Mathf.AxisZ);
		transformation = transformation.translate(position);
        return transformation;
    }

    public mat3 GetNormalMatrix() {
        return mat3(GetTransformation().inverse().transposed());
    }
}