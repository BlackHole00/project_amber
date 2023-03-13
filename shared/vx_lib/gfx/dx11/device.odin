package vx_lib_gfx_dx11

import "core:strings"
import "shared:vx_lib/gfx"

device_check_requirements :: proc(requirements: gfx.Device_Requirements) -> gfx.Device_Set_Error {
    if requirements.headless do return .Impossible_Functionality // TODO

    return .Unavaliable_Functionality
}

device_set :: proc(requirements: gfx.Device_Requirements) {
    // TODO: Free all the previous resources.
}

device_get_info :: proc() -> Maybe(gfx.Device_Info) {

    return gfx.Device_Info {}
}

device_check_swapchain_descriptor :: proc(descriptor: gfx.Swapchain_Descriptor) -> gfx.Swapchain_Set_Error {
    return .Unavaliable_Functionality
}

device_set_swapchain :: proc(descriptor: gfx.Swapchain_Descriptor) {
    CONTEXT_INSTANCE.swapchain_descriptor = descriptor
}

deviceinfo_free :: proc(info: gfx.Device_Info) {
    delete(info.device_name)
    delete(info.driver_info)
    delete(info.api_info)
}