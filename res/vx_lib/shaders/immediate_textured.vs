#version 450 core

const mat4 MAT4_IDENTITY = mat4 (
    1.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0
);

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aUv;

out vec2 vUv;

void main() {
    gl_Position =  vec4(aPos, 1.0);

    vUv = aUv;
}