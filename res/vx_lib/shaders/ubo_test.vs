#version 330 core
layout (location = 0) in vec3 a_pos;

layout (std140) uniform u_block {
    vec4 u_color;
};
out vec4 v_color;

void main() {
    gl_Position = vec4(a_pos, 1.0);

    v_color = u_color;
}
