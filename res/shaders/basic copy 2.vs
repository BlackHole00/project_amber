#version 450 core

const mat4 MAT4_IDENTITY = mat4 (
    1.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0
);

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aUv;
layout (location = 2) in vec4 aInstanceModelPart1;
layout (location = 3) in vec4 aInstanceModelPart2;
layout (location = 4) in vec4 aInstanceModelPart3;
layout (location = 5) in vec4 aInstanceModelPart4;

layout(location = 0) uniform mat4 uView = MAT4_IDENTITY;
layout(location = 1) uniform mat4 uProj = MAT4_IDENTITY;

out float vDist;
out vec2 vUv;

void main() {
    mat4 InstanceModelMatrix = mat4(aInstanceModelPart1, aInstanceModelPart2, aInstanceModelPart3, aInstanceModelPart4);

    gl_Position = uProj * uView * InstanceModelMatrix * vec4(aPos, 1.0);

    vec3 ObjPos = (InstanceModelMatrix * vec4(aPos, 1.0)).xyz;
    vec3 CameraPos = -uView[3].xyz * mat3(uView);

    vUv = aUv;

    vDist = clamp(1.0 / distance(CameraPos, ObjPos) * 5.0, 0.0, 1.0);
}