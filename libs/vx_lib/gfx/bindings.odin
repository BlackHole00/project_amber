package vx_lib_gfx

import "core:slice"

Texture_Binding :: struct {
    texture: Texture,
    uniform_name: string,
}

// Represents an OpenGl state. It represents what should be bound when drawing
// something.  
// Note that bindings should not be recreated every frame, only 
// This struct can be copied.
Bindings_Impl :: struct {
    // vertex_count: uint,
    // vertex_buffers: [16]Buffer,
    // index_buffer: Maybe(Buffer),

    // texture_count: uint,
    // textures: [16]Texture_Binding,

    vertex_buffers: []Buffer,
    index_buffer: Maybe(Buffer),

    textures: []Texture_Binding,
}

Bindings :: ^Bindings_Impl

// Initializes the bindings.  
// Arguments: 
// - vertex_buffers: contains the buffers that will be used relative to the 
// gfx.Layout_Element.buffer_idx in the Pipeline_Descriptor.Pipeline_Layout of 
// the pipeline that the bindings will be used with.  
// - index_buffer should be nil if draw_arrays will be used.  
// - textures: A list of textures and corrisponding uniform name that needs to be 
// applied.
bindings_new :: proc(vertex_buffers: []Buffer, index_buffer: Maybe(Buffer), textures: []Texture_Binding) -> Bindings {
    when ODIN_DEBUG do if index_buffer != nil do if index_buffer.?.type != .Index_Buffer do panic("The index buffer in the bindings should be a valid index buffer.")

    bindings := new(Bindings_Impl, OPENGL_CONTEXT.gl_allocator)

    bindings.vertex_buffers = slice.clone(vertex_buffers, OPENGL_CONTEXT.gl_allocator)
    bindings.textures = slice.clone(textures, OPENGL_CONTEXT.gl_allocator)
    bindings.index_buffer = index_buffer

    return bindings
}

bindings_free :: proc(bindings: Bindings) {
    delete(bindings.vertex_buffers, OPENGL_CONTEXT.allocator)
    delete(bindings.textures, OPENGL_CONTEXT.allocator)

    free(bindings, OPENGL_CONTEXT.allocator)
}

/**************************************************************************************************
***************************************************************************************************
**************************************************************************************************/

@(private)
bindings_apply :: proc(pipeline: Pipeline, bindings: Bindings) {
    // if bindings.index_buffer == nil do pipeline_layout_apply(pipeline^, bindings.vertex_buffers[:bindings.vertex_count])
    // else do pipeline_layout_apply(pipeline^, bindings.vertex_buffers[:bindings.vertex_count], bindings.index_buffer.(Buffer))

    // for i in 0..<bindings.texture_count {
    //     texture_full_bind(bindings.textures[i].texture, (u32)(i))
    //     pipeline_texture_apply(pipeline, (u32)(i), bindings.textures[i].uniform_name)
    // }

    if bindings.index_buffer == nil do pipeline_layout_apply(pipeline, bindings.vertex_buffers)
    else do pipeline_layout_apply(pipeline, bindings.vertex_buffers, bindings.index_buffer.?)

    for binding, i in bindings.textures do pipeline_texture_apply(pipeline, binding.texture, (u32)(i), binding.uniform_name)
}
