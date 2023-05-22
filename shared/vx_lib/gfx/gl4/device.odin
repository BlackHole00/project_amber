//+build windows, linux
package vx_lib_gfx_gl4

import "core:fmt"
import "core:strings"
import "shared:glfw"
import gl "vendor:OpenGL"
import bku "shared:vx_lib/gfx/backendutils"
import "shared:vx_lib/gfx"

get_device_count :: proc() -> uint {
    return 1
}

get_deviceinfo_of_idx :: proc(index: uint) -> gfx.Device_Info {
    assert(index == 0)

    return device_get_deviceinfo_from_driver()
}

deviceinfo_free :: proc(info: gfx.Device_Info) {
    context.allocator = CONTEXT_INSTANCE.allocator

    delete(info.device_description)
}

device_get_info :: proc() -> gfx.Device_Info {
    return device_get_deviceinfo_from_driver()
}

device_set :: proc(index: uint) -> bool {
    // OpenGl only has ONE device
    if index != 0 do return false

    return true
}

device_check_swapchain_descriptor :: proc(descriptor: gfx.Swapchain_Descriptor) -> gfx.Swapchain_Set_Error {
    return .Unavaliable_Functionality
}

device_set_swapchain :: proc(descriptor: gfx.Swapchain_Descriptor) {
    CONTEXT_INSTANCE.swapchain_descriptor = descriptor

    switch descriptor.present_mode {
        case .Vsync: glfw.SwapInterval(1)
        case .Immediate: glfw.SwapInterval(0)
    }
    swapchain_resize(descriptor.size)

}

@(private)
device_get_deviceinfo_from_driver :: proc() -> gfx.Device_Info {
    context.allocator = CONTEXT_INSTANCE.allocator

    device_name := strings.clone_from_cstring(gl.GetString(gl.RENDERER))
    defer delete(device_name)
    driver_info := strings.clone_from_cstring(gl.GetString(gl.VENDOR))
    defer delete(driver_info)
    api_info := strings.clone_from_cstring(gl.GetString(gl.VERSION))
    defer delete(api_info)
 
    l_device_name := strings.to_lower(device_name)
    defer delete(l_device_name)
    l_driver_info := strings.to_lower(driver_info)
    defer delete(l_driver_info)

    return gfx.Device_Info {
        device_description = fmt.aprint(device_name, driver_info, api_info),
        device_vendor = bku.try_predict_devicevendor(device_name),
        device_type = bku.try_predict_devicetype(device_name),
        dedicated_memory = gfx.Device_Memory_Cannot_Determine {},
        shared_memory = gfx.Device_Memory_Cannot_Determine {},
    }
}