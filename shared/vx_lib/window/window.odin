package vx_lib_window

import "core:c"
import "core:strings"
import "core:time"
import "core:runtime"
import "core:log"
import "shared:glfw"
import core "shared:vx_core"
import plt "shared:vx_lib/platform"

// SINGLETON - A simple glfw window representation.
Window :: struct {
    handle: glfw.WindowHandle,

    data: Window_Platform_Data,

    last_time: time.Time,
}
@(private)
WINDOW_INSTANCE: core.Cell(Window)

// Initializes the window using the descriptor.  
// WINDOWCONTEXT_INSTANCE must be valid or the function will panic.  
// GLFW must be already initialized using Platform.
window_init :: proc() -> (plt.Platform_Operation_Result, string) {
    if !core.cell_is_valid(WINDOW_DESCRIPTOR_INSTANCE) {
        return .Fatal, "Window descriptor has not yet been set!"
    }
    core.cell_init(&WINDOW_INSTANCE)

    windowhelper_init()
    WINDOW_INSTANCE.data = WINDOW_DESCRIPTOR_INSTANCE.ptr^

    title := strings.clone_to_cstring(WINDOW_INSTANCE.data.title, context.temp_allocator)
    monitor: glfw.MonitorHandle = WINDOW_INSTANCE.data.fullscreen ? glfw.GetPrimaryMonitor() : nil

    glfw.WindowHint(glfw.DECORATED, (c.int)(WINDOW_INSTANCE.data.decorated))
    glfw.WindowHint(glfw.RESIZABLE, (c.int)(WINDOW_INSTANCE.data.resizable))

    log.info("Creating the glfw window.")
    WINDOW_INSTANCE.handle = glfw.CreateWindow((c.int)(WINDOW_INSTANCE.data.size.x), (c.int)(WINDOW_INSTANCE.data.size.y), title, monitor, nil)
    if WINDOW_INSTANCE.handle == nil {
        return .Fatal, "Could not create the glfw window."
    }
    log.info("Successfully created the glfw window.")

    glfw.SetWindowSizeCallback(WINDOW_INSTANCE.handle, window_resize_callback)
    glfw.SetCursorPosCallback(WINDOW_INSTANCE.handle, window_mouse_pos_callback)
    glfw.SetScrollCallback(WINDOW_INSTANCE.handle, window_mouse_scroll_callback)
    glfw.SetMouseButtonCallback(WINDOW_INSTANCE.handle, window_mouse_button_callback)
    glfw.SetKeyCallback(WINDOW_INSTANCE.handle, window_key_callback)

    WINDOW_INSTANCE.last_time = time.now()

    return .Ok, ""
}

window_preframe :: proc() {
    if glfw.WindowShouldClose(WINDOW_INSTANCE.handle) {
        return
    }

    // calculation of delta and update of Window_Helper's timings.
    current_time := time.now()
    delta := time.diff(WINDOW_INSTANCE.last_time, current_time)
    WINDOW_INSTANCE.last_time = current_time
    windowhelper_update_timing_info(time.duration_milliseconds(delta))
}

window_postframe :: proc() {
    if glfw.WindowShouldClose(WINDOW_INSTANCE.handle) {
        plt.platform_request_close()

        return
    }

    windowhelper_post_frame_update()
    glfw.PollEvents()
}

// Frees the glfw window and relative data.
window_deinit :: proc() {
    windowhelper_deinit()

    core.cell_free(&WINDOW_INSTANCE)
}

@(private="file")
window_resize_callback :: proc "c" (_handle: glfw.WindowHandle, width: c.int, height: c.int) {
    context = runtime.default_context()

    windowhelper_set_window_size({ (uint)(width), (uint)(height) })
    WINDOWHELPER_INSTANCE.state.resized = true
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
