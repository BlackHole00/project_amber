package vx_lib_gfx

import "core:log"
import gl "vendor:OpenGL"

Framebuffer_Descriptor :: struct {
    use_color_attachment: bool,
    use_depth_stencil_attachment: bool,
    // use_stencil_attachment: bool,

    internal_texture_format: i32,
    color_texture_unit: i32,
    color_texture_warp_s: i32,
    color_texture_warp_t: i32,
    color_texture_min_filter: i32,
    color_texture_mag_filter: i32,
    color_texture_gen_mipmaps: bool,

    depth_stencil_texture_unit: i32,

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
    gl.GenFramebuffers(1, &framebuffer.framebuffer_handle)
    framebuffer_bind(framebuffer^)

    if desc.use_depth_stencil_attachment {
        texture_init(&framebuffer.depth_stencil_attachment, Texture_Descriptor {
            gl_type = gl.TEXTURE_2D,
            internal_texture_format = gl.DEPTH24_STENCIL8,
            texture_unit = desc.depth_stencil_texture_unit,
            warp_s = gl.MIRRORED_REPEAT,
            warp_t = gl.MIRRORED_REPEAT,
            min_filter = gl.LINEAR,
            mag_filter = gl.LINEAR,
            gen_mipmaps = false,
        })

        texture_set_size_2d(framebuffer.depth_stencil_attachment, desc.framebuffer_size, gl.DEPTH_STENCIL, gl.UNSIGNED_INT_24_8)

        gl.FramebufferTexture2D(gl.FRAMEBUFFER, gl.DEPTH_STENCIL_ATTACHMENT, gl.TEXTURE_2D, framebuffer.depth_stencil_attachment.texture_handle, 0)
    } 

    if desc.use_color_attachment {
        texture_init(&framebuffer.color_attachment, Texture_Descriptor {
            gl_type = gl.TEXTURE_2D,
            internal_texture_format = desc.internal_texture_format,
            texture_unit = desc.color_texture_unit,
            warp_s = desc.color_texture_warp_s,
            warp_t = desc.color_texture_warp_t,
            min_filter = desc.color_texture_min_filter,
            mag_filter = desc.color_texture_mag_filter,
            gen_mipmaps = desc.color_texture_gen_mipmaps,
        })

        texture_set_size_2d(framebuffer.color_attachment, desc.framebuffer_size, (u32)(desc.internal_texture_format))

        gl.FramebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, framebuffer.color_attachment.texture_handle, 0)
    }

    framebuffer.framebuffer_size = desc.framebuffer_size
    framebuffer.use_color_attachment = desc.use_color_attachment
    framebuffer.use_depth_stencil_attachment = desc.use_depth_stencil_attachment

    bind_to_default_framebuffer()
}

framebuffer_bind :: proc(framebuffer: Framebuffer) {
    gl.BindFramebuffer(gl.FRAMEBUFFER, framebuffer.framebuffer_handle)
}

framebuffer_free :: proc(framebuffer: ^Framebuffer) {
    gl.DeleteFramebuffers(1, &framebuffer.framebuffer_handle)

    framebuffer.framebuffer_handle = INVALID_HANDLE
}

bind_to_default_framebuffer :: proc() {
    gl.BindFramebuffer(gl.FRAMEBUFFER, 0)
}

framebuffer_apply_color_attachment :: proc(framebuffer: Framebuffer, shader: ^Shader, color_texture_uniform: string) {
    if !framebuffer.use_color_attachment {
        log.warn("This framebuffer do not support color_attachment")
        return
    }

    texture_apply(framebuffer.color_attachment, shader, color_texture_uniform)
}

framebuffer_apply_depth_stencil_attachment :: proc(framebuffer: Framebuffer, shader: ^Shader, depth_stencil_texture_uniform: string) {
    if !framebuffer.use_depth_stencil_attachment {
        log.warn("This framebuffer do not support depth_stencil_attachment")
        return
    }
    
    texture_apply(framebuffer.depth_stencil_attachment, shader, depth_stencil_texture_uniform)
}

framebuffer_bind_color_attachment :: proc(framebuffer: Framebuffer) {
    if !framebuffer.use_color_attachment {
        log.warn("This framebuffer do not support color_attachment")
        return
    }

    texture_bind(framebuffer.color_attachment)
}

framebuffer_bind_color_depth_stencil_attachment :: proc(framebuffer: Framebuffer) {
    if !framebuffer.use_depth_stencil_attachment {
        log.warn("This framebuffer do not support depth_stencil_attachment")
        return
    }

    texture_bind(framebuffer.depth_stencil_attachment)
}
