package vx_lib_gfx_gl3

import "core:slice"
import "shared:vx_lib/gfx"

// Represents an OpenGl state. It represents what should be bound when drawing
// something.  
// Note that bindings should not be recreated every frame, only 
// This struct can be copied.
Bindings_Impl :: struct {
    vertex_buffers: []Gl3Buffer,
    index_buffer: Maybe(Gl3Buffer),

    textures: []gfx.Texture_Binding,

    uniform_buffers: []gfx.Uniform_Buffer_Binding,
}
Gl3Bindings :: ^Bindings_Impl

// Initializes the bindings.
// Arguments: 
// - vertex_buffers: contains the buffers that will be used relative to the 
// gfx.Layout_Element.buffer_idx in the Pipeline_Descriptor.Pipeline_Layout of 
// the pipeline that the bindings will be used with.  
// - index_buffer should be nil if draw_arrays will be used.  
// - textures: A list of textures and corrisponding uniform name that needs to be 
// applied.
bindings_new :: proc(vertex_buffers: []Gl3Buffer, index_buffer: Maybe(Gl3Buffer), textures: []gfx.Texture_Binding, uniform_buffers: []gfx.Uniform_Buffer_Binding) -> Gl3Bindings {
    when ODIN_DEBUG do if index_buffer != nil do if index_buffer.?.type != .Index_Buffer do panic("The index buffer in the bindings should be a valid index buffer.")

    bindings := new(Bindings_Impl, CONTEXT.gl_allocator)

    bindings.vertex_buffers = slice.clone(vertex_buffers, CONTEXT.gl_allocator)
    bindings.textures = slice.clone(textures, CONTEXT.gl_allocator)
    bindings.uniform_buffers = slice.clone(uniform_buffers, CONTEXT.gl_allocator)
    bindings.index_buffer = index_buffer

    return bindings
}

bindings_free :: proc(bindings: Gl3Bindings) {
    delete(bindings.vertex_buffers, CONTEXT.gl_allocator)
    delete(bindings.textures, CONTEXT.gl_allocator)
    delete(bindings.uniform_buffers, CONTEXT.gl_allocator)

    free(bindings, CONTEXT.gl_allocator)
}

/**************************************************************************************************
***************************************************************************************************
**************************************************************************************************/

@(private)
bindings_apply :: proc(pipeline: Gl3Pipeline, bindings: Gl3Bindings) {
    if bindings.index_buffer == nil do pipeline_layout_apply(pipeline, bindings.vertex_buffers)
    else do pipeline_layout_apply(pipeline, bindings.vertex_buffers, bindings.index_buffer.?)

    for binding, i in bindings.textures do pipeline_texture_apply(pipeline, (Gl3Texture)(binding.texture), (u32)(i), binding.uniform_name)
    for binding in bindings.uniform_buffers do pipeline_uniformbuffer_apply(pipeline, (u32)((Gl3Buffer)(binding.buffer).uniform_bindings_point), binding.uniform_name)
}
