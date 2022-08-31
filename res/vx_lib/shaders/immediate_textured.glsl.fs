#version 450 core

layout(location = 2) uniform sampler2D uTexture;

in vec2 vUv;

out vec4 FragColor;

void main() {
    FragColor = texture(uTexture, vUv);
}