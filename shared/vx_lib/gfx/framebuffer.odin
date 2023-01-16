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

// An abstraction over an OpenGl FBO 
Framebuffer :: distinct rawptr

framebuffer_new :: proc(desc: Framebuffer_Descriptor) -> Framebuffer {
    return GFXPROCS_INSTANCE.framebuffer_new(desc)
}

// Initializes the framebuffer using existing textures.
framebuffer_new_from_textures :: proc(framebuffer_size: [2]uint, color_attachment: Maybe(Texture), depth_attachment: Maybe(Texture)) -> Framebuffer {
    return GFXPROCS_INSTANCE.framebuffer_new_from_textures(framebuffer_size, color_attachment, depth_attachment)
}

framebuffer_free :: proc(framebuffer: Framebuffer) {
    GFXPROCS_INSTANCE.framebuffer_free(framebuffer)
}

framebuffer_resize :: proc(framebuffer: Framebuffer, size: [2]uint) {
    GFXPROCS_INSTANCE.framebuffer_resize(framebuffer, size)
}

framebuffer_get_color_texture_bindings :: proc(framebuffer: Framebuffer, color_texture_uniform: string) -> Texture_Binding {
    return GFXPROCS_INSTANCE.framebuffer_get_color_texture_bindings(framebuffer, color_texture_uniform)
}

framebuffer_get_depth_stencil_texture_bindings:: proc(framebuffer: Framebuffer, depth_stencil_texture_uniform: string) -> Texture_Binding {
    return framebuffer_get_depth_stencil_texture_bindings(framebuffer, depth_stencil_texture_uniform)
}

