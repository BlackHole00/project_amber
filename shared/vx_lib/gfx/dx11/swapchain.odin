package vx_lib_gfx_dx11

import win "core:sys/windows"
import "vendor:directx/dxgi"
import "shared:vx_lib/gfx"

swapchain_get_info :: proc() -> Maybe(gfx.Swapchain_Info) {
    return CONTEXT_INSTANCE.swapchain_descriptor
}

swapchain_resize :: proc(size: [2]uint) -> bool {
    unimplemented()
}

swapchain_get_rendertarget :: proc() -> gfx.Render_Target {
    return nil
}

@(private)
swapchain_present :: proc() {
    flags: u32 = 0
    interval: u32 = 1
    if CONTEXT_INSTANCE.swapchain_descriptor.?.present_mode != .Vsync {
        flags = (u32)(dxgi.PRESENT_FLAG.ALLOW_TEARING)
        interval = 0
    }

    assert(CONTEXT_INSTANCE.swapchain->Present(interval, flags) == win.NO_ERROR)
}
