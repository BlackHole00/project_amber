package vx_lib_gfx_gl4

import "core:strings"
import "shared:glfw"
import gl "vendor:OpenGL"
import "shared:vx_lib/gfx"

device_set :: proc(index: uint) -> bool {
    // OpenGl only has ONE device
    if index != 0 do return false

    CONTEXT_INSTANCE.device_set = true

    return true
}

device_get_info :: proc() -> Maybe(gfx.Device_Info) {
    if !CONTEXT_INSTANCE.device_set do return nil

    return device_get_deviceinfo_from_driver()
}

get_deviceinfolist :: proc() -> gfx.Device_Info_List {
    list := make([]gfx.Device_Info, 1) 
    list[0] = device_get_deviceinfo_from_driver()

    return list
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
    context.allocator = CONTEXT_INSTANCE.allocator

    delete(info.device_name)
    delete(info.driver_info)
    delete(info.api_info)
}

deviceinfolist_free :: proc(list: gfx.Device_Info_List) {
    context.allocator = CONTEXT_INSTANCE.allocator

    deviceinfo_free(list[0])
    delete(list)
}

@(private)
device_get_deviceinfo_from_driver :: proc() -> gfx.Device_Info {
    context.allocator = CONTEXT_INSTANCE.allocator

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