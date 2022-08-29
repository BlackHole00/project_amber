package vx_lib_gfx

import gl "vendor:OpenGL"

@(private)
_glimpl_buffer_init_empty :: proc(buffer: ^Buffer, desc: Buffer_Descriptor) {
    buffer.type = _glimpl_buffertype_to_glenum(desc.type)
    buffer.usage = _glimpl_bufferusage_to_glenum(desc.usage)

    gl.CreateBuffers(1, ([^]u32)(&(buffer.buffer_handle)))
}

@(private)
_glimpl_buffer_init_with_data :: proc(buffer: ^Buffer, desc: Buffer_Descriptor, data: []byte) {
    _glimpl_buffer_init_empty(buffer, desc)
    _glimpl_buffer_set_data(buffer^, data)
}

@(private)
_glimpl_buffer_set_data :: proc(buffer: Buffer, data: []byte) {
    gl.NamedBufferData((u32)(buffer.buffer_handle), len(data), raw_data(data), buffer.usage)
}

@(private)
_glimpl_buffer_free :: proc(buffer: ^Buffer) {
    gl.DeleteBuffers(1, ([^]u32)(&buffer.buffer_handle))

    buffer.buffer_handle = INVALID_HANDLE
}

@(private)
_glimpl_buffertype_to_glenum :: proc(type: Buffer_Type) -> u32 {
    switch type {
        case .Index_Buffer: return gl.ELEMENT_ARRAY_BUFFER
        case .Vertex_Buffer: return gl.ARRAY_BUFFER
    }

    return 0
}

@(private)
_glimpl_bufferusage_to_glenum :: proc(type: Buffer_Usage) -> u32 {
    switch type {
        case .Static_Draw: return gl.STATIC_DRAW
        case .Dynamic_Draw: return gl.DYNAMIC_DRAW
    }

    return 0
}