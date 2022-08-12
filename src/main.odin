package main

import "core:log"
import "core:os"
import "core:mem"
import "core:math/noise"
import "vx_lib:core"
import "vx_lib:platform"
import "vx_lib:common"
import "vx_lib:gfx"
import "vx_lib:logic"
import "vx_lib:logic/objects"
import gl "vendor:OpenGL"

VERTICES := []f32 {
    // FRONT FACE
    -0.5, -0.5, 0.5, 0.0, 0.0,
     0.5, -0.5, 0.5, 1.0, 0.0,
     0.5,  0.5, 0.5, 1.0, 1.0,
    -0.5,  0.5, 0.5, 0.0, 1.0,

    // REAR FACE
    -0.5, -0.5, -0.5, 0.0, 0.0,
    -0.5,  0.5, -0.5, 1.0, 0.0,
     0.5,  0.5, -0.5, 1.0, 1.0,
     0.5, -0.5, -0.5, 0.0, 1.0,

    // LEFT FACE
    -0.5, -0.5, -0.5, 0.0, 0.0,
    -0.5, -0.5,  0.5, 1.0, 0.0,
    -0.5,  0.5,  0.5, 1.0, 1.0,
    -0.5,  0.5, -0.5, 0.0, 1.0,

    // RIGHT FACE
    0.5, -0.5, -0.5, 0.0, 0.0,
    0.5,  0.5, -0.5, 1.0, 0.0,
    0.5,  0.5,  0.5, 1.0, 1.0,
    0.5, -0.5,  0.5, 0.0, 1.0,

    // TOP FACE
    -0.5,  0.5, -0.5, 0.0, 0.0,
    -0.5,  0.5,  0.5, 1.0, 0.0,
     0.5,  0.5,  0.5, 1.0, 1.0,
     0.5,  0.5, -0.5, 0.0, 1.0,

    // BOTTOM FACE
    -0.5, -0.5, -0.5, 0.0, 0.0,
     0.5, -0.5, -0.5, 1.0, 0.0,
     0.5, -0.5,  0.5, 1.0, 1.0,
    -0.5, -0.5,  0.5, 0.0, 1.0,
}
VERTEX_LAYOUT := []gfx.Layout_Element {
	{
		gl_type = gl.FLOAT,
		count = 3,
		normalized = false,
		buffer_idx = 0,
	},
	{
		gl_type = gl.FLOAT,
		count = 2,
		normalized = false,
		buffer_idx = 0,
	},
	{
		gl_type = gl.FLOAT,
		count = 4,
		normalized = false,
		buffer_idx = 1,
		divisor = 1,
	},
	{
		gl_type = gl.FLOAT,
		count = 4,
		normalized = false,
		buffer_idx = 1,
		divisor = 1,
	},
	{
		gl_type = gl.FLOAT,
		count = 4,
		normalized = false,
		buffer_idx = 1,
		divisor = 1,
	},
	{
		gl_type = gl.FLOAT,
		count = 4,
		normalized = false,
		buffer_idx = 1,
		divisor = 1,
	},
}
INDICES := []u32 {
    // FRONT FACE
    0, 1, 2, 2, 3, 0,

    // REAR FACE
    4, 5, 6, 6, 7, 4,

    // LEFT FACE
    8, 9, 10, 10, 11, 8,

    // RIGHT FACE
    12, 13, 14, 14, 15, 12,

    // TOP FACE
    16, 17, 18, 18, 19, 16,

    // BOTTOM FACE
    20, 21, 22, 22, 23, 20,
}
TEXTURE_NAMES := []string {
	"bricks",
	"dirt",
	"grass",
	"sand",
	"stone",
}

State :: struct {
	//mesh: objects.Simple_Mesh,
	mesh: objects.Instanced_Mesh,
	pipeline: gfx.Pipeline,
	bundle: gfx.Texture_Bundle,

	camera: objects.Simple_Camera,
}
STATE: core.Cell(State)

