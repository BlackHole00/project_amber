package vx_lib_gfx

import "core:mem"
import "core:log"
import "shared:glfw"
import core "shared:vx_core"

Backend_User_Initialization_Data :: struct {
    allocator: mem.Allocator,
    logger: log.Logger,
    debug: bool,
    extra_data: rawptr,
}

Backend_Initialization_Data :: struct {
    window_handle: glfw.WindowHandle,
}

Backend_Initializer :: struct {
    init_proc: proc(user_init_data: Backend_User_Initialization_Data, init_data: Backend_Initialization_Data) -> bool,
	deinit_proc: proc(),
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