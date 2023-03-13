package vx_lib_gfx

import "core:mem"
import "core:log"
import core "shared:vx_core"
import "shared:glfw"

Gfx_Descriptor :: struct {
	allocator: mem.Allocator,
	logger: log.Logger,
	debug: bool,

	window_handle: glfw.WindowHandle,
}

init :: proc(desciptor: Gfx_Descriptor, initializer: Backend_Initializer, user_init_data: Backend_User_Initialization_Data) -> bool {
    core.cell_init(&CONTEXT_INSTANCE, desciptor.allocator)

    CONTEXT_INSTANCE.backend_deinit_proc = initializer.deinit_proc

    CONTEXT_INSTANCE.allocator = desciptor.allocator
    CONTEXT_INSTANCE.logger = desciptor.logger
    CONTEXT_INSTANCE.debug = desciptor.debug

    return initializer.init_proc(user_init_data, Backend_Initialization_Data {
        window_handle = desciptor.window_handle,
    })
}

deinit :: proc() {
    CONTEXT_INSTANCE.backend_deinit_proc()

    core.cell_free(&CONTEXT_INSTANCE)
}