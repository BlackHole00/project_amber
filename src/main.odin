package main

// import "core:log"
// import gl "vendor:OpenGL"
// import "shared:glfw"
// import "shared:vx_lib/platform"
// import "shared:vx_lib/common"
// import "shared:vx_lib/gfx"
// import core "shared:vx_core"

// State :: struct {
// }
// STATE: core.Cell(State)

// init :: proc() {
// 	context = core.default_context()

// 	DEVICE_REQUIREMENTS :: gfx.Device_Requirements {
// 		device_type = .Performance,
// 	}
// 	SWAPCHAIN_DESCRIPTOR := gfx.Swapchain_Descriptor {
// 		present_mode = .Fifo,
// 		size = platform.windowhelper_get_window_size(),
// 		refresh_rate = 60,
// 		format = .Unknown,
// 	}

// 	backend_info := gfx.backend_get_info()
// 	defer gfx.backendinfo_free(backend_info)

// 	log.info("Using backend: ", backend_info)

// 	if state := gfx.device_try_set(DEVICE_REQUIREMENTS); state == .Unavaliable_Functionality {
// 		gfx.device_set(DEVICE_REQUIREMENTS)
// 	} else {
// 		log.fatal(args = { "Could not set a device (error", state, ")" }, sep = "")
// 		panic("Could not set a device")
// 	}

// 	device_info := gfx.device_get_info()
// 	defer gfx.deviceinfo_free(device_info)

// 	if device_info == nil do log.warn("Could not get device info.")
// 	else do log.info("Using device: ", device_info.?)

// 	if state := gfx.device_try_set_swapchain(SWAPCHAIN_DESCRIPTOR); state == .Unavaliable_Functionality {
// 		gfx.device_set_swapchain(SWAPCHAIN_DESCRIPTOR)
// 	} else {
// 		log.fatal(args = { "Could not set the swapchain (error", state, ")" }, sep = "")
// 		panic("Could not set the swapchain")
// 	}

// 	swpachain_info := gfx.swapchain_get_info()
// 	if swpachain_info == nil do log.warn("Could not get swapchain info.")
// 	else do log.info("Using swapchain: ", swpachain_info.?)
// }

// tick :: proc() {
// 	input_common()
// }

// draw :: proc() {
// 	gl.ClearColor(1.0, 0.5, 0.25, 1.0)
// 	gl.Clear(gl.COLOR_BUFFER_BIT)
// }

// close :: proc() {
// 	core.cell_free(&STATE)
// }

// resize :: proc() {
// 	context = core.default_context()

// 	gfx.swapchain_resize(platform.windowhelper_get_window_size())

// 	swpachain_info := gfx.swapchain_get_info()
// 	if swpachain_info == nil do log.warn("Could not get swapchain info.")
// 	else do log.info("Using new swapchain: ", swpachain_info.?)
// }

// main :: proc() {
// 	context = core.default_context()
// 	defer core.free_default_context()

// 	common.vx_lib_init()
// 	defer common.vx_lib_free()

// 	platform.platform_start()
// 	defer platform.platform_close()

// 	desc: platform.Window_Descriptor
// 	desc.title = "Window"
// 	desc.size = { 640, 480 }
// 	desc.decorated = true
// 	desc.show_fps_in_title = true
// 	desc.init_proc = init
// 	desc.logic_proc = tick
// 	desc.draw_proc = draw
// 	desc.resize_proc = resize
// 	desc.close_proc = close
// 	desc.vsync = false
// 	desc.resizable = true
// 	desc.fullscreen = false

// 	platform.window_init(desc)
// 	defer platform.window_deinit()

// 	platform.window_run()
// }

// input_common :: proc() {
//     if platform.windowhelper_get_keyboard_keystate(glfw.KEY_TAB).just_pressed {
//         platform.windowhelper_set_mouse_grabbbed(!platform.windowhelper_is_mouse_grabbed())
//     }
//     if platform.windowhelper_get_keyboard_keystate(glfw.KEY_ESCAPE).just_pressed {
//         platform.windowhelper_close_window()
//     }

//     if platform.windowhelper_get_keyboard_keystate(glfw.KEY_LEFT_ALT).pressed && platform.windowhelper_get_keyboard_keystate(glfw.KEY_F).just_pressed {
//         @static not_fullscreen_size: [2]uint

//         if !platform.windowhelper_is_fullscreen() {
//             not_fullscreen_size = platform.windowhelper_get_window_size()

//             platform.windowhelper_set_window_size(platform.windowhelper_get_screen_size())
//         } else do platform.windowhelper_set_window_size(not_fullscreen_size)
//         platform.windowhelper_set_fullscreen(!platform.windowhelper_is_fullscreen())
//     }
// }

import core "shared:vx_core"
import "shared:vx_lib/platform"

main :: proc() {
	context = core.default_context()

	platform.platform_init()
	defer platform.platform_deinit()

	platform.platform_register_extension(platform.Platform_Extension {
		name = "windowing",
		dependants = {},
		dependencies = {},
	})

	platform.platform_register_extension(platform.Platform_Extension {
		name = "gfx",
		dependants = {},
		dependencies = { "windowing" },
	})

	platform.platform_register_extension(platform.Platform_Extension {
		name = "game",
		dependants = {},
		dependencies = { "windowing", "gfx" },
	})

	platform.platform_run()
}
