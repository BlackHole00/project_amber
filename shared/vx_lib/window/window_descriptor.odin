package vx_lib_window

import core "shared:vx_core"

Window_Platform_Data :: struct {
    fullscreen: bool,

    size: [2]uint,
    title: string,
    decorated: bool,
    resizable: bool,
    show_fps_in_title: bool,
    grab_cursor: bool,
}

// Describes how a window should be created.
Window_Descriptor :: Window_Platform_Data

@(private)
WINDOW_DESCRIPTOR_INSTANCE: core.Cell(Window_Descriptor)

window_set_descriptor :: proc(descriptor: Window_Descriptor) {
    if !core.cell_is_valid(WINDOW_DESCRIPTOR_INSTANCE) {
        core.cell_init(&WINDOW_DESCRIPTOR_INSTANCE, descriptor)

        return
    }

    WINDOW_DESCRIPTOR_INSTANCE.ptr^ = descriptor
}

window_get_descriptor :: proc() -> ^Window_Descriptor {
    if !core.cell_is_valid(WINDOW_DESCRIPTOR_INSTANCE) {
        return nil
    }

    return WINDOW_DESCRIPTOR_INSTANCE.ptr
}
