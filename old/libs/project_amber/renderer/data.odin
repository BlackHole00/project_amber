package project_amber_renderer

import "vx_lib:gfx"
import gl "vendor:OpenGL"

World_Vertex :: struct {
    pos: [3]f32,
    uv: [2]f32,
}

WORLD_VERTEX_LAYOUT := gfx.Pipeline_Layout {
    {
        gl_type = gl.FLOAT,
        count = 3,
        normalized = false,
        buffer_idx = 0,
        divisor = 0,
    },
    {
        gl_type = gl.FLOAT,
        count = 2,
        normalized = false,
        buffer_idx = 0,
        divisor = 0,
    },
}

SKYBOX_LAYOUT := gfx.Pipeline_Layout {
    {
		gl_type = gl.FLOAT,
		count = 3,
		normalized = false,
		buffer_idx = 0,
		divisor = 0,
	},
}
