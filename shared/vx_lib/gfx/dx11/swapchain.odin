//+build windows
package vx_lib_gfx_dx11

import win "core:sys/windows"
import "vendor:directx/dxgi"
import "vendor:directx/d3d11"
import "shared:vx_lib/gfx"

swapchain_get_info :: proc() -> gfx.Swapchain_Info {
    return CONTEXT_INSTANCE.swapchain_descriptor.?
}

swapchain_resize :: proc(size: [2]uint) -> gfx.Swapchain_Resize_Error {
    tmp_desc := CONTEXT_INSTANCE.swapchain_descriptor.?
    tmp_desc.size = size
    CONTEXT_INSTANCE.swapchain_descriptor = tmp_desc

    swapchain_release_all_buffers()

    flags: u32 = 0
    if CONTEXT_INSTANCE.swapchain_descriptor.?.present_mode != .Vsync {
        flags = (u32)(dxgi.SWAP_CHAIN_FLAG.ALLOW_TEARING)
    }

    if CONTEXT_INSTANCE.swapchain->ResizeBuffers(
        1,
        (u32)(CONTEXT_INSTANCE.swapchain_descriptor.?.size.x),
        (u32)(CONTEXT_INSTANCE.swapchain_descriptor.?.size.y),
        gfxImageFormat_to_d3d11SwapchanFormat(CONTEXT_INSTANCE.swapchain_descriptor.?.format),
        flags,
    ) != win.NO_ERROR {
        return .Backend_Set_Error
    }

    if !swapchain_generate_rendertargets() {
        return .Backend_Set_Error
    }

    // TODO: check if device_context->RSSetViewports() is necessary or the renderpass should handle it.

    return .Ok
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

@(private)
swapchain_release_all_buffers :: proc() {
    if CONTEXT_INSTANCE.swapchain_rendertarget != nil do CONTEXT_INSTANCE.swapchain_rendertarget->Release()
}

@(private)
swapchain_generate_rendertargets :: proc() -> bool {
    framebuffer_texture: ^d3d11.ITexture2D
    if CONTEXT_INSTANCE.swapchain->GetBuffer(0, d3d11.ITexture2D_UUID, auto_cast &framebuffer_texture) != win.NO_ERROR {
        return false
    }
    defer framebuffer_texture->Release()

    if CONTEXT_INSTANCE.device->CreateRenderTargetView(framebuffer_texture, nil, &CONTEXT_INSTANCE.swapchain_rendertarget) != win.NO_ERROR {
        return false
    }

    return true
}
