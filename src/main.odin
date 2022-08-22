package main

import "core:log"
import "core:os"
import "core:mem"
import "core:math"
import "vx_lib:core"
import "vx_lib:platform"
import "vx_lib:common"
import "vx_lib:gfx"
import "vx_lib:gfx/immediate"
import "vx_lib:logic"
import "vx_lib:logic/objects"
import "vx_lib:utils"
import gl "vendor:OpenGL"

Vertex :: struct #packed {
	pos: [3]f32,
	uv:  [2]f32,
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
		count = 2,
		normalized = false,
		buffer_idx = 0,
		divisor = 0,
	},
}

SKYBOX_LAYOUT := []gfx.Layout_Element {
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
	texture: gfx.Texture,
	atlas: utils.Texture_Atlas,

	skybox_pipeline: gfx.Pipeline,
	skybox: objects.Skybox,
	skybox_bindings: gfx.Bindings,

	camera: objects.Simple_Camera,
}
STATE: core.Cell(State)

init :: proc() {
	core.cell_init(&STATE)

	immediate.context_init(immediate.Context_Descriptor {
		target_framebuffer = nil,
		viewport_size = { 640, 480 },
		clear_color = false,
		clear_depth_buffer = true,
	})

	vertex_src, ok := os.read_entire_file("res/shaders/basic.vs")
	if !ok do panic("Could not open vertex shader file")

	fragment_src, ok2 := os.read_entire_file("res/shaders/basic.fs")
	if !ok2 do panic("Could not open fragment shader file")

	gfx.pipeline_init(&STATE.pipeline, gfx.Pipeline_Descriptor {
		vertex_source = (string)(vertex_src),
		fragment_source = (string)(fragment_src),

		layout = VERTEX_LAYOUT,

		cull_enabled = false,
		cull_front_face = gl.CW,
		cull_face = gl.BACK,

		depth_enabled = true,
		depth_func = gl.LEQUAL,

		blend_enabled = true,
		blend_src_rgb_func = gl.SRC_ALPHA,
		blend_dst_rgb_func = gl.ONE_MINUS_SRC_ALPHA,
		blend_src_alpha_func = gl.ONE,
		blend_dstdst_alphargb_func = gl.ZERO,

		wireframe = false,

		viewport_size = { 640, 480 },

		clearing_color = { 0.0, 0.0, 0.0, 0.0 },
		clear_color = true,
		clear_depth = true,
	})

	delete(vertex_src)
	vertex_src, ok = os.read_entire_file("res/shaders/skybox.vs")
	if !ok do panic("Could not open vertex shader file")
	defer delete(vertex_src)

	delete(fragment_src)
	fragment_src, ok2 = os.read_entire_file("res/shaders/skybox.fs")
	if !ok2 do panic("Could not open fragment shader file")
	defer delete(fragment_src)

	gfx.pipeline_init(&STATE.skybox_pipeline, gfx.Pipeline_Descriptor { 
		vertex_source = (string)(vertex_src),
		fragment_source = (string)(fragment_src),

		layout = SKYBOX_LAYOUT,

		cull_enabled = false,
		depth_enabled = false,
		blend_enabled = false,

		wireframe = false,

		viewport_size = { 640, 480 },

		clear_color = false,
		clear_depth = false,
	})

	logic.camera_init(&STATE.camera, logic.Perspective_Camera_Descriptor {
		fov = 3.14 / 2.0,
		viewport_size = platform.windowhelper_get_window_size(),
		near = 0.01, 
		far = 1000.0,
	})
	STATE.camera.position = { 0.0, 0.0, 0.0 }
	STATE.camera.rotation = { math.to_radians_f32(180.0), 0.0, 0.0 }

	STATE.mesh.transform.position = { 0.0, 0.0, -1.0 }
	STATE.mesh.transform.rotation = { 0.0, 0.0, 0.0 }
	STATE.mesh.transform.scale = { 1.0, 1.0, 1.0 }
	logic.transform_calc_matrix(&STATE.mesh.transform)

	utils.textureatlas_init_from_file(&STATE.atlas, utils.Texture_Atlas_Descriptor {
		internal_texture_format = gl.RGBA8,
		warp_s = gl.REPEAT,
		warp_t = gl.REPEAT,
		min_filter = gl.NEAREST,
		mag_filter = gl.NEAREST,
		gen_mipmaps = true,
	}, "res/textures/font_atlas.png", "res/textures/font_atlas.csv")
	top, bottom, left, right := utils.textureatlas_get_uv(&STATE.atlas, "char_65")
	log.info(top, bottom, left, right)

	mesh_builder: utils.Mesh_Builder = ---
	utils.meshbuilder_init(&mesh_builder)
	defer utils.meshbuilder_free(mesh_builder)

	utils.meshbuilder_push_quad(&mesh_builder, []Vertex {
		{
			pos = { -0.5, -0.5, 0.0 }, uv = { left, bottom },
		},
		{
			pos = {  0.5, -0.5, 0.0 }, uv = { right, bottom },
		},
		{
			pos = {  0.5,  0.5, 0.0 }, uv = { right, top },
		},
		{
			pos = { -0.5,  0.5, 0.0 }, uv = { left, top },
		},
	})

	logic.meshcomponent_init(&STATE.mesh, logic.Mesh_Descriptor {
		index_buffer_type = gl.UNSIGNED_INT,
		gl_usage = gl.STATIC_DRAW,
		gl_draw_mode = gl.TRIANGLES,
	})
	utils.meshbuilder_build(mesh_builder, &STATE.mesh)

	logic.skybox_init(&STATE.skybox.mesh, &STATE.skybox.texture, "res/textures/skybox/right.bmp", "res/textures/skybox/left.bmp", "res/textures/skybox/top.bmp", "res/textures/skybox/bottom.bmp", "res/textures/skybox/front.bmp", "res/textures/skybox/back.bmp")

	gfx.texture_init(&STATE.texture, gfx.Texture_Descriptor {
		gl_type = gl.TEXTURE_2D,
		internal_texture_format = gl.RGBA8,
		warp_s = gl.REPEAT,
		warp_t = gl.REPEAT,
		min_filter = gl.NEAREST,
		mag_filter = gl.NEAREST,
		gen_mipmaps = true,
	}, "res/textures/dirt.png")

	gfx.texture_resize_2d(&STATE.texture, { 64, 64 })
}

