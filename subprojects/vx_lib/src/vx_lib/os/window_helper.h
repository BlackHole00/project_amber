#pragma once

#include "keys.h"
#include <vx_utils/hash_table.h>
#include "window.h"

namespace vx {

struct WindowHelper {
    struct {
        struct {
            bool grabbed;

            bool moved;
            Vec2<f64> offset;
            Vec2<f64> position;

            bool scrolled;
            Vec2<f64> scroll_offset;

            KeyState mouse_buttons[GLFW_MOUSE_BUTTON_LAST];
        } mouse_data;

        struct {
            HashTable<KeyState, KeyboardKey> keys;
        } keyboard;

    } input;
};

VX_DECLARE_INSTANCE(WindowHelper, WINDOWHELPER_INSTANCE);

void windowhelper_init(bool grabbed, f64 mouse_pos_x, f64 mouse_pos_y);
void windowhelper_free();

inline KeyState windowhelper_input_get_keystate(KeyboardKey key) {
    return *hash_table_get_or_insert(&WINDOWHELPER_INSTANCE.input.keyboard.keys, key);
}

void windowhelper_input_set_mouse_grab(bool grabbed);
void windowhelper_input_set_mouse_pos(f64 pos_x, f64 pos_y, bool update_offset = false);

void _windowhelper_postlogic_update();
void _windowhelper_update_mouse_pos(f64 pos_x, f64 pos_y);
inline KeyState* _windowhelper_get_keystate(KeyboardKey key) {
    return hash_table_get_or_insert(&WINDOWHELPER_INSTANCE.input.keyboard.keys, key);
}

};