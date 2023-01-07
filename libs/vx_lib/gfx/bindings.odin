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
Bindings :: struct {
    // vertex_count: uint,
    // vertex_buffers: [16]Buffer,
    // index_buffer: Maybe(Buffer),

    // texture_count: uint,
    // textures: [16]Texture_Binding,

    vertex_buffers: []Buffer,
    index_buffer: Maybe(Buffer),

    textures: []Texture_Binding,
}

// Initializes the bindings.  
// Arguments: 
// - vertex_buffers: contains the buffers that will be used relative to the 
// gfx.Layout_Element.buffer_idx in the Pipeline_Descriptor.Pipeline_Layout of 
// the pipeline that the bindings will be used with.  
// - index_buffer should be nil if draw_arrays will be used.  
// - textures: A list of textures and corrisponding uniform name that needs to be 
// applied.
bindings_init :: proc(bindings: ^Bindings, vertex_buffers: []Buffer, index_buffer: Maybe(Buffer), textures: []Texture_Binding) {
    when ODIN_DEBUG do if index_buffer != nil do if index_buffer.?.type != .Index_Buffer do panic("The index buffer in the bindings should be a valid index buffer.")

    // bindings.vertex_count = len(vertex_buffers)
    // if bindings.vertex_count != 0 do mem.copy(&bindings.vertex_buffers[0], &vertex_buffers[0], len(vertex_buffers) * size_of(Buffer))

    // bindings.index_buffer = index_buffer

    // bindings.texture_count = len(textures)
    // if bindings.texture_count != 0 do mem.copy(&bindings.textures[0], &textures[0], len(textures) * size_of(Texture_Binding))

    bindings.vertex_buffers = slice.clone(vertex_buffers)
    bindings.textures = slice.clone(textures)
    bindings.index_buffer = index_buffer
}

bindings_free :: proc(bindings: Bindings) {
    delete(bindings.vertex_buffers)
    delete(bindings.textures)
}

/**************************************************************************************************
***************************************************************************************************
**************************************************************************************************/

@(private)
bindings_apply :: proc(pipeline: ^Pipeline, bindings: ^Bindings) {
    // if bindings.index_buffer == nil do pipeline_layout_apply(pipeline^, bindings.vertex_buffers[:bindings.vertex_count])
    // else do pipeline_layout_apply(pipeline^, bindings.vertex_buffers[:bindings.vertex_count], bindings.index_buffer.(Buffer))

    // for i in 0..<bindings.texture_count {
    //     texture_full_bind(bindings.textures[i].texture, (u32)(i))
    //     pipeline_texture_apply(pipeline, (u32)(i), bindings.textures[i].uniform_name)
    // }

    if bindings.index_buffer == nil do pipeline_layout_apply(pipeline^, bindings.vertex_buffers)
    else do pipeline_layout_apply(pipeline^, bindings.vertex_buffers, bindings.index_buffer.?)

    for binding, i in bindings.textures do pipeline_texture_apply(pipeline, binding.texture, (u32)(i), binding.uniform_name)
}
