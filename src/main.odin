package main

import "core:os"
import "shared:glfw"
import "shared:fmod"
import "shared:vx_lib/gfx"
import "shared:vx_lib/platform"
import "shared:vx_lib/logic"
import "shared:vx_lib/logic/objects"
import "shared:vx_lib/common"
import core "shared:vx_core"

State :: struct {
	v_buffer: gfx.Buffer,
	i_buffer: gfx.Buffer,
	bindings: gfx.Bindings,
	texture: gfx.Texture,

	ctexture: gfx.Texture,

	camera: objects.Simple_Camera,

	pipeline: gfx.Pipeline,

	framebuffer: gfx.Framebuffer,
	basic_v_buffer: gfx.Buffer,
	basic_i_buffer: gfx.Buffer,
	basic_pipeline: gfx.Pipeline,
	basic_bindings: gfx.Bindings,

	system: fmod.SYSTEM,
	channel: fmod.CHANNEL,
	sound1: fmod.SOUND,
	sound2: fmod.SOUND,
	sound3: fmod.SOUND,
}
STATE: core.Cell(State)

init :: proc() {
	core.cell_init(&STATE)

	// Computing
	compute_source, _ := os.read_entire_file("res/vx_lib/shaders/test.cl")
	defer delete(compute_source)

	compute_pipeline := gfx.computepipeline_new(gfx.Compute_Pipeline_Descriptor {
		source = string(compute_source),
    	entry_point = "colorify",

    	dimensions = 2,
    	global_work_sizes = { 256, 256 },
		local_work_sizes  = { 16, 16 },
	})
	defer gfx.computepipeline_free(compute_pipeline)

	STATE.ctexture = gfx.texture_new(gfx.Texture_Descriptor {
		type = .Texture_2D,
		internal_texture_format = .R8G8B8A8,
		format = .R8G8B8A8,
		pixel_type = .UByte,
		warp_s = .Clamp_To_Border,
		warp_t = .Clamp_To_Border,
		min_filter = .Linear,
		mag_filter = .Linear,
		gen_mipmaps = false,
	}, [2]uint{ 256, 256 })

	output := gfx.computebuffer_new_from_texture(gfx.Compute_Buffer_Descriptor {
		type = .Write_Only,
		//size = 256 * 256 * 4,
	}, STATE.ctexture)
	defer gfx.computebuffer_free(output)

	bindings := gfx.computebindings_new([]gfx.Compute_Bindings_Element {
		gfx.Compute_Bindings_Buffer_Element {
			buffer = output,
		},
		gfx.Compute_Bindings_I32_Element {
			value = 256,
		},
		gfx.Compute_Bindings_I32_Element {
			value = 256,
		},
	})
	defer gfx.computebindings_free(bindings)

	compute_sync: gfx.Sync
	gfx.computepipeline_compute(compute_pipeline, bindings, &compute_sync)

	// Offscreen rendering setup.
	{
		STATE.framebuffer = gfx.framebuffer_new(gfx.Framebuffer_Descriptor {
			use_color_attachment = true,
    		use_depth_stencil_attachment = true,

    		internal_texture_format = .R8G8B8A8,
    		color_texture_warp_s = .Clamp_To_Border,
    		color_texture_warp_t = .Clamp_To_Border,
    		color_texture_min_filter = .Linear,
    		color_texture_mag_filter = .Linear,
    		color_texture_gen_mipmaps = true,

    		framebuffer_size = platform.windowhelper_get_window_size(),
		})

		vertex_source, _ := os.read_entire_file("res/vx_lib/shaders/test.vs")
		defer delete(vertex_source)
		fragment_source, _ := os.read_entire_file("res/vx_lib/shaders/test.fs")
		defer delete(fragment_source)

		STATE.pipeline = gfx.pipeline_new(gfx.Pipeline_Descriptor {
			cull_enabled = false,
			depth_enabled = false,
			blend_enabled = false,
			wireframe = false,
			viewport_size = platform.windowhelper_get_window_size(),

			vertex_source = string(vertex_source),
			fragment_source = string(fragment_source),

			layout = []gfx.Layout_Element {
				{
					type = .F32,
					count = 3,
					normalized = false,
					buffer_idx = 0,
					divisor = 0,
				}, {
					type = .F32,
					count = 3,
					normalized = false,
					buffer_idx = 0,
					divisor = 0,
				}, {
					type = .F32,
					count = 2,
					normalized = false,
					buffer_idx = 0,
					divisor = 0,
				},
			},

			clearing_color = { 1.0, 0.5, 0.25, 1.0 },
			clear_color = true,
		}, STATE.framebuffer)

		STATE.v_buffer = gfx.buffer_new(gfx.Buffer_Descriptor {
			type = .Vertex_Buffer,
			usage = .Static_Draw,
		}, []f32 {
			-0.5, -0.5, 1.0, 1.0, 0.0, 0.0, 0.0, 1.0,
			-0.5,  0.5, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0,
			0.5,  0.5, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0,
			0.5, -0.5, 1.0, 0.0, 1.0, 0.0, 1.0, 1.0,
		})
		STATE.i_buffer = gfx.buffer_new(gfx.Buffer_Descriptor {
			type = .Index_Buffer,
			usage = .Static_Draw,
			index_type = .U32,
		}, []u32 {
			0, 1, 2,
			2, 3, 0,
		})

		STATE.texture = gfx.texture_new(gfx.Texture_Descriptor {
			type = .Texture_2D,
			internal_texture_format = .R8G8B8A8,
			format = .R8G8B8A8,
			pixel_type = .UByte,
			warp_s = .Clamp_To_Border,
			warp_t = .Clamp_To_Border,
			min_filter = .Linear,
			mag_filter = .Linear,
			gen_mipmaps = true,
		}, "res/vx_lib/textures/test.png")
		gfx.texture_resize_2d(STATE.texture, { 1000, 1000 })

		STATE.bindings = gfx.bindings_new([]gfx.Buffer { STATE.v_buffer }, STATE.i_buffer, []gfx.Texture_Binding { {
				texture = STATE.texture,
				uniform_name = "u_texture",
			},
		}, {})

		logic.camera_init(&STATE.camera, logic.Orthographic_Camera_Descriptor {
			near = 0.001,
			far = 1000.0,
		})
		logic.camera_resize_view_port(&STATE.camera, platform.windowhelper_get_window_size())
		STATE.camera.position = { 0.0, 0.0, -5.0 }
		STATE.camera.rotation = { 0.0, 0.0,  0.0 }
	}

	// Basic window rendering setup.
	{
		vertex_source, _ := os.read_entire_file("res/vx_lib/shaders/texture.vs")
		defer delete(vertex_source)
		fragment_source, _ := os.read_entire_file("res/vx_lib/shaders/texture.fs")
		defer delete(fragment_source)

		STATE.basic_pipeline = gfx.pipeline_new(gfx.Pipeline_Descriptor {
			cull_enabled = false,
			depth_enabled = false,
			blend_enabled = false,
			wireframe = false,
			viewport_size = platform.windowhelper_get_window_size(),

			vertex_source = string(vertex_source),
			fragment_source = string(fragment_source),

			layout = []gfx.Layout_Element {
				{
					type = .F32,
					count = 3,
					normalized = false,
					buffer_idx = 0,
					divisor = 0,
				}, {
					type = .F32,
					count = 2,
					normalized = false,
					buffer_idx = 0,
					divisor = 0,
				},
			},

			clearing_color = { 1.0, 1.0, 1.0, 1.0 },
			clear_color = true,
		})

		STATE.basic_v_buffer = gfx.buffer_new(gfx.Buffer_Descriptor {
			type = .Vertex_Buffer,
			usage = .Static_Draw,
		}, []f32 {
			-1.0, -1.0, 1.0, 1.0, 0.0,
			-1.0,  1.0, 1.0, 1.0, 1.0,
			 1.0,  1.0, 1.0, 0.0, 1.0,
			 1.0, -1.0, 1.0, 0.0, 0.0,
		})
		STATE.basic_i_buffer = gfx.buffer_new(gfx.Buffer_Descriptor {
			type = .Index_Buffer,
			usage = .Static_Draw,
			index_type = .U32,
		}, []u32 {
			0, 1, 2,
			2, 3, 0,
		})
	}

	STATE.basic_bindings = gfx.bindings_new([]gfx.Buffer { STATE.basic_v_buffer }, STATE.basic_i_buffer, []gfx.Texture_Binding {
		gfx.framebuffer_get_color_texture_bindings(STATE.framebuffer, "u_texture1"),
		{
			uniform_name = "u_texture2",
			texture = STATE.ctexture,
		},
	}, {})

	when #config(ENABLE_FMOD, false) {
		if fmod.System_Create(&STATE.system, fmod.VERSION) != .OK do panic("aaaaa")
		if fmod.System_Init(STATE.system, 32, fmod.INIT_NORMAL, nil) != .OK do panic("bbbb")
		fmod.System_Set3DSettings(STATE.system, 1.0, 1.0, 1.0)

		if fmod.System_CreateSound(STATE.system, "res/vx_lib/sfx/drumloop.wav", fmod.FMOD_3D, nil, &STATE.sound1) != .OK do panic("cccc")
		fmod.Sound_SetMode(STATE.sound1, fmod.LOOP_NORMAL)
		fmod.Sound_Set3DMinMaxDistance(STATE.sound1, 0.01, 5000.0)

		if fmod.System_CreateSound(STATE.system, "res/vx_lib/sfx/jaguar.wav",   fmod.FMOD_3D, nil, &STATE.sound2) != .OK do panic("dddd")
		fmod.Sound_SetMode(STATE.sound2, fmod.LOOP_NORMAL)
		fmod.Sound_Set3DMinMaxDistance(STATE.sound1, 0.01, 5000.0)

		if fmod.System_CreateSound(STATE.system, "res/vx_lib/sfx/swish.wav",    fmod.FMOD_2D, nil, &STATE.sound3) != .OK do panic("eeee")
	}
	gfx.sync_await(compute_sync)
}

