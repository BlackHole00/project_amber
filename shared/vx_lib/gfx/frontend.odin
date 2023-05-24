package vx_lib_gfx

import "core:runtime"
import core "shared:vx_core"
import "shared:glfw"
import wnd "shared:vx_lib/window"

Frontend_User_Descritor :: struct {
	frontend_context: runtime.Context,
	debug: bool,
}

Gfx_Descriptor :: struct {
	frontend_user_descriptor: Frontend_User_Descritor,
	backend_user_descriptor: Backend_User_Descritor,
	backend_initializer: Backend_Initializer,
}

gfx_set_descriptor :: proc(descriptor: Gfx_Descriptor) {
    context = descriptor.frontend_user_descriptor.frontend_context

    core.cell_init(&CONTEXT_INSTANCE)

    CONTEXT_INSTANCE.descriptor = descriptor
}

gfx_pre_window_init :: proc() -> bool {
    context = gfx_default_context()
    assert(core.cell_is_valid(CONTEXT_INSTANCE), "The gfx descriptor must be set before calling gfx_pre_window_init.")

    return CONTEXT_INSTANCE.backend_initializer.pre_window_init_proc(CONTEXT_INSTANCE.descriptor.backend_user_descriptor)
}

gfx_init :: proc(window_handle: glfw.WindowHandle = nil) -> bool {
    handle := window_handle
    if (handle == nil) do handle = wnd.windowhelper_get_raw_handle()

    return CONTEXT_INSTANCE.backend_initializer.init_proc(Backend_Initialization_Data {
        window_handle = handle,
    })
}

gfx_post_frame :: proc(window_handle: glfw.WindowHandle = nil) {
    handle := window_handle
    if (handle == nil) do handle = wnd.windowhelper_get_raw_handle()

    CONTEXT_INSTANCE.backend_initializer.post_frame_proc(handle)
}

gfx_deinit :: proc() {
    CONTEXT_INSTANCE.backend_initializer.deinit_proc()

    core.cell_free(&CONTEXT_INSTANCE)
}