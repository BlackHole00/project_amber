package vx_lib_gfx

when ODIN_OS == .Darwin {

import MTL "vendor:darwin/Metal"

//@(private)
Mtl_Pass_Data :: struct {
    pass: ^MTL.RenderPassDescriptor,
    command_buffer: ^MTL.CommandBuffer,
}

@(private)
_metalimpl_pass_init :: proc(pass: ^Pass, desc: Pass_Descriptor, target: Maybe(Framebuffer) = nil) {
    pass.desc = desc
    pass.render_target = target

    pass.extra_data = (rawptr)(new(Mtl_Pass_Data))
    (^Mtl_Pass_Data)(pass.extra_data).pass = MTL.RenderPassDescriptor.renderPassDescriptor()
}

@(private)
_metalimpl_pass_begin :: proc(pass: ^Pass) {
    if pass.clear_color {
        color_attachment := (^Mtl_Pass_Data)(pass.extra_data).pass->colorAttachments()->object(0)
        assert(color_attachment != nil)
        color_attachment->setClearColor(MTL.ClearColor{
            pass.clearing_color[0],
            pass.clearing_color[1],
            pass.clearing_color[2],
            pass.clearing_color[3],
        })
        color_attachment->setLoadAction(.Clear)
        color_attachment->setStoreAction(.Store)
        color_attachment->setTexture(METAL_CONTEXT.drawable->texture())
    }
    if pass.clear_depth do panic("TODO!")

    if pass.render_target == nil do (^Mtl_Pass_Data)(pass.extra_data).command_buffer = METAL_CONTEXT.default_command_buffer
    else do (^Mtl_Pass_Data)(pass.extra_data).command_buffer = METAL_CONTEXT.command_queue->commandBuffer()
}

@(private)
_metalimpl_pass_end :: proc(pass: ^Pass) {
    if pass.render_target != nil {
        panic("TODO!")
        // (^Mtl_Pass_Data)(pass.extra_data).command_buffer->presentDrawable( _metalimpl_framebuffer_get_mtl_drawable(pass.render_target.(RenderTarget)) )
	    // (^Mtl_Pass_Data)(pass.extra_data).command_buffer->commit()
        // (^Mtl_Pass_Data)(pass.extra_data).command_buffer->release()
    } 
}

@(private)
_metalimpl_pass_resize :: proc(pass: ^Pass, size: [2]uint) {
    pass.viewport_size = size
}

@(private)
_metalimpl_pass_free :: proc(pass: ^Pass) {
    (^Mtl_Pass_Data)(pass.extra_data).pass->release()

    free(pass.extra_data)
}

@(private)
_metalimpl_pass_get_mtl_pass :: proc(pass: Pass) -> ^MTL.RenderPassDescriptor {
    return (^Mtl_Pass_Data)(pass.extra_data).pass
}

@(private)
_metalimpl_pass_get_commandbuffer :: proc(pass: Pass) -> ^MTL.CommandBuffer {
    return (^Mtl_Pass_Data)(pass.extra_data).command_buffer
}   

}
