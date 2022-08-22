package vx_lib_gfx

import "core:mem"

Abstract_Buffer :: struct {
    data: []byte,
}

abstractbuffer_init_empty :: proc(buffer: ^Abstract_Buffer) {
    buffer.data = make([]byte, 0)
}

abstractbuffer_init_with_data :: abstractbuffer_set_data

abstractbuffer_init :: proc { abstractbuffer_init_empty, abstractbuffer_init_with_data }

abstractbuffer_set_data :: proc(buffer: ^Abstract_Buffer, data: []$T) {
    buffer.data = make([]byte, len(data) * size_of(T))
    mem.copy_non_overlapping(&buffer.data[0], &data[0], len(data) * size_of(T))
}

abstractbuffer_free :: proc(buffer: Abstract_Buffer) {
    delete(buffer.data)
}
