#pragma once

#include <bgfx/bgfx.h>
#include <vx_utils/utils.h>

namespace vx {

vx::Option<bgfx::ShaderHandle> load_bgfx_shader(const char* shader_folder, const char* file_name, const char* resource_root = "res/shaders/", Allocator* allocator = nullptr);

};