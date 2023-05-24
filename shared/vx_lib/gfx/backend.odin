package vx_lib_gfx

import "core:runtime"
import "shared:glfw"
import core "shared:vx_core"

Backend_User_Descritor :: struct {
	backend_context: runtime.Context,
	debug: bool,
	extra_data: rawptr, // To be interpreted by the backend implementation
}

Backend_Initialization_Data :: struct {
	window_handle: glfw.WindowHandle,
}

Backend_Initializer :: struct {
	// returns false if the initialization has failed.
	init_proc: proc(data: Backend_Initialization_Data) -> bool,
	deinit_proc: proc(),
	pre_window_init_proc: proc(user_descriptor: Backend_User_Descritor) -> bool,
	post_frame_proc: proc(handle: glfw.WindowHandle),
}

Backend_Info :: struct {
    name: string,
	version: core.Version,
}

backend_get_info :: proc() -> Backend_Info {
    return CONTEXT_INSTANCE.backend_get_info()
}

backendinfo_free :: proc(info: Backend_Info) {
    CONTEXT_INSTANCE.backendinfo_free(info)
}