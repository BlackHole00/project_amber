package vx_lib_gfx_gl4

import gl "vendor:OpenGL"
import "shared:vx_lib/gfx"

swapchain_get_info :: proc() -> Maybe(gfx.Swapchain_Info) {
    return CONTEXT_INSTANCE.swapchain_descriptor
}

swapchain_resize :: proc(size: [2]uint) -> bool {
    gl.BindFramebuffer(gl.FRAMEBUFFER, 0)
    gl.Viewport(0, 0, (i32)(size.x), (i32)(size.y))

    CONTEXT_INSTANCE.swapchain_descriptor = gfx.Swapchain_Descriptor {
        present_mode = CONTEXT_INSTANCE.swapchain_descriptor.?.present_mode,
        size = size,
        format = .Unknown,
    }

    return true
}

swapchain_get_rendertarget :: proc() -> gfx.Render_Target {
    return nil
}
