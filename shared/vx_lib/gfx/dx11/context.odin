package vx_lib_gfx_dx11

import "core:mem"
import "core:log"
import win "core:sys/windows"
import "vendor:directx/d3d11"
import "vendor:directx/dxgi"
import core "shared:vx_core"
import "shared:vx_lib/gfx"

Context :: struct {
    allocator: mem.Allocator,
	logger: log.Logger,
	debug: bool,

    native_hwnd: win.HWND,

    device: ^d3d11.IDevice,
    device_context: ^d3d11.IDeviceContext,
    swapchain: ^dxgi.ISwapChain,
    swpachain_rendertarget: ^d3d11.IRenderTargetView,

    swapchain_descriptor: Maybe(gfx.Swapchain_Descriptor),
}
CONTEXT_INSTANCE: core.Cell(Context)
