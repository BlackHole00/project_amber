#version 450 core
out vec4 FragColor;

in vec3 vUv;

layout (location = 2) uniform samplerCube uSkybox;

void main() {
    FragColor = texture(uSkybox, vUv);
}