package vx_lib_gfx

import gl "vendor:OpenGL"

Buffer_Descriptor :: struct {
    gl_type: u32,
    gl_usage: u32,
}

Buffer :: struct {
    buffer_handle: u32,
    gl_type: u32,
    gl_usage: u32,
}

buffer_init_empty :: proc(buffer: ^Buffer, desc: Buffer_Descriptor) {
    buffer.gl_type = desc.gl_type
    buffer.gl_usage = desc.gl_usage

    gl.GenBuffers(1, &buffer.buffer_handle)
}

buffer_init_with_data :: proc(buffer: ^Buffer, desc: Buffer_Descriptor, data: []$T) {
    buffer_init_empty(buffer, desc)

    buffer_add_data(buffer^, data)
}

buffer_init :: proc { buffer_init_empty, buffer_init_with_data }

@(private)
buffer_bind :: proc(buffer: Buffer) {
    gl.BindBuffer(buffer.gl_type, buffer.buffer_handle)
}

buffer_add_data :: proc(buffer: Buffer, data: []$T) {
    tmp := len(data) * size_of(T)

    buffer_bind(buffer)
    gl.BufferData(buffer.gl_type, tmp, raw_data(data), buffer.gl_usage)
}

buffer_free :: proc(buffer: ^Buffer) {
    gl.DeleteBuffers(1, &buffer.buffer_handle)

    buffer.buffer_handle = INVALID_HANDLE
}
