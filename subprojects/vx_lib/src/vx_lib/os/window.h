#pragma once

#include <GLFW/glfw3.h>
#include <vx_utils/utils.h>

namespace vx {

struct WindowDescriptor {
    const char* title = "Window";
    Vec2<i32> size = { 640, 480 };
    bool fullscreen = false;
    bool decorated = true;
    bool transparent_framebuffer = false;
    bool resizable = false;
    bool show_fps_in_title = true;
    bool grab_cursor = false;

    u32 swap_interval = 0;

    VX_CALLBACK(void, init_fn,      void)       = nullptr;
    VX_CALLBACK(void, logic_fn,     void)       = nullptr;
    VX_CALLBACK(void, draw_fn,      void)       = nullptr;
    VX_CALLBACK(void, close_fn,     void)       = nullptr;
    VX_CALLBACK(void, resize_fn,    void)       = nullptr;
};

struct Window {
    struct {
        const char* title;
        Vec2<i32> size;
        bool fullscreen;
        bool decorated;
        bool transparent_framebuffer;
        bool resizable;
        bool show_fps_in_title;

        u32 swap_interval;
    } info_data;

    struct {
        VX_CALLBACK(void, init,     void);
        VX_CALLBACK(void, logic,    void);
        VX_CALLBACK(void, draw,     void);
        VX_CALLBACK(void, close,    void);
        VX_CALLBACK(void, resize,   void);
    } callbacks;

    GLFWwindow* glfw_window;
};
VX_DECLARE_INSTANCE(Window, WINDOW_INSTANCE);

void window_init(WindowDescriptor* descriptor);
void window_run();

inline void glfw_window_hint(int hint, int value) {
    glfwWindowHint(hint, value);
}

};