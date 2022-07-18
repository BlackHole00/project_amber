#pragma once

#include <bgfx/bgfx.h>
#include <vx_utils/instance.h>
#include "../window_context.h"

namespace vx {

struct BgfxCallbacks: public bgfx::CallbackI {
    void fatal(const char *_filePath, uint16_t _line, bgfx::Fatal::Enum _code, const char *_str);
    void traceVargs(const char *_filePath, uint16_t _line, const char *_format, va_list _argList);
    void profilerBegin(const char *_name, uint32_t _abgr, const char *_filePath, uint16_t _line);
    void profilerBeginLiteral(const char *_name, uint32_t _abgr, const char *_filePath, uint16_t _line);
    void profilerEnd();
    uint32_t cacheReadSize(uint64_t _id);
    bool cacheRead(uint64_t _id, void *_data, uint32_t _size);
    void cacheWrite(uint64_t _id, const void *_data, uint32_t _size);
    void screenShot(const char *_filePath, uint32_t _width, uint32_t _height, uint32_t _pitch, const void *_data, uint32_t _size, bool _yflip);
    void captureBegin(uint32_t _width, uint32_t _height, uint32_t _pitch, bgfx::TextureFormat::Enum _format, bool _yflip);
    void captureEnd();
    void captureFrame(const void *_data, uint32_t _size);
};

struct BgfxContext {
    bgfx::Init bgfx_initializer;
    BgfxCallbacks callbacks;
};
VX_DECLARE_INSTANCE(BgfxContext, BGFX_CONTEXT_INSTANCE);

void bgfxcontext_init_fn(GLFWwindow* window, WindowDescriptor* descriptor);
void bgfxcontext_close_fn();

inline void windowcontext_init_with_bgfx() {
    windowcontext_init(bgfxcontext_init_fn, bgfxcontext_close_fn);
}

};