package vx_lib_common

when ODIN_OS == .Darwin {

import "../gfx"
import "../platform"
import "vendor:glfw"

when ODIN_OS == .Darwin {

windowcontext_init_with_metal :: proc() {
    init_metal :: proc(handle: glfw.WindowHandle, desc: platform.Window_Descriptor) -> (bool, string) {  
        gfx.gfxprocs_init_with_metal()
        gfx.metalcontext_init(handle)
    
        return true, ""
    }

    close_metal :: proc() {
        gfx.metalcontext_free()
        gfx.gfxprocs_free()
    }

    pre_window_init :: proc() -> (bool, string) {
        glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API)

        gfx.GFX_BACKEND_API = .Metal

        return true, ""
    }

    pre_frame_proc :: proc(handle: glfw.WindowHandle) {
        gfx.metalcontext_pre_frame()
    }

    post_frame_proc :: proc(handle: glfw.WindowHandle) {
        gfx.metalcontext_post_frame()
    }

    platform.windowcontext_init()
    platform.WINDOWCONTEXT_INSTANCE.pre_window_init_proc = pre_window_init
    platform.WINDOWCONTEXT_INSTANCE.post_window_init_proc = init_metal
    platform.WINDOWCONTEXT_INSTANCE.close_proc = close_metal
    platform.WINDOWCONTEXT_INSTANCE.post_frame_proc = post_frame_proc
    platform.WINDOWCONTEXT_INSTANCE.pre_frame_proc = pre_frame_proc
}

}

}