package main

import "core:os"
import "vendor:glfw"
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
}
STATE: core.Cell(State)

init :: proc() {
	core.cell_init(&STATE)

	{
		gfx.framebuffer_init(&STATE.framebuffer, gfx.Framebuffer_Descriptor {
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

		gfx.pipeline_init(&STATE.pipeline, gfx.Pipeline_Descriptor {
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
				},
				{
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

		gfx.buffer_init(&STATE.v_buffer, gfx.Buffer_Descriptor {
			type = .Vertex_Buffer,
			usage = .Static_Draw,
		}, []f32 {
			-0.5, -0.5, 1.0, 1.0, 0.0, 0.0, 0.0, 1.0,
			-0.5,  0.5, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0,
			0.5,  0.5, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0,
			0.5, -0.5, 1.0, 0.0, 1.0, 0.0, 1.0, 1.0,
		})
		gfx.buffer_init(&STATE.i_buffer, gfx.Buffer_Descriptor {
			type = .Index_Buffer,
			usage = .Static_Draw,
			index_type = .U32,
		}, []u32 {
			0, 1, 2,
			2, 3, 0,
		})

		gfx.texture_init(&STATE.texture, gfx.Texture_Descriptor {
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
		gfx.texture_resize_2d(&STATE.texture, { 1000, 1000 })

		gfx.bindings_init(&STATE.bindings, []gfx.Buffer { STATE.v_buffer }, STATE.i_buffer, []gfx.Texture_Binding { {
				texture = STATE.texture,
				uniform_name = "u_texture",
			},
		})

		logic.camera_init(&STATE.camera, logic.Orthographic_Camera_Descriptor {
			left = -1.0,
			right = 1.0,
			top = 1.0,
			bottom = -1.0,
			near = 0.001,
			far = 1000.0,
		})
		STATE.camera.position = { 0.0, 0.0, -5.0 }
		STATE.camera.rotation = { 0.0, 0.0,  0.0 }
	}

	{
		vertex_source, _ := os.read_entire_file("res/vx_lib/shaders/texture.vs")
		defer delete(vertex_source)
		fragment_source, _ := os.read_entire_file("res/vx_lib/shaders/texture.fs")
		defer delete(fragment_source)

		gfx.pipeline_init(&STATE.basic_pipeline, gfx.Pipeline_Descriptor {
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
				},
				{
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

		gfx.buffer_init(&STATE.basic_v_buffer, gfx.Buffer_Descriptor {
			type = .Vertex_Buffer,
			usage = .Static_Draw,
		}, []f32 {
			-1.0, -1.0, 1.0, 1.0, 0.0,
			-1.0,  1.0, 1.0, 1.0, 1.0,
			 1.0,  1.0, 1.0, 0.0, 1.0,
			 1.0, -1.0, 1.0, 0.0, 0.0,
		})
		gfx.buffer_init(&STATE.basic_i_buffer, gfx.Buffer_Descriptor {
			type = .Index_Buffer,
			usage = .Static_Draw,
			index_type = .U32,
		}, []u32 {
			0, 1, 2,
			2, 3, 0,
		})
	}

	{
		compute_source, _ := os.read_entire_file("res/vx_lib/shaders/test.cl")
		defer delete(compute_source)

		compute_pipeline: gfx.Compute_Pipeline
		gfx.computepipeline_init(&compute_pipeline, gfx.Compute_Pipeline_Descriptor {
			source = string(compute_source),
    		entry_point = "colorify",

    		dimensions = 2,
    		global_work_sizes = { 256, 256 },
			local_work_sizes  = { 16, 16 },
		})
		defer gfx.computepipeline_free(compute_pipeline)

		gfx.texture_init(&STATE.ctexture, gfx.Texture_Descriptor {
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

		output: gfx.Compute_Buffer
		gfx.computebuffer_init_from_texture(&output, gfx.Compute_Buffer_Descriptor {
			type = .Write_Only,
			size = 256 * 256 * 4,
		}, STATE.ctexture)
		defer gfx.computebuffer_free(output)

		bindings: gfx.Compute_Bindings
		gfx.computebindings_init(&bindings, []gfx.Compute_Bindings_Element {
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

		gfx.computepipeline_compute(&compute_pipeline, &bindings)
	}

	gfx.bindings_init(&STATE.basic_bindings, []gfx.Buffer { STATE.basic_v_buffer }, STATE.basic_i_buffer, []gfx.Texture_Binding {
		gfx.framebuffer_get_color_texture_bindings(STATE.framebuffer, "u_texture1"),
		{
			uniform_name = "u_texture2",
			texture = STATE.ctexture,
		},
	})
}

tick :: proc() {
	input_common()
}

draw :: proc() {
	gfx.pipeline_clear(STATE.pipeline)

	gfx.pipeline_uniform_1f(&STATE.pipeline, "u_time", (f32)(platform.windowhelper_get_time()))
	logic.camera_apply(STATE.camera, STATE.camera.position, STATE.camera.rotation, &STATE.pipeline)

	gfx.pipeline_draw_elements(&STATE.pipeline, &STATE.bindings, .Triangles, 6)

	gfx.pipeline_clear(STATE.basic_pipeline)
	gfx.pipeline_draw_elements(&STATE.basic_pipeline, &STATE.basic_bindings, .Triangles, 6)

}

close :: proc() {
	gfx.pipeline_free(&STATE.pipeline)
	gfx.buffer_free(&STATE.v_buffer)
	gfx.buffer_free(&STATE.i_buffer)
	gfx.texture_free(&STATE.texture)
	gfx.bindings_free(STATE.bindings)

	gfx.framebuffer_free(&STATE.framebuffer)

	gfx.pipeline_free(&STATE.basic_pipeline)
	gfx.buffer_free(&STATE.basic_v_buffer)
	gfx.buffer_free(&STATE.basic_i_buffer)
	gfx.bindings_free(STATE.basic_bindings)

	core.cell_free(&STATE)
}

resize :: proc() {
	gfx.pipeline_resize(&STATE.basic_pipeline, platform.windowhelper_get_window_size())
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
