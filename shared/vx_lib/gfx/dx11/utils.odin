package vx_lib_gfx_dx11

import "core:log"
import "vendor:directx/dxgi"
import "shared:vx_lib/gfx"

@(private)
gfxImageFormat_to_d3d11SwapchanFormat :: proc(format: gfx.Image_Format) -> dxgi.FORMAT {
    context.logger = CONTEXT_INSTANCE.logger

    #partial switch format {
        case .R8: return .R8_UNORM
        case .R8G8: return .R8G8_UNORM
        case .R8G8B8: {
            log.info("R8G8B8 do not have a d3d11 equivalent for the swapchain. Using R8G8B8A8_UNORM.")

            return .R8G8B8A8_UNORM
        }
        case .R8G8B8A8: return .R8G8B8A8_UNORM
        case .D24S8: return .D24_UNORM_S8_UINT
        case: {
            log.info("gfxImageFormat_to_d3d11SwapchanFormat cannot find a d3d11 equivalent format for the swapchain. Using R8G8B8A8_UNORM.")
            return .R8G8B8A8_UNORM
        }
    }
}