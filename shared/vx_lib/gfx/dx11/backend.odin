//+build windows
package vx_lib_gfx_dx11

import "vendor:directx/d3d11"
import "shared:glfw"
import core "shared:vx_core"
import "shared:vx_lib/gfx"
import wnd "shared:vx_lib/window"

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
    wnd.windowhelper_set_fullscreen(false)

    if CONTEXT_INSTANCE.swpachain_rendertarget != nil do CONTEXT_INSTANCE.swpachain_rendertarget->Release()
    // TODO: VVV Fix this line in fullscreen VVV
    if CONTEXT_INSTANCE.swapchain != nil do CONTEXT_INSTANCE.swapchain->Release()

    if CONTEXT_INSTANCE.debug {
        debug: ^d3d11.IDebug
        CONTEXT_INSTANCE.device->QueryInterface(d3d11.IDebug_UUID, auto_cast &debug)

        debug->ReportLiveDeviceObjects({ .DETAIL })
        CONTEXT_INSTANCE.device_context->ClearState()
        CONTEXT_INSTANCE.device_context->Flush()
    }

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

    gfx.CONTEXT_INSTANCE.backend_get_info   = backend_get_info
    gfx.CONTEXT_INSTANCE.backendinfo_free   = backendinfo_free
    gfx.CONTEXT_INSTANCE.device_get_info    = device_get_info
    gfx.CONTEXT_INSTANCE.get_device_count   = get_device_count
    gfx.CONTEXT_INSTANCE.deviceinfo_free    = deviceinfo_free
    gfx.CONTEXT_INSTANCE.get_deviceinfo_of_idx = get_deviceinfo_of_idx
    gfx.CONTEXT_INSTANCE.device_set         = device_set
    gfx.CONTEXT_INSTANCE.device_check_swapchain_descriptor = device_check_swapchain_descriptor
    gfx.CONTEXT_INSTANCE.device_set_swapchain = device_set_swapchain
    gfx.CONTEXT_INSTANCE.swapchain_get_info = swapchain_get_info
    gfx.CONTEXT_INSTANCE.swapchain_resize = swapchain_resize
    gfx.CONTEXT_INSTANCE.swapchain_get_rendertarget = swapchain_get_rendertarget

    return true
}

@(private)
backend_post_frame :: proc(handle: glfw.WindowHandle) {
    swapchain_present()
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