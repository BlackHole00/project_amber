package vx_lib_common

import "shared:glfw"
import "shared:vx_lib/platform"
import "shared:vx_lib/gfx"

// MODERN_OPENGL defines what version of OpenGl should be used. If it is false
// OpenGl 3.3 will be used, without DSA. This is usefull for older devices and
// for MacOs. If it is true OpenGl 4.6 will be used, with DSA. This provides
// a boost in performance (and a better API for us programmers). MODERN_OPENGL
// cannot be enabled in a MacOs enviroment.
when #config(MODERN_OPENGL, false) {
    OPENGL_VERSION: [2]int = { 4, 6 }
    MODERN_OPENGL :: true

    when ODIN_OS == .Darwin do #panic("The user is requesting to use Modern Opengl (DSA) on MacOs. This is not possible. Please build with -define:MODERN_OPENGL=false when targeting MacOs.")

    import "shared:vx_lib/gfx/GL4"
} else {
    OPENGL_VERSION: [2]int = { 3, 3 }
    MODERN_OPENGL :: false

    import "shared:vx_lib/gfx/gl3"
}

windowcontext_init_with_gl :: proc() {
    init_gl :: proc(handle: glfw.WindowHandle, desc: platform.Window_Descriptor) -> (bool, string) {
        gfx.gfxprocs_init()
        when MODERN_OPENGL do GL4.init(GL4.Context_Descriptor {
            glfw_window = handle,
            vsync = desc.vsync,
            version = OPENGL_VERSION,
        }, context.allocator)
        else do gl3.init(gl3.Context_Descriptor {
            glfw_window = handle,
            vsync = desc.vsync,
            version = OPENGL_VERSION,
        }, context.allocator)

        return true, ""
    }

    pre_window_init_gl :: proc() -> (bool, string) {
        glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, (i32)(OPENGL_VERSION[0]))
        glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, (i32)(OPENGL_VERSION[1]))
        glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
        when ODIN_OS == .Darwin do glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, 1)

        return true, ""
    }

    post_frame_gl :: proc(handle: glfw.WindowHandle) {
        glfw.SwapBuffers(handle)
        glfw.PollEvents()
    }

    close_gl :: proc() {
        when MODERN_OPENGL do GL4.deinit()
        else do gl3.deinit()
        gfx.gfxprocs_deinit()
    }

    platform.windowcontext_init(platform.Window_Context_Descriptor {
        pre_window_init_proc = pre_window_init_gl,
        post_window_init_proc = init_gl,
        post_frame_proc = post_frame_gl,
        close_proc = close_gl,
    })
}