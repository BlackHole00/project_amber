package vx_lib_gfx_gl4

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

    glfw.MakeContextCurrent(init_data.window_handle)

    gl.load_up_to(4, 6, glfw.gl_set_proc_address)

    gfx.CONTEXT_INSTANCE.backend_get_info   = backend_get_info
    gfx.CONTEXT_INSTANCE.backendinfo_free   = backendinfo_free
    gfx.CONTEXT_INSTANCE.device_check_requirements = device_check_requirements
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
backend_deinit :: proc() {
    core.cell_free(&CONTEXT_INSTANCE)
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