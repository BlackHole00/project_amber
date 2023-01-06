package vx_lib_gfx

import gl "vendor:OpenGL"

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
Framebuffer :: struct {
    color_attachment: Texture,

    // We could need the depth as texture in future, so a render_buffer is not 
    // being used.
    depth_stencil_attachment: Texture,

    framebuffer_handle: u32,

    framebuffer_size: [2]uint,
    use_color_attachment: bool,
    use_depth_stencil_attachment: bool,
}

framebuffer_init :: proc(framebuffer: ^Framebuffer, desc: Framebuffer_Descriptor) {
    when MODERN_OPENGL do gl.CreateFramebuffers(1, &framebuffer.framebuffer_handle)
    else {
        gl.GenFramebuffers(1, &framebuffer.framebuffer_handle)
        framebuffer_bind(framebuffer^)
    }

    if desc.use_depth_stencil_attachment {
        texture_init(&framebuffer.depth_stencil_attachment, Texture_Descriptor {
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

        when MODERN_OPENGL do gl.NamedFramebufferTexture(framebuffer.framebuffer_handle, gl.DEPTH_STENCIL_ATTACHMENT, framebuffer.depth_stencil_attachment.texture_handle, 0)
        else do gl.FramebufferTexture(gl.FRAMEBUFFER, gl.DEPTH_STENCIL_ATTACHMENT, framebuffer.depth_stencil_attachment.texture_handle, 0)
    } 

    if desc.use_color_attachment {
        texture_init(&framebuffer.color_attachment, Texture_Descriptor {
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

        when MODERN_OPENGL do gl.NamedFramebufferTexture(framebuffer.framebuffer_handle, gl.COLOR_ATTACHMENT0, framebuffer.color_attachment.texture_handle, 0)
        else do gl.FramebufferTexture(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, framebuffer.color_attachment.texture_handle, 0)
    }

    framebuffer.framebuffer_size = desc.framebuffer_size
    framebuffer.use_color_attachment = desc.use_color_attachment
    framebuffer.use_depth_stencil_attachment = desc.use_depth_stencil_attachment

    when ODIN_DEBUG do bind_to_default_framebuffer()
}

// Initializes the framebuffer using existing textures.
framebuffer_init_from_textures :: proc(framebuffer: ^Framebuffer, framebuffer_size: [2]uint, color_attachment: Maybe(Texture), depth_attachment: Maybe(Texture)) {
    when MODERN_OPENGL do gl.CreateFramebuffers(1, &framebuffer.framebuffer_handle)
    else {
        gl.GenFramebuffers(1, &framebuffer.framebuffer_handle)
        framebuffer_bind(framebuffer^)
    }

    if color_attachment != nil {
        when MODERN_OPENGL do gl.NamedFramebufferTexture(framebuffer.framebuffer_handle, gl.COLOR_ATTACHMENT0, color_attachment.?.texture_handle, 0)
        else do gl.FramebufferTexture(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, color_attachment.?.texture_handle, 0)

        framebuffer.color_attachment = color_attachment.?
    }
    if depth_attachment != nil {
        when MODERN_OPENGL do gl.NamedFramebufferTexture(framebuffer.framebuffer_handle, gl.DEPTH_STENCIL_ATTACHMENT, depth_attachment.?.texture_handle, 0)
        else do gl.FramebufferTexture(gl.FRAMEBUFFER, gl.DEPTH_STENCIL_ATTACHMENT, depth_attachment.?.texture_handle, 0)

        framebuffer.depth_stencil_attachment = depth_attachment.?
    }

    framebuffer.framebuffer_size = framebuffer_size
    framebuffer.use_color_attachment = color_attachment != nil
    framebuffer.use_depth_stencil_attachment = depth_attachment != nil

    when !MODERN_OPENGL do bind_to_default_framebuffer()
}

framebuffer_free :: proc(framebuffer: ^Framebuffer) {
    gl.DeleteFramebuffers(1, &framebuffer.framebuffer_handle)

    framebuffer.framebuffer_handle = INVALID_HANDLE
}

framebuffer_get_color_texture_bindings :: proc(framebuffer: Framebuffer, color_texture_uniform: string) -> Texture_Binding {
    if !framebuffer.use_color_attachment do panic("This framebuffer do not support color_attachment")

    return Texture_Binding {
        texture = framebuffer.color_attachment,
        uniform_name = color_texture_uniform,
    }
}

framebuffer_get_depth_stencilr_texture_bindings:: proc(framebuffer: Framebuffer, depth_stencil_texture_uniform: string) -> Texture_Binding {
    if !framebuffer.use_depth_stencil_attachment do panic("This framebuffer do not support depth_stencil_attachment")

    return Texture_Binding {
        texture = framebuffer.depth_stencil_attachment,
        uniform_name = depth_stencil_texture_uniform,
    }
}

/**************************************************************************************************
***************************************************************************************************
**************************************************************************************************/

@(private)
framebuffer_bind :: proc(framebuffer: Framebuffer) {
    gl.BindFramebuffer(gl.FRAMEBUFFER, framebuffer.framebuffer_handle)
}

@(private)
bind_to_default_framebuffer :: proc() {
    gl.BindFramebuffer(gl.FRAMEBUFFER, 0)
}

@(private)
framebuffer_bind_color_attachment_to_readbuffer :: proc(framebuffer: Framebuffer) {
    framebuffer_bind(framebuffer)
    gl.ReadBuffer(gl.COLOR_ATTACHMENT0)
}
