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

void logic(f64 delta) {
    //vx::log(vx::LogMessageLevel::INFO, "Mouse offset: %lf, %lf\n", vx::WINDOWHELPER_INSTANCE.input.mouse_data.offset_x, vx::WINDOWHELPER_INSTANCE.input.mouse_data.offset_y);

    //if (vx::windowhelper_input_get_keystate(vx::KeyboardKey::Space).just_pressed) {
    //    vx::debug_log("aaaa");
    //} else if (vx::windowhelper_input_get_keystate(vx::KeyboardKey::Space).just_released) {
    //    vx::debug_log("bbbb");
    //}
    //if (vx::windowhelper_input_get_keystate(vx::KeyboardKey::Space).pressed) {
    //    vx::debug_log("cccc");
    //}
}

void draw() {
    bgfx::setViewRect(0, 0, 0, uint16_t(640), uint16_t(480) );
    bgfx::setViewClear(0, BGFX_CLEAR_COLOR, 0);

	// This dummy draw call is here to make sure that view 0 is cleared
	// if no other draw calls are submitted to view 0.
	bgfx::touch(0);

    bgfx::frame();
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

    vx::Slice<int> slice = vx::slice_new(TEST_VEC, 10);
    vx::SliceIterator<int> iter = vx::to_iter(slice);
    vx::log(vx::LogMessageLevel::DEBUG, "%llu asdasd", iter.current_idx);
    VX_FOREACH(num, slice,
        vx::log(vx::LogMessageLevel::DEBUG, "%d asdasd", *num);
    )

    vx::Vector<int> vec = vx::vector_new<int>();
    VX_DEFER(vx::vector_free(&vec));
    vx::vector_push(&vec, 0);
    vx::vector_push(&vec, 1);
    vx::vector_push(&vec, 2);
    vx::vector_push(&vec, 3);
    vx::vector_push(&vec, 4);
    vx::vector_push(&vec, 5);
    vx::vector_push(&vec, 6);
    vx::vector_push(&vec, 7);

    VX_FOREACH(num, &vec,
        vx::log(vx::LogMessageLevel::DEBUG, "%d asdasd", *num);
    )

    vx::windowcontext_init_with_bgfx();

    vx::WindowDescriptor descriptor;
    descriptor.init_fn = am::init;
    descriptor.logic_fn = am::logic;
    descriptor.draw_fn = am::draw;
    descriptor.close_fn = am::close;

    vx::window_init(&descriptor);
    vx::window_run();

    vx::allocator_stack_get_current_allocator()->memory_report();

    return 0;
}

