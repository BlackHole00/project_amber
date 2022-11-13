package vx_lib_gfx

import "shared:vx_lib/core"
import "shared:wgpu"

Wgpu_Context :: struct {
    surface: wgpu.Surface,
    adapter: wgpu.Adapter,
    device: wgpu.Device,
}

WGPUCONTEXT_INSTANCE: core.Cell(Wgpu_Context)