package vx_lib_gfx_gl4

import gl "vendor:OpenGL"
import "shared:vx_lib/gfx"

Buffer_Impl :: struct {
    buffer_handle: u32,
    type: gfx.Buffer_Type,
    usage: gfx.Buffer_Usage,

    // Used only if is an index buffer.
    index_type: gfx.Index_Type,

    // Used only if it is an uniform buffer.
    uniform_bindings_point: uint,
}
gl4Buffer :: ^Buffer_Impl

buffer_new_empty :: proc(desc: gfx.Buffer_Descriptor) -> gl4Buffer {
    buffer := new(Buffer_Impl, CONTEXT.gl_allocator)

    buffer.type = desc.type
    buffer.usage = desc.usage
    buffer.index_type = desc.index_type

    gl.CreateBuffers(1, &buffer.buffer_handle)

    if buffer.type == .Uniform_Buffer do buffer.uniform_bindings_point = glcontext_get_available_ubo_bind_point()

    return buffer
}

buffer_new_with_data :: proc(desc: gfx.Buffer_Descriptor, data: rawptr, data_size: uint) -> gl4Buffer {
    buffer := buffer_new_empty(desc)
    buffer_set_data(buffer, data, data_size)

    return buffer
}

buffer_set_data :: proc(buffer: gl4Buffer, data: rawptr, data_size: uint) {
    gl.NamedBufferData(buffer.buffer_handle, (int)(data_size), data, bufferusage_to_glenum(buffer.usage))

    if buffer.type == .Uniform_Buffer {
        buffer_non_dsa_bind(buffer)
        gl.BindBufferBase(buffertype_to_glenum(buffer.type), (u32)(buffer.uniform_bindings_point), buffer.buffer_handle)
        when ODIN_DEBUG do buffer_non_dsa_unbind(buffer.type)
    }
}

buffer_free :: proc(buffer: gl4Buffer) {
    gl.DeleteBuffers(1, &buffer.buffer_handle)

    free(buffer, CONTEXT.gl_allocator)
}

@(private)
buffer_non_dsa_bind :: proc(buffer: gl4Buffer) {
    gl.BindBuffer(buffertype_to_glenum(buffer.type), buffer.buffer_handle)
}

@(private)
buffer_non_dsa_unbind :: proc(type: gfx.Buffer_Type) {
    when ODIN_DEBUG do gl.BindBuffer(buffertype_to_glenum(type), 0)
}

@(private)
buffertype_to_glenum :: proc(type: gfx.Buffer_Type) -> u32 {
    switch type {
        case .Index_Buffer: return gl.ELEMENT_ARRAY_BUFFER
        case .Vertex_Buffer: return gl.ARRAY_BUFFER
        case .Uniform_Buffer: return gl.UNIFORM_BUFFER,
    }

    return 0
}

@(private)
bufferusage_to_glenum :: proc(type: gfx.Buffer_Usage) -> u32 {
    switch type {
        case .Static_Draw: return gl.STATIC_DRAW
        case .Dynamic_Draw: return gl.DYNAMIC_DRAW
    }

    return 0
}

@(private)
indextype_to_glenum :: proc(type: gfx.Index_Type) -> u32 {
    switch type {
        case .U8: return gl.UNSIGNED_BYTE
        case .U16: return gl.UNSIGNED_SHORT
        case .U32: return gl.UNSIGNED_INT
    }

    return 0
}
