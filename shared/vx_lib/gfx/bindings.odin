package vx_lib_gfx

Texture_Binding :: struct {
    texture: Texture,
    uniform_name: string,
}

Uniform_Buffer_Binding :: struct {
    buffer: Buffer,
    uniform_name: string,
}

// Represents an OpenGl state. It represents what should be bound when drawing
// something.
// Note that bindings should not be recreated every frame, only 
// This struct can be copied.
Bindings :: distinct rawptr

// Initializes the bindings.  
// Arguments: 
// - vertex_buffers: contains the buffers that will be used relative to the 
// gfx.Layout_Element.buffer_idx in the Pipeline_Descriptor.Pipeline_Layout of 
// the pipeline that the bindings will be used with.  
// - index_buffer should be nil if draw_arrays will be used.  
// - textures: A list of textures and corrisponding uniform name that needs to be 
// applied.
bindings_new :: proc(vertex_buffers: []Buffer, index_buffer: Maybe(Buffer), textures: []Texture_Binding, uniform_buffers: []Uniform_Buffer_Binding) -> Bindings {
    when ODIN_DEBUG {
        for buffer in vertex_buffers do if buffer_get_buffertype(buffer) != .Vertex_Buffer do panic("All vertex buffers must be of type .Vertex_Buffer.")
        if index_buffer != nil do if buffer_get_buffertype(index_buffer.?) != .Index_Buffer do panic("The index buffer must be of type .Index_Buffer")
        for buffer in uniform_buffers do if buffer_get_buffertype(buffer.buffer) != .Uniform_Buffer do panic("All uniform buffers must be of type .Uniform_Buffer")
    }

    return GFXPROCS_INSTANCE.bindings_new(vertex_buffers, index_buffer, textures, uniform_buffers)
}

bindings_free :: proc(bindings: Bindings) {
    GFXPROCS_INSTANCE.bindings_free(bindings)
}

bindings_has_index_buffer :: proc(bindings: Bindings) -> bool {
    return GFXPROCS_INSTANCE.bindings_has_index_buffer(bindings)
}
