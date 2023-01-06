package vx_lib_gfx

import gl "vendor:OpenGL"

Buffer_Type :: enum {
    Vertex_Buffer,
    Index_Buffer,
}

Buffer_Usage :: enum {
    Static_Draw,
    Dynamic_Draw,
}

Index_Type :: enum {
    U8,
    U16,
    U32,
}

Buffer_Descriptor :: struct {
    type: Buffer_Type,
    usage: Buffer_Usage,
    index_type: Index_Type,
}

// An abstraction over a plain OpenGL VBO or EBO. Like a OpenGl buffer, its 
// memory management is automatic, so it doesn't have a fixed size.
Buffer :: struct {
    buffer_handle: u32,
    type: Buffer_Type,
    usage: Buffer_Usage,
    index_type: Maybe(Index_Type),
}

buffer_init_empty :: proc(buffer: ^Buffer, desc: Buffer_Descriptor) {
    buffer.type = desc.type
    buffer.usage = desc.usage
    buffer.index_type = desc.index_type

    when ODIN_DEBUG do if desc.index_type != nil && desc.type != .Index_Buffer do panic("desc.indext_type should be used only when using an index buffer")
    when ODIN_DEBUG do if desc.index_type == nil && desc.type == .Index_Buffer do panic("When creating an index buffer a index type should be used.")

    when MODERN_OPENGL do gl.CreateBuffers(1, &buffer.buffer_handle)
    else {
        gl.GenBuffers(1, &buffer.buffer_handle)
    }
}

buffer_init_with_data :: proc(buffer: ^Buffer, desc: Buffer_Descriptor, data: []$T) {
    buffer_init_empty(buffer, desc)

    buffer_set_data(buffer^, data)
}

buffer_init_from_abstractbuffer :: proc(buffer: ^Buffer, desc: Buffer_Descriptor, abstractbuffer: Abstract_Buffer) {
    buffer_init_empty(buffer, desc)

    buffer_set_data(buffer^, abstractbuffer.data)
}

buffer_init :: proc { buffer_init_empty, buffer_init_with_data }

buffer_set_data :: proc(buffer: Buffer, data: []$T) {
    tmp := len(data) * size_of(T)

    when MODERN_OPENGL do gl.NamedBufferData(buffer.buffer_handle, tmp, raw_data(data), bufferusage_to_glenum(buffer.usage))
    else {
        buffer_non_dsa_bind(buffer)
        gl.BufferData(buffertype_to_glenum(buffer.type), tmp, raw_data(data), bufferusage_to_glenum(buffer.usage))
        buffer_non_dsa_unbind(buffer.type)
    }
}

buffer_free :: proc(buffer: ^Buffer) {
    gl.DeleteBuffers(1, &buffer.buffer_handle)

    buffer.buffer_handle = INVALID_HANDLE
}

@(private)
buffer_non_dsa_bind :: proc(buffer: Buffer) {
    gl.BindBuffer(buffertype_to_glenum(buffer.type), buffer.buffer_handle)
}

@(private)
buffer_non_dsa_unbind :: proc(type: Buffer_Type) {
    when ODIN_DEBUG do gl.BindBuffer(buffertype_to_glenum(type), 0)
}

@(private)
buffertype_to_glenum :: proc(type: Buffer_Type) -> u32 {
    switch type {
        case .Index_Buffer: return gl.ELEMENT_ARRAY_BUFFER
        case .Vertex_Buffer: return gl.ARRAY_BUFFER
    }

    return 0
}

@(private)
bufferusage_to_glenum :: proc(type: Buffer_Usage) -> u32 {
    switch type {
        case .Static_Draw: return gl.STATIC_DRAW
        case .Dynamic_Draw: return gl.DYNAMIC_DRAW
    }

    return 0
}

@(private)
indextype_to_glenum :: proc(type: Index_Type) -> u32 {
    switch type {
        case .U8: return gl.UNSIGNED_BYTE
        case .U16: return gl.UNSIGNED_SHORT
        case .U32: return gl.UNSIGNED_INT
    }

    return 0
}
