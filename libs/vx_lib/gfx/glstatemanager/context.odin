package vx_lib_gfx_glstatemanager

import core "shared:vx_core"

Context :: struct {
    // Traking the state of vertex and index buffer is non trivial, since it 
    // depens on the vao state when MODERN_OPENGL is not used and it is not 
    // necessary when MODERN_OPENGL is used (because DSA is used instead of
    // binding).

    // Helds the texture bound for each texture unit.
    textures: [16]u32,

    vertex_array: u32,
    program: u32,

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
}

deinit :: proc() {
    delete(CONTEXT_INSTANCE.enables)
    delete(CONTEXT_INSTANCE.polygon_modes)

    core.cell_free(&CONTEXT_INSTANCE)
}
