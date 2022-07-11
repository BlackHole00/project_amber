#pragma once

#include "keys.h"
#include <vx_utils/hash_table.h>
#include "window.h"

namespace vx {

struct InputHelper {
    struct {
        bool grabbed;

        bool moved;
        f64 offset_x;
        f64 offset_y;
        f64 pos_x;
        f64 pos_y;

        bool scrolled;
        f64 scroll_offset_x;
        f64 scroll_offset_y;

        KeyState mouse_buttons[GLFW_MOUSE_BUTTON_LAST];
    } mouse_data;

    struct {
        HashTable<KeyState, KeyboardKey> keys;
    } keyboard;
};

VX_DECLARE_INSTANCE(InputHelper, INPUT_HELPER_INSTANCE);

void input_helper_init();
void input_helper_free();

};