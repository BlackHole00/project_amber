package vx_lib_gfx

import gl "vendor:OpenGL"

Buffer_Type :: enum {
    Vertex_Buffer,
    Index_Buffer,
    Uniform_Buffer,
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

Buffer_Impl :: struct {
    buffer_handle: u32,
    type: Buffer_Type,
    usage: Buffer_Usage,

    // Used only if is an index buffer.
    index_type: Index_Type,

    // Used only if it is an uniform buffer.
    uniform_bindings_point: uint,
}

// An abstraction over a plain OpenGL VBO or EBO. Like a OpenGl buffer, its 
// memory management is automatic, so it doesn't have a fixed size.
Buffer :: ^Buffer_Impl

buffer_new_empty :: proc(desc: Buffer_Descriptor) -> Buffer {
    buffer := new(Buffer_Impl, OPENGL_CONTEXT.gl_allocator)

    buffer.type = desc.type
    buffer.usage = desc.usage
    buffer.index_type = desc.index_type

    when MODERN_OPENGL do gl.CreateBuffers(1, &buffer.buffer_handle)
    else do gl.GenBuffers(1, &buffer.buffer_handle)

    if buffer.type == .Uniform_Buffer do buffer.uniform_bindings_point = glcontext_get_available_ubo_bind_point()

    return buffer
}

buffer_new_with_data :: proc(desc: Buffer_Descriptor, data: []$T) -> Buffer {
    buffer := buffer_new_empty(desc)
    buffer_set_data(buffer, data)

    return buffer
}

buffer_new_from_abstractbuffer :: proc(desc: Buffer_Descriptor, abstractbuffer: Abstract_Buffer) -> Buffer {
    buffer := buffer_new_empty(desc)
    buffer_set_data(buffer, abstractbuffer.data)

    return buffer
}

buffer_new :: proc { buffer_new_empty, buffer_new_with_data }

buffer_set_data :: proc(buffer: Buffer, data: []$T) {
    tmp := len(data) * size_of(T)

    when MODERN_OPENGL do gl.NamedBufferData(buffer.buffer_handle, tmp, raw_data(data), bufferusage_to_glenum(buffer.usage))
    else {
        buffer_non_dsa_bind(buffer)
        gl.BufferData(buffertype_to_glenum(buffer.type), tmp, raw_data(data), bufferusage_to_glenum(buffer.usage))
        buffer_non_dsa_unbind(buffer.type)
    }

    if buffer.type == .Uniform_Buffer {
        buffer_non_dsa_bind(buffer)
        gl.BindBufferBase(buffertype_to_glenum(buffer.type), (u32)(buffer.uniform_bindings_point), buffer.buffer_handle)
        when ODIN_DEBUG do buffer_non_dsa_unbind(buffer.type)
    }
}

buffer_free :: proc(buffer: Buffer) {
    gl.DeleteBuffers(1, &buffer.buffer_handle)

    free(buffer, OPENGL_CONTEXT.gl_allocator)
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
        case .Uniform_Buffer: return gl.UNIFORM_BUFFER,
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
