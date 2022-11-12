#version 450 core

layout(location = 3) uniform sampler2D uBlockTextureAtlas;

in vec2 vUv;

out vec4 FragColor;

void main() {
    FragColor = texture(uBlockTextureAtlas, vUv);
}