init :: proc() {
	core.cell_init(&STATE)

	offscreen_init()

	logic.instancedmeshcomponent_init(&STATE.mesh, logic.Instanced_Mesh_Descriptor {
		index_buffer_type = gl.UNSIGNED_INT,
		gl_usage = gl.STATIC_DRAW,
		gl_draw_mode = gl.TRIANGLES,
	})
	logic.instancedmeshcomponent_set_data(&STATE.mesh, VERTICES, INDICES)
	logic.dynamicstorage_init(&STATE.mesh.transforms, 10000)

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

		cull_enabled = true,
		cull_front_face = gl.CCW,
		cull_face = gl.BACK,

		depth_enabled = true,
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
	STATE.camera.rotation = { 3.14 / 2, 0.0, 0.0 }

	gfx.texturebundle_init(&STATE.bundle, gfx.Texture_Descriptor {
		gl_type = gl.TEXTURE_2D,
		internal_texture_format = gl.RGBA,
		texture_unit = 0,
		warp_s = gl.REPEAT,
		warp_t = gl.REPEAT,
		min_filter = gl.NEAREST,
		mag_filter = gl.NEAREST,
		gen_mipmaps = true,
	})
	gfx.texturebundle_insert_texture(&STATE.bundle, TEXTURE_NAMES[0], "res/textures/bricks.png")
	gfx.texturebundle_insert_texture(&STATE.bundle, TEXTURE_NAMES[1], "res/textures/dirt.png")
	gfx.texturebundle_insert_texture(&STATE.bundle, TEXTURE_NAMES[2], "res/textures/grass.png")
	gfx.texturebundle_insert_texture(&STATE.bundle, TEXTURE_NAMES[3], "res/textures/sand.png")
	gfx.texturebundle_insert_texture(&STATE.bundle, TEXTURE_NAMES[4], "res/textures/stone.png")
	gfx.texturebundle_set_current_texture(&STATE.bundle, TEXTURE_NAMES[0])
	gfx.texturebundle_apply(STATE.bundle, &STATE.pipeline, "uTexture")

	logic.instancedmeshcomponent_apply(STATE.mesh, STATE.pipeline)
}

tick :: proc() {
	for i := 0; i < logic.dynamicstorage_get_size(STATE.mesh.transforms); i += 1 {
		transform := logic.dynamicstorage_get(&STATE.mesh.transforms, i)

		vec := ([2]f64){ platform.windowhelper_get_time(), platform.windowhelper_get_time() }
		vec *= 0.1
		vec2 := ([2]f64){ (f64)(i), (f64)(i) }
		vec += vec2

		transform.position = logic.Position_Component { noise.noise_2d(0, vec), noise.noise_2d(1, vec), noise.noise_2d(2, vec) }
		transform.position += ({
			noise.noise_2d(0, vec2), noise.noise_2d(1, vec2), noise.noise_2d(2, vec2),
		} * 50.0)

		transform.rotation = logic.Rotation_Component { (f32)(i), (f32)(i * 2), (f32)(i * 3) }
		transform.scale = logic.Scale_Component { 1.0, 1.0, 1.0 }

		logic.transform_calc_matrix(&transform)

		logic.dynamicstorage_set(&STATE.mesh.transforms, transform, i)
	}

	logic.instancedmeshcomponent_set_instanced_data(&STATE.mesh, objects.instancedmesh_transforms_as_matrices(&STATE.mesh.transforms), logic.dynamicstorage_get_size(STATE.mesh.transforms))

	input_common()
	input_camera_movement()
}

draw :: proc() {
	offscreen_draw()

	gfx.pipeline_apply(STATE.pipeline)
	logic.camera_apply(STATE.camera, STATE.camera.position, STATE.camera.rotation, &STATE.pipeline)
	gfx.framebuffer_apply_color_attachment(OFFSCREEN_INSTANCE.framebuffer, &STATE.pipeline, "uTexture")
	gfx.framebuffer_bind_color_attachment(OFFSCREEN_INSTANCE.framebuffer)

	gfx.pipeline_clear(STATE.pipeline)

	logic.instancedmeshcomponent_draw(&STATE.mesh, STATE.pipeline)
}

close :: proc() {
	offscreen_free()

	gfx.pipeline_free(&STATE.pipeline)
	gfx.texturebundle_free(&STATE.bundle)
	logic.meshcomponent_free(&STATE.mesh)
	logic.dynamicstorage_free(STATE.mesh.transforms)

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
