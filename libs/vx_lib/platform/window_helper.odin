package vx_lib_platform

import "vx_lib:core"
import "vendor:glfw"
import "core:fmt"
import "core:strings"
import "core:c"

Window_Helper_Mouse_Data :: struct {
    buttons: map[Glfw_Key]Key_State,

    moved: bool,
    offset: [2]f64,
    position: [2]f64,

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
    delta: f64,
    fps: u64,
    ms: f64,

    _frame_count: u64,
    _delta_counter: f64,
}

Window_Helper :: struct {
    input: Window_Helper_Input,
    state: Window_Helper_General_State,
}

WINDOWHELPER_INSTANCE: core.Cell(Window_Helper)

windowhelper_init :: proc() {
    core.cell_init(&WINDOWHELPER_INSTANCE)
}

windowhelper_free :: proc() {
    core.cell_free(&WINDOWHELPER_INSTANCE)
}

windowhelper_get_mouse_keystate :: proc(button: Glfw_Key) -> Key_State {
    return WINDOWHELPER_INSTANCE.input.mouse.buttons[button]
}

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

windowhelper_get_mouse_offset :: proc() -> [2]f64 {
    return WINDOWHELPER_INSTANCE.input.mouse.offset
}

windowhelper_get_scroll_offset :: proc() -> [2]f64 {
    return WINDOWHELPER_INSTANCE.input.mouse.scroll_offset
}

windowhelper_get_mousegrab :: proc() -> bool {
    return WINDOW_INSTANCE.data.grab_cursor
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

windowhelper_set_mousegrab :: proc(mousegrab: bool) {
    WINDOW_INSTANCE.data.grab_cursor = mousegrab

    glfw.SetInputMode(WINDOW_INSTANCE.handle, glfw.CURSOR, mousegrab ? glfw.CURSOR_DISABLED : glfw.CURSOR_NORMAL)
}

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

    if (WINDOW_INSTANCE.data.show_fps_in_title) {
        new_title := fmt.aprint(args = { title, " (", WINDOWHELPER_INSTANCE.state.fps, " fps - ", WINDOWHELPER_INSTANCE.state.ms, " ms)" }, sep = "")
        defer delete(new_title)

        glfw.SetWindowTitle(WINDOW_INSTANCE.handle, strings.clone_to_cstring(new_title, context.temp_allocator))
    } else {
        glfw.SetWindowTitle(WINDOW_INSTANCE.handle, strings.clone_to_cstring(title, context.temp_allocator))
    }
}

windowhelper_update_title :: proc() {
    if (WINDOW_INSTANCE.data.show_fps_in_title) {
        new_title := fmt.aprint(args = { WINDOW_INSTANCE.data.title, " (", WINDOWHELPER_INSTANCE.state.fps, " fps - ", WINDOWHELPER_INSTANCE.state.ms, " ms)" }, sep = "")
        defer delete(new_title)

        glfw.SetWindowTitle(WINDOW_INSTANCE.handle, strings.clone_to_cstring(new_title, context.temp_allocator))
    } else {
        glfw.SetWindowTitle(WINDOW_INSTANCE.handle, strings.clone_to_cstring(WINDOW_INSTANCE.data.title, context.temp_allocator))
    }
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

    glfw.SetWindowMonitor(WINDOW_INSTANCE.handle, monitor, 0, 0, (c.int)(WINDOW_INSTANCE.data.size.x), (c.int)(WINDOW_INSTANCE.data.size.y), glfw.DONT_CARE)

    if !fullscreen {
        pos := windowhelper_get_window_pos()
        windowhelper_set_window_pos({ pos.x, pos.y + 30 })
    }
}

windowhelper_set_decorated :: proc(decorated: bool) {
    WINDOW_INSTANCE.data.decorated = decorated

    glfw.SetWindowAttrib(WINDOW_INSTANCE.handle, glfw.DECORATED, (i32)(decorated))
}

windowhelper_set_show_fps_in_title :: proc(show_fps: bool) {
    WINDOW_INSTANCE.data.show_fps_in_title = show_fps
}

@(private)
windowhelper_update_timing_info :: proc(delta: f64, frames_offset: u64 = 1) {
    WINDOWHELPER_INSTANCE.state.delta = delta
    WINDOWHELPER_INSTANCE.state._delta_counter += delta
    WINDOWHELPER_INSTANCE.state._frame_count   += frames_offset

    if WINDOWHELPER_INSTANCE.state._delta_counter > 1000.0 {
        WINDOWHELPER_INSTANCE.state.fps = WINDOWHELPER_INSTANCE.state._frame_count
        WINDOWHELPER_INSTANCE.state.ms = WINDOWHELPER_INSTANCE.state._delta_counter / (f64)(WINDOWHELPER_INSTANCE.state._frame_count)

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

@(private)
windowhelper_update_mouse_pos :: proc(mouse_pos: [2]f64) {
    WINDOWHELPER_INSTANCE.input.mouse.offset.x += WINDOWHELPER_INSTANCE.input.mouse.position.x - mouse_pos.x
    WINDOWHELPER_INSTANCE.input.mouse.offset.y += WINDOWHELPER_INSTANCE.input.mouse.position.y - mouse_pos.y

    WINDOWHELPER_INSTANCE.input.mouse.position.x = mouse_pos.x
    WINDOWHELPER_INSTANCE.input.mouse.position.y = mouse_pos.y

    WINDOWHELPER_INSTANCE.input.mouse.moved = true
}

@(private)
windowhelper_update_mouse_scroll :: proc(mouse_scroll: [2]f64) {
    WINDOWHELPER_INSTANCE.input.mouse.scroll_offset.x = mouse_scroll.x
    WINDOWHELPER_INSTANCE.input.mouse.scroll_offset.y = mouse_scroll.y

    WINDOWHELPER_INSTANCE.input.mouse.scrolled = true
}

@(private)
windowhelper_post_frame_update :: proc() {
    WINDOWHELPER_INSTANCE.input.mouse.moved         = false
    WINDOWHELPER_INSTANCE.input.mouse.scrolled      = false
    WINDOWHELPER_INSTANCE.input.mouse.offset        = { 0.0, 0.0 }
    WINDOWHELPER_INSTANCE.input.mouse.scroll_offset = { 0.0, 0.0 }

    for _, key in &WINDOWHELPER_INSTANCE.input.mouse.buttons {
        key.just_pressed = false
        key.just_released = false
    }
    for _, key in &WINDOWHELPER_INSTANCE.input.keyboard.keys {
        key.just_pressed = false
        key.just_released = false
    }
}
