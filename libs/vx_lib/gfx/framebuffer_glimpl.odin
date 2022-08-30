package vx_lib_gfx

import gl "vendor:OpenGL"

@(private)
_glimpl_framebuffer_init :: proc(framebuffer: ^Framebuffer, desc: Framebuffer_Descriptor) {
    gl.CreateFramebuffers(1, &framebuffer.framebuffer_handle)

    if desc.use_depth_stencil_attachment {
        texture_init(&framebuffer.depth_stencil_attachment, Texture_Descriptor {
            type = .Texture_2D,
            internal_texture_format = .D24S8,
            warp_s = .Mirrored_Repeat,
            warp_t = .Mirrored_Repeat,
            min_filter = .Linear,
            mag_filter = .Linear,
            gen_mipmaps = false,
        }, desc.framebuffer_size)

        gl.NamedFramebufferTexture(framebuffer.framebuffer_handle, gl.DEPTH_STENCIL_ATTACHMENT, (u32)(framebuffer.depth_stencil_attachment.texture_handle), 0)
    } 

    if desc.use_color_attachment {
        texture_init(&framebuffer.color_attachment, Texture_Descriptor {
            type = .Texture_2D,
            internal_texture_format = desc.internal_texture_format,
            warp_s = desc.color_texture_warp_s,
            warp_t = desc.color_texture_warp_t,
            min_filter = desc.color_texture_min_filter,
            mag_filter = desc.color_texture_mag_filter,
            gen_mipmaps = desc.color_texture_gen_mipmaps,
        }, desc.framebuffer_size)

        gl.NamedFramebufferTexture(framebuffer.framebuffer_handle, gl.COLOR_ATTACHMENT0, (u32)(framebuffer.color_attachment.texture_handle), 0)
    }

    framebuffer.framebuffer_size = desc.framebuffer_size
    framebuffer.use_color_attachment = desc.use_color_attachment
    framebuffer.use_depth_stencil_attachment = desc.use_depth_stencil_attachment

    _glimpl_bind_to_default_framebuffer()
}

@(private)
_glimpl_framebuffer_free :: proc(framebuffer: ^Framebuffer) {
    gl.DeleteFramebuffers(1, &framebuffer.framebuffer_handle)

    framebuffer.framebuffer_handle = INVALID_HANDLE
}

@(private)
_glimpl_framebuffer_get_color_texture_bindings :: proc(framebuffer: Framebuffer, color_texture_location: uint) -> Texture_Binding {
    if !framebuffer.use_color_attachment do panic("This framebuffer do not support color_attachment")

    return Texture_Binding {
        texture = framebuffer.color_attachment,
        uniform_location = color_texture_location,
    }
}

@(private)
_glimpl_framebuffer_get_depth_stencil_texture_bindings:: proc(framebuffer: Framebuffer, depth_stencil_texture_location: uint) -> Texture_Binding {
    if !framebuffer.use_depth_stencil_attachment do panic("This framebuffer do not support depth_stencil_attachment")

    return Texture_Binding {
        texture = framebuffer.depth_stencil_attachment,
        uniform_location = depth_stencil_texture_location,
    }
}

@(private)
_glimpl_framebuffer_bind :: proc(framebuffer: Framebuffer) {
    gl.BindFramebuffer(gl.FRAMEBUFFER, framebuffer.framebuffer_handle)
}

@(private)
_glimpl_bind_to_default_framebuffer :: proc() {
    gl.BindFramebuffer(gl.FRAMEBUFFER, 0)
}
