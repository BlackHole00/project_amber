#pragma once

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#include <vx_utils/utils.h>

typedef struct {
    VX_CALLBACK(void, context_init_fn, GLFWwindow*);
} vx_WindowContext;
VX_DECLARE_INSTANCE(vx_WindowContext, VX_WINDOWCONTEXT_INSTANCE);

void vx_windowcontext_init(void (*context_init_fn)(GLFWwindow*));