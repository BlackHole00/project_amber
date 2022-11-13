package vx_lib_common

import "vendor:glfw"
import "core:sys/windows"
import "core:log"
import "shared:wgpu"
import "shared:vx_lib/core"
import "shared:vx_lib/platform"
import "shared:vx_lib/gfx"

Adapter_Request_Userdata :: struct {
    adapter: ^wgpu.Adapter,
    ok: bool,
}
ADAPTERREQUESTUSERDATA_INSTANCE: Adapter_Request_Userdata

Device_Request_Userdata :: struct {
    device: ^wgpu.Device,
    ok: bool,
}
DEVICEREQUESTUSERDATA_INSTANCE: Device_Request_Userdata

windowcontext_init_with_wgpu :: proc() {
    // void request_adapter_callback(WGPURequestAdapterStatus status,WGPUAdapter received, const char *message, void *userdata)
    handle_adapter_request :: proc "c" (status: wgpu.RequestAdapterStatus, adapter: wgpu.Adapter, message: cstring, userdata: rawptr) {
        context = core.default_context()

        if status == .RequestadapterstatusSuccess {
            ADAPTERREQUESTUSERDATA_INSTANCE.ok = true
            ADAPTERREQUESTUSERDATA_INSTANCE.adapter^ = adapter

            log.info("Successfully requested an adapter.")
        } else {
            ADAPTERREQUESTUSERDATA_INSTANCE.ok = false

            log.fatal("Error requesting an adapter:", status, "-", message)
        }
    }

    handle_device_request :: proc "c" (status: wgpu.RequestDeviceStatus, device: wgpu.Device, message: cstring, userdata: rawptr) {
        context = core.default_context()

        if status == .RequestdevicestatusSuccess {
            DEVICEREQUESTUSERDATA_INSTANCE.ok = true
            DEVICEREQUESTUSERDATA_INSTANCE.device^ = device

            log.info("Successfully requested a device.")
        } else {
            ADAPTERREQUESTUSERDATA_INSTANCE.ok = false

            log.fatal("Error requesting a device:", status, "-", message)
        }
    }

    handle_uncaptured_error :: proc "c" (type: wgpu.ErrorType, message: cstring, userdata: rawptr) {
        context = core.default_context()

        log.error("Wgpu Uncaptured error:", type, "-", message)
    }

    handle_device_lost :: proc "c" (reason: wgpu.DeviceLostReason, message : cstring, userdata : rawptr) {
        context = core.default_context()

        log.fatal("Wgpu device lost:", reason, "-", message)
        panic("Lost wgpu device.")
    }

    init_wgpu :: proc(handle: glfw.WindowHandle, desc: platform.Window_Descriptor) -> (bool, string) {
        core.cell_init(&gfx.WGPUCONTEXT_INSTANCE)

        when ODIN_OS == .Windows {
            hwnd := glfw.GetWin32Window(handle)
            hinstance := windows.GetModuleHandleA(nil)

            gfx.WGPUCONTEXT_INSTANCE.surface = wgpu.instance_create_surface(nil, &wgpu.SurfaceDescriptor {
                label = nil,
                next_in_chain = auto_cast &wgpu.SurfaceDescriptorFromWindowsHwnd {
                    hinstance = hinstance,
                    hwnd = hwnd,
                    chain = wgpu.ChainedStruct {
                        next = nil,
                        s_type = wgpu.SType.StypeSurfacedescriptorfromwindowshwnd,
                    },
                },
            })
        } else do #panic("OS not yet supported.")

        ADAPTERREQUESTUSERDATA_INSTANCE.adapter = &gfx.WGPUCONTEXT_INSTANCE.adapter
        wgpu.instance_request_adapter(nil, &wgpu.RequestAdapterOptions {
            compatible_surface = gfx.WGPUCONTEXT_INSTANCE.surface,
            force_fallback_adapter = true,
            next_in_chain = nil,
        }, auto_cast handle_adapter_request, nil)
        if !ADAPTERREQUESTUSERDATA_INSTANCE.ok do return false, "Failed to request an adapter."

        DEVICEREQUESTUSERDATA_INSTANCE.device = &gfx.WGPUCONTEXT_INSTANCE.device
        wgpu.adapter_request_device(gfx.WGPUCONTEXT_INSTANCE.adapter, &wgpu.DeviceDescriptor {
            label = "device",
            required_limits = &wgpu.RequiredLimits {
                limits = wgpu.Limits {
                    max_bind_groups = 1,
                },
                next_in_chain = nil,
            },
            default_queue = wgpu.QueueDescriptor {
                label = nil,
                next_in_chain = nil,
            },
            next_in_chain = nil,
        }, auto_cast handle_device_request, nil)
        if !ADAPTERREQUESTUSERDATA_INSTANCE.ok do return false, "Failed to request a device."

        wgpu.device_set_uncaptured_error_callback(gfx.WGPUCONTEXT_INSTANCE.device, auto_cast handle_uncaptured_error, nil)
        wgpu.device_set_device_lost_callback(gfx.WGPUCONTEXT_INSTANCE.device, auto_cast handle_device_lost, nil)

        return true, ""
    }

    pre_window_init_wgpu :: proc() -> (bool, string) {
        glfw.WindowHint(glfw.NO_API, 1)

        return true, ""
    }

    post_frame_wgpu :: proc(handle: glfw.WindowHandle) {
    }

    close_wgpu :: proc() {
        core.cell_free(&gfx.WGPUCONTEXT_INSTANCE)
    }

    platform.windowcontext_init(platform.Window_Context_Descriptor {
        pre_window_init_proc = pre_window_init_wgpu,
        post_window_init_proc = init_wgpu,
        post_frame_proc = post_frame_wgpu,
        close_proc = close_wgpu,
    })
}