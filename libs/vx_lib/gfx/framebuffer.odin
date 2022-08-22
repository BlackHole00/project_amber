package vx_lib_gfx

import glsm "glstatemanager"
import gl "vendor:OpenGL"

Framebuffer_Descriptor :: struct {
    use_color_attachment: bool,
    use_depth_stencil_attachment: bool,

    internal_texture_format: i32,
    color_texture_warp_s: i32,
    color_texture_warp_t: i32,
    color_texture_min_filter: i32,
    color_texture_mag_filter: i32,
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
    gl.CreateFramebuffers(1, &framebuffer.framebuffer_handle)

    if desc.use_depth_stencil_attachment {
        texture_init(&framebuffer.depth_stencil_attachment, Texture_Descriptor {
            gl_type = gl.TEXTURE_2D,
            internal_texture_format = gl.DEPTH24_STENCIL8,
            warp_s = gl.MIRRORED_REPEAT,
            warp_t = gl.MIRRORED_REPEAT,
            min_filter = gl.LINEAR,
            mag_filter = gl.LINEAR,
            gen_mipmaps = false,
        }, desc.framebuffer_size)

        gl.NamedFramebufferTexture(framebuffer.framebuffer_handle, gl.DEPTH_STENCIL_ATTACHMENT, framebuffer.depth_stencil_attachment.texture_handle, 0)
    } 

    if desc.use_color_attachment {
        texture_init(&framebuffer.color_attachment, Texture_Descriptor {
            gl_type = gl.TEXTURE_2D,
            internal_texture_format = desc.internal_texture_format,
            warp_s = desc.color_texture_warp_s,
            warp_t = desc.color_texture_warp_t,
            min_filter = desc.color_texture_min_filter,
            mag_filter = desc.color_texture_mag_filter,
            gen_mipmaps = desc.color_texture_gen_mipmaps,
        }, desc.framebuffer_size)

        gl.NamedFramebufferTexture(framebuffer.framebuffer_handle, gl.COLOR_ATTACHMENT0, framebuffer.color_attachment.texture_handle, 0)
    }

    framebuffer.framebuffer_size = desc.framebuffer_size
    framebuffer.use_color_attachment = desc.use_color_attachment
    framebuffer.use_depth_stencil_attachment = desc.use_depth_stencil_attachment

    bind_to_default_framebuffer()
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
    glsm.BindFramebuffer(gl.FRAMEBUFFER, framebuffer.framebuffer_handle)
}

@(private)
bind_to_default_framebuffer :: proc() {
    glsm.BindFramebuffer(gl.FRAMEBUFFER, 0)
}
