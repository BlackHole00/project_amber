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
#include <vx_utils/file.h>
#include <vx_utils/slice.h>
#include <vx_utils/panic.h>
#include <cstdio>

namespace vx {

VX_CREATE_INSTANCE(BgfxContext, BGFX_CONTEXT_INSTANCE);

void BgfxCallbacks::fatal(const char *_filePath, uint16_t _line, bgfx::Fatal::Enum _code, const char *_str) {
    log(LogMessageLevel::FATAL, "BGFX Panic from %s::%u : [%d] %s", _filePath, _line, _code, _str);

    halt();
}

void BgfxCallbacks::traceVargs(const char *_filePath, uint16_t _line, const char *_format, va_list _argList) {
    usize len = std::vsnprintf(nullptr, 0, _format, _argList);

    char* ptr = alloc<char>(len + 1);
    VX_DEFER(::vx::free(ptr));

    std::vsnprintf(ptr, len + 1, _format, _argList);

    log(LogMessageLevel::INFO, "BGFX Info from %s::%u : %s", _filePath, _line, ptr);
}

void BgfxCallbacks::profilerBegin(const char *_name, uint32_t _abgr, const char *_filePath, uint16_t _line) {}
void BgfxCallbacks::profilerBeginLiteral(const char *_name, uint32_t _abgr, const char *_filePath, uint16_t _line) {}
void BgfxCallbacks::profilerEnd() {}
uint32_t BgfxCallbacks::cacheReadSize(uint64_t _id) {
    char file_path[256];
	std::snprintf(file_path, sizeof(file_path), "temp/%016llx", _id);

    return filepath_get_len(file_path, "rb");
}
bool BgfxCallbacks::cacheRead(uint64_t _id, void *_data, uint32_t _size) {
    char file_path[256];
	std::snprintf(file_path, sizeof(file_path), "temp/%016llx", _id);

    Slice<char> buffer = slice_new<char>((char*)_data, _size);
    filepath_get_content_to_slice(file_path, buffer, "rb");

    return true;
}
void BgfxCallbacks::cacheWrite(uint64_t _id, const void *_data, uint32_t _size) {
    char file_path[256];
	std::snprintf(file_path, sizeof(file_path), "temp/%016llx", _id);

    std::FILE* file = std::fopen(file_path, "wb");
    if (!file) {
        return;
    }

    const char* data = (const char*)(_data);
    for (usize i = 0; i < _size; i++) {
        std::fputc(data[i], file);
    }

    std::fclose(file);
}
void BgfxCallbacks::screenShot(const char *_filePath, uint32_t _width, uint32_t _height, uint32_t _pitch, const void *_data, uint32_t _size, bool _yflip) {}
void BgfxCallbacks::captureBegin(uint32_t _width, uint32_t _height, uint32_t _pitch, bgfx::TextureFormat::Enum _format, bool _yflip) {}
void BgfxCallbacks::captureEnd() {}
void BgfxCallbacks::captureFrame(const void *_data, uint32_t _size) {}

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
    BGFX_CONTEXT_INSTANCE.bgfx_initializer.type = bgfx::RendererType::Direct3D11;
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

    if (BGFX_CONTEXT_INSTANCE.bgfx_initializer.callback == nullptr) {
	    BGFX_CONTEXT_INSTANCE.bgfx_initializer.callback = &BGFX_CONTEXT_INSTANCE.callbacks;
    }

    BGFX_CONTEXT_INSTANCE_VALID = true;

    VX_ASSERT("Count not initialize bgfx!", bgfx::init(BGFX_CONTEXT_INSTANCE.bgfx_initializer));
}

void bgfxcontext_close_fn() {
    bgfx::shutdown();
}

};
