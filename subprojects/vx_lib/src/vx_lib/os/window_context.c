#include "window_context.h"

VX_CREATE_INSTANCE(vx_WindowContext, VX_WINDOWCONTEXT_INSTANCE);

void vx_windowcontext_init(void (*context_init_fn)(GLFWwindow*)) {
    VX_WINDOWCONTEXT_INSTANCE.context_init_fn = context_init_fn;
    VX_WINDOWCONTEXT_INSTANCE_VALID = true;
}