package main

// import "core:strings"
import "core:strconv"
import "core:log"
import "core:os"
// import gl "vendor:OpenGL"
// import win "core:sys/windows"
import "shared:glfw"
import "shared:glslang"
import core "shared:vx_core"
import deps "shared:vx_lib/dependences"
import plt "shared:vx_lib/platform"
import wnd "shared:vx_lib/window"
import "shared:vx_lib/gfx"
import "shared:vx_lib/gfx/gl4"
import "shared:vx_lib/gfx/dx11"

_ :: gl4
_ :: dx11

counter := 0

init :: proc() -> (result: plt.Platform_Operation_Result, message: string) {
	context = core.default_context()

	device_id: uint = 0
	if data, ok := os.read_entire_file("config.txt"); ok {
		defer delete(data)

		device_id, _ = strconv.parse_uint((string)(data))
	}

	SWAPCHAIN_DESCRIPTOR := gfx.Swapchain_Descriptor {
		present_mode = .Vsync,
		size = wnd.windowhelper_get_window_size(),
		format = .R8G8B8A8,
		// fullscreen = true,
	}

	backend_info := gfx.backend_get_info()
	defer gfx.backendinfo_free(backend_info)

	log.info("Using backend: ", backend_info)

	devices := gfx.get_deviceinfolist()
	defer gfx.deviceinfolist_free(devices)

	assert(len(devices) > 0, "No gfx devices are currently available.")
	log.info("Got gfx devices:")
	for device, i in devices {
		log.info(args = {
			"\t", i, ": ", device,
		}, sep = "")
	}

	log.info("Setting device with idx =", device_id)

	// TODO: choose the best device. Note that OpenGl will only have one device.
	if gfx.device_set(device_id) != .Ok {
		panic("Could not set a device!")
	}

	if state := gfx.device_set_swapchain(SWAPCHAIN_DESCRIPTOR); state != .Unavaliable_Functionality && state != .Ok {
		log.fatal(args = { "Could not set the swapchain (error", state, ")" }, sep = "")
		panic("Could not set the swapchain")
	}

	swpachain_info := gfx.swapchain_get_info()
	if swpachain_info == nil do log.warn("Could not get swapchain info.")
	else do log.info("Using swapchain: ", swpachain_info.?)

	buffer, err := gfx.buffer_new(gfx.Buffer_Descriptor {
		type = .Vertex_Buffer,
		usage = .Default,
		allocation_mode = .Dynamic,
		cpu_access = .Read_Write,
		size = 12,
		is_compute = false,
	})
	if err != .Ok {
		panic("Could not create a buffer")
	}
	defer gfx.buffer_free(buffer)

	if gfx.buffer_set_data(buffer, []u32 { 1, 2, 3, 4 }) != .Ok {
		panic("Could not set the buffer data")
	}

	data, map_error := gfx.buffer_map(buffer, .Read_Write)
	if map_error != .Ok {
		panic("Could not map the buffer")
	}

	log.info(data)
	data[2] = 5
	log.info(data)
	
	if gfx.buffer_unmap(buffer) != .Ok {
		panic("Could not unmap the buffer")
	}

	log.info(gfx.buffer_get_size(buffer))

	return .Ok, ""
}

frame :: proc() -> (result: plt.Platform_Operation_Result, message: string) {
	input_common()
	check_for_resize()
	
	// gl.ClearColor(1.0, 0.5, 0.25, 1.0)
	// gl.Clear(gl.COLOR_BUFFER_BIT)

	return .Ok, ""
}

deinit :: proc() -> (result: plt.Platform_Operation_Result, message: string) {
	return .Ok, ""
}

main :: proc() {
	glslang.shader_create(nil)

	context = core.default_context()
	defer core.free_default_context()

	plt.platform_init()
	defer plt.platform_deinit()

	plt.platform_register_extension(deps.GLFW_EXTENSION)
	plt.platform_register_extension(wnd.WINDOW_EXTENSION)
	plt.platform_register_extension(gfx.GFXSUPPORT_EXTENSION)
	plt.platform_register_extension(gfx.GFX_EXTENSION)
	plt.platform_register_extension(plt.Platform_Extension {
		name = "project_amber.game",
		dependants = {},
		dependencies = { "vx_lib.window" },
		
		init_proc = init,
		frame_proc = frame,
		deinit_proc = deinit,
	})

	wnd.window_set_descriptor(wnd.Window_Descriptor {
		fullscreen = false,
		size 		= { 640, 480 },
		title 		= "Project Amber",
		decorated 	= true,
		resizable	= true,
		show_fps_in_title = true,
		grab_cursor = false,
	})

	gfx.gfx_set_descriptor(gfx.Gfx_Descriptor {
		frontend_user_descriptor = gfx.Frontend_User_Descritor {
			frontend_context = context,
			debug = ODIN_DEBUG,
		},
		backend_user_descriptor = gfx.Backend_User_Descritor {
			backend_context = context,
			debug = ODIN_DEBUG,
		},
		backend_initializer = dx11.BACKEND_INITIALIZER,
		// backend_initializer = gl4.BACKEND_INITIALIZER,
	})

	plt.platform_run()
}

input_common :: proc() {
    if wnd.windowhelper_get_keyboard_keystate(glfw.KEY_TAB).just_pressed {
        wnd.windowhelper_set_mouse_grabbbed(!wnd.windowhelper_is_mouse_grabbed())
    }
    if wnd.windowhelper_get_keyboard_keystate(glfw.KEY_ESCAPE).just_pressed {
        wnd.windowhelper_close_window()
    }

    if wnd.windowhelper_get_keyboard_keystate(glfw.KEY_LEFT_ALT).pressed && wnd.windowhelper_get_keyboard_keystate(glfw.KEY_F).just_pressed {
        @static not_fullscreen_size: [2]uint

        if !wnd.windowhelper_is_fullscreen() {
            not_fullscreen_size = wnd.windowhelper_get_window_size()

            wnd.windowhelper_set_window_size(wnd.windowhelper_get_screen_size())
        } else do wnd.windowhelper_set_window_size(not_fullscreen_size)
        wnd.windowhelper_set_fullscreen(!wnd.windowhelper_is_fullscreen())
    }
}

check_for_resize :: proc() {
	if wnd.windowhelper_has_been_resized() {
		gfx.swapchain_resize(wnd.windowhelper_get_window_size())
	}
}
