package vx_lib_platform

import "shared:vx_lib/core"
import "core:c"
import "core:strings"
import "core:time"
import "core:runtime"
import "core:log"
import "vendor:glfw"

Window :: struct {
    handle: glfw.WindowHandle,
    data: Window_Platform_Data,
    callbacks: Window_Callbacks,
}

WINDOW_INSTANCE: core.Cell(Window)

window_init :: proc(desc: Window_Descriptor) {
    core.cell_init(&WINDOW_INSTANCE)

    assert(core.cell_is_valid(WINDOWCONTEXT_INSTANCE), "Window context instance is not valid.")
    windowcontext_safetize_procs()

    title := strings.clone_to_cstring(desc.title, context.temp_allocator)
    monitor: glfw.MonitorHandle = desc.fullscreen ? glfw.GetPrimaryMonitor() : nil

    glfw.WindowHint(glfw.DECORATED, (c.int)(desc.decorated))
    glfw.WindowHint(glfw.RESIZABLE, (c.int)(desc.resizable))

    if ok, msg := WINDOWCONTEXT_INSTANCE.pre_window_init_proc(); !ok {
        log.error("Window context creation has failed with the following message:", msg)
    }

    WINDOW_INSTANCE.handle = glfw.CreateWindow((c.int)(desc.size.x), (c.int)(desc.size.y), title, monitor, nil)

    if ok, msg := WINDOWCONTEXT_INSTANCE.post_window_init_proc(WINDOW_INSTANCE.handle, desc); !ok {
        log.error("Window context creation has failed with the following message:", msg)
    }

    glfw.SetWindowSizeCallback(WINDOW_INSTANCE.handle, window_resize_callback)
    glfw.SetCursorPosCallback(WINDOW_INSTANCE.handle, window_mouse_pos_callback)
    glfw.SetScrollCallback(WINDOW_INSTANCE.handle, window_mouse_scroll_callback)
    glfw.SetMouseButtonCallback(WINDOW_INSTANCE.handle, window_mouse_button_callback)
    glfw.SetKeyCallback(WINDOW_INSTANCE.handle, window_key_callback)

    WINDOW_INSTANCE.callbacks   = desc
    WINDOW_INSTANCE.data        = desc

    core.safetize_function(&WINDOW_INSTANCE.callbacks.init_proc)
    core.safetize_function(&WINDOW_INSTANCE.callbacks.logic_proc)
    core.safetize_function(&WINDOW_INSTANCE.callbacks.draw_proc)
    core.safetize_function(&WINDOW_INSTANCE.callbacks.close_proc)
    core.safetize_function(&WINDOW_INSTANCE.callbacks.resize_proc)

    windowhelper_init()
}

window_run :: proc() {
    if (!core.cell_is_valid(WINDOW_INSTANCE)) do panic("WINDOW_INSTANCE is not valid")

    last_time := time.now()

    WINDOW_INSTANCE.callbacks.init_proc()

    for !glfw.WindowShouldClose(WINDOW_INSTANCE.handle) {
        WINDOWCONTEXT_INSTANCE.pre_frame_proc(WINDOW_INSTANCE.handle)
        current_time := time.now()
        delta := time.diff(last_time, current_time)
        last_time = current_time

        windowhelper_update_timing_info(time.duration_milliseconds(delta))

        WINDOW_INSTANCE.callbacks.logic_proc()
        WINDOW_INSTANCE.callbacks.draw_proc()

        windowhelper_post_frame_update()
        glfw.PollEvents()
        WINDOWCONTEXT_INSTANCE.post_frame_proc(WINDOW_INSTANCE.handle)
    }

    WINDOW_INSTANCE.callbacks.close_proc()
}

window_deinit :: proc() {
    WINDOWCONTEXT_INSTANCE.close_proc()

    windowhelper_free()

    core.cell_free(&WINDOW_INSTANCE)
}

@(private="file")
window_resize_callback :: proc "c" (_handle: glfw.WindowHandle, width: c.int, height: c.int) {
    context = runtime.default_context()

    windowhelper_set_window_size({ (uint)(width), (uint)(height) })
}

@(private="file")
window_mouse_pos_callback :: proc "c" (_handle: glfw.WindowHandle, pos_x: f64, pos_y: f64) {
    context = runtime.default_context()

    windowhelper_update_mouse_pos({ pos_x, pos_y })
}

@(private="file")
window_mouse_scroll_callback :: proc "c" (_handle: glfw.WindowHandle, pos_x: f64, pos_y: f64) {
    context = runtime.default_context()

    windowhelper_update_mouse_scroll({ pos_x, pos_y })
}

@(private="file")
window_mouse_button_callback :: proc "c" (_handle: glfw.WindowHandle, button: c.int, action: c.int, mod: c.int) {
    context = runtime.default_context()

    ks := windowhelper_get_mouse_keystate_ptr(button)
    if action == glfw.PRESS {
        ks.just_pressed = true
        ks.pressed = true
    } else if action == glfw.RELEASE {
        ks.just_released = true
        ks.pressed = false
    }
}

@(private="file")
window_key_callback :: proc "c" (_handle: glfw.WindowHandle, key: c.int, scancode: c.int, action: c.int, mod: c.int) {
    context = runtime.default_context()

    ks := windowhelper_get_keyboard_keystate_ptr(key)
    if action == glfw.PRESS {
        ks.just_pressed = true
        ks.pressed = true
    } else if action == glfw.RELEASE {
        ks.just_released = true
        ks.pressed = false
    }
}
