package vx_lib_gfx_gl4

import "core:strings"
import "shared:glfw"
import gl "vendor:OpenGL"
import "shared:vx_lib/gfx"

device_check_requirements :: proc(requirements: gfx.Device_Requirements) -> gfx.Device_Set_Error {
    return .Unavaliable_Functionality
}

device_set :: proc(requirements: gfx.Device_Requirements) {}

device_get_info :: proc() -> Maybe(gfx.Device_Info) {
    device_name := strings.clone_from_cstring(gl.GetString(gl.RENDERER))
    driver_info := strings.clone_from_cstring(gl.GetString(gl.VENDOR))
    api_info := strings.clone_from_cstring(gl.GetString(gl.VERSION))

    return gfx.Device_Info {
        device_name = device_name,
        driver_info = driver_info,
        api_info = api_info,

        device_type = .Unknown,
    }
}

device_check_swapchain_descriptor :: proc(descriptor: gfx.Swapchain_Descriptor) -> gfx.Swapchain_Set_Error {
    if descriptor.refresh_rate != 60 do return .Illegal_Refresh_Rate

    return .Unavaliable_Functionality
}

device_set_swapchain :: proc(descriptor: gfx.Swapchain_Descriptor) {
    CONTEXT_INSTANCE.swapchain_descriptor = descriptor

    switch descriptor.present_mode {
        case .Fifo: glfw.SwapInterval(1)
        case .Immediate: glfw.SwapInterval(0)
        case .Mailbox: glfw.SwapInterval(0)
    }
    swapchain_resize(descriptor.size)

}

deviceinfo_free :: proc(info: gfx.Device_Info) {
    delete(info.device_name)
    delete(info.driver_info)
    delete(info.api_info)
}