#version 330 core

uniform sampler2D uBlockTextureAtlas;

in vec2 vUv;

out vec4 FragColor;

void main() {
    FragColor = texture(uBlockTextureAtlas, vUv);
}