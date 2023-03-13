package vx_lib_common

import "shared:glfw"
import "shared:vx_lib/platform"
import "shared:vx_lib/gfx"
import "shared:vx_lib/gfx/gl4"

when ODIN_OS == .Darwin do #panic("The user is requesting to use Modern Opengl (DSA) on MacOs. This is not possible. Please build with -define:MODERN_OPENGL=false when targeting MacOs.")

windowcontext_init_with_gl :: proc() {
    init_gl :: proc(handle: glfw.WindowHandle, desc: platform.Window_Descriptor) -> (bool, string) {
        gfx.init(gfx.Gfx_Descriptor {
                allocator = context.allocator,
                logger = context.logger,
                debug = ODIN_DEBUG,

                window_handle = handle,
            },
            gl4.BACKEND_INITIALIZER, 
            gfx.Backend_User_Initialization_Data {
                allocator = context.allocator,
                logger = context.logger,
                debug = ODIN_DEBUG,
            },
        )

        return true, ""
    }

    pre_window_init_gl :: proc() -> (bool, string) {
        glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4)
        glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 6)
        glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

        return true, ""
    }

    post_frame_gl :: proc(handle: glfw.WindowHandle) {
        glfw.SwapBuffers(platform.WINDOW_INSTANCE.handle)
    }

    close_gl :: proc() {
        gfx.deinit()
    }

    platform.windowcontext_init(platform.Window_Context_Descriptor {
        pre_window_init_proc = pre_window_init_gl,
        post_window_init_proc = init_gl,
        post_frame_proc = post_frame_gl,
        close_proc = close_gl,
    })
}