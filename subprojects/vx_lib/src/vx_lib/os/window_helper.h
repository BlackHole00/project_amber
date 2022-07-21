#pragma once

#include "keys.h"
#include <ctime>
#include <vx_utils/hash_table.h>
#include "window.h"

namespace vx {

struct WindowHelperMouseData {
    bool grabbed;

    bool moved;
    Vec2<f64> offset;
    Vec2<f64> position;

    bool scrolled;
    Vec2<f64> scroll_offset;
};

struct WindowHelper {
    struct {
        WindowHelperMouseData mouse_data;
        HashTable<KeyState, Key> keys;
    } input;

    f64 delta;
};

VX_DECLARE_INSTANCE(WindowHelper, WINDOWHELPER_INSTANCE);

void windowhelper_init(bool grabbed, Vec2<f64> mouse_pos);
void windowhelper_free();

inline KeyState windowhelper_input_get_keystate(Key key) {
    return *hashtable_get_or_insert(&WINDOWHELPER_INSTANCE.input.keys, key);
}
inline const WindowHelperMouseData* windowhelper_input_get_mouse_data() {
    return &WINDOWHELPER_INSTANCE.input.mouse_data;
}
inline bool windowhelper_input_is_mouse_grabbed() {
    return WINDOWHELPER_INSTANCE.input.mouse_data.grabbed;
}
inline bool windowhelper_input_is_mouse_moved() {
    return WINDOWHELPER_INSTANCE.input.mouse_data.moved;
}
inline bool windowhelper_input_is_mouse_scrolled() {
    return WINDOWHELPER_INSTANCE.input.mouse_data.scrolled;
}
inline Vec2<f64> windowhelper_input_get_mouse_pos() {
    return WINDOWHELPER_INSTANCE.input.mouse_data.position;
}
inline Vec2<f64> windowhelper_input_get_mouse_offset() {
    return WINDOWHELPER_INSTANCE.input.mouse_data.offset;
}
inline Vec2<f64> windowhelper_input_get_scroll_offset() {
    return WINDOWHELPER_INSTANCE.input.mouse_data.scroll_offset;
}

inline const char* windowhelper_state_get_title() {
    return WINDOW_INSTANCE.info_data.title;
}
inline Vec2<i32> windowhelper_state_get_window_size() {
    return WINDOW_INSTANCE.info_data.size;
}
inline bool windowhelper_state_is_fullscreen() {
    return WINDOW_INSTANCE.info_data.fullscreen;
}
inline bool windowhelper_state_is_decorated() {
    return WINDOW_INSTANCE.info_data.decorated;
}
inline bool windowhelper_state_is_resizable() {
    return WINDOW_INSTANCE.info_data.resizable;
}

inline f64 windowhelper_time() {
    return glfwGetTime();
}
inline f64 windowhelper_delta_time() {
    return WINDOWHELPER_INSTANCE.delta;
}
inline u64 windowhelper_system_time() {
    return std::time(nullptr);
}
inline void windowhelper_close_window() {
    glfwSetWindowShouldClose(WINDOW_INSTANCE.glfw_window, true);
}

void windowhelper_input_set_mouse_grab(bool grabbed);
void windowhelper_input_set_mouse_pos(Vec2<f64> pos, bool update_offset = false);

void windowhelper_state_set_title(const char* str);
void windowhelper_state_set_window_size(Vec2<i32> size, bool call_resize_callback = true);
void windowhelper_state_set_fullscreen(bool fullscreen);
inline void windowhelper_state_set_show_fps_in_title(bool show) {
    WINDOW_INSTANCE.info_data.show_fps_in_title = show;
}

void _windowhelper_postlogic_update();
void _windowhelper_update_mouse_pos(Vec2<f64> pos);
void _windowhelper_update_mouse_scroll(Vec2<f64> scroll);
inline void _windowhelper_set_delta_time(f64 delta) {
    WINDOWHELPER_INSTANCE.delta = delta;
}
inline KeyState* _windowhelper_get_keystate(Key key) {
    return hashtable_get_or_insert(&WINDOWHELPER_INSTANCE.input.keys, key);
}

};