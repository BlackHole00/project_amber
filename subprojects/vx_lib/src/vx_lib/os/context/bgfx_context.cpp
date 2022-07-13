#include "bgfx_context.h"

#ifdef VX_PLATFORM_LINUX
#   define GLFW_EXPOSE_NATIVE_X11
#   define GLFW_EXPOSE_NATIVE_WAYLAND
#elif defined(VX_PLATFORM_OSX)
#   define GLFW_EXPOSE_NATIVE_COCOA
#else
#   define GLFW_EXPOSE_NATIVE_WIN32
#endif
#include <glfw/glfw3native.h>
#include <vx_utils/panic.h>

namespace vx {

VX_CREATE_INSTANCE(BgfxContext, BGFX_CONTEXT_INSTANCE);

static void* _glfwNativeWindowHandle(GLFWwindow* _window) {
#ifdef VX_PLATFORM_LINUX
    #ifdef ENTRY_CONFIG_USE_WAYLAND
		wl_egl_window *win_impl = (wl_egl_window*)glfwGetWindowUserPointer(_window);
		if(!win_impl)
		{
			int width, height;
			glfwGetWindowSize(_window, &width, &height);
			struct wl_surface* surface = (struct wl_surface*)glfwGetWaylandWindow(_window);
			if(!surface)
				return nullptr;
			win_impl = wl_egl_window_create(surface, width, height);
			glfwSetWindowUserPointer(_window, (void*)(uintptr_t)win_impl);
		}
		return (void*)(uintptr_t)win_impl;
    #else
		return (void*)(uintptr_t)glfwGetX11Window(_window);
    #endif
#elif defined(VX_PLATFORM_OSX)
	return glfwGetCocoaWindow(_window);
#else // BX_PLATFORM_WINDOWS
	return glfwGetWin32Window(_window);
#endif
}

void bgfxcontext_init_fn(GLFWwindow* window, WindowDescriptor* descriptor) {
    BGFX_CONTEXT_INSTANCE.bgfx_initializer.debug = true;
    BGFX_CONTEXT_INSTANCE.bgfx_initializer.profile = true;
    BGFX_CONTEXT_INSTANCE.bgfx_initializer.type = bgfx::RendererType::Vulkan;

#ifdef BX_PLATFORM_LINUX
#   if ENTRY_CONFIG_USE_WAYLAND
		BGFX_CONTEXT_INSTANCE.bgfx_initializer.platformData.ndt      = glfwGetWaylandDisplay();
#   else
		BGFX_CONTEXT_INSTANCE.bgfx_initializer.platformData.ndt      = glfwGetX11Display();
#   endif
#elifdef BX_PLATFORM_OSX
	BGFX_CONTEXT_INSTANCE.bgfx_initializer.platformData.ndt      = NULL;
#else // BX_PLATFORM_WINDOWS
	BGFX_CONTEXT_INSTANCE.bgfx_initializer.platformData.ndt      = NULL;
    BGFX_CONTEXT_INSTANCE.bgfx_initializer.type = bgfx::RendererType::Direct3D12;
#endif
	BGFX_CONTEXT_INSTANCE.bgfx_initializer.platformData.nwh          = _glfwNativeWindowHandle(window);
	BGFX_CONTEXT_INSTANCE.bgfx_initializer.platformData.context      = NULL;
	BGFX_CONTEXT_INSTANCE.bgfx_initializer.platformData.backBuffer   = NULL;
	BGFX_CONTEXT_INSTANCE.bgfx_initializer.platformData.backBufferDS = NULL;

    if (!BGFX_CONTEXT_INSTANCE_VALID) {
        BGFX_CONTEXT_INSTANCE.bgfx_initializer.resolution = bgfx::Resolution();
        BGFX_CONTEXT_INSTANCE.bgfx_initializer.resolution.width = descriptor->size.width;
        BGFX_CONTEXT_INSTANCE.bgfx_initializer.resolution.height = descriptor->size.height;
        BGFX_CONTEXT_INSTANCE.bgfx_initializer.resolution.reset = BGFX_RESET_VSYNC;
    }

    BGFX_CONTEXT_INSTANCE_VALID = true;

    VX_ASSERT("Count not initialize bgfx!", bgfx::init(BGFX_CONTEXT_INSTANCE.bgfx_initializer));
}

void bgfxcontext_close_fn() {
    bgfx::shutdown();
}

};
