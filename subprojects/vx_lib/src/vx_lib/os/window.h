#pragma once

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#include <vx_utils/utils.h>

#include "key_state.h"

typedef struct {
    char* title;
    i32 width;
    i32 height;
    bool fullscreen;
    bool decorated;
    bool transparent_framebuffer;
    bool resizable;
    bool show_fps_in_title;
    bool grab_cursor;

    u32 swap_interval;

    VX_CALLBACK(init_fn,   void, void);
    VX_CALLBACK(logic_fn,  void, f64 delta);
    VX_CALLBACK(draw_fn,   void, void);
    VX_CALLBACK(close_fn,  void, void);
    VX_CALLBACK(resize_fn, void, usize width, usize height);
} vx_WindowDescriptor;
VX_CREATE_DEFAULT(vx_WindowDescriptor,
    .title      = "Window",
    .width      = 640,
    .height     = 480,
    .fullscreen = 0,
    .resizable  = false,
    .decorated  = true,
    .grab_cursor = false,
    .swap_interval = 0,
    .transparent_framebuffer = false,
    .show_fps_in_title = true,
    .init_fn    = NULL,
    .logic_fn   = NULL,
    .draw_fn    = NULL,
    .close_fn   = NULL,
    .resize_fn  = NULL,
)

typedef struct {
    struct {
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

            vx_KeyState mouse_buttons[GLFW_MOUSE_BUTTON_LAST];
        } mouse_data;

        struct {
            vx_KeyState keys[GLFW_KEY_LAST];
        } keyboard_data;
    } input_data;

    struct {
        char* title;
        i32 width;
        i32 height;
        bool fullscreen;
        bool decorated;
        bool transparent_framebuffer;
        bool resizable;
        bool show_fps_in_title;

        u32 swap_interval;
    } info_data;

    struct {
        VX_CALLBACK(init,   void, void);
        VX_CALLBACK(logic,   void, f64 delta);
        VX_CALLBACK(draw,   void, void);
        VX_CALLBACK(close,  void, void);
        VX_CALLBACK(resize, void, usize width, usize height);
    } callbacks;

    GLFWwindow* glfw_window;
} vx_Window;
VX_DECLARE_INSTANCE(vx_Window, VX_WINDOW_INSTANCE);

void vx_window_init(vx_WindowDescriptor* descriptor);
void vx_window_run();

#define vx_glfw_window_hint(_HINT, _VALUE) glfwWindowHint((_HINT), (_VALUE));