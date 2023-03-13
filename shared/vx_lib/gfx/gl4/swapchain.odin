package vx_lib_gfx_gl4

import gl "vendor:OpenGL"
import "shared:vx_lib/gfx"

swapchain_get_info :: proc() -> Maybe(gfx.Swapchain_Info) {
    if CONTEXT_INSTANCE.swapchain_descriptor == nil do return nil

    return gfx.Swapchain_Info {
        present_mode = CONTEXT_INSTANCE.swapchain_descriptor.?.present_mode,
        size = CONTEXT_INSTANCE.swapchain_descriptor.?.size,
        refresh_rate = CONTEXT_INSTANCE.swapchain_descriptor.?.refresh_rate,
        format = .Unknown,
    }
}

swapchain_resize :: proc(size: [2]uint) -> bool {
    gl.BindFramebuffer(gl.FRAMEBUFFER, 0)
    gl.Viewport(0, 0, (i32)(size.x), (i32)(size.y))

    CONTEXT_INSTANCE.swapchain_descriptor = gfx.Swapchain_Descriptor {
        present_mode = CONTEXT_INSTANCE.swapchain_descriptor.?.present_mode,
        size = size,
        refresh_rate = CONTEXT_INSTANCE.swapchain_descriptor.?.refresh_rate,
        format = .Unknown,
    }

    return true
}

swapchain_get_rendertarget :: proc() -> gfx.Render_Target {
    return nil
}
