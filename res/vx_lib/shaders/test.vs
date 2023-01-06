#version 330 core

layout (location = 0) in vec3 a_position;
layout (location = 1) in vec3 a_color;
layout (location = 2) in vec2 a_uv;

uniform mat4 u_view;
uniform mat4 u_proj;

out vec3 v_color;
out vec2 v_uv;

void main() {
    gl_Position = u_proj * u_view * vec4(a_position, 1.0);

    v_color = a_color;
    v_uv = a_uv;
}
