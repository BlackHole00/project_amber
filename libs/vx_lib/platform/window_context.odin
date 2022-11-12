package vx_lib_platform

import "vendor:glfw"
import "shared:vx_lib/core"

Window_Context :: struct {
    pre_window_init_proc: proc()-> (bool, string),
    post_window_init_proc: proc(glfw.WindowHandle, Window_Descriptor) -> (bool, string),
    pre_frame_proc: proc(glfw.WindowHandle),
    post_frame_proc: proc(glfw.WindowHandle),
    close_proc: proc(),
}

Window_Context_Descriptor :: Window_Context

WINDOWCONTEXT_INSTANCE: core.Cell(Window_Context)

windowcontext_init :: proc(desc: Window_Context_Descriptor) {
    core.cell_init(&WINDOWCONTEXT_INSTANCE)

    WINDOWCONTEXT_INSTANCE.ptr^ = desc
}

windowcontext_free :: proc() {
    core.cell_free(&WINDOWCONTEXT_INSTANCE)
}

@(private)
windowcontext_safetize_procs :: proc() {
    core.safetize_function(&WINDOWCONTEXT_INSTANCE.pre_window_init_proc)
    core.safetize_function(&WINDOWCONTEXT_INSTANCE.post_window_init_proc)
    core.safetize_function(&WINDOWCONTEXT_INSTANCE.post_frame_proc)
    core.safetize_function(&WINDOWCONTEXT_INSTANCE.close_proc)
    core.safetize_function(&WINDOWCONTEXT_INSTANCE.pre_frame_proc)
}
