//+build darwin

package vx_lib_gfx

when ODIN_OS == .Darwin {

import "../core"
import "vendor:glfw"
import "../platform"
import "core:log"
import MTL "vendor:darwin/Metal"
import CA "vendor:darwin/QuartzCore"

Metal_Context :: struct {
    // Permanent
    device: ^MTL.Device,
    swapchain: ^CA.MetalLayer,
    command_queue: ^MTL.CommandQueue,

    // Per frame
    drawable: ^CA.MetalDrawable,
    default_command_buffer: ^MTL.CommandBuffer,
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

    METAL_CONTEXT.command_queue = METAL_CONTEXT.device->newCommandQueue()
}

metalcontext_pre_frame :: proc() {
    METAL_CONTEXT.default_command_buffer = METAL_CONTEXT.command_queue->commandBuffer()
    METAL_CONTEXT.drawable = METAL_CONTEXT.swapchain->nextDrawable()
	assert(METAL_CONTEXT.drawable != nil)

}

metalcontext_post_frame :: proc() {
    METAL_CONTEXT.default_command_buffer->presentDrawable(METAL_CONTEXT.drawable)
	METAL_CONTEXT.default_command_buffer->commit()
    METAL_CONTEXT.default_command_buffer->release()

    METAL_CONTEXT.drawable->release()
}

metalcontext_free :: proc() {
    METAL_CONTEXT.device->release()
    METAL_CONTEXT.swapchain->release()
    METAL_CONTEXT.command_queue->release()

    core.cell_free(&METAL_CONTEXT)
}

}