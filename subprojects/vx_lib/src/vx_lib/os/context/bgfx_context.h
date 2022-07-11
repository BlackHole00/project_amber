#pragma once

#include <bgfx/bgfx.h>
#include <vx_utils/instance.h>
#include "../window_context.h"

namespace vx {

struct BgfxContext {
    bgfx::Init bgfx_initializer;
};
VX_DECLARE_INSTANCE(BgfxContext, BGFX_CONTEXT_INSTANCE);

void bgfxcontext_init_fn(GLFWwindow* window, WindowDescriptor* descriptor);
void bgfxcontext_close_fn();

inline void windowcontext_init_with_bgfx() {
    windowcontext_init(bgfxcontext_init_fn, bgfxcontext_close_fn);
}

};