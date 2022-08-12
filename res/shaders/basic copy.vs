#version 450 core

const mat4 MAT4_IDENTITY = mat4 (
    1.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0
);

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aUv;

layout(location = 0) uniform mat4 uModel = MAT4_IDENTITY;
layout(location = 16) uniform mat4 uView = MAT4_IDENTITY;
layout(location = 32) uniform mat4 uProj = MAT4_IDENTITY;

out vec2 vUv;

void main() {
    gl_Position = uProj * uView * uModel * vec4(aPos, 1.0);
    vUv = aUv;
}