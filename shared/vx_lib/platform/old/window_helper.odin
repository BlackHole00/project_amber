package vx_lib_platform

import "core:fmt"
import "core:strings"
import "core:c"
import "shared:glfw"
import core "shared:vx_core"

Window_Helper_Mouse_Data :: struct {
    buttons: map[Glfw_Key]Key_State,

    // Mouse positon related.
    moved: bool,
    offset: [2]f64,
    position: [2]f64,

    // Mouse scroll wheel related.
    scrolled: bool,
    scroll_offset: [2]f64,
}

Window_Helper_KeyBoard_Data :: struct {
    keys: map[Glfw_Key]Key_State,
}

Window_Helper_Input :: struct {
    mouse: Window_Helper_Mouse_Data,
    keyboard: Window_Helper_KeyBoard_Data,
}

Window_Helper_General_State :: struct {
    resized: bool,

    delta: f64,
    fps: u64,
    ms: f64,

    // An internal counter. It counts the frames and is resetted every time
    // _delta_counter is resetted. It is used to know when calculate the fps 
    // and ms.
    _frame_count: u64,
    // An internal counter. Is resetted every time it reaches 1 second (1000.0)
    // Counts the sum of deltas. It is used to know when calculate the fps and 
    // ms.
    _delta_counter: f64,
}

// SINGLETON - A struct that is used to interface with the window and handle 
// user inputs.  
// It is initilialized in the window_init() procedure. It does not need to be
// initialized by the user.
Window_Helper :: struct {
    input: Window_Helper_Input,
    state: Window_Helper_General_State,
}
WINDOWHELPER_INSTANCE: core.Cell(Window_Helper)

@(private)
windowhelper_init :: proc() {
    core.cell_init(&WINDOWHELPER_INSTANCE)
}

@(private)
windowhelper_deinit :: proc() {
    core.cell_free(&WINDOWHELPER_INSTANCE)
}

// Returns the state of a mouse button.
windowhelper_get_mouse_keystate :: proc(button: Glfw_Key) -> Key_State {
    return WINDOWHELPER_INSTANCE.input.mouse.buttons[button]
}

// Returns the state of a keyboard key.
windowhelper_get_keyboard_keystate :: proc(key: Glfw_Key) -> Key_State {
    return WINDOWHELPER_INSTANCE.input.keyboard.keys[key]
}

windowhelper_is_mouse_grabbed :: proc() -> bool {
    return WINDOW_INSTANCE.data.grab_cursor
}

windowhelper_is_mouse_moved :: proc() -> bool {
    return WINDOWHELPER_INSTANCE.input.mouse.moved
}

windowhelper_is_mouse_scrolled :: proc() -> bool {
    return WINDOWHELPER_INSTANCE.input.mouse.scrolled
}

windowhelper_get_mouse_pos :: proc() -> [2]f64 {
    return WINDOWHELPER_INSTANCE.input.mouse.position
}

// Returns the mouse movement difference relative from the last frame.
windowhelper_get_mouse_offset :: proc() -> [2]f64 {
    return WINDOWHELPER_INSTANCE.input.mouse.offset
}

// Returns the mouse scroll wheel movement difference relative from the last 
// frame.
windowhelper_get_scroll_offset :: proc() -> [2]f64 {
    return WINDOWHELPER_INSTANCE.input.mouse.scroll_offset
}

windowhelper_get_window_title :: proc() -> string {
    return WINDOW_INSTANCE.data.title
}

windowhelper_get_window_size :: proc() -> [2]uint {
    return WINDOW_INSTANCE.data.size
}

windowhelper_get_screen_size :: proc() -> [2]uint {
    mode := glfw.GetVideoMode(glfw.GetPrimaryMonitor())

    return { (uint)(mode.width), (uint)(mode.height) }
}

windowhelper_get_window_pos :: proc() -> [2]uint {
    x, y := glfw.GetWindowPos(WINDOW_INSTANCE.handle)

    return { (uint)(x), (uint)(y) }
}

windowhelper_get_mouse_keystates :: proc() -> map[Glfw_Key]Key_State {
    return WINDOWHELPER_INSTANCE.input.mouse.buttons
}

windowhelper_get_keyboard_keystates :: proc() -> map[Glfw_Key]Key_State {
    return WINDOWHELPER_INSTANCE.input.keyboard.keys
}

windowhelper_is_fullscreen :: proc() -> bool {
    return WINDOW_INSTANCE.data.fullscreen
}

windowhelper_is_window_decorated :: proc() -> bool {
    return WINDOW_INSTANCE.data.decorated
}

windowhelper_is_window_resizable :: proc() -> bool {
    return WINDOW_INSTANCE.data.resizable
}

windowhelper_get_time :: proc() -> f64 {
    return glfw.GetTime()
}

windowhelper_get_delta_time :: proc() -> f64 {
    return WINDOWHELPER_INSTANCE.state.delta
}

windowhelper_get_fps :: proc() -> u64 {
    return WINDOWHELPER_INSTANCE.state.fps
}

windowhelper_get_ms :: proc() -> f64 {
    return WINDOWHELPER_INSTANCE.state.ms
}


windowhelper_close_window :: proc() {
    glfw.SetWindowShouldClose(WINDOW_INSTANCE.handle, true)
}

windowhelper_set_mouse_grabbbed :: proc(mousegrab: bool) {
    WINDOW_INSTANCE.data.grab_cursor = mousegrab

    glfw.SetInputMode(WINDOW_INSTANCE.handle, glfw.CURSOR, mousegrab ? glfw.CURSOR_DISABLED : glfw.CURSOR_NORMAL)
}

// Sets the position of the mouse. The update_offset parameter determines if 
// this movement should be considered in the movement offset.
windowhelper_set_mousepos :: proc(mouse_pos: [2]f64, update_offset: bool) {
    if update_offset {
        WINDOWHELPER_INSTANCE.input.mouse.offset.x += WINDOWHELPER_INSTANCE.input.mouse.position.x - mouse_pos.x
        WINDOWHELPER_INSTANCE.input.mouse.offset.y += WINDOWHELPER_INSTANCE.input.mouse.position.y - mouse_pos.y
    }

    WINDOWHELPER_INSTANCE.input.mouse.position.x = mouse_pos.x
    WINDOWHELPER_INSTANCE.input.mouse.position.y = mouse_pos.y

    glfw.SetCursorPos(WINDOW_INSTANCE.handle, mouse_pos.x, mouse_pos.y)
}

windowhelper_set_title :: proc(title: string) {
    WINDOW_INSTANCE.data.title = title

    windowhelper_update_title()
}

windowhelper_set_window_size :: proc (size: [2]uint, call_resize_callback := true) {
    WINDOW_INSTANCE.data.size = size

    glfw.SetWindowSize(WINDOW_INSTANCE.handle, (c.int)(size.x), (c.int)(size.y))

    if (call_resize_callback) {
        WINDOW_INSTANCE.callbacks.resize_proc()
    }
}

windowhelper_set_window_pos :: proc(size: [2]uint) {
    glfw.SetWindowPos(WINDOW_INSTANCE.handle, (c.int)(size.x), (c.int)(size.y))
}

windowhelper_set_fullscreen :: proc(fullscreen: bool) {
    WINDOW_INSTANCE.data.fullscreen = fullscreen
    monitor: glfw.MonitorHandle = fullscreen ? glfw.GetPrimaryMonitor() : nil

    glfw.SetWindowMonitor(WINDOW_INSTANCE.handle, monitor, 0, 0, (c.int)(WINDOW_INSTANCE.data.size.x), (c.int)(WINDOW_INSTANCE.data.size.y), WINDOW_INSTANCE.data.vsync ? 60 : glfw.DONT_CARE)

    if !fullscreen {
        pos := windowhelper_get_window_pos()
        _ = pos

        // The +30 is for windows shenanigans. 30 is the height of the windows
        // title bar. If it is not considered the window reappear in the wrong 
        // place, with the bar outside of the screen.
        when ODIN_OS == .Windows do if pos.y == 0 do windowhelper_set_window_pos({ pos.x, pos.y + 30 })
        else do windowhelper_set_window_pos(pos)
    }
}

windowhelper_set_decorated :: proc(decorated: bool) {
    WINDOW_INSTANCE.data.decorated = decorated

    glfw.SetWindowAttrib(WINDOW_INSTANCE.handle, glfw.DECORATED, (i32)(decorated))
}

windowhelper_set_show_fps_in_title :: proc(show_fps: bool) {
    WINDOW_INSTANCE.data.show_fps_in_title = show_fps
}

windowhelper_has_been_resized :: proc() -> bool {
    return WINDOWHELPER_INSTANCE.state.resized
}

