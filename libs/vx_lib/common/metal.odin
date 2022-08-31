package vx_lib_common

when ODIN_OS == .Darwin {

import "../gfx"
import "../platform"
import "vendor:glfw"

windowcontext_init_with_metal :: proc() {
    init_metal :: proc(handle: glfw.WindowHandle, desc: platform.Window_Descriptor) -> (bool, string) {  
        gfx.gfxprocs_init_empty()
        gfx.metalcontext_init(handle)
    
        return true, ""
    }

    close_metal :: proc() {
        gfx.metalcontext_free()
        gfx.gfxprocs_free()
    }

    pre_window_init :: proc() -> (bool, string) {
        glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API)

        return true, ""
    }

    post_frame_proc :: proc(handle: glfw.WindowHandle) {
    }

    platform.windowcontext_init()
    platform.WINDOWCONTEXT_INSTANCE.pre_window_init_proc = pre_window_init
    platform.WINDOWCONTEXT_INSTANCE.post_window_init_proc = init_metal
    platform.WINDOWCONTEXT_INSTANCE.close_proc = close_metal
    platform.WINDOWCONTEXT_INSTANCE.post_frame_proc = post_frame_proc
}

}