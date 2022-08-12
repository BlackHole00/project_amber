package vx_lib_gfx

import gl "vendor:OpenGL"
import "core:math/linalg/glsl"
import "core:strings"
import "core:log"

Shader_Descriptor :: struct {
    vertex_source: string,
    fragment_source: string,
}

Shader :: struct {
    shader_handle: u32,

    uniform_locations: map[string]i32,
}

shader_init :: proc(shader: ^Shader, desc: Shader_Descriptor) {
    if program, ok := gl.load_shaders_source(desc.vertex_source, desc.fragment_source); !ok {
		panic("Could not compile shaders")
	} else do shader.shader_handle = program
}

shader_free :: proc(shader: ^Shader) {
    gl.DeleteProgram(shader.shader_handle)
}

shader_bind :: proc(shader: Shader) {
    gl.UseProgram(shader.shader_handle)
}

shader_uniform_1f :: proc(shader: ^Shader, uniform_name: string, value: f32) {
    if loc, ok := shader_find_uniform_location(shader, uniform_name); !ok {
        log.warn("Could not find the uniform", uniform_name, "in shader", shader.shader_handle)
    } else {
        shader_bind(shader^)
        gl.Uniform1f(loc, value)
    }
}

shader_uniform_2f :: proc(shader: ^Shader, uniform_name: string, value: glsl.vec2) {
    if loc, ok := shader_find_uniform_location(shader, uniform_name); !ok {
        log.warn("Could not find the uniform", uniform_name, "in shader", shader.shader_handle)
    } else {
        shader_bind(shader^)
        gl.Uniform2f(loc, value.x, value.y)
    }
}

shader_uniform_3f :: proc(shader: ^Shader, uniform_name: string, value: glsl.vec3) {
    if loc, ok := shader_find_uniform_location(shader, uniform_name); !ok {
        log.warn("Could not find the uniform", uniform_name, "in shader", shader.shader_handle)
    } else {
        shader_bind(shader^)
        gl.Uniform3f(loc, value.x, value.y, value.z)
    }
}

shader_uniform_4f :: proc(shader: ^Shader, uniform_name: string, value: glsl.vec4) {
    if loc, ok := shader_find_uniform_location(shader, uniform_name); !ok {
        log.warn("Could not find the uniform", uniform_name, "in shader", shader.shader_handle)
    } else {
        shader_bind(shader^)
        gl.Uniform4f(loc, value.x, value.y, value.z, value.w)
    }
}

shader_uniform_mat4f :: proc(shader: ^Shader, uniform_name: string, value: ^glsl.mat4) {
    if loc, ok := shader_find_uniform_location(shader, uniform_name); !ok {
        log.warn("Could not find the uniform", uniform_name, "in shader", shader.shader_handle)
    } else {
        shader_bind(shader^)
        gl.UniformMatrix4fv(loc, 1, false, &value[0, 0])
    }
}

shader_uniform_1i :: proc(shader: ^Shader, uniform_name: string, value: i32) {
    if loc, ok := shader_find_uniform_location(shader, uniform_name); !ok {
        log.warn("Could not find the uniform", uniform_name, "in shader", shader.shader_handle)
    } else {
        shader_bind(shader^)
        gl.Uniform1i(loc, value)
    }
}

@(private)
shader_find_uniform_location :: proc(shader: ^Shader, uniform_name: string) -> (i32, bool) {
    if uniform_name in shader.uniform_locations do return shader.uniform_locations[uniform_name], true

    loc := gl.GetUniformLocation(shader.shader_handle, strings.clone_to_cstring(uniform_name, context.temp_allocator))
    shader.uniform_locations[uniform_name] = loc

    return loc, loc != -1
}
