package main

import "core:math"
import "vx_lib:platform"
import "vx_lib:logic"
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

input_camera_movement :: proc() {
    delta := (f32)(platform.windowhelper_get_delta_time()) * 0.005

    if platform.windowhelper_get_keyboard_keystate(glfw.KEY_LEFT_CONTROL).pressed {
        delta *= 2.5
    }

    if platform.windowhelper_get_keyboard_keystate(glfw.KEY_W).pressed {
        logic.position_move_forward(&STATE.camera.position, STATE.camera.rotation, delta)
    } else if platform.windowhelper_get_keyboard_keystate(glfw.KEY_S).pressed {
        logic.position_move_backward(&STATE.camera.position, STATE.camera.rotation, delta)
    }
    if platform.windowhelper_get_keyboard_keystate(glfw.KEY_A).pressed {
        logic.position_move_left(&STATE.camera.position, STATE.camera.rotation, delta)
    } else if platform.windowhelper_get_keyboard_keystate(glfw.KEY_D).pressed {
        logic.position_move_right(&STATE.camera.position, STATE.camera.rotation, delta)
    }
    if platform.windowhelper_get_keyboard_keystate(glfw.KEY_SPACE).pressed {
        STATE.camera.position.y += delta
    } else if platform.windowhelper_get_keyboard_keystate(glfw.KEY_LEFT_SHIFT).pressed {
        STATE.camera.position.y -= delta
    }

    if platform.windowhelper_get_mousegrab() {
        offset := platform.windowhelper_get_mouse_offset()
        logic.rotation_rotate(&STATE.camera.rotation, { (f32)(offset.x), (f32)(offset.y), 0.0 }, 0.01)
    }

    scroll := platform.windowhelper_get_scroll_offset()
    fov := logic.camera_get_fov(STATE.camera)
    fov += -(f32)(scroll.y) * 0.05
    if fov >= math.to_radians_f32(120.0)  do fov = math.to_radians_f32(120.0)
    else if fov <= math.to_radians_f32(10.0) do fov = math.to_radians_f32(10.0)

    logic.camera_set_fov(&STATE.camera, fov)
}