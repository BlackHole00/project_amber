#version 330 core

uniform sampler2D uTexture;

in vec2 vUv;
in float vDist;

out vec4 FragColor;

void main() {
    FragColor = texture(uTexture, vUv) * vec4(vDist, vDist, vDist, 1.0);
}