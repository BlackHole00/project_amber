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

Buffer_Descriptor :: struct {
    type: Buffer_Type,
    usage: Buffer_Usage,
}

Buffer :: struct {
    buffer_handle: u32,
    type: u32,
    usage: u32,
}

buffer_init_empty :: proc(buffer: ^Buffer, desc: Buffer_Descriptor) {
    buffer.type = buffertype_to_glenum(desc.type)
    buffer.usage = bufferusage_to_glenum(desc.usage)

    gl.CreateBuffers(1, &buffer.buffer_handle)
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

    gl.NamedBufferData(buffer.buffer_handle, tmp, raw_data(data), buffer.usage)
}

buffer_free :: proc(buffer: ^Buffer) {
    gl.DeleteBuffers(1, &buffer.buffer_handle)

    buffer.buffer_handle = INVALID_HANDLE
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
