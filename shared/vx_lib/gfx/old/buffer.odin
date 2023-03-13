package vx_lib_gfx

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

// An abstraction over a plain OpenGL VBO or EBO. Like a OpenGl buffer, its 
// memory management is automatic, so it doesn't have a fixed size.
Buffer :: distinct rawptr

buffer_new_empty :: proc(desc: Buffer_Descriptor) -> Buffer {
    return GFXPROCS_INSTANCE.buffer_new_empty(desc)
}

buffer_new_with_data :: proc(desc: Buffer_Descriptor, data: []$T) -> Buffer {
    return GFXPROCS_INSTANCE.buffer_new_with_data(desc, raw_data(data), size_of(T) * len(data))
}

buffer_new_from_abstractbuffer :: proc(desc: Buffer_Descriptor, abstractbuffer: Abstract_Buffer) -> Buffer {
    buffer := buffer_new_empty(desc)
    buffer_set_data(buffer, abstractbuffer.data)

    return buffer
}

buffer_new :: proc { buffer_new_empty, buffer_new_with_data }

buffer_set_data :: proc(buffer: Buffer, data: []$T) {
    GFXPROCS_INSTANCE.buffer_set_data(buffer, raw_data(data), size_of(T) * len(data))
}

buffer_free :: proc(buffer: Buffer) {
    GFXPROCS_INSTANCE.buffer_free(buffer)
}

buffer_get_buffertype :: proc(buffer: Buffer) -> Buffer_Type {
    return GFXPROCS_INSTANCE.buffer_get_buffertype(buffer)
}

buffer_get_bufferusage :: proc(buffer: Buffer) -> Buffer_Usage {
    return GFXPROCS_INSTANCE.buffer_get_bufferusage(buffer)
}

buffer_get_indextype :: proc(buffer: Buffer) -> Index_Type {
    when ODIN_DEBUG do if buffer_get_buffertype(buffer) != .Index_Buffer do panic("buffer_get_indextype works only with index buffers")
    return GFXPROCS_INSTANCE.buffer_get_indextype(buffer)
}