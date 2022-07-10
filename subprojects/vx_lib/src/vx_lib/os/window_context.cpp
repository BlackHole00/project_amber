#include "window_context.h"

namespace vx {

VX_CREATE_INSTANCE(WindowContext, WINDOWCONTEXT_INSTANCE);

void windowcontext_init(
    VX_CALLBACK(void, context_init_fn, GLFWwindow*, WindowDescriptor*),
    VX_CALLBACK(void, context_close_fn)
) {
    WINDOWCONTEXT_INSTANCE.context_init_fn = context_init_fn;
    WINDOWCONTEXT_INSTANCE.context_close_fn = context_close_fn;
    WINDOWCONTEXT_INSTANCE_VALID = true;
}

};
