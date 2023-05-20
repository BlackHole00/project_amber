package vx_lib_gfx

import rnt "core:runtime"
import core "shared:vx_core"

@(private="package")
Context :: struct {
    using descriptor: Gfx_Descriptor,

    using procs: struct {
        backend_get_info: proc() -> Backend_Info,
        backendinfo_free: proc(info: Backend_Info),

        get_device_count: proc() -> uint,
        get_deviceinfo_of_idx: proc(index: uint) -> Device_Info,
        deviceinfo_free: proc(info: Device_Info),

        device_get_info: proc() -> Device_Info,
        device_set: proc(index: uint) -> bool,
        device_check_swapchain_descriptor: proc(descriptor: Swapchain_Descriptor) -> Swapchain_Set_Error,
        device_set_swapchain: proc(descriptor: Swapchain_Descriptor),

        swapchain_get_info: proc() -> Maybe(Swapchain_Info),
        swapchain_resize: proc(size: [2]uint) -> bool,
        swapchain_get_rendertarget: proc() -> Render_Target,
    },

    selected_device_index: Maybe(uint),
}

CONTEXT_INSTANCE: core.Cell(Context)

@(private)
gfx_default_context :: proc() -> (ctx: rnt.Context) {
    assert(core.cell_is_valid(CONTEXT_INSTANCE), "The CONTEXT_INSTANCE is not valid. Exiting.")

    ctx = core.default_context()
    ctx.allocator = CONTEXT_INSTANCE.frontend_user_descriptor.allocator
    ctx.logger = CONTEXT_INSTANCE.frontend_user_descriptor.logger

    return
}

gfx_is_debug :: proc() -> bool {
    assert(core.cell_is_valid(CONTEXT_INSTANCE), "The CONTEXT_INSTANCE is not valid. Exiting.")

    return CONTEXT_INSTANCE.frontend_user_descriptor.debug
}
