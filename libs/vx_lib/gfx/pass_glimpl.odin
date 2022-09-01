package vx_lib_gfx

import glsm "../gfx/glstatemanager"
import gl "vendor:OpenGL"

@(private)
_glimpl_pass_init :: proc(pass: ^Pass, desc: Pass_Descriptor, target: Maybe(Framebuffer) = nil) {
    pass.desc = desc
    pass.render_target = target
}

@(private)
_glimpl_pass_begin :: proc(pass: ^Pass) {
    _glimpl_pass_bind_rendertarget(pass^)

    // VERY IMPORTANT NOTE: If DepthMask is set to false when clearing a screen, the depth buffer will not be properly cleared, causing a black screen.
    // Leave the depth mask to true!
    glsm.DepthMask(true)

    clear_bits: u32 = 0

    if pass.clear_depth && pass.clear_depth do clear_bits |= gl.DEPTH_BUFFER_BIT
    if pass.clear_color {
        clear_bits |= gl.COLOR_BUFFER_BIT

        // We could use glClearNamedFramebufferfv but I don't care about dsa in this case.
        glsm.ClearColor((f32)(pass.clearing_color[0]),
            (f32)(pass.clearing_color[1]),
            (f32)(pass.clearing_color[2]),
            (f32)(pass.clearing_color[3]),
        )
    }

    gl.Clear(clear_bits)
}

@(private)
_glimpl_pass_end :: proc(pass: ^Pass) {}

@(private)
_glimpl_pass_resize :: proc(pass: ^Pass, size: [2]uint) {
    pass.viewport_size = size
}

@(private)
_glimpl_pass_bind_rendertarget :: proc(pass: Pass) {
    if pass.render_target != nil do _glimpl_framebuffer_bind(pass.render_target.(Framebuffer))
    else do _glimpl_bind_to_default_framebuffer()

    glsm.Viewport(0, 0, (i32)(pass.viewport_size.x), (i32)(pass.viewport_size.y))
}