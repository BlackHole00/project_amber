package vx_lib_platform

Window_Callbacks :: struct {
    init_proc:  proc(),
    logic_proc: proc(),
    draw_proc:  proc(),
    close_proc: proc(),
    resize_proc: proc(),
}

Window_Gfx_Data :: struct {
    fullscreen: bool,
    vsync: bool,
}

Window_Platform_Data :: struct {
    using window_gfx_data: Window_Gfx_Data,

    size: [2]uint,
    title: string,
    decorated: bool,
    resizable: bool,
    show_fps_in_title: bool,
    grab_cursor: bool,
}

// Describes how a window should be created.  
// The user, aside from basic informations should also provide callbacks that
// will be called by the window_run() procedure.  
// These callbacks are:
//   - init_proc: called before the first frame
//   - logic_proc: called every frame. It should only be used for updating 
//                 logic and not for drawing.
//   - draw_proc: called every frame. It should only be used for drawing and
//                not for updating logic.
//   - close_proc: called after the last frame.
//   - resize_proc: called when the window is resized.
Window_Descriptor :: struct {
    using window_platform_data: Window_Platform_Data,
    using window_callbacks: Window_Callbacks,
}
