package vx_lib_gfx

import gl "vendor:OpenGL"

Render_Buffer_Descriptor :: struct {
    internal_format: u32,
    buffer_size: [2]uint,
}

Render_Buffer :: struct {
    renderbuffer_handle: u32,
    internal_format: u32,
    buffer_size: [2]uint,
}

renderbuffer_init :: proc(buffer: ^Render_Buffer, desc: Render_Buffer_Descriptor) {
    gl.GenRenderbuffers(1, &buffer.renderbuffer_handle)
    buffer.internal_format = desc.internal_format

    renderbuffer_set_size(buffer, desc.buffer_size)
}

renderbuffer_set_size :: proc(buffer: ^Render_Buffer, buffer_size: [2]uint) {
    buffer.buffer_size = buffer_size

    renderbuffer_bind(buffer^)
    gl.RenderbufferStorage(gl.RENDERBUFFER, buffer.internal_format, (i32)(buffer_size.x), (i32)(buffer_size.y))
}

renderbuffer_free :: proc(buffer: ^Render_Buffer) {
    gl.DeleteRenderbuffers(1, &buffer.renderbuffer_handle)

    buffer.renderbuffer_handle = INVALID_HANDLE
}

/**************************************************************************************************
***************************************************************************************************
**************************************************************************************************/

@(private)
renderbuffer_bind :: proc(buffer: Render_Buffer) {
    gl.BindRenderbuffer(gl.RENDERBUFFER, buffer.renderbuffer_handle)
}
