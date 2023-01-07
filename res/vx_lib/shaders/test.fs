#version 330 core

uniform sampler2D u_texture;
uniform float u_time;

in vec3 v_color;
in vec2 v_uv;

out vec4 o_color;

void main() {
    u_texture;

    //o_color = texture(u_texture, v_uv) * vec4(v_color, 1.0);
    o_color = mod(u_time, 1.0) * texture(u_texture, v_uv) * vec4(v_color, 1.0);
}