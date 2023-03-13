package vx_lib_common

import "shared:glfw"
import "shared:vx_lib/platform"
import "shared:vx_lib/gfx"
import "shared:vx_lib/gfx/dx11"

when ODIN_OS != .Windows do #panic("The user is requesting to use Directx on an unsupported OS. This is not possible.")

windowcontext_init_with_dx11 :: proc() {
    init_dx11 :: proc(handle: glfw.WindowHandle, desc: platform.Window_Descriptor) -> (bool, string) {
        gfx.init(gfx.Gfx_Descriptor {
                allocator = context.allocator,
                logger = context.logger,
                debug = ODIN_DEBUG,

                window_handle = handle,
            },
            dx11.BACKEND_INITIALIZER, 
            gfx.Backend_User_Initialization_Data {
                allocator = context.allocator,
                logger = context.logger,
                debug = ODIN_DEBUG,
            },
        )

        return true, ""
    }

    pre_window_init_dx11 :: proc() -> (bool, string) {
        glfw.WindowHint(glfw.CLIENT_API , glfw.NO_API)

        return true, ""
    }

    post_frame_dx11 :: proc(handle: glfw.WindowHandle) {}

    close_dx11 :: proc() {
        gfx.deinit()
    }

    platform.windowcontext_init(platform.Window_Context_Descriptor {
        pre_window_init_proc = pre_window_init_dx11,
        post_window_init_proc = init_dx11,
        post_frame_proc = post_frame_dx11,
        close_proc = close_dx11,
    })
}