tick :: proc() {
	input_common()

	when #config(ENABLE_FMOD, false) {
	if platform.windowhelper_get_keyboard_keystate(glfw.KEY_1).just_pressed do if fmod.System_PlaySound(STATE.system, STATE.sound1, nil, false, &STATE.channel) != .OK do panic("aaaa")
	if platform.windowhelper_get_keyboard_keystate(glfw.KEY_2).just_pressed do if fmod.System_PlaySound(STATE.system, STATE.sound2, nil, false, &STATE.channel) != .OK do panic("aaaa")
	if platform.windowhelper_get_keyboard_keystate(glfw.KEY_3).just_pressed do if fmod.System_PlaySound(STATE.system, STATE.sound3, nil, false, &STATE.channel) != .OK do panic("aaaa")
	fmod.System_Update(STATE.system)
	}
}

draw :: proc() {
	gfx.pipeline_clear(STATE.pipeline)

	gfx.pipeline_uniform_1f(STATE.pipeline, "u_time", (f32)(platform.windowhelper_get_time()))
	logic.camera_apply(STATE.camera, STATE.camera.position, STATE.camera.rotation, STATE.pipeline)

	gfx.pipeline_draw_elements(STATE.pipeline, STATE.bindings, .Triangles, 6)

	gfx.pipeline_clear(STATE.basic_pipeline)
	gfx.pipeline_draw_elements(STATE.basic_pipeline, STATE.basic_bindings, .Triangles, 6)
}

close :: proc() {
	gfx.pipeline_free(STATE.pipeline)
	gfx.buffer_free(STATE.v_buffer)
	gfx.buffer_free(STATE.i_buffer)
	gfx.texture_free(STATE.texture)
	gfx.texture_free(STATE.ctexture)
	gfx.bindings_free(STATE.bindings)

	gfx.framebuffer_free(STATE.framebuffer)

	gfx.pipeline_free(STATE.basic_pipeline)
	gfx.buffer_free(STATE.basic_v_buffer)
	gfx.buffer_free(STATE.basic_i_buffer)
	gfx.bindings_free(STATE.basic_bindings)

	when #config(ENABLE_FMOD, false) { 
		if fmod.Sound_Release(STATE.sound1) != .OK do panic("aaaa")
		if fmod.Sound_Release(STATE.sound2) != .OK do panic("aaaa")
		if fmod.Sound_Release(STATE.sound3) != .OK do panic("aaaa")
		if fmod.System_Close(STATE.system) != .OK do panic("aaaa")
		if fmod.System_Release(STATE.system) != .OK do panic("aaaa")
	}

	core.cell_free(&STATE)
}

resize :: proc() {
	gfx.pipeline_resize(STATE.basic_pipeline, platform.windowhelper_get_window_size())
	gfx.pipeline_resize(STATE.pipeline, platform.windowhelper_get_window_size())
	gfx.framebuffer_resize(STATE.framebuffer, platform.windowhelper_get_window_size())

	logic.camera_resize_view_port(&STATE.camera.camera, platform.windowhelper_get_window_size())
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
	desc.init_proc = init
	desc.logic_proc = tick
	desc.draw_proc = draw
	desc.resize_proc = resize
	desc.close_proc = close
	desc.vsync = false
	desc.resizable = true
	desc.fullscreen = false

	platform.window_init(desc)
	defer platform.window_deinit()

	platform.window_run()
}

input_common :: proc() {
    if platform.windowhelper_get_keyboard_keystate(glfw.KEY_TAB).just_pressed {
        platform.windowhelper_set_mouse_grabbbed(!platform.windowhelper_is_mouse_grabbed())
    }
    if platform.windowhelper_get_keyboard_keystate(glfw.KEY_ESCAPE).just_pressed {
        platform.windowhelper_close_window()
    }

    if platform.windowhelper_get_keyboard_keystate(glfw.KEY_LEFT_ALT).pressed && platform.windowhelper_get_keyboard_keystate(glfw.KEY_F).just_pressed {
        @static not_fullscreen_size: [2]uint

        if !platform.windowhelper_is_fullscreen() {
            not_fullscreen_size = platform.windowhelper_get_window_size()

            platform.windowhelper_set_window_size(platform.windowhelper_get_screen_size())
        } else do platform.windowhelper_set_window_size(not_fullscreen_size)
        platform.windowhelper_set_fullscreen(!platform.windowhelper_is_fullscreen())
    }
}
