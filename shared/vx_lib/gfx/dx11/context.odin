//+build windows
package vx_lib_gfx_dx11

import "core:runtime"
import win "core:sys/windows"
import "vendor:directx/d3d11"
import "vendor:directx/dxgi"
import core "shared:vx_core"
import "shared:vx_lib/gfx"

Map_Data :: struct {
    buffer: ^d3d11.IBuffer,
    map_mode: gfx.Buffer_Map_Mode,
}

Context :: struct {
    d3d11_context: runtime.Context,
	debug: bool,

    native_hwnd: win.HWND,

    // this array will only be valid before device_set() is called.
    adapters: Maybe([dynamic]^dxgi.IAdapter),

    adapter: ^dxgi.IAdapter,
    device: ^d3d11.IDevice,
    device_context: ^d3d11.IDeviceContext,
    swapchain: ^dxgi.ISwapChain1,
    swapchain_rendertarget: ^d3d11.IRenderTargetView,

    swapchain_descriptor: Maybe(gfx.Swapchain_Descriptor),

    map_buffer_associations: map[^d3d11.IBuffer]Map_Data,
}
CONTEXT_INSTANCE: core.Cell(Context)


@(private)
d3d11_default_context :: proc() -> runtime.Context {
    return CONTEXT_INSTANCE.d3d11_context
}