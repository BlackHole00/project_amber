package main

import "vx_lib:platform"
import "vendor:glfw"

input_common :: proc() {
    if platform.windowhelper_get_keyboard_keystate(glfw.KEY_TAB).just_pressed {
        platform.windowhelper_set_mousegrab(!platform.windowhelper_get_mousegrab())
    }
    if platform.windowhelper_get_keyboard_keystate(glfw.KEY_ESCAPE).just_pressed {
        platform.windowhelper_close_window()
    }

    if platform.windowhelper_get_keyboard_keystate(glfw.KEY_ENTER).just_pressed && platform.windowhelper_get_keyboard_keystate(glfw.KEY_LEFT_ALT).pressed {
        platform.windowhelper_set_window_size(platform.windowhelper_get_screen_size())
        platform.windowhelper_set_fullscreen(!platform.windowhelper_is_fullscreen())
    }
}
