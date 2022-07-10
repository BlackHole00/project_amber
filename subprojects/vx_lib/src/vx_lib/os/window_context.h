#pragma once

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#include <vx_utils/utils.h>
#include "window.h"

namespace vx {

struct WindowContext {
    VX_CALLBACK(void, context_init_fn, GLFWwindow*, WindowDescriptor*);
    VX_CALLBACK(void, context_close_fn);
};
VX_DECLARE_INSTANCE(WindowContext, WINDOWCONTEXT_INSTANCE);

void windowcontext_init(
    VX_CALLBACK(void, context_init_fn, GLFWwindow*, WindowDescriptor*),
    VX_CALLBACK(void, context_close_fn)
);

};
