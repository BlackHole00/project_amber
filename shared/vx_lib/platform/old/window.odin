package vx_lib_platform

import "core:c"
import "core:strings"
import "core:time"
import "core:runtime"
import "core:log"
import "core:mem"
import "shared:glfw"
import core "shared:vx_core"

// SINGLETON - A simple glfw window representation.
Window :: struct {
    handle: glfw.WindowHandle,
    data: Window_Platform_Data,
    callbacks: Window_Callbacks,
}
WINDOW_INSTANCE: core.Cell(Window)

// Initializes the window using the descriptor.  
// WINDOWCONTEXT_INSTANCE must be valid or the function will panic.  
// GLFW must be already initialized using Platform.
window_init :: proc(desc: Window_Descriptor) {
    core.cell_init(&WINDOW_INSTANCE)

    windowhelper_init()
    WINDOW_INSTANCE.data = desc

    assert(core.cell_is_valid(WINDOWCONTEXT_INSTANCE), "Window context instance is not valid.")
    windowcontext_safetize_procs()

    title := strings.clone_to_cstring(desc.title, context.temp_allocator)
    monitor: glfw.MonitorHandle = desc.fullscreen ? glfw.GetPrimaryMonitor() : nil

    log.info("Running the context's pre-window initialization.")
    if ok, msg := WINDOWCONTEXT_INSTANCE.pre_window_init_proc(); !ok {
        log.fatal("Window context creation has failed with the following message:", msg)
        panic("Error when initializing window user gfx context.")
    } else do log.info("Successfully run the context's pre-window initialization.")
    glfw.WindowHint(glfw.DECORATED, (c.int)(desc.decorated))
    glfw.WindowHint(glfw.RESIZABLE, (c.int)(desc.resizable))

    log.info("Creating the glfw window.")
    WINDOW_INSTANCE.handle = glfw.CreateWindow((c.int)(desc.size.x), (c.int)(desc.size.y), title, monitor, nil)
    assert(WINDOW_INSTANCE.handle != nil, "Could not create the glfw window.")
    log.info("Successfully created the glfw window.")

    log.info("Running the context's post-window initialization.")
    if ok, msg := WINDOWCONTEXT_INSTANCE.post_window_init_proc(WINDOW_INSTANCE.handle, desc); !ok {
        log.fatal("Window context creation has failed with the following message:", msg)
        panic("Error when initializing window user gfx context.")
    } else do log.info("Successfully run the context's post-window initialization.")

    glfw.SetWindowSizeCallback(WINDOW_INSTANCE.handle, window_resize_callback)
    glfw.SetCursorPosCallback(WINDOW_INSTANCE.handle, window_mouse_pos_callback)
    glfw.SetScrollCallback(WINDOW_INSTANCE.handle, window_mouse_scroll_callback)
    glfw.SetMouseButtonCallback(WINDOW_INSTANCE.handle, window_mouse_button_callback)
    glfw.SetKeyCallback(WINDOW_INSTANCE.handle, window_key_callback)

    WINDOW_INSTANCE.callbacks = desc.window_callbacks

    // In order to not use an if statement at every call, the functions are
    // made safe to call. They will now point to a dummy function that is safe
    // to call.
    core.safetize_function(&WINDOW_INSTANCE.callbacks.init_proc)
    core.safetize_function(&WINDOW_INSTANCE.callbacks.logic_proc)
    core.safetize_function(&WINDOW_INSTANCE.callbacks.draw_proc)
    core.safetize_function(&WINDOW_INSTANCE.callbacks.close_proc)
    core.safetize_function(&WINDOW_INSTANCE.callbacks.resize_proc)
}

// Shows the window and runs the main game loop. It will call the user 
// init_proc before the first frame, will call, respectively logic_proc and
// draw_proc every frame and, finally the close_proc. All these functions are
// the ones taken from the user descriptor during initialization.  
// WINDOW_INSTANCE must be valid.
window_run :: proc() {
    if (!core.cell_is_valid(WINDOW_INSTANCE)) do panic("WINDOW_INSTANCE is not valid")

    last_time := time.now()

    log.info("Running user init proc.")
    WINDOW_INSTANCE.callbacks.init_proc()

    log.info("Starting main loop.")
    for !glfw.WindowShouldClose(WINDOW_INSTANCE.handle) {
        WINDOWCONTEXT_INSTANCE.pre_frame_proc(WINDOW_INSTANCE.handle)

        // calculation of delta and update of Window_Helper's timings.
        current_time := time.now()
        delta := time.diff(last_time, current_time)
        last_time = current_time
        windowhelper_update_timing_info(time.duration_milliseconds(delta))

        WINDOW_INSTANCE.callbacks.logic_proc()
        WINDOW_INSTANCE.callbacks.draw_proc()

        windowhelper_post_frame_update()
        glfw.PollEvents()
        WINDOWCONTEXT_INSTANCE.post_frame_proc(WINDOW_INSTANCE.handle)

        mem.free_all(context.temp_allocator)
    }
    log.info("Main loop ended.")

    log.info("Running user close proc.")
    WINDOW_INSTANCE.callbacks.close_proc()
}

// Frees the glfw window and relative data.
window_deinit :: proc() {
    WINDOWCONTEXT_INSTANCE.close_proc()

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
