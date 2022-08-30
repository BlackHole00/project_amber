package vx_lib_gfx

Framebuffer_Descriptor :: struct {
    use_color_attachment: bool,
    use_depth_stencil_attachment: bool,

    internal_texture_format: Texture_Format,
    color_texture_warp_s: Texture_Warp,
    color_texture_warp_t: Texture_Warp,
    color_texture_min_filter: Texture_Filter,
    color_texture_mag_filter: Texture_Filter,
    color_texture_gen_mipmaps: bool,

    framebuffer_size: [2]uint,
}

Framebuffer :: struct {
    color_attachment: Texture,

    // We could need the depth as texture in future, so a render_buffer is not being used.
    depth_stencil_attachment: Texture,

    framebuffer_handle: u32,

    framebuffer_size: [2]uint,
    use_color_attachment: bool,
    use_depth_stencil_attachment: bool,
}

framebuffer_init :: proc(framebuffer: ^Framebuffer, desc: Framebuffer_Descriptor) {
    GFX_PROCS.framebuffer_init(framebuffer, desc)
}

framebuffer_free :: proc(framebuffer: ^Framebuffer) {
    GFX_PROCS.framebuffer_free(framebuffer)
}

framebuffer_get_color_texture_bindings :: proc(framebuffer: Framebuffer, color_texture_uniform: string) -> Texture_Binding {
    return GFX_PROCS.framebuffer_get_color_texture_bindings(framebuffer, color_texture_uniform)
}

framebuffer_get_depth_stencil_texture_bindings:: proc(framebuffer: Framebuffer, depth_stencil_texture_uniform: string) -> Texture_Binding {
    return GFX_PROCS.framebuffer_get_depth_stencil_texture_bindings(framebuffer, depth_stencil_texture_uniform)
}

/**************************************************************************************************
***************************************************************************************************
**************************************************************************************************/
