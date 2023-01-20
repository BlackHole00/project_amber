package vx_lib_gfx_GL4

import gl "vendor:OpenGL"
import "shared:vx_lib/gfx"

Framebuffer_Impl :: struct {
    color_attachment: GL4Texture,

    // We could need the depth as texture in future, so a render_buffer is not 
    // being used.
    depth_stencil_attachment: GL4Texture,

    framebuffer_handle: u32,

    external_textures: bool,

    framebuffer_size: [2]uint,
    use_color_attachment: bool,
    use_depth_stencil_attachment: bool,
}
GL4Framebuffer :: ^Framebuffer_Impl

framebuffer_new :: proc(desc: gfx.Framebuffer_Descriptor) -> GL4Framebuffer {
    framebuffer := new(Framebuffer_Impl, CONTEXT.gl_allocator)

    gl.CreateFramebuffers(1, &framebuffer.framebuffer_handle)

    if desc.use_depth_stencil_attachment {
        framebuffer.depth_stencil_attachment = texture_new_with_size_2d(gfx.Texture_Descriptor {
            type = .Texture_2D,
            internal_texture_format = .D24S8,
            format = .D24S8,
            pixel_type = .UInt24_8,
            warp_s = .Mirrored_Repeat,
            warp_t = .Mirrored_Repeat,
            min_filter = .Linear,
            mag_filter = .Linear,
            gen_mipmaps = false,
        }, desc.framebuffer_size)
    }
    if desc.use_color_attachment {
        framebuffer.color_attachment = texture_new_with_size_2d(gfx.Texture_Descriptor {
            type = .Texture_2D,
            internal_texture_format = desc.internal_texture_format,
            format = .R8G8B8A8,
            pixel_type = .UByte,
            warp_s = desc.color_texture_warp_s,
            warp_t = desc.color_texture_warp_t,
            min_filter = desc.color_texture_min_filter,
            mag_filter = desc.color_texture_mag_filter,
            gen_mipmaps = desc.color_texture_gen_mipmaps,
        }, desc.framebuffer_size)
    }

    framebuffer.framebuffer_size = desc.framebuffer_size
    framebuffer.use_color_attachment = desc.use_color_attachment
    framebuffer.use_depth_stencil_attachment = desc.use_depth_stencil_attachment

    finalize_framebuffer(framebuffer)

    return framebuffer
}

// Initializes the framebuffer using existing textures.
framebuffer_new_from_textures :: proc(framebuffer_size: [2]uint, color_attachment: Maybe(GL4Texture), depth_attachment: Maybe(GL4Texture)) -> GL4Framebuffer {
    framebuffer := new(Framebuffer_Impl, CONTEXT.gl_allocator)

    gl.CreateFramebuffers(1, &framebuffer.framebuffer_handle)

    if color_attachment != nil do framebuffer.color_attachment = color_attachment.?
    if depth_attachment != nil do framebuffer.depth_stencil_attachment = depth_attachment.?

    framebuffer.framebuffer_size = framebuffer_size
    framebuffer.use_color_attachment = color_attachment != nil
    framebuffer.use_depth_stencil_attachment = depth_attachment != nil
    framebuffer.external_textures = true

    finalize_framebuffer(framebuffer)

    return framebuffer
}

framebuffer_free :: proc(framebuffer: GL4Framebuffer) {
    gl.DeleteFramebuffers(1, &framebuffer.framebuffer_handle)

    if !framebuffer.external_textures {
        if framebuffer.use_color_attachment do texture_free(framebuffer.color_attachment)
        if framebuffer.use_depth_stencil_attachment do texture_free(framebuffer.depth_stencil_attachment)
    }

    free(framebuffer, CONTEXT.allocator)
}

framebuffer_resize :: proc(framebuffer: GL4Framebuffer, size: [2]uint) {
    if framebuffer.use_color_attachment do texture_resize_2d(framebuffer.color_attachment, size, false)
    if framebuffer.use_depth_stencil_attachment do texture_resize_2d(framebuffer.depth_stencil_attachment, size, false)

    finalize_framebuffer(framebuffer)
}

framebuffer_get_color_texture_bindings :: proc(framebuffer: GL4Framebuffer, color_texture_uniform: string) -> gfx.Texture_Binding {
    return gfx.Texture_Binding {
        texture = (gfx.Texture)(framebuffer.color_attachment),
        uniform_name = color_texture_uniform,
    }
}

framebuffer_get_depth_stencil_texture_bindings:: proc(framebuffer: GL4Framebuffer, depth_stencil_texture_uniform: string) -> gfx.Texture_Binding {
    return gfx.Texture_Binding {
        texture = (gfx.Texture)(framebuffer.depth_stencil_attachment),
        uniform_name = depth_stencil_texture_uniform,
    }
}

framebuffer_has_color_attachment :: proc(framebuffer: GL4Framebuffer) -> bool {
    return framebuffer.use_color_attachment
}

framebuffer_has_depthstencil_attachment :: proc(framebuffer: GL4Framebuffer) -> bool {
    return framebuffer.use_depth_stencil_attachment
}

framebuffer_uses_external_textures :: proc(framebuffer: GL4Framebuffer) -> bool {
    return framebuffer.external_textures
}

/**************************************************************************************************
***************************************************************************************************
**************************************************************************************************/

@(private)
framebuffer_bind :: proc(framebuffer: GL4Framebuffer) {
    gl.BindFramebuffer(gl.FRAMEBUFFER, framebuffer.framebuffer_handle)
}

@(private)
bind_to_default_framebuffer :: proc() {
    gl.BindFramebuffer(gl.FRAMEBUFFER, 0)
}

@(private)
finalize_framebuffer :: proc(framebuffer: GL4Framebuffer) {
    if framebuffer.use_depth_stencil_attachment do gl.NamedFramebufferTexture(framebuffer.framebuffer_handle, gl.DEPTH_STENCIL_ATTACHMENT, framebuffer.depth_stencil_attachment.texture_handle, 0)
    if framebuffer.use_color_attachment do gl.NamedFramebufferTexture(framebuffer.framebuffer_handle, gl.COLOR_ATTACHMENT0, framebuffer.color_attachment.texture_handle, 0)
}

@(private)
framebuffer_bind_color_attachment_to_readbuffer :: proc(framebuffer: GL4Framebuffer) {
    framebuffer_bind(framebuffer)
    gl.ReadBuffer(gl.COLOR_ATTACHMENT0)
}
