package vx_lib_gfx_backendutils

import "core:strings"
import "shared:vx_lib/gfx"

try_predict_devicetype :: proc(device_desc: string) -> gfx.Device_Type {
    l_device_desc := strings.to_lower(device_desc)
    defer delete(l_device_desc)

    if (l_device_desc == "microsoft basic render driver") {
        return .Software
    }

    if strings.contains(l_device_desc, "amd") || strings.contains(l_device_desc, "ati") || strings.contains(l_device_desc, "radeon") {
        if strings.contains(l_device_desc, "0m") || strings.contains(l_device_desc, "mobile") || strings.contains(l_device_desc, "vega") { // as in AMD Radeon RX 6800M
            return .Likely_Power_Efficient
        }

        return .Likely_Power_Efficient
    }
    if strings.contains(l_device_desc, "nvidia") {
        // nvidia never created integrated graphics... only some low level graphics cards

        return .Performance
    }
    if strings.contains(l_device_desc, "intel") {
        if strings.contains(l_device_desc, "arc") {
            return .Likely_Performance
        }

        return .Likely_Power_Efficient
    }
    if strings.contains(l_device_desc, "apple") {
        // apple never made any dedicated gpu, their SoCs have technically integrated gpus
        return .Power_Efficient
    }

    return .Unknown
}

try_predict_devicevendor :: proc(device_desc: string) -> gfx.Device_Vendor {
    l_device_desc := strings.to_lower(device_desc)
    defer delete(l_device_desc)

    if strings.contains(l_device_desc, "amd") || strings.contains(l_device_desc, "ati") || strings.contains(l_device_desc, "radeon") {
        return .Amd
    }
    if strings.contains(l_device_desc, "nvidia") {
        return .Nvidia
    }
    if strings.contains(l_device_desc, "intel") {
        return .Intel
    }
    if strings.contains(l_device_desc, "apple") {
        return .Apple
    }
    if strings.contains(l_device_desc, "microsoft") {
        return .Other
    }

    return .Unknown
}