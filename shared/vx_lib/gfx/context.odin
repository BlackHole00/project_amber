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
        device_set: proc(index: uint) -> Device_Set_Error,
        device_check_swapchain_descriptor: proc(descriptor: Swapchain_Descriptor) -> Swapchain_Set_Error,
        device_set_swapchain: proc(descriptor: Swapchain_Descriptor) -> Swapchain_Set_Error,

        swapchain_get_info: proc() -> Swapchain_Info,
        swapchain_resize: proc(size: [2]uint) -> Swapchain_Resize_Error,
        swapchain_get_rendertarget: proc() -> Render_Target,

        buffer_new_empty: proc(descriptor: Buffer_Descriptor) -> (Buffer, Buffer_Creation_Error),
        buffer_new_with_data: proc(descriptor: Buffer_Descriptor, data: []byte) -> (Buffer, Buffer_Creation_Error),
        buffer_free: proc(buffer: Buffer),
        buffer_set_data: proc(buffer: Buffer, data: []byte) -> Buffer_Set_Data_Error,
        buffer_map: proc(buffer: Buffer, mode: Buffer_Map_Mode) -> ([]byte, Buffer_Map_Error),
        buffer_unmap: proc(buffer: Buffer) -> Buffer_Unmap_Error,
        buffer_resize: proc(buffer: Buffer, size: uint) -> Buffer_Resize_Error,
        buffer_get_type: proc(buffer: Buffer) -> Buffer_Type,
        buffer_get_usage: proc(buffer: Buffer) -> Buffer_Usage,
        buffer_get_allocation_mode: proc(buffer: Buffer) -> Buffer_Allocation_Mode,
        buffer_get_size: proc(buffer: Buffer) -> uint,
        buffer_is_compute: proc(buffer: Buffer) -> bool,
    },

    selected_device_index: Maybe(uint),
    swapchain_set: bool,
}

CONTEXT_INSTANCE: core.Cell(Context)

@(private)
gfx_default_context :: proc() -> (ctx: rnt.Context) {
    assert(core.cell_is_valid(CONTEXT_INSTANCE), "The CONTEXT_INSTANCE is not valid. Exiting.")

    return CONTEXT_INSTANCE.frontend_user_descriptor.frontend_context
}

gfx_is_debug :: proc() -> bool {
    assert(core.cell_is_valid(CONTEXT_INSTANCE), "The CONTEXT_INSTANCE is not valid. Exiting.")

    return CONTEXT_INSTANCE.frontend_user_descriptor.debug
}
