package vx_lib_gfx

import gl "vendor:OpenGL"

Renderbuffer_Descriptor :: struct {
    internal_format: u32,
    buffer_size: [2]uint,
}

Renderbuffer_Impl :: struct {
    renderbuffer_handle: u32,
    internal_format: u32,
    buffer_size: [2]uint,
}
Renderbuffer :: ^Renderbuffer_Impl

renderbuffer_new :: proc(desc: Renderbuffer_Descriptor) -> Renderbuffer {
    buffer := new(Renderbuffer_Impl, OPENGL_CONTEXT.gl_allocator)

    gl.GenRenderbuffers(1, &buffer.renderbuffer_handle)
    buffer.internal_format = desc.internal_format

    renderbuffer_set_size(buffer, desc.buffer_size)

    return buffer
}

renderbuffer_set_size :: proc(buffer: Renderbuffer, buffer_size: [2]uint) {
    buffer.buffer_size = buffer_size

    renderbuffer_bind(buffer)
    gl.RenderbufferStorage(gl.RENDERBUFFER, buffer.internal_format, (i32)(buffer_size.x), (i32)(buffer_size.y))
}

renderbuffer_free :: proc(buffer: Renderbuffer) {
    gl.DeleteRenderbuffers(1, &buffer.renderbuffer_handle)

    free(buffer, OPENGL_CONTEXT.gl_allocator)
}

@(private)
renderbuffer_bind :: proc(buffer: Renderbuffer) {
    gl.BindRenderbuffer(gl.RENDERBUFFER, buffer.renderbuffer_handle)
}
