#include "shader_utils.h"

#include <cstdio>

namespace vx {

vx::Option<bgfx::ShaderHandle> load_bgfx_shader(const char* shader_folder, const char* file_name, const char* resource_root, Allocator* allocator) {
    VX_VALIDATE_ALLOCATOR(allocator);

    const char* renderer_folder = "/shaders/spirv/";

    switch(bgfx::getRendererType()) {
        case bgfx::RendererType::Noop:
	    case bgfx::RendererType::Direct3D9:  renderer_folder = "/shaders/dx9/"  ; break;
	    case bgfx::RendererType::Direct3D11:
	    case bgfx::RendererType::Direct3D12: renderer_folder = "/shaders/dx11/" ; break;
	    case bgfx::RendererType::Agc:
	    case bgfx::RendererType::Gnm:        renderer_folder = "/shaders/pssl/" ; break;
	    case bgfx::RendererType::Metal:      renderer_folder = "/shaders/metal/"; break;
	    case bgfx::RendererType::Nvn:        renderer_folder = "/shaders/nvn/"  ; break;
	    case bgfx::RendererType::OpenGL:     renderer_folder = "/shaders/glsl/" ; break;
	    case bgfx::RendererType::OpenGLES:   renderer_folder = "/shaders/essl/" ;  break;
	    case bgfx::RendererType::Vulkan:
	    case bgfx::RendererType::WebGPU:     renderer_folder = "/shaders/spirv/" ; break;
        default: {
            VX_PANIC("Unknown renderer?");
        };
    }

    int required_chars = std::snprintf(NULL, 0, "%s%s%s%s.bin", resource_root, shader_folder, renderer_folder, file_name);

    char* path = vx::alloc<char>(required_chars + 1);
    VX_DEFER(vx::free(path));

    std::snprintf(path, required_chars + 1, "%s%s%s%s.bin", resource_root, shader_folder, renderer_folder, file_name);

    usize file_len;
    char* content = filepath_get_content(path, &file_len, "rb");
    log(vx::LogMessageLevel::DEBUG, "Size: %u", file_len);
    if (content == nullptr) {
        return option_none<bgfx::ShaderHandle>();
    }

    bgfx::ShaderHandle handle = bgfx::createShader(bgfx::makeRef(content, file_len, [](void* ptr, void* user_data) {
        Allocator* alloc = (Allocator*)(user_data);
        ::vx::free(ptr, alloc);
    }, allocator));

    return option_some<bgfx::ShaderHandle>(handle);
}

};
