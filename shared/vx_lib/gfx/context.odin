package vx_lib_gfx

import "core:mem"
import "core:log"
import core "shared:vx_core"

@(private="package")
Context :: struct {
	backend_deinit_proc: proc(),

    allocator: mem.Allocator,
	logger: log.Logger,
	debug: bool,

    using procs: struct {
        backend_get_info: proc() -> Backend_Info,
        backendinfo_free: proc(info: Backend_Info),

        device_check_requirements: proc(requirements: Device_Requirements) -> Device_Set_Error,
        device_set: proc(requirements: Device_Requirements),

        device_check_swapchain_descriptor: proc(descriptor: Swapchain_Descriptor) -> Swapchain_Set_Error,
        device_set_swapchain: proc(descriptor: Swapchain_Descriptor),

        device_get_info: proc() -> Maybe(Device_Info),
        deviceinfo_free: proc(info: Device_Info),

        swapchain_get_info: proc() -> Maybe(Swapchain_Info),
        swapchain_resize: proc(size: [2]uint) -> bool,
        swapchain_get_rendertarget: proc() -> Render_Target,
    },
}

CONTEXT_INSTANCE: core.Cell(Context)
