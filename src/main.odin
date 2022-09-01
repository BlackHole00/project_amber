package main

import "core:log"
import "core:os"
import "core:mem"
import "core:math"
import "core:fmt"
import "vx_lib:core"
import "vx_lib:platform"
import "vx_lib:common"
import "vx_lib:gfx"
import "vx_lib:gfx/immediate"
import "vx_lib:logic"
import "vx_lib:logic/objects"
import "project_amber:world"
import "project_amber:renderer"
import gl "vendor:OpenGL"
import NS "vendor:darwin/Foundation"
import MTL "vendor:darwin/Metal"


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
	camera: objects.Simple_Camera,

	world_accessor: world.World_Accessor,

	vertex_positions_buffer: gfx.Buffer,
	vertex_colors_buffer: gfx.Buffer,
	index_buffer: gfx.Buffer,
	pipeline: gfx.Pipeline,
	command_queue: ^MTL.CommandQueue,
	pass: gfx.Pass,
}
STATE: core.Cell(State)

init :: proc() {
	build_buffers :: proc() -> (vertex_positions_buffer, vertex_colors_buffer: gfx.Buffer) {
		positions := [?][3]f32{
			{-0.8,  0.8, 0.0},
			{-0.8, -0.8, 0.0},
			{ 0.8, -0.8, 0.0},
			{ 0.8,  0.8, 0.0},
		}
		colors := [?][3]f32{
			{1.0, 0.0, 0.0},
			{0.0, 1.0, 0.0},
			{0.0, 0.0, 1.0},
			{0.0, 1.0, 0.0},
		}
	
		gfx.buffer_init(&vertex_positions_buffer, gfx.Buffer_Descriptor {
			type = .Vertex_Buffer,
			usage = .Static_Draw,
		}, positions[:])
		gfx.buffer_init(&vertex_colors_buffer, gfx.Buffer_Descriptor {
			type = .Vertex_Buffer,
			usage = .Static_Draw,
		}, colors[:])
		return
	}

	core.cell_init(&STATE)

	gfx.pipeline_init(&STATE.pipeline, gfx.Pipeline_Descriptor {
		source_path = "res/shader_test",
	})

	device := gfx.METAL_CONTEXT.device

	INDICES := [?]u16 {
		0, 1, 2,
		2, 3, 0,
	}

	STATE.vertex_positions_buffer, STATE.vertex_colors_buffer = build_buffers()
	gfx.buffer_init(&STATE.index_buffer, gfx.Buffer_Descriptor {
		type = .Index_Buffer,
		usage = .Static_Draw,
	}, INDICES[:])

	STATE.command_queue = device->newCommandQueue()

	gfx.pass_init(&STATE.pass, gfx.Pass_Descriptor {
		clear_color = true,
		clear_depth = false,
		clearing_color = { 0.0, 0.0, 0.0, 0.0 },
		viewport_size = { 640, 480 },
	})

//	renderer.renderer_init()
//
//	immediate.init(immediate.Context_Descriptor {
//		pass = renderer.renderer_get_pass(),
//	})
//
//	logic.camera_init(&STATE.camera, logic.Perspective_Camera_Descriptor {
//		fov = 3.14 / 2.0,
//		viewport_size = platform.windowhelper_get_window_size(),
//		near = 0.01, 
//		far = 1000.0,
//	})
//	STATE.camera.position = { 0.0, 0.0, 0.0 }
//	STATE.camera.rotation = { math.to_radians_f32(180.0), 0.0, 0.0 }
//
//	world.blockregistar_init()
//	world.blockregistar_register_block("dirt", world.Block_Behaviour {
//		solid = true,
//		mesh = world.Full_Block_Mesh {
//			texturing = world.Full_Block_Mesh_Single_Texture {
//				texture = "dirt",
//				modifiers = { .Natural_Flip_X, .Natural_Flip_Y },
//			},
//		},
//	})
//	world.blockregistar_register_block("grass", world.Block_Behaviour {
//		solid = true,
//		mesh = world.Full_Block_Mesh {
//			texturing = world.Full_Block_Mesh_Multi_Texture {
//				{ texture = "grass_top",  modifiers = { .Natural_Flip_X, .Natural_Flip_Y } },
//				{ texture = "dirt", 	  modifiers = { .Natural_Flip_X, .Natural_Flip_Y } },
//				{ texture = "grass_side", modifiers = { .Natural_Flip_X } },
//				{ texture = "grass_side", modifiers = { .Natural_Flip_X } },
//				{ texture = "grass_side", modifiers = { .Natural_Flip_X } },
//				{ texture = "grass_side", modifiers = { .Natural_Flip_X } },
//			},
//		},
//	})
//
//	world.worldregistar_init()
//	world.worldregistar_add_world("level_0")
//	STATE.world_accessor = world.worldregistar_get_world_accessor("level_0")
//
//	world.worldaccessor_register_chunk(STATE.world_accessor, { 0, 0, 0 })
//	chunk := world.worldaccessor_get_chunk(STATE.world_accessor, { 0, 0, 0 })
//	for x in 0..<world.CHUNK_SIZE do for y in 0..<(world.CHUNK_SIZE - 1) do for z in 0..<world.CHUNK_SIZE do world.chunk_set_block(chunk, (uint)(x), (uint)(y), (uint)(z), world.Block_Instance_Descriptor {
//		block = "dirt",
//	})
//	for x in 0..<world.CHUNK_SIZE do for z in 0..<world.CHUNK_SIZE do world.chunk_set_block(chunk, (uint)(x), world.CHUNK_SIZE - 1, (uint)(z), world.Block_Instance_Descriptor {
//		block = "grass",
//	})
//	world.chunk_set_block(chunk, 7, 15, 7, world.Block_Instance_Descriptor {
//		block = "air",
//	})
//	world.chunk_remesh(chunk, STATE.world_accessor)
}

tick :: proc() {
	input_common()
//	input_camera_movement()
}

draw :: proc() {
	swapchain := gfx.METAL_CONTEXT.swapchain

	pipeline := gfx._metalimpl_shaderhandle_to_metalpipeline(STATE.pipeline.shader_handle)

	gfx.pass_begin(&STATE.pass)


	bindings: gfx.Bindings = ---
	gfx.bindings_init(&bindings, []gfx.Buffer {
		STATE.vertex_positions_buffer,
		STATE.vertex_colors_buffer,
	}, STATE.index_buffer)

	//gfx.pipeline_draw_arrays(&STATE.pipeline, &STATE.pass, &bindings, .Triangles, 0, 3)
	gfx.pipeline_draw_elements(&STATE.pipeline, &STATE.pass, &bindings, .Triangles, .U16, 6)

	gfx.pass_end(&STATE.pass)
}

close :: proc() {
	//renderer.renderer_free()
	//world.worldregistar_deinit()
	//immediate.free()
	core.cell_free(&STATE)
}

resize :: proc() {
//	size := platform.windowhelper_get_window_size()
//
//	logic.camera_resize_view_port(&STATE.camera, size)
//
//	renderer.renderer_resize(size)
//
//	immediate.resize_viewport(size)
}

main :: proc() {
	file, ok := os.open("log.txt", os.O_CREATE | os.O_WRONLY)

	logger: log.Logger = ---
	if ok != 0 do logger = log.create_console_logger(); else {
		logger = log.create_multi_logger(
			log.create_console_logger(),
			log.create_file_logger(file),
		)
	}
	context.logger = logger
	if ok != 0 do log.warn("Could not open the log file!")

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
	desc.vsync = false
	desc.resizable = true

	platform.window_init(desc)
	defer platform.window_deinit()

	platform.window_run()
}
