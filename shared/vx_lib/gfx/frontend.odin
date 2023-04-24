package vx_lib_gfx

import "core:mem"
import "core:log"
import core "shared:vx_core"
import "shared:glfw"

Gfx_Descriptor :: struct {
	allocator: mem.Allocator,
	logger: log.Logger,
	debug: bool,
}

pre_window_init :: proc(descriptor: Gfx_Descriptor, initializer: Backend_Initializer) -> bool {
    core.cell_init(&CONTEXT_INSTANCE, descriptor.allocator)

    CONTEXT_INSTANCE.backend_initializer = initializer

    CONTEXT_INSTANCE.descriptor = descriptor

    return initializer.pre_window_init_proc()
}

init :: proc(window_handle: glfw.WindowHandle, user_init_data: Backend_User_Initialization_Data) -> bool {
    return CONTEXT_INSTANCE.backend_initializer.init_proc(user_init_data, Backend_Initialization_Data {
        window_handle = window_handle,
    })
}

post_frame :: proc(handle: glfw.WindowHandle) {
    CONTEXT_INSTANCE.backend_initializer.post_frame_proc(handle)
}

deinit :: proc() {
    CONTEXT_INSTANCE.backend_initializer.deinit_proc()

    core.cell_free(&CONTEXT_INSTANCE)
}