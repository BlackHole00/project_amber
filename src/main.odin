package main

import "core:log"
import "core:os"
import "core:mem"
import "vx_lib:core"
import "vx_lib:platform"
import "vx_lib:common"
import "vx_lib:gfx"
import "vx_lib:logic"
import "vx_lib:logic/objects"
import "vx_lib:utils"
import gl "vendor:OpenGL"

Vertex :: struct #packed {
	pos: [3]f32,
	color: [3]f32,
}
VERTEX_LAYOUT := []gfx.Layout_Element {
	{
		gl_type = gl.FLOAT,
		count = 3,
		normalized = false,
		buffer_idx = 0,
		divisor = 0,
	},
	{
		gl_type = gl.FLOAT,
		count = 3,
		normalized = false,
		buffer_idx = 0,
		divisor = 0,
	},
}

State :: struct {
	pipeline: gfx.Pipeline,
	mesh: objects.Simple_Mesh,

	camera: objects.Simple_Camera,
}
STATE: core.Cell(State)

init :: proc() {
	core.cell_init(&STATE)

	vertex_src, ok := os.read_entire_file("res/shaders/basic.vs")
	if !ok do panic("Could not open vertex shader file")
	defer delete(vertex_src)

	fragment_src, ok2 := os.read_entire_file("res/shaders/basic.fs")
	if !ok2 do panic("Could not open fragment shader file")
	defer delete(fragment_src)

	shader: gfx.Shader = ---
	gfx.shader_init(&shader, gfx.Shader_Descriptor { 
		vertex_source = (string)(vertex_src), 
		fragment_source = (string)(fragment_src),
	})
	layout: gfx.Layout = ---
	gfx.layout_init(&layout, gfx.Layout_Descriptor {
		elements = VERTEX_LAYOUT,
	})

	gfx.pipeline_init(&STATE.pipeline, gfx.Pipeline_Descriptor { 
		shader = shader,
		layout = layout,

		cull_enabled = false,
		cull_front_face = gl.CCW,
		cull_face = gl.BACK,

		depth_enabled = false,
		depth_func = gl.LESS,

		blend_enabled = false,

		wireframe = false,

		viewport_size = { 640, 480 },

		clear_color = { 0.0, 0.0, 0.0, 0.0 },
	})

	logic.camera_init(&STATE.camera, logic.Perspective_Camera_Descriptor {
		fov = 3.14 / 2.0,
		viewport_size = platform.windowhelper_get_window_size(),
		near = 0.01, 
		far = 1000.0,
	})
	STATE.camera.position = { 0.0, 0.0, 0.0 }
	STATE.camera.rotation = { 0.0, 0.0, 0.0 }

	STATE.mesh.transform.position = { 0.0, 0.0, 1.0 }
	STATE.mesh.transform.rotation = { 0.0, 0.0, 0.0 }
	STATE.mesh.transform.scale = { 1.0, 1.0, 1.0 }
	logic.transform_calc_matrix(&STATE.mesh.transform)

	mesh_builder: utils.Mesh_Builder = ---
	utils.meshbuilder_init(&mesh_builder, utils.MeshBuilder_Descriptor {
		gl_usage = gl.STATIC_DRAW,
		gl_draw_mode = gl.TRIANGLES,
	})
	defer utils.meshbuilder_free(mesh_builder)

	utils.meshbuilder_push_quad(&mesh_builder, []Vertex {
		{
			pos = { -0.5, -0.5, 0.0 }, color = { 1.0, 0.0, 0.0 },
		},
		{
			pos = {  0.5, -0.5, 0.0 }, color = { 0.0, 1.0, 0.0 },
		},
		{
			pos = {  0.5,  0.5, 0.0 }, color = { 0.0, 0.0, 1.0 },
		},
		{
			pos = { -0.5,  0.5, 0.0 }, color = { 0.0, 1.0, 0.0 },
		},
	})
	utils.meshbuilder_build(mesh_builder, &STATE.mesh)
}

tick :: proc() {
	input_common()
	input_camera_movement()
}

draw :: proc() {
	gfx.pipeline_apply(STATE.pipeline)
	logic.camera_apply(STATE.camera, STATE.camera.position, STATE.camera.rotation, &STATE.pipeline)
	logic.transform_apply(&STATE.mesh, &STATE.pipeline)

	gfx.pipeline_clear(STATE.pipeline)
	logic.meshcomponent_apply(STATE.mesh, STATE.pipeline)
	logic.meshcomponent_draw(STATE.mesh, STATE.pipeline)
}

close :: proc() {
	gfx.pipeline_free(&STATE.pipeline)

	core.cell_free(&STATE)
}

resize :: proc() {
	size := platform.windowhelper_get_window_size()

	logic.camera_resize_view_port(&STATE.camera, size)
	gfx.pipeline_resize(&STATE.pipeline, size)
}

main :: proc() {
	file, ok := os.open("log.txt", os.O_CREATE | os.O_WRONLY)
	if ok != 0 do panic("Could not open log file")

	context.logger = log.create_multi_logger(
		log.create_console_logger(),
		log.create_file_logger(file),
	)

	ta: mem.Tracking_Allocator = ---
	mem.tracking_allocator_init(&ta, context.allocator)
	defer mem.tracking_allocator_destroy(&ta)
	context.allocator = mem.tracking_allocator(&ta)

	common.vx_lib_init()
	defer common.vx_lib_free()

	platform.platform_start()
	defer platform.platform_close()

	desc: platform.Window_Descriptor
	desc.title = "Window"
	desc.size = { 640, 480 }
	desc.decorated = true
	desc.show_fps_in_title = true
	desc.init_proc = init
	desc.logic_proc = tick
	desc.draw_proc = draw
	desc.resize_proc = resize
	desc.close_proc = close
	desc.vsync = true
	desc.resizable = true

	platform.window_init(desc)
	defer platform.window_deinit()

	platform.window_run()
}
