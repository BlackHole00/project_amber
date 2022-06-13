#include <vx_utils/utils.h>
#include <vx_utils/traits/traits.h>
#include <vx_utils/loggers/stream_logger.h>
#include <vx_lib/os/window.h>

int main() {
    vx::stream_logger_init(stdout, vx::LogMessageLevel::DEBUG);
    vx::allocator_stack_init();

    VX_DEFER(vx::stream_logger_free());
    VX_DEFER(vx::allocator_stack_free());

    vx::WindowDescriptor descriptor;

    vx::window_init(&descriptor);
    vx::window_run();

    return 0;
}

