package vx_lib_platform

import "vendor:glfw"
import core "shared:vx_core"

// SINGLETON - Provides the user a way to initialize the graphics backend 
// before and after creating the window using callbacks. See
// Window_Context_Descriptor for more info.
Window_Context :: struct {
    pre_window_init_proc: proc() -> (bool, string),
    post_window_init_proc: proc(glfw.WindowHandle, Window_Descriptor) -> (bool, string),
    pre_frame_proc: proc(glfw.WindowHandle),
    post_frame_proc: proc(glfw.WindowHandle),
    close_proc: proc(),
}
WINDOWCONTEXT_INSTANCE: core.Cell(Window_Context)

// Provides the callback needed for the Window_Context'initialization.  
// The callback that the user should implement are:
// - pre_window_init_proc: called before the window is created. It is usually
//                         used for providing custom glfw window hints. It must
//                         return if it was successfull and a message about the
//                         error (it is not used if the function was 
//                         successfull, in this case it can be "").
// - post_window_init_proc: called after the window had been created. Like the
//                          pre_window_init_proc it return if it was 
//                          successfull and an eventual error message.
// - pre_frame_proc: called before every frame.
// - post_frame_proc: called after every frame.
// - close_proc: called after the main loop ended, after the user close_proc.
Window_Context_Descriptor :: Window_Context

windowcontext_init :: proc(desc: Window_Context_Descriptor) {
    core.cell_init(&WINDOWCONTEXT_INSTANCE)

    WINDOWCONTEXT_INSTANCE.ptr^ = desc
}

windowcontext_free :: proc() {
    core.cell_free(&WINDOWCONTEXT_INSTANCE)
}

@(private)
windowcontext_safetize_procs :: proc() {
    // It is not possible to use safetize_function() for pre_window_init_proc 
    // and post_window_init_proc because they will return always false. It is
    // used this dummy procedure besause it returns true.
    dummy_pre_post_window_init_proc :: proc() -> (bool, string) {
        return true, ""
    }

    if WINDOWCONTEXT_INSTANCE.pre_window_init_proc == nil {
        WINDOWCONTEXT_INSTANCE.pre_window_init_proc = dummy_pre_post_window_init_proc
    }
    if WINDOWCONTEXT_INSTANCE.post_window_init_proc == nil {
        WINDOWCONTEXT_INSTANCE.post_window_init_proc = auto_cast dummy_pre_post_window_init_proc
    }
    core.safetize_function(&WINDOWCONTEXT_INSTANCE.post_frame_proc)
    core.safetize_function(&WINDOWCONTEXT_INSTANCE.close_proc)
    core.safetize_function(&WINDOWCONTEXT_INSTANCE.pre_frame_proc)
}