@(private)
windowhelper_update_timing_info :: proc(delta: f64, frames_offset: u64 = 1) {
    WINDOWHELPER_INSTANCE.state.delta = delta
    WINDOWHELPER_INSTANCE.state._delta_counter += delta
    WINDOWHELPER_INSTANCE.state._frame_count   += frames_offset

    WINDOWHELPER_INSTANCE.state.ms = delta

    // If a second or more has been passed...
    if WINDOWHELPER_INSTANCE.state._delta_counter > 1000.0 {
        // Update the fps and the ms.
        WINDOWHELPER_INSTANCE.state.fps = WINDOWHELPER_INSTANCE.state._frame_count

        // Reset the counters.
        WINDOWHELPER_INSTANCE.state._frame_count = 0
        WINDOWHELPER_INSTANCE.state._delta_counter = 0.0

        if WINDOW_INSTANCE.data.show_fps_in_title do windowhelper_update_title()
    }
}

@(private)
windowhelper_get_mouse_keystate_ptr :: proc(button: Glfw_Key) -> ^Key_State {
    if button not_in WINDOWHELPER_INSTANCE.input.mouse.buttons do WINDOWHELPER_INSTANCE.input.mouse.buttons[button] = {}

    return &WINDOWHELPER_INSTANCE.input.mouse.buttons[button]
}

@(private)
windowhelper_get_keyboard_keystate_ptr :: proc(key: Glfw_Key) -> ^Key_State {
    if key not_in WINDOWHELPER_INSTANCE.input.keyboard.keys do WINDOWHELPER_INSTANCE.input.keyboard.keys[key] = {}

    return &WINDOWHELPER_INSTANCE.input.keyboard.keys[key]
}

// PRIVATE - called by the window when the mouse position has been changed by
// the user.
@(private)
windowhelper_update_mouse_pos :: proc(mouse_pos: [2]f64) {
    WINDOWHELPER_INSTANCE.input.mouse.offset.x += WINDOWHELPER_INSTANCE.input.mouse.position.x - mouse_pos.x
    WINDOWHELPER_INSTANCE.input.mouse.offset.y += WINDOWHELPER_INSTANCE.input.mouse.position.y - mouse_pos.y

    WINDOWHELPER_INSTANCE.input.mouse.position.x = mouse_pos.x
    WINDOWHELPER_INSTANCE.input.mouse.position.y = mouse_pos.y

    WINDOWHELPER_INSTANCE.input.mouse.moved = true
}

// PRIVATE - called by the window when the mouse wheel has been scrolled by
// the user.
@(private)
windowhelper_update_mouse_scroll :: proc(mouse_scroll: [2]f64) {
    WINDOWHELPER_INSTANCE.input.mouse.scroll_offset.x = mouse_scroll.x
    WINDOWHELPER_INSTANCE.input.mouse.scroll_offset.y = mouse_scroll.y

    WINDOWHELPER_INSTANCE.input.mouse.scrolled = true
}

// PRIVATE - Called by the window after a frame (and its logic). Resets all the
// flags needed.
@(private)
windowhelper_post_frame_update :: proc() {
    // MACOS does not update the opengl contents of a window until it has not 
    // been moved.
    when ODIN_OS == .Darwin do if WINDOWHELPER_INSTANCE.state.resized {
        pos1 := windowhelper_get_window_pos()
        pos2 := pos1 + { 1, 1 }

        windowhelper_set_window_pos(pos2)
        windowhelper_set_window_pos(pos1)
    }

    WINDOWHELPER_INSTANCE.input.mouse.moved         = false
    WINDOWHELPER_INSTANCE.input.mouse.scrolled      = false
    WINDOWHELPER_INSTANCE.input.mouse.offset        = { 0.0, 0.0 }
    WINDOWHELPER_INSTANCE.input.mouse.scroll_offset = { 0.0, 0.0 }
    WINDOWHELPER_INSTANCE.state.resized             = false

    for _, key in &WINDOWHELPER_INSTANCE.input.mouse.buttons {
        key.just_pressed = false
        key.just_released = false
    }
    for _, key in &WINDOWHELPER_INSTANCE.input.keyboard.keys {
        key.just_pressed = false
        key.just_released = false
    }
}

@(private)
windowhelper_update_title :: proc() {
    if (WINDOW_INSTANCE.data.show_fps_in_title) {
        new_title := fmt.aprint(args = { WINDOW_INSTANCE.data.title, " (", WINDOWHELPER_INSTANCE.state.fps, " fps - ", WINDOWHELPER_INSTANCE.state.ms, " ms)" }, sep = "")
        defer delete(new_title)

        glfw.SetWindowTitle(WINDOW_INSTANCE.handle, strings.clone_to_cstring(new_title, context.temp_allocator))
    } else {
        glfw.SetWindowTitle(WINDOW_INSTANCE.handle, strings.clone_to_cstring(WINDOW_INSTANCE.data.title, context.temp_allocator))
    }
}
