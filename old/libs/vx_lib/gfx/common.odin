package vx_lib_gfx

import "core:fmt"

Gfx_Handle :: u64

Gfx_Backend_Api :: enum {
    OpenGL,
    Metal,
    None,
}
GFX_BACKEND_API: Gfx_Backend_Api = .None

INVALID_HANDLE :: 0

COMMON_MODEL_UNIFORM_LOCATION :: 0
COMMON_VIEW_UNIFORM_LOCATION :: 1
COMMON_PROJ_UNIFORM_LOCATION :: 2

SKYBOX_VIEW_UNIFORM_LOCATION :: 0
SKYBOX_PROJ_UNIFORM_LOCATION :: 1
SKYBOX_CUBEMAP_UNIFORM_LOCATION :: 2

IMMEDIATE_VIEW_UNIFORM_LOCATION :: 0
IMMEDIATE_PROJ_UNIFORM_LOCATION :: 1
IMMEDIATE_TEXTURE_UNIFORM_LOCATION :: 2

SHADER_VERTEX_MAIN_FUNCTION :: "vertex_main"
SHADER_FRAGMENT_MAIN_FUNCTION :: "fragment_main"

@(private)
get_shader_files_from_name :: proc(name: string, allocator := context.allocator) -> (res: []string) {
    context.allocator = allocator
    
    switch GFX_BACKEND_API {
        case .OpenGL: {
            res = make([]string, 2)

            res[0] = fmt.aprint(args = { name, ".glsl.vs" }, sep = "")
            res[1] = fmt.aprint(args = { name, ".glsl.fs" }, sep = "")

            return
        }
        case .Metal: {
            res = make([]string, 1)
            
            res[0] = fmt.aprint(args = { name, ".metal" }, sep = "")

            return
        }
        case .None: panic("get_shader_files_from_name called when GFX_BACKEND_API is .None")
    }

    return
}
