//+build windows
package vx_lib_gfx_dx11

import win "core:sys/windows"
import "vendor:directx/dxgi"
import "shared:vx_lib/gfx"

swapchain_get_info :: proc() -> gfx.Swapchain_Info {
    return CONTEXT_INSTANCE.swapchain_descriptor.?
}

swapchain_resize :: proc(size: [2]uint) -> gfx.Swapchain_Resize_Error {
    tmp_desc := CONTEXT_INSTANCE.swapchain_descriptor.?
    tmp_desc.size = size
    CONTEXT_INSTANCE.swapchain_descriptor = tmp_desc

    // TODO: check if device_context->RSSetViewports() is necessary or the renderpass should handle it.

    #partial switch device_set_swapchain(CONTEXT_INSTANCE.swapchain_descriptor.?) {
        case .Ok: return .Ok
        case .Unavaliable_Functionality: return .Ok
        case: return .Backend_Set_Error
    }
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

    err := CONTEXT_INSTANCE.swapchain->Present(interval, flags)
    assert(err == win.NO_ERROR || err == dxgi.STATUS_OCCLUDED)
}
