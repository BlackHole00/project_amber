package vx_lib_platform

Window_Callbacks :: struct {
    init_proc:  proc(),
    logic_proc: proc(),
    draw_proc:  proc(),
    close_proc: proc(),
    resize_proc: proc(),
}

Window_Platform_Data :: struct {
    size: [2]uint,
    title: string,
    fullscreen: bool,
    decorated: bool,
    resizable: bool,
    show_fps_in_title: bool,
    grab_cursor: bool,
    vsync: bool,
}

Window_Descriptor :: struct {
    using window_platform_data: Window_Platform_Data,
    using window_callbacks: Window_Callbacks,
}