tick :: proc() {
	input_common()
	input_camera_movement()
}

draw :: proc() {
	gfx.pipeline_clear(STATE.pipeline)

	logic.camera_apply(STATE.camera, STATE.camera.position, STATE.camera.rotation, &STATE.skybox_pipeline)
	logic.skybox_draw(&STATE.skybox_pipeline, STATE.skybox.mesh, STATE.skybox.texture)

	atlas_bind := utils.textureatlas_get_texture_bindings(STATE.atlas, "uTexture")

	logic.camera_apply(STATE.camera, STATE.camera.position, STATE.camera.rotation, &STATE.pipeline)
	logic.transform_apply(&STATE.mesh, &STATE.pipeline)
	logic.meshcomponent_draw(STATE.mesh, &STATE.pipeline, []gfx.Texture_Binding {
		atlas_bind,
	})

	immediate.push_string({ 0.0, 0.0 }, immediate.DEFAULT_FONT_SIZE, "Hello Font!")
	immediate.draw()
}

close :: proc() {
	gfx.pipeline_free(&STATE.pipeline)

	immediate.context_free()
	core.cell_free(&STATE)
}

resize :: proc() {
	size := platform.windowhelper_get_window_size()

	logic.camera_resize_view_port(&STATE.camera, size)
	gfx.pipeline_resize(&STATE.pipeline, size)
	gfx.pipeline_resize(&STATE.skybox_pipeline, size)
	immediate.resize_viewport(size)
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
