package vx_lib_gfx_glstatemanager

import gl "vendor:OpenGL"

ClearColor :: proc(red, green, blue, alpha: f32) {
    if  red   != CONTEXT_INSTANCE.clear_color[0] ||
        green != CONTEXT_INSTANCE.clear_color[1] ||
        blue  != CONTEXT_INSTANCE.clear_color[2] ||
        alpha != CONTEXT_INSTANCE.clear_color[3]
    {
        CONTEXT_INSTANCE.clear_color = { red, green, blue, alpha }

        gl.ClearColor(
            CONTEXT_INSTANCE.clear_color[0],
            CONTEXT_INSTANCE.clear_color[1],
            CONTEXT_INSTANCE.clear_color[2],
            CONTEXT_INSTANCE.clear_color[3],
        )
    }
}

DepthMask :: proc(flag: bool) {
    if CONTEXT_INSTANCE.depth_mask != flag {
        CONTEXT_INSTANCE.depth_mask = flag
        gl.DepthMask(flag)
    }
}

Enable :: proc(cap: u32) {
    if !(cap in CONTEXT_INSTANCE.enables) { 
        map_insert(&CONTEXT_INSTANCE.enables, cap, true)
        gl.Enable(cap)

        return
    }

    if CONTEXT_INSTANCE.enables[cap] != true {
        CONTEXT_INSTANCE.enables[cap] = true
        gl.Enable(cap)
    }
}

Disable :: proc(cap: u32) {
    if !(cap in CONTEXT_INSTANCE.enables) { 
        map_insert(&CONTEXT_INSTANCE.enables, cap, false)
        gl.Disable(cap)

        return
    }

    if CONTEXT_INSTANCE.enables[cap] != false {
        CONTEXT_INSTANCE.enables[cap] = false
        gl.Disable(cap)
    }
}

FrontFace :: proc(mode: u32) {
    if mode != CONTEXT_INSTANCE.front_face {
        CONTEXT_INSTANCE.front_face = mode

        gl.FrontFace(mode)
    }
}

CullFace :: proc(mode: u32) {
    if mode != CONTEXT_INSTANCE.cull_face {
        CONTEXT_INSTANCE.cull_face = mode

        gl.CullFace(mode)
    }
}

DepthFunc :: proc(func: u32) {
    if func != CONTEXT_INSTANCE.depth_func {
        CONTEXT_INSTANCE.depth_func = func

        gl.DepthFunc(func)
    }
}

BlendFuncSeparate :: proc(sfactorRGB: u32, dfactorRGB: u32, sfactorAlpha: u32, dfactorAlpha: u32) {
    if  sfactorRGB   != CONTEXT_INSTANCE.blend_src_rgb_func     ||
        dfactorRGB   != CONTEXT_INSTANCE.blend_dst_rgb_func     ||
        sfactorAlpha != CONTEXT_INSTANCE.blend_src_alpha_func   ||
        dfactorAlpha != CONTEXT_INSTANCE.blend_dstdst_alphargb_func
    {
        CONTEXT_INSTANCE.blend_src_rgb_func = sfactorRGB
        CONTEXT_INSTANCE.blend_dst_rgb_func = dfactorRGB
        CONTEXT_INSTANCE.blend_src_alpha_func = sfactorAlpha
        CONTEXT_INSTANCE.blend_dstdst_alphargb_func = dfactorAlpha

        gl.BlendFuncSeparate(sfactorRGB, dfactorRGB, sfactorAlpha, dfactorAlpha)
    }
}

PolygonMode :: proc(face, mode: u32) {
    if !(face in CONTEXT_INSTANCE.polygon_modes) { 
        map_insert(&CONTEXT_INSTANCE.polygon_modes, face, mode)
        gl.PolygonMode(face, mode)

        return
    }

    if CONTEXT_INSTANCE.polygon_modes[face] != mode {
        CONTEXT_INSTANCE.polygon_modes[face] = mode
        gl.PolygonMode(face, mode)
    }
}

Viewport :: proc(x, y, width, height: i32) {
    if  x      != CONTEXT_INSTANCE.viewport[0] ||
        y      != CONTEXT_INSTANCE.viewport[1] ||
        width  != CONTEXT_INSTANCE.viewport[2] ||
        height != CONTEXT_INSTANCE.viewport[3]
    {
        CONTEXT_INSTANCE.viewport = { x, y, width, height }

        gl.Viewport(x, y, width, height)
    }
}

BindVertexArray :: proc(array: u32) {
    if array != CONTEXT_INSTANCE.vertex_array {
        CONTEXT_INSTANCE.vertex_array = array

        gl.BindVertexArray(array)
    }
}

UseProgram :: proc(program: u32) {
    if program != CONTEXT_INSTANCE.program {
        CONTEXT_INSTANCE.program = program

        gl.UseProgram(program)
    }
}
