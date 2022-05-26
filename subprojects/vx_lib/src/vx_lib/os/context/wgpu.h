#pragma once

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#include <vx_utils/utils.h>

typedef struct {

} vx_WgpuContext;
VX_DECLARE_INSTANCE(vx_WgpuContext, VX_WGPUCONTEXT_INSTANCE);

void vx_wgpucontext_init(GLFWwindow* window);