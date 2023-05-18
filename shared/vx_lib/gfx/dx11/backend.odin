package vx_lib_gfx_dx11

import "shared:glfw"
import core "shared:vx_core"
import "shared:vx_lib/gfx"

BACKEND_INITIALIZER :: gfx.Backend_Initializer {
    pre_window_init_proc = backend_pre_window_init,
    init_proc = backend_init,
    post_frame_proc = backend_post_frame,
    deinit_proc = backend_deinit,
}

@(private)
backend_init :: proc(data: gfx.Backend_Initialization_Data) -> bool {
    CONTEXT_INSTANCE.native_hwnd = glfw.GetWin32Window(data.window_handle)

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

@(private)
backend_pre_window_init :: proc(user_descriptor: gfx.Backend_User_Descritor) -> bool {
    glfw.WindowHint(glfw.CLIENT_API , glfw.NO_API)

    core.cell_init(&CONTEXT_INSTANCE)

    CONTEXT_INSTANCE.allocator = user_descriptor.allocator
    CONTEXT_INSTANCE.logger = user_descriptor.logger
    CONTEXT_INSTANCE.debug = user_descriptor.debug

    return true
}

@(private)
backend_post_frame :: proc(handle: glfw.WindowHandle) {
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