package vx_lib_gfx_gl4

import "core:mem"
import "core:log"
import core "shared:vx_core"
import "shared:vx_lib/gfx"

Context :: struct {
    allocator: mem.Allocator,
	logger: log.Logger,
	debug: bool,

    device_set: bool,
    swapchain_descriptor: Maybe(gfx.Swapchain_Descriptor),
}
CONTEXT_INSTANCE: core.Cell(Context)
