//+build windows, linux
package vx_lib_gfx_gl4

import gl "vendor:OpenGL"
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
    glfw.MakeContextCurrent(data.window_handle)

    gl.load_up_to(4, 5, glfw.gl_set_proc_address)

    return true
}

@(private)
backend_deinit :: proc() {
    core.cell_free(&CONTEXT_INSTANCE)
}

@(private)
backend_pre_window_init :: proc(user_descriptor: gfx.Backend_User_Descritor) -> bool {
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 5)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    core.cell_init(&CONTEXT_INSTANCE)

    CONTEXT_INSTANCE.allocator = user_descriptor.allocator
    CONTEXT_INSTANCE.logger = user_descriptor.logger
    CONTEXT_INSTANCE.debug = user_descriptor.debug

    gfx.CONTEXT_INSTANCE.backend_get_info   = backend_get_info
    gfx.CONTEXT_INSTANCE.backendinfo_free   = backendinfo_free
    gfx.CONTEXT_INSTANCE.get_device_count   = get_device_count
    gfx.CONTEXT_INSTANCE.get_deviceinfo_of_idx = get_deviceinfo_of_idx
    gfx.CONTEXT_INSTANCE.device_set         = device_set
    gfx.CONTEXT_INSTANCE.device_get_info    = device_get_info
    gfx.CONTEXT_INSTANCE.deviceinfo_free    = deviceinfo_free
    gfx.CONTEXT_INSTANCE.device_check_swapchain_descriptor = device_check_swapchain_descriptor
    gfx.CONTEXT_INSTANCE.device_set_swapchain = device_set_swapchain
    gfx.CONTEXT_INSTANCE.swapchain_get_info = swapchain_get_info 
    gfx.CONTEXT_INSTANCE.swapchain_resize   = swapchain_resize 
    gfx.CONTEXT_INSTANCE.swapchain_get_rendertarget = swapchain_get_rendertarget 

    return true
}

@(private)
backend_post_frame :: proc(handle: glfw.WindowHandle) {
    glfw.SwapBuffers(handle)
}

backend_get_info :: proc() -> gfx.Backend_Info {
    return gfx.Backend_Info {
        name = "OpenGL",
        version = core.Version {
            major = 0,
            minor = 1,
            revision = 0,
        },
    }
}

backendinfo_free :: proc(info: gfx.Backend_Info) {}