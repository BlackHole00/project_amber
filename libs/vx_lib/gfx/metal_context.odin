package vx_lib_gfx

import "../core"
import "vendor:glfw"
import "../platform"
import "core:log"
//import NS "vendor:darwin/Foundation"
import MTL "vendor:darwin/Metal"
import CA "vendor:darwin/QuartzCore"

when ODIN_OS == .Darwin {

Metal_Context :: struct {
    device: ^MTL.Device,
    swapchain: ^CA.MetalLayer,
}
METAL_CONTEXT: core.Cell(Metal_Context)

metalcontext_init :: proc(handle: glfw.WindowHandle) {
    core.cell_init(&METAL_CONTEXT)
    
    cocoa_window := platform.GetCocoaWindow(handle)
    METAL_CONTEXT.device = MTL.CreateSystemDefaultDevice()

    device_name := METAL_CONTEXT.device->name()->odinString()
    log.info("Using device", device_name)

    METAL_CONTEXT.swapchain = CA.MetalLayer.layer()
    METAL_CONTEXT.swapchain->setDevice(METAL_CONTEXT.device)
	METAL_CONTEXT.swapchain->setPixelFormat(.BGRA8Unorm_sRGB)
	METAL_CONTEXT.swapchain->setFramebufferOnly(true)
	METAL_CONTEXT.swapchain->setFrame(cocoa_window->frame())

	cocoa_window->contentView()->setLayer(METAL_CONTEXT.swapchain)
	cocoa_window->setOpaque(true)
	cocoa_window->setBackgroundColor(nil)
}

metalcontext_free :: proc() {
    METAL_CONTEXT.device->release()
    METAL_CONTEXT.swapchain->release()

    core.cell_free(&METAL_CONTEXT)
}

}