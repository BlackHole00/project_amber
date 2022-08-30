package vx_lib_common

import "../platform"
import "../gfx"
import "vendor:glfw"

vx_lib_init :: proc() {
    platform.platform_init()
    platform_register_default_procs()

    when ODIN_OS != .Darwin do windowcontext_init_with_gl(); else do windowcontext_init_empty() 
}

vx_lib_free :: proc() {
    platform.windowcontext_free()
    platform.platform_free()
}

windowcontext_init_empty :: proc() {
    init_empty :: proc(handle: glfw.WindowHandle, desc: platform.Window_Descriptor) -> (bool, string) {  
        gfx.gfxprocs_init_empty()
    
        return true, ""
    }

    close_empty :: proc() {
        gfx.gfxprocs_free()
    }    

    platform.windowcontext_init()
    platform.WINDOWCONTEXT_INSTANCE.post_window_init_proc = init_empty
    platform.WINDOWCONTEXT_INSTANCE.close_proc = close_empty
}
