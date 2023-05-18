//+build windows
package vx_lib_gfx_dx11

import "core:log"
import "core:fmt"
import win "core:sys/windows"
import "vendor:directx/dxgi"
import "shared:vx_lib/gfx"

device_set :: proc(index: uint) -> bool {
    if CONTEXT_INSTANCE.adapters == nil do return false
    if index >= len(CONTEXT_INSTANCE.adapters.?) do return false

    CONTEXT_INSTANCE.adapter = CONTEXT_INSTANCE.adapters.?[index]
    free_adapter_list()

    // TODO: create d3d11 device

    return true
}

device_get_info :: proc() -> Maybe(gfx.Device_Info) {
    if CONTEXT_INSTANCE.adapter == nil do return nil

    return deviceinfo_get_from_adapter(CONTEXT_INSTANCE.adapter)
}

get_deviceinfolist :: proc() -> gfx.Device_Info_List {
    if CONTEXT_INSTANCE.adapters == nil do generate_adapter_list()

    context.allocator = CONTEXT_INSTANCE.allocator

    list := make([]gfx.Device_Info, len(CONTEXT_INSTANCE.adapters.?))
    for adapter, i in CONTEXT_INSTANCE.adapters.? {
        list[i] = deviceinfo_get_from_adapter(adapter)
    }

    return list
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
    // delete(info.api_info)
}

deviceinfolist_free :: proc(list: gfx.Device_Info_List) {
    context.allocator = CONTEXT_INSTANCE.allocator

    for info in list {
        deviceinfo_free(info)
    }
    delete(list)
}

@(private)
generate_adapter_list :: proc() {
    context.allocator = CONTEXT_INSTANCE.allocator
    context.logger = CONTEXT_INSTANCE.logger

    if CONTEXT_INSTANCE.adapters != nil {
        log.warn("generate_adapter_list called when the adapter list is still valid. Returning.")
        return
    }

    CONTEXT_INSTANCE.adapters = make([dynamic]^dxgi.IAdapter)

    dxgi_factory: ^dxgi.IFactory
    assert(dxgi.CreateDXGIFactory(dxgi.IFactory_UUID, auto_cast &dxgi_factory) == 0, "Could not create a DXGIFactory")
    defer dxgi_factory->Release()

    adapter: ^dxgi.IAdapter
    i: u32 = 0
    for dxgi_factory->EnumAdapters(i, &adapter) != dxgi.ERROR_NOT_FOUND {
        append(&CONTEXT_INSTANCE.adapters.?, adapter)
        i += 1
    }
}

@(private)
free_adapter_list :: proc() {
    delete(CONTEXT_INSTANCE.adapters.?)
    CONTEXT_INSTANCE.adapters = nil
}


@(private)
deviceinfo_get_from_adapter :: proc(adapter: ^dxgi.IAdapter) -> gfx.Device_Info {
    adapter_desc: dxgi.ADAPTER_DESC
    adapter->GetDesc(&adapter_desc)

    info: gfx.Device_Info

    if str, err := win.utf16_to_utf8(transmute([]u16)(adapter_desc.Description[:]), context.allocator); err == .None {
        info.device_name = str
    }
    info.driver_info = fmt.aprint(adapter_desc.Revision)
    info.api_info = "Unknown"
    info.device_type = .Unknown

    return info
}