#include "window_helper.h"

namespace vx {

VX_CREATE_INSTANCE(WindowHelper, WINDOWHELPER_INSTANCE);

void windowhelper_init(bool grabbed, f64 mouse_pos_x, f64 mouse_pos_y) {
    if (WINDOWHELPER_INSTANCE_VALID) {
        log(LogMessageLevel::WARN, "Double init of input helper.");

        return;
    }

    WINDOWHELPER_INSTANCE.input.keyboard.keys = hash_table_new_with_size<KeyState, KeyboardKey>((usize)(KeyboardKey::Count));
    hash_table_set_all_values(&WINDOWHELPER_INSTANCE.input.keyboard.keys, KeyState { 0 });

    windowhelper_input_set_mouse_grab(grabbed);
    windowhelper_input_set_mouse_pos(mouse_pos_x, mouse_pos_y);

    WINDOWHELPER_INSTANCE_VALID = true;
}

void windowhelper_free() {
    hash_table_free(&WINDOWHELPER_INSTANCE.input.keyboard.keys);
}

void windowhelper_input_set_mouse_grab(bool grabbed) {
    WINDOWHELPER_INSTANCE.input.mouse_data.grabbed = grabbed;

    glfwSetInputMode(WINDOW_INSTANCE.glfw_window, GLFW_CURSOR, grabbed ? GLFW_CURSOR_DISABLED : GLFW_CURSOR_NORMAL);
}

void windowhelper_input_set_mouse_pos(f64 pos_x, f64 pos_y, bool update_offset) {
    if (update_offset) {
        WINDOWHELPER_INSTANCE.input.mouse_data.offset.x += WINDOWHELPER_INSTANCE.input.mouse_data.position.x - pos_x;
        WINDOWHELPER_INSTANCE.input.mouse_data.offset.y += WINDOWHELPER_INSTANCE.input.mouse_data.position.y - pos_y;
    }

    WINDOWHELPER_INSTANCE.input.mouse_data.position.x = pos_x;
    WINDOWHELPER_INSTANCE.input.mouse_data.position.y = pos_y;

    glfwSetCursorPos(WINDOW_INSTANCE.glfw_window, pos_x, pos_y);
}

void _windowhelper_postlogic_update() {
    // TODO: Make iterators.
    for (usize i = 0; i < len(&WINDOWHELPER_INSTANCE.input.keyboard.keys.elements); i++) {
        if (WINDOWHELPER_INSTANCE.input.keyboard.keys.elements[i].state == HashTableBucketState::Used) {
            WINDOWHELPER_INSTANCE.input.keyboard.keys.elements[i].value.just_pressed = false;
            WINDOWHELPER_INSTANCE.input.keyboard.keys.elements[i].value.just_released = false;
        }
    }

    WINDOWHELPER_INSTANCE.input.mouse_data.offset.x = 0.0f;
    WINDOWHELPER_INSTANCE.input.mouse_data.offset.y = 0.0f;

    WINDOWHELPER_INSTANCE.input.mouse_data.moved = false;
}

void _windowhelper_update_mouse_pos(f64 pos_x, f64 pos_y) {
    WINDOWHELPER_INSTANCE.input.mouse_data.offset.x = WINDOWHELPER_INSTANCE.input.mouse_data.position.x - pos_x;
    WINDOWHELPER_INSTANCE.input.mouse_data.offset.y = WINDOWHELPER_INSTANCE.input.mouse_data.position.y - pos_y;

    WINDOWHELPER_INSTANCE.input.mouse_data.position.x = pos_x;
    WINDOWHELPER_INSTANCE.input.mouse_data.position.y = pos_y;

    if (WINDOWHELPER_INSTANCE.input.mouse_data.offset.x != 0.0f ||
        WINDOWHELPER_INSTANCE.input.mouse_data.offset.y != 0.0f
    ) {
        WINDOWHELPER_INSTANCE.input.mouse_data.moved = true;
    }
}

};