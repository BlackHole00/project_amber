package vx_lib_gfx_dx11

import gl "vendor:OpenGL"
import "shared:glfw"
import core "shared:vx_core"
import "shared:vx_lib/gfx"

BACKEND_INITIALIZER :: gfx.Backend_Initializer {
    init_proc = backend_init,
    deinit_proc = backend_deinit,
}

@(private)
backend_init :: proc(user_init_data: gfx.Backend_User_Initialization_Data, init_data: gfx.Backend_Initialization_Data) -> bool {
    core.cell_init(&CONTEXT_INSTANCE)

    CONTEXT_INSTANCE.allocator = user_init_data.allocator
    CONTEXT_INSTANCE.logger = user_init_data.logger
    CONTEXT_INSTANCE.debug = user_init_data.debug

    CONTEXT_INSTANCE.native_hwnd = glfw.GetWin32Window(init_data.window_handle)

    return true
}

@(private)
backend_deinit :: proc() {
    if CONTEXT_INSTANCE.swpachain_rendertarget != nil do CONTEXT_INSTANCE.swpachain_rendertarget->Release()
    if CONTEXT_INSTANCE.swapchain != nil do CONTEXT_INSTANCE.swapchain->Release()
    if CONTEXT_INSTANCE.device != nil do CONTEXT_INSTANCE.device->Release()
    if CONTEXT_INSTANCE.device_context != nil do CONTEXT_INSTANCE.device_context->Release()

    core.cell_free(&CONTEXT_INSTANCE)
}

backend_get_info :: proc() -> gfx.Backend_Info {
    return gfx.Backend_Info {
        name = "DirectX 11",
        version = core.Version {
            major = 0,
            minor = 1,
            revision = 0,
        },
    }
}

backendinfo_free :: proc(info: gfx.Backend_Info) {}