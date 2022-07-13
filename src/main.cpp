#include <vx_utils/utils.h>
#include <vx_utils/traits/traits.h>
#include <vx_utils/loggers/stream_logger.h>
#include <vx_lib/os/window.h>
#include <vx_lib/os/window_helper.h>
#include <vx_lib/os/keys.h>
#include <vx_lib/os/context/bgfx_context.h>
#include <bgfx/bgfx.h>

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#define GLFW_EXPOSE_NATIVE_WIN32
#define GLFW_EXPOSE_NATIVE_WGL
#include <GLFW/glfw3native.h>

namespace am {

void init() {

}

void logic() {
    if (vx::windowhelper_input_get_keystate(vx::Key::Escape).pressed) {
        vx::windowhelper_close_window();
    }
}

void draw() {
    bgfx::setViewRect(0, 0, 0, uint16_t(640), uint16_t(480) );
    bgfx::setViewClear(0, BGFX_CLEAR_COLOR, 0);

	// This dummy draw call is here to make sure that view 0 is cleared
	// if no other draw calls are submitted to view 0.
	bgfx::touch(0);

    bgfx::frame();
}

void resize() {
    var size = vx::windowhelper_state_get_window_size();
    vx::log(vx::LogMessageLevel::INFO, "Window resized to %dx%d", size.width, size.height);
}

void close() {
}

};

int TEST_VEC[] = {
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10
};

int main() {
    vx::stream_logger_init(stdout, vx::LogMessageLevel::DEBUG);
    vx::allocator_stack_init();

    VX_DEFER(vx::stream_logger_free());
    VX_DEFER(vx::allocator_stack_free());

    vx::windowcontext_init_with_bgfx();

    vx::WindowDescriptor descriptor;
    descriptor.resizable = true;
    descriptor.init_fn  = am::init;
    descriptor.logic_fn = am::logic;
    descriptor.draw_fn  = am::draw;
    descriptor.close_fn = am::close;
    descriptor.resize_fn = am::resize;

    vx::window_init(&descriptor);
    vx::window_run();

    vx::allocator_stack_get_current_allocator()->memory_report();

    return 0;
}

