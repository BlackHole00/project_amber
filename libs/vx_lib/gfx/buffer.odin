package vx_lib_gfx

import "core:mem"

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
    buffer_handle: Gfx_Handle,
    type: Buffer_Type,
    usage: Buffer_Usage,
    size: uint,
}

buffer_init_empty :: proc(buffer: ^Buffer, desc: Buffer_Descriptor) {
    GFX_PROCS.buffer_init_empty(buffer, desc)
}

buffer_init_with_data :: proc(buffer: ^Buffer, desc: Buffer_Descriptor, data: []$T) {
    GFX_PROCS.buffer_init_with_data(buffer, desc, mem.slice_to_bytes(data))
}

buffer_init_from_abstractbuffer :: proc(buffer: ^Buffer, desc: Buffer_Descriptor, abstractbuffer: Abstract_Buffer) {
    buffer_init_with_data(buffer, desc, abstractbuffer.data)
}

buffer_init :: proc { buffer_init_empty, buffer_init_with_data }

buffer_set_data :: proc(buffer: ^Buffer, data: []$T) {
    GFX_PROCS.buffer_set_data(buffer, mem.slice_to_bytes(data))
}

buffer_free :: proc(buffer: ^Buffer) {
    GFX_PROCS.buffer_free(buffer)
}

