package vx_lib_gfx_glstatemanager

import "../../core"
import gl "vendor:OpenGL"

Context :: struct {
    // We are primarly using DSA, so it is not needed to track the state of
    // buffers and other things like that.

    // Helds the texture bound for each texture unit.
    textures: [16]u32,

    vertex_array: u32,
    program: u32,
    framebuffers: map[u32]u32,

    // We do not use the depth mask, instead we use a pipeline with depth
    // disabled, but whatever.
    depth_mask: bool,

    clear_color: [4]f32,

    enables: map[u32]bool,

    front_face: u32,
    cull_face: u32,
    depth_func: u32,

    blend_src_rgb_func: u32,
    blend_dst_rgb_func: u32,
    blend_src_alpha_func: u32,
    blend_dstdst_alphargb_func: u32,

    polygon_modes: map[u32]u32,

    viewport: [4]i32,
}
CONTEXT_INSTANCE: core.Cell(Context)

init :: proc() {
    core.cell_init(&CONTEXT_INSTANCE)

    CONTEXT_INSTANCE.enables = make(map[u32]bool)
    CONTEXT_INSTANCE.polygon_modes = make(map[u32]u32)
    CONTEXT_INSTANCE.framebuffers = make(map[u32]u32)
}

free :: proc() {
    delete(CONTEXT_INSTANCE.enables)
    delete(CONTEXT_INSTANCE.polygon_modes)
    delete(CONTEXT_INSTANCE.framebuffers)

    core.cell_free(&CONTEXT_INSTANCE)
}

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

BindFramebuffer :: proc(target: u32, framebuffer: u32) {
    if !(target in CONTEXT_INSTANCE.framebuffers) { 
        map_insert(&CONTEXT_INSTANCE.framebuffers, target, framebuffer)
        gl.BindFramebuffer(target, framebuffer)

        return
    }

    if CONTEXT_INSTANCE.framebuffers[target] != framebuffer {
        CONTEXT_INSTANCE.framebuffers[target] = framebuffer
        gl.BindFramebuffer(target, framebuffer)
    }
}
