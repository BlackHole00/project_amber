package vx_lib_gfx_immediate

import "../../gfx"
import gl "vendor:OpenGL"

@(private)
TEXTURED_LAYOUT := gfx.Pipeline_Layout {
    gfx.Layout_Element {    // Position
        gl_type = gl.FLOAT,
        count = 3,
        normalized = false,
        buffer_idx = 0,
        divisor = 0,
    },
    gfx.Layout_Element {    // Uv
        gl_type = gl.FLOAT,
        count = 2,
        normalized = false, 
        buffer_idx = 0,
        divisor = 0,
    },
}

@(private)
COLOR_LAYOUT := gfx.Pipeline_Layout {
    gfx.Layout_Element {    // Position
        gl_type = gl.FLOAT,
        count = 3,
        normalized = false,
        buffer_idx = 0,
        divisor = 0,
    },
    gfx.Layout_Element {    // Color
        gl_type = gl.FLOAT,
        count = 3,
        normalized = false, 
        buffer_idx = 0,
        divisor = 0,
    },
}

DEFAULT_FONT_SIZE: [2]f32 = { 0.075, 0.1 }

Color_Vertex :: struct #packed {
    position: [3]f32,
    color: [3]f32,
}

Textured_Vertex :: struct #packed {
    position: [3]f32,
    uv: [2]f32,
}
