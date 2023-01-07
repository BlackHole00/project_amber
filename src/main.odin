package main

// import "core:os"
import "vendor:glfw"
import "shared:vx_lib/gfx"
import "shared:vx_lib/platform"
// import "shared:vx_lib/logic"
// import "shared:vx_lib/logic/objects"
import "shared:vx_lib/common"
import core "shared:vx_core"

State :: struct {
    clear_pipeline: gfx.Pipeline,
}
STATE: core.Cell(State)

init :: proc() {
	core.cell_init(&STATE)

    STATE.clear_pipeline = gfx.pipeline_new(gfx.Pipeline_Descriptor {
        viewport_size = platform.windowhelper_get_window_size(),
        clearing_color = gfx.TESTING_ORANGE,
        clear_depth = true,
        clear_color = true,
    })
}

tick :: proc() {
	input_common()
}

draw :: proc() {
    gfx.pipeline_clear(STATE.clear_pipeline)
}

close :: proc() {
    gfx.pipeline_free(STATE.clear_pipeline)

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
