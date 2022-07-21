#include "window.h"

#include "window_context.h"
#include "window_helper.h"

namespace vx {

VX_CREATE_INSTANCE(Window, WINDOW_INSTANCE);

static bool _is_glfw_initialized = false;

static void _glfw_init() {
    if (!_is_glfw_initialized) {
        VX_ASSERT("Could not initialize glfw!", glfwInit());
        _is_glfw_initialized = true;
    }
}
static void _glfw_terminate() {
    if (_is_glfw_initialized) {
        glfwTerminate();
        _is_glfw_initialized = false;
    }
}
static void _internal_glfw_resize(GLFWwindow* window, i32 width, i32 height) {
    windowhelper_state_set_window_size(vec2_new(width, height));
}
static void _internal_glfw_mouse_pos(GLFWwindow* window, f64 pos_x, f64 pos_y) {
    _windowhelper_update_mouse_pos(vec2_new(pos_x, pos_y));
}
static void _internal_glfw_mouse_scroll(GLFWwindow* window, f64 x_offset, f64 y_offset) {
    _windowhelper_update_mouse_scroll(vec2_new(x_offset, y_offset));
}
static void _internal_glfw_mouse_button(GLFWwindow* window, i32 button, i32 action, i32 mods) {
    if (action == GLFW_PRESS) {
        KeyState* ks = _windowhelper_get_keystate((Key)(button));

        ks->just_pressed = true;
        ks->pressed = true;
    } else if (action == GLFW_RELEASE) {
        KeyState* ks = _windowhelper_get_keystate((Key)(button));

        ks->just_released = true;
        ks->pressed = false;
    }
}
static void _internal_glfw_keys(GLFWwindow* window, i32 key, i32 scancode, i32 action, i32 mods) {
    if (action == GLFW_PRESS) {
        KeyState* ks = _windowhelper_get_keystate((Key)(key));

        ks->just_pressed = true;
        ks->pressed = true;
    } else if (action == GLFW_RELEASE) {
        KeyState* ks = _windowhelper_get_keystate((Key)(key));

        ks->just_released = true;
        ks->pressed = false;
    }
}

void window_init(WindowDescriptor* descriptor) {
    VX_NULL_ASSERT(descriptor);

    _glfw_init();

    glfw_window_hint(GLFW_DECORATED,                 descriptor->decorated);
    glfw_window_hint(GLFW_RESIZABLE,                 descriptor->resizable);
    glfw_window_hint(GLFW_TRANSPARENT_FRAMEBUFFER,   descriptor->transparent_framebuffer);

    WINDOW_INSTANCE.glfw_window = glfwCreateWindow(descriptor->size.width, descriptor->size.height, descriptor->title, descriptor->fullscreen ? glfwGetPrimaryMonitor(): NULL, NULL);
    VX_ASSERT_EXIT_OP("Could not create the glfw window!", WINDOW_INSTANCE.glfw_window, _glfw_terminate());

    glfwSetWindowSizeCallback(WINDOW_INSTANCE.glfw_window,   _internal_glfw_resize);
    glfwSetCursorPosCallback(WINDOW_INSTANCE.glfw_window,    _internal_glfw_mouse_pos);
    glfwSetScrollCallback(WINDOW_INSTANCE.glfw_window,       _internal_glfw_mouse_scroll);
    glfwSetKeyCallback(WINDOW_INSTANCE.glfw_window,          _internal_glfw_keys);
    glfwSetMouseButtonCallback(WINDOW_INSTANCE.glfw_window,  _internal_glfw_mouse_button);

    if (!WINDOWCONTEXT_INSTANCE_VALID) {
        log(LogMessageLevel::WARN, "A window is being created without a context.");
    } else {
        WINDOWCONTEXT_INSTANCE.context_init_fn(WINDOW_INSTANCE.glfw_window, descriptor);
    }

    WINDOW_INSTANCE.callbacks.init   = VX_SAFE_FUNC_PTR(descriptor->init_fn);
    WINDOW_INSTANCE.callbacks.logic  = VX_SAFE_FUNC_PTR(descriptor->logic_fn);
    WINDOW_INSTANCE.callbacks.draw   = VX_SAFE_FUNC_PTR(descriptor->draw_fn);
    WINDOW_INSTANCE.callbacks.resize = VX_SAFE_FUNC_PTR(descriptor->resize_fn);
    WINDOW_INSTANCE.callbacks.close  = VX_SAFE_FUNC_PTR(descriptor->close_fn);

    WINDOW_INSTANCE.info_data.title      = descriptor->title;
    WINDOW_INSTANCE.info_data.size       = descriptor->size;
    WINDOW_INSTANCE.info_data.fullscreen = descriptor->fullscreen;
    WINDOW_INSTANCE.info_data.resizable  = descriptor->resizable;
    WINDOW_INSTANCE.info_data.decorated  = descriptor->decorated;
    WINDOW_INSTANCE.info_data.swap_interval = descriptor->swap_interval,
    WINDOW_INSTANCE.info_data.show_fps_in_title = descriptor->show_fps_in_title;
    WINDOW_INSTANCE.info_data.transparent_framebuffer = descriptor->transparent_framebuffer;

    glfwSwapInterval(descriptor->swap_interval);

    WINDOW_INSTANCE_VALID = true;

    windowhelper_init(descriptor->grab_cursor, vec2_new<f64>(descriptor->size.width / 2.0f, descriptor->size.height / 2.0f));
}

void window_run() {
    VX_ASSERT("The window instance has not been initilized yet!", WINDOW_INSTANCE_VALID);

    /*  Time counting data  initialization. */
    f64 last_time       = glfwGetTime();
    f64 current_time    = 0.0f;
    f64 delta           = 0.0f;
    f64 counter         = 0.0f;
    u64 frames          = 0;    /*  Frames per second. Used for ms. */


    /*  Call the user's init function.  */
    WINDOW_INSTANCE.callbacks.init();

    /*  Main loop   */
    while (!glfwWindowShouldClose(WINDOW_INSTANCE.glfw_window)) {
        /*  Time calculation stuff. */
        current_time = glfwGetTime();
        delta = current_time - last_time;
        last_time = current_time;
        _windowhelper_set_delta_time(delta);

        /*  Once a second update the title bar if needed.   */
        if (WINDOW_INSTANCE.info_data.show_fps_in_title) {
            counter += delta;
            frames++;
            if (counter >= 1.0f) {
                char title[256];
                snprintf(title, 255, "%s (%ld fps - %4.2lf ms)", WINDOW_INSTANCE.info_data.title, (long)frames, (double)counter / (double)frames);
                glfwSetWindowTitle(WINDOW_INSTANCE.glfw_window, title);

                frames = 0;
                counter = 0.0f;
            }
        }

        /*  Call the user's functions.  */
        WINDOW_INSTANCE.callbacks.logic();
        WINDOW_INSTANCE.callbacks.draw();

        /*  Update the window input helper. */
        _windowhelper_postlogic_update();


        glfwPollEvents();
    }

    /*  Call the user's close function and destroy the window.  */
    WINDOW_INSTANCE.callbacks.close();

    if (WINDOWCONTEXT_INSTANCE_VALID) {
        WINDOWCONTEXT_INSTANCE.context_close_fn();
    }
    if (WINDOWHELPER_INSTANCE_VALID) {
        windowhelper_free();
    }

    glfwDestroyWindow(WINDOW_INSTANCE.glfw_window);

    _glfw_terminate();

    WINDOW_INSTANCE_VALID = false;
}

};
