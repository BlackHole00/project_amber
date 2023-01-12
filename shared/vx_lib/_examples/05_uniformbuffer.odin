package main

import "shared:glfw"
import "shared:vx_lib/gfx"
import "shared:vx_lib/platform"
import "shared:vx_lib/common"
import core "shared:vx_core"

State :: struct {
    clear_pipeline: gfx.Pipeline,

    pipeline: gfx.Pipeline,

    v_buffer: gfx.Buffer,
    u_buffer: gfx.Buffer,

    bindings: gfx.Bindings,
}
STATE: core.Cell(State)

vertex_source := `
#version 330 core
layout (location = 0) in vec3 a_pos;

layout (std140) uniform u_block {
    vec4 u_color;
};
out vec4 v_color;

void main() {
    gl_Position = vec4(a_pos, 1.0);

    v_color = u_color;
}
`

fragment_source := `
#version 330 core

in vec4 v_color;

out vec4 o_color;

void main() {
    o_color = v_color;
}
`

init :: proc() {
	core.cell_init(&STATE)

    STATE.clear_pipeline = gfx.pipeline_new(gfx.Pipeline_Descriptor {
        viewport_size = platform.windowhelper_get_window_size(),
        clearing_color = gfx.TESTING_ORANGE,
        clear_depth = false,
        clear_color = true,
    })

    STATE.pipeline = gfx.pipeline_new(gfx.Pipeline_Descriptor {
        cull_enabled = false,
        depth_enabled = false,
        blend_enabled = false,
        wireframe = false,

        vertex_source = vertex_source,
        fragment_source = fragment_source,

        layout = []gfx.Layout_Element {
            {
                type = .F32,
                count = 3,
                normalized = false,
                buffer_idx = 0,
                divisor = 0,
            },
        },

        viewport_size = platform.windowhelper_get_window_size(),

        clear_depth = false,
        clear_color = false,
    })

    STATE.v_buffer = gfx.buffer_new(gfx.Buffer_Descriptor {
        type = .Vertex_Buffer,
        usage = .Static_Draw,
    }, []f32 {
        -0.5, -0.5, 1.0,
         0.0,  0.5, 1.0,
         0.5, -0.5, 1.0,
    })

    STATE.u_buffer = gfx.buffer_new(gfx.Buffer_Descriptor {
        type = .Uniform_Buffer,
        usage = .Static_Draw,
    }, []f32 {
        0.0, 0.25, 0.5, 1.0,
    })

    STATE.bindings = gfx.bindings_new(
        []gfx.Buffer { STATE.v_buffer },
        nil,
        []gfx.Texture_Binding {},
        []gfx.Uniform_Buffer_Binding { 
            {
                uniform_name = "u_block",
                buffer = STATE.u_buffer, 
            },
        },
    )
}

tick :: proc() {
	input_common()
}

draw :: proc() {
    gfx.pipeline_clear(STATE.clear_pipeline)
    gfx.pipeline_draw_arrays(STATE.pipeline, STATE.bindings, .Triangles, 0, 3)
}

close :: proc() {
    gfx.buffer_free(STATE.v_buffer)
    gfx.buffer_free(STATE.u_buffer)
    gfx.bindings_free(STATE.bindings)
    gfx.pipeline_free(STATE.clear_pipeline)
    gfx.pipeline_free(STATE.pipeline)

	core.cell_free(&STATE)
}

resize :: proc() {
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
