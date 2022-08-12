package main

import "core:os"
import gl "vendor:OpenGL"
import "vx_lib:core"
import "vx_lib:gfx"
import "vx_lib:logic"

QUAD_VERTICES := []f32 {
    -0.5, -0.5, 1.0, 0.0, 0.0,
     0.5, -0.5, 0.0, 1.0, 0.0,
     0.5,  0.5, 0.0, 0.0, 1.0,
    -0.5,  0.5, 0.0, 1.0, 0.0,
}
QUAD_INDICES := []u32 {
    0, 1, 2, 2, 3, 0,
}
QUAD_LAYOUT := []gfx.Layout_Element {
    {
		gl_type = gl.FLOAT,
		count = 2,
		normalized = false,
		buffer_idx = 0,
	},
	{
		gl_type = gl.FLOAT,
		count = 3,
		normalized = false,
		buffer_idx = 0,
	},
}

Offscreen :: struct {
    mesh: logic.Mesh_Component,
    pipeline: gfx.Pipeline,
    framebuffer: gfx.Framebuffer,
}
OFFSCREEN_INSTANCE: core.Cell(Offscreen)

offscreen_init :: proc() {
    core.cell_init(&OFFSCREEN_INSTANCE)

    logic.meshcomponent_init(&OFFSCREEN_INSTANCE.mesh, logic.Mesh_Descriptor {
        index_buffer_type = gl.UNSIGNED_INT,
        gl_usage = gl.STATIC_DRAW,
        gl_draw_mode = gl.TRIANGLES,
    }, QUAD_VERTICES, QUAD_INDICES)

    vertex_src, ok := os.read_entire_file("res/shaders/quad.vs")
	if !ok do panic("Could not open vertex shader file")
	defer delete(vertex_src)

	fragment_src, ok2 := os.read_entire_file("res/shaders/quad.fs")
	if !ok2 do panic("Could not open fragment shader file")
	defer delete(fragment_src)

	shader: gfx.Shader = ---
	gfx.shader_init(&shader, gfx.Shader_Descriptor { 
		vertex_source = (string)(vertex_src), 
		fragment_source = (string)(fragment_src),
	})
	layout: gfx.Layout = ---
	gfx.layout_init(&layout, gfx.Layout_Descriptor {
		elements = QUAD_LAYOUT,
	})

    gfx.framebuffer_init(&OFFSCREEN_INSTANCE.framebuffer, gfx.Framebuffer_Descriptor {
        use_color_attachment = true,
        use_depth_stencil_attachment = true,

        internal_texture_format = gl.RGBA,
        color_texture_unit = 0,
        color_texture_warp_s = gl.MIRRORED_REPEAT,
        color_texture_warp_t = gl.MIRRORED_REPEAT,
        color_texture_min_filter = gl.LINEAR,
        color_texture_mag_filter = gl.LINEAR,
        color_texture_gen_mipmaps = true,

        depth_stencil_texture_unit = 0,

        framebuffer_size = { 640, 480 },
    })

	gfx.pipeline_init(&OFFSCREEN_INSTANCE.pipeline, gfx.Pipeline_Descriptor {
		shader = shader,
		layout = layout,

		cull_enabled = false,
		cull_front_face = gl.CCW,
		cull_face = gl.BACK,

		depth_enabled = true,
		depth_func = gl.LESS,

		blend_enabled = false,

		wireframe = false,

		viewport_size = { 640, 480 },

		clear_color = { 1.0, 1.0, 1.0, 1.0 },
	}, OFFSCREEN_INSTANCE.framebuffer)

    logic.meshcomponent_apply(OFFSCREEN_INSTANCE.mesh, OFFSCREEN_INSTANCE.pipeline)
}

offscreen_draw :: proc() {
    gfx.pipeline_clear(OFFSCREEN_INSTANCE.pipeline)

    gfx.pipeline_apply(OFFSCREEN_INSTANCE.pipeline)
    logic.meshcomponent_draw(OFFSCREEN_INSTANCE.mesh, OFFSCREEN_INSTANCE.pipeline)
}

offscreen_free :: proc() {
    logic.meshcomponent_free(&OFFSCREEN_INSTANCE.mesh)
    gfx.pipeline_free(&OFFSCREEN_INSTANCE.pipeline)

    core.cell_free(&OFFSCREEN_INSTANCE)
}
