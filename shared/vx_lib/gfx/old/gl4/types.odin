package vx_lib_gfx_GL4

import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

Gl_Handle :: u32

size_of_gl_type :: proc(gl_type: u32) -> uint {
    switch gl_type {
        case gl.FLOAT:          return size_of(f32)
        case gl.DOUBLE:         return size_of(f64)
        case gl.UNSIGNED_INT:   fallthrough
        case gl.INT:            return size_of(u32)
        case gl.UNSIGNED_SHORT: fallthrough
        case gl.SHORT:          return size_of(u16)
        case gl.UNSIGNED_BYTE:  fallthrough
        case gl.BYTE:           return size_of(byte)
        case gl.FLOAT_MAT4:     return size_of(glsl.mat4)
    }

    panic("Unknown gl type")
}