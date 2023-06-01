package vx_lib_gfx_gl4

import "core:mem"
import gl "vendor:OpenGL"
import "shared:vx_lib/gfx"
import bku "shared:vx_lib/gfx/backendutils"

_ :: mem


// TODO: implement uniform blocks (Uniform buffers)
Buffer :: struct {
    opengl_buffer: u32,
    info: gfx.Buffer_Info,
    is_mapped: bool,
}

buffer_new_empty :: proc(descriptor: gfx.Buffer_Descriptor) -> (gfx.Buffer, gfx.Buffer_Creation_Error) {
    context = gl4_default_context()

    buffer := new(Buffer)
    buffer.info = bku.bufferdescriptor_to_bufferinfo(descriptor)

    buffer.opengl_buffer = gen_openglbuffer_with_data(descriptor.usage, nil, descriptor.size.?)

    return (gfx.Buffer)(buffer), .Ok
}

buffer_new_with_data :: proc(descriptor: gfx.Buffer_Descriptor, data: []byte) -> (gfx.Buffer, gfx.Buffer_Creation_Error) {
    context = gl4_default_context()

    buffer := new(Buffer)
    buffer.info = bku.bufferdescriptor_to_bufferinfo(descriptor)

    size: uint = len(data)
    if descriptor.size != nil && descriptor.size.? > size {
        size = descriptor.size.?
        buffer.info.size = size
    }

    buffer.opengl_buffer = gen_openglbuffer_with_data(descriptor.usage, &data[0], descriptor.size.?)

    return (gfx.Buffer)(buffer), .Ok
}

buffer_free :: proc(buffer: gfx.Buffer) {
    context = gl4_default_context()

    buffer := (^Buffer)(buffer)
    gl.DeleteBuffers(1, &buffer.opengl_buffer)

    free(buffer)
}

buffer_set_data :: proc(buffer: gfx.Buffer, data: []byte) -> gfx.Buffer_Set_Data_Error {
    buffer := (^Buffer)(buffer)
    gl.NamedBufferSubData(buffer.opengl_buffer, 0, len(data), &data[0])

    return .Ok
}

buffer_map :: proc(buffer: gfx.Buffer, mode: gfx.Buffer_Map_Mode) -> ([]byte, gfx.Buffer_Map_Error) {
    buffer := (^Buffer)(buffer)

    if buffer.is_mapped do return nil, .Alreay_Mapped

    access: u32 = 0
    switch mode {
        case .Read: access = gl.READ_ONLY
        case .Write: access = gl.WRITE_ONLY
        case .Read_Write: access = gl.READ_WRITE
    }
    data_ptr := gl.MapNamedBuffer(buffer.opengl_buffer, access)

    if data_ptr == nil do return nil, .Backend_Generic_Error

    buffer.is_mapped = true

    return mem.byte_slice(data_ptr, buffer.info.size), .Ok
}

buffer_unmap :: proc(buffer: gfx.Buffer) -> gfx.Buffer_Unmap_Error {
    buffer := (^Buffer)(buffer)

    if !buffer.is_mapped do return .Not_Mapped
    if !gl.UnmapNamedBuffer(buffer.opengl_buffer) do return .Backend_Generic_Error

    buffer.is_mapped = false

    return .Ok
}

buffer_resize :: proc(buffer: gfx.Buffer, size: uint) -> gfx.Buffer_Resize_Error {
    buffer := (^Buffer)(buffer)

    gl_usage: u32 = gl.STATIC_DRAW
    if buffer.info.usage == .Dynamic do gl_usage = gl.DYNAMIC_DRAW

    gl.NamedBufferData(buffer.opengl_buffer, (int)(size), nil, gl_usage)

    buffer.info.size = size

    return .Ok
}

buffer_get_type :: proc(buffer: gfx.Buffer) -> gfx.Buffer_Type {
    buffer := (^Buffer)(buffer)
    return buffer.info.type
}

buffer_get_usage :: proc(buffer: gfx.Buffer) -> gfx.Buffer_Usage {
    buffer := (^Buffer)(buffer)
    return buffer.info.usage
}

buffer_get_allocation_mode :: proc(buffer: gfx.Buffer) -> gfx.Buffer_Allocation_Mode {
    buffer := (^Buffer)(buffer)
    return buffer.info.allocation_mode
}

buffer_get_cpu_access :: proc(buffer: gfx.Buffer) -> gfx.Buffer_Cpu_Access {
    buffer := (^Buffer)(buffer)
    return buffer.info.cpu_access
}

buffer_get_size :: proc(buffer: gfx.Buffer) -> uint {
    buffer := (^Buffer)(buffer)
    return buffer.info.size
}

buffer_is_compute :: proc(buffer: gfx.Buffer) -> bool {
    buffer := (^Buffer)(buffer)
    return buffer.info.is_compute
}

@(private)
gen_openglbuffer_with_data :: proc(usage: gfx.Buffer_Usage, ptr: rawptr, size: uint) -> (buffer: u32) {
    gl.CreateBuffers(1, &buffer)

    if usage == .Static {
        gl.NamedBufferStorage(buffer, (int)(size), ptr, gl.DYNAMIC_STORAGE_BIT)
    } else {
        gl_usage: u32 = gl.STATIC_DRAW
        if usage == .Dynamic do gl_usage = gl.DYNAMIC_DRAW

        gl.NamedBufferData(buffer, (int)(size), ptr, gl_usage)
    }

    return
}