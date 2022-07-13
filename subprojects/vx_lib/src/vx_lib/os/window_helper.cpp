#include "window_helper.h"

namespace vx {

VX_CREATE_INSTANCE(WindowHelper, WINDOWHELPER_INSTANCE);

void windowhelper_init(bool grabbed, Vec2<f64> mouse_pos) {
    if (WINDOWHELPER_INSTANCE_VALID) {
        log(LogMessageLevel::WARN, "Double init of input helper.");

        return;
    }

    WINDOWHELPER_INSTANCE.input.keys = hashtable_new_with_size<KeyState, Key>((usize)(Key::Count));
    hashtable_set_all_values(&WINDOWHELPER_INSTANCE.input.keys, KeyState { 0 });

    windowhelper_input_set_mouse_grab(grabbed);
    windowhelper_input_set_mouse_pos(mouse_pos);

    WINDOWHELPER_INSTANCE_VALID = true;
}

void windowhelper_free() {
    hashtable_free(&WINDOWHELPER_INSTANCE.input.keys);

    WINDOWHELPER_INSTANCE_VALID = false;
}

void windowhelper_input_set_mouse_grab(bool grabbed) {
    WINDOWHELPER_INSTANCE.input.mouse_data.grabbed = grabbed;

    glfwSetInputMode(WINDOW_INSTANCE.glfw_window, GLFW_CURSOR, grabbed ? GLFW_CURSOR_DISABLED : GLFW_CURSOR_NORMAL);
}

void windowhelper_input_set_mouse_pos(Vec2<f64> pos, bool update_offset) {
    if (update_offset) {
        WINDOWHELPER_INSTANCE.input.mouse_data.offset.x += WINDOWHELPER_INSTANCE.input.mouse_data.position.x - pos.x;
        WINDOWHELPER_INSTANCE.input.mouse_data.offset.y += WINDOWHELPER_INSTANCE.input.mouse_data.position.y - pos.y;
    }

    WINDOWHELPER_INSTANCE.input.mouse_data.position.x = pos.x;
    WINDOWHELPER_INSTANCE.input.mouse_data.position.y = pos.y;

    glfwSetCursorPos(WINDOW_INSTANCE.glfw_window, pos.x, pos.y);
}

void windowhelper_state_set_title(const char* str) {
    WINDOW_INSTANCE.info_data.title = str;
    if (!WINDOW_INSTANCE.info_data.show_fps_in_title) {
        glfwSetWindowTitle(WINDOW_INSTANCE.glfw_window, str);
    }
}

void windowhelper_state_set_window_size(Vec2<i32> size, bool call_resize_callback) {
    WINDOW_INSTANCE.info_data.size = size;

    glfwSetWindowSize(WINDOW_INSTANCE.glfw_window, size.width, size.height);

    if (call_resize_callback) {
        WINDOW_INSTANCE.callbacks.resize();
    }
}

void windowhelper_state_set_fullscreen(bool fullscreen) {
    WINDOW_INSTANCE.info_data.fullscreen = fullscreen;
    GLFWmonitor *monitor = fullscreen ? glfwGetPrimaryMonitor() : nullptr;

    glfwSetWindowMonitor(WINDOW_INSTANCE.glfw_window, monitor, 0, 0, WINDOW_INSTANCE.info_data.size.width, WINDOW_INSTANCE.info_data.size.height, GLFW_DONT_CARE);
}

void _windowhelper_postlogic_update() {
    VX_FOREACH(key_state, &WINDOWHELPER_INSTANCE.input.keys, 
        key_state->just_pressed = false;
        key_state->just_released = false;
    )

    WINDOWHELPER_INSTANCE.input.mouse_data.offset.x = 0.0f;
    WINDOWHELPER_INSTANCE.input.mouse_data.offset.y = 0.0f;

    WINDOWHELPER_INSTANCE.input.mouse_data.moved = false;
    WINDOWHELPER_INSTANCE.input.mouse_data.scrolled = false;
}

void _windowhelper_update_mouse_pos(Vec2<f64> pos) {
    WINDOWHELPER_INSTANCE.input.mouse_data.offset.x = WINDOWHELPER_INSTANCE.input.mouse_data.position.x - pos.x;
    WINDOWHELPER_INSTANCE.input.mouse_data.offset.y = WINDOWHELPER_INSTANCE.input.mouse_data.position.y - pos.y;

    WINDOWHELPER_INSTANCE.input.mouse_data.position.x = pos.x;
    WINDOWHELPER_INSTANCE.input.mouse_data.position.y = pos.y;

    if (WINDOWHELPER_INSTANCE.input.mouse_data.offset.x != 0.0f ||
        WINDOWHELPER_INSTANCE.input.mouse_data.offset.y != 0.0f
    ) {
        WINDOWHELPER_INSTANCE.input.mouse_data.moved = true;
    }
}

void _windowhelper_update_mouse_scroll(Vec2<f64> scroll) {
    WINDOWHELPER_INSTANCE.input.mouse_data.scroll_offset = scroll;
    WINDOWHELPER_INSTANCE.input.mouse_data.scrolled = true;
}

};