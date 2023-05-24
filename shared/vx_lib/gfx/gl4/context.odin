//+build windows, linux
package vx_lib_gfx_gl4

import "core:runtime"
import core "shared:vx_core"
import "shared:vx_lib/gfx"

Context :: struct {
    gl4_context: runtime.Context,
	debug: bool,

    swapchain_descriptor: Maybe(gfx.Swapchain_Descriptor),
}
CONTEXT_INSTANCE: core.Cell(Context)

@(private)
gl4_default_context :: proc() -> runtime.Context {
    return CONTEXT_INSTANCE.gl4_context
}
