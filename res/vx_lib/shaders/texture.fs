#version 330 core

uniform sampler2D u_texture1;
uniform sampler2D u_texture2;

in vec2 v_uv;

out vec4 o_color;

void main() {
    u_texture2;
    o_color = mix(1.0 - texture(u_texture1, v_uv), texture(u_texture2, v_uv), 0.65);
    //o_color = 1.0 - texture(u_texture1, v_uv);
}