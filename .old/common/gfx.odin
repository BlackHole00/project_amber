package vx_lib_common

import "shared:glfw"
import "shared:vx_lib/platform"
import "shared:vx_lib/gfx"
import "shared:vx_lib/gfx/gl4"
import "shared:vx_lib/gfx/dx11"

when ODIN_OS == .Darwin do #panic("The user is requesting to use Modern Opengl (DSA) on MacOs. This is not possible. Please build with -define:MODERN_OPENGL=false when targeting MacOs.")

windowcontext_init_with_gfx :: proc() {
    pre_window_init_proc :: proc() -> (bool, string) {
        if !gfx.pre_window_init(
                gfx.Gfx_Descriptor {
                allocator = context.allocator,
                logger = context.logger,
                debug = ODIN_DEBUG,
            },
            gl4.BACKEND_INITIALIZER,
        ) {
            return false, "Could not initialize gfx backend."
        }

        return true, ""
    }

    init_proc :: proc(handle: glfw.WindowHandle, desc: platform.Window_Descriptor) -> (bool, string) {
        gfx.init(
            handle,
            gfx.Backend_User_Initialization_Data {
                allocator = context.allocator,
                logger = context.logger,
                debug = ODIN_DEBUG,
            },
        )

        return true, ""
    }

    post_frame_proc :: proc(handle: glfw.WindowHandle) {
        gfx.post_frame(handle)
    }

    close_proc :: proc() {
        gfx.deinit()
    }

    platform.windowcontext_init(platform.Window_Context_Descriptor {
        pre_window_init_proc = pre_window_init_proc,
        post_window_init_proc = init_proc,
        post_frame_proc = post_frame_proc,
        close_proc = close_proc,
    })
}

_ :: gl4
_ :: dx11
