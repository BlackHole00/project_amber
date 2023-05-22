//+build windows
package vx_lib_gfx_dx11

import "core:log"
import "core:strings"
import win "core:sys/windows"
import "vendor:directx/dxgi"
import "vendor:directx/d3d11"
import bku "shared:vx_lib/gfx/backendutils"
import "shared:vx_lib/gfx"

get_device_count :: proc() -> uint {
    if CONTEXT_INSTANCE.adapters == nil do generate_adapter_list()

    return len(CONTEXT_INSTANCE.adapters.?)
}

get_deviceinfo_of_idx :: proc(index: uint) -> gfx.Device_Info {
    if CONTEXT_INSTANCE.adapters == nil do generate_adapter_list()

    return deviceinfo_get_from_adapter(CONTEXT_INSTANCE.adapters.?[index])
}

deviceinfo_free :: proc(info: gfx.Device_Info) {
    delete(info.device_description)
}

device_get_info :: proc() -> gfx.Device_Info {
    return deviceinfo_get_from_adapter(CONTEXT_INSTANCE.adapter)
}

device_set :: proc(index: uint) -> bool {
    if CONTEXT_INSTANCE.adapters == nil do generate_adapter_list()

    CONTEXT_INSTANCE.adapter = CONTEXT_INSTANCE.adapters.?[index]
    free_adapter_list()

    flags: d3d11.CREATE_DEVICE_FLAGS
    if CONTEXT_INSTANCE.debug {
        // flags += d3d11.CREATE_DEVICE_FLAG.DEBUG
        incl(&flags, d3d11.CREATE_DEVICE_FLAG.DEBUG)
    }
    feature_levels := []d3d11.FEATURE_LEVEL {
        // ._12_1,
        // ._12_0,
        ._11_1,
    }

    if err := d3d11.CreateDevice(
        CONTEXT_INSTANCE.adapter,
        .UNKNOWN,
        nil,
        flags,
        &feature_levels[0],
        (u32)(len(feature_levels)),
        d3d11.SDK_VERSION,
        &CONTEXT_INSTANCE.device,
        nil,
        &CONTEXT_INSTANCE.device_context,
    ); err != win.NO_ERROR {
        log.error("Device failed to start with error", err)
        return false
    }

    return true
}

device_check_swapchain_descriptor :: proc(descriptor: gfx.Swapchain_Descriptor) -> gfx.Swapchain_Set_Error {
    return .Unavaliable_Functionality
}

device_set_swapchain :: proc(descriptor: gfx.Swapchain_Descriptor) {
    CONTEXT_INSTANCE.swapchain_descriptor = descriptor

    dxgi_factory: ^dxgi.IFactory2
    if (CONTEXT_INSTANCE.debug) {
        assert(dxgi.CreateDXGIFactory2(dxgi.CREATE_FACTORY_DEBUG, dxgi.IFactory2_UUID, auto_cast &dxgi_factory) == 0, "Could not create a DXGIFactory")
    } else {
        assert(dxgi.CreateDXGIFactory2(0, dxgi.IFactory2_UUID, auto_cast &dxgi_factory) == 0, "Could not create a DXGIFactory")
    }
    defer dxgi_factory->Release()

    flags: u32 = 0
    if descriptor.present_mode != .Vsync {
        flags = (u32)(dxgi.SWAP_CHAIN_FLAG.ALLOW_TEARING)
    }

    swapchain_desc := dxgi.SWAP_CHAIN_DESC1 {
        Width = (u32)(descriptor.size.x),
        Height = (u32)(descriptor.size.y),
        Format = gfxImageFormat_to_d3d11SwapchanFormat(descriptor.format),
        Stereo = false,
        SwapEffect = .DISCARD,
        SampleDesc = dxgi.SAMPLE_DESC {
            Count = 1,
            Quality = 0,
        },
        BufferUsage = { .RENDER_TARGET_OUTPUT },
        BufferCount = 1,
        Scaling = .STRETCH,
        AlphaMode = .UNSPECIFIED,
        Flags = flags,
    }

    swapchain_fullscreen_desc := dxgi.SWAP_CHAIN_FULLSCREEN_DESC {
        RefreshRate = dxgi.RATIONAL {
            Numerator = 1,
            Denominator = 60,
        },
        ScanlineOrdering = .UNSPECIFIED,
        Scaling = .STRETCHED,
        Windowed = (win.BOOL)(!descriptor.fullscreen),
    }

    assert(dxgi_factory->CreateSwapChainForHwnd(CONTEXT_INSTANCE.device, CONTEXT_INSTANCE.native_hwnd, &swapchain_desc, &swapchain_fullscreen_desc, nil, &CONTEXT_INSTANCE.swapchain) == win.NO_ERROR)
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
        info.device_description = str
    }

    l_device_description := strings.to_lower(info.device_description)
    defer delete(l_device_description)

    device_vendor := bku.try_predict_devicevendor(info.device_description)
    device_type := bku.try_predict_devicetype(info.device_description)

    info.device_vendor = device_vendor
    info.device_type = device_type
    info.shared_memory = adapter_desc.SharedSystemMemory
    info.dedicated_memory = adapter_desc.DedicatedVideoMemory

    return info
}