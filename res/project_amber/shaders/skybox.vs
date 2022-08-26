#version 450 core

layout (location = 0) in vec3 aPos;

out vec3 vUv;

uniform mat4 uProj;
uniform mat4 uView;

void main() {
    vec3 CameraPos = -uView[3].xyz * mat3(uView);

    vUv = aPos;
    gl_Position = uProj * uView * vec4(aPos + CameraPos, 1.0);
}