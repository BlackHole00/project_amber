package main

import "shared:vx_lib/platform"
import "shared:vx_lib/common"
import "shared:vx_lib/gfx"
import core "shared:vx_core"

VERTEX_SOURCE := `
#version 330 core

layout (location = 0) in vec3 a_pos;
layout (location = 1) in vec3 a_color;

out vec3 v_color;

void main() {
	gl_Position = vec4(a_pos, 1.0);

	v_color = a_color;
}
`

FRAGMENT_SOURCE := `
#version 330 core

in vec3 v_color;

out vec4 o_color;

void main() {
	o_color = vec4(v_color, 1.0);
}
`

VERTEX_DATA := []f32 {
	-0.5, -0.5, 1.0, 1.0, 0.0, 0.0,
	 0.0,  0.5, 1.0, 0.0, 1.0, 0.0,
	 0.5, -0.5, 1.0, 0.0, 0.0, 1.0,
}

State :: struct {
	vertex_buffer: gfx.Buffer,
	pipeline: gfx.Pipeline,
	bindings: gfx.Bindings,
}
STATE: core.Cell(State)

init :: proc() {
	core.cell_init(&STATE)

	gfx.buffer_init(&STATE.vertex_buffer, gfx.Buffer_Descriptor {
		type = .Vertex_Buffer,
		usage = .Static_Draw,
	}, VERTEX_DATA)

	gfx.pipeline_init(&STATE.pipeline, gfx.Pipeline_Descriptor {
		cull_enabled = false,
		depth_enabled = false,
		blend_enabled = false,
		wireframe = false,
		viewport_size = platform.windowhelper_get_window_size(),

		vertex_source = VERTEX_SOURCE,
		fragment_source = FRAGMENT_SOURCE,

		layout = []gfx.Layout_Element {
			{
				type = .F32,
    			count = 3,
    			normalized = false,
    			buffer_idx = 0,
    			divisor = 0,
			},
			{
				type = .F32,
    			count = 3,
    			normalized = false,
    			buffer_idx = 0,
    			divisor = 0,
			},
		},

		clearing_color = { 1.0, 0.5, 0.25, 1.0 },
		clear_depth = false,
		clear_color = true,
	})

	gfx.bindings_init(&STATE.bindings, []gfx.Buffer {
		STATE.vertex_buffer,
	}, nil, {})
}

draw :: proc() {
	gfx.pipeline_clear(STATE.pipeline)
	gfx.pipeline_draw_arrays(&STATE.pipeline, &STATE.bindings, .Triangles, 0, 3)
}

close :: proc() {
	gfx.buffer_free(&STATE.vertex_buffer)
	gfx.pipeline_free(&STATE.pipeline)

	core.cell_free(&STATE)
}

main :: proc() {
	context = core.default_context()
	defer core.free_default_context()

	common.vx_lib_init()
	defer common.vx_lib_free()

	platform.platform_start()
	defer platform.platform_close()

	desc: platform.Window_Descriptor
	desc.title = "Window"
	desc.size = { 640, 480 }
	desc.decorated = true
	desc.show_fps_in_title = true
	desc.vsync = false
	desc.resizable = false
	desc.fullscreen = false
    desc.init_proc = init
	desc.draw_proc = draw
	desc.close_proc = close

	platform.window_init(desc)
	defer platform.window_deinit()

	platform.window_run()
}