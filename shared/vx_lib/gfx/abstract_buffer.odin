package vx_lib_gfx

import "core:mem"

// An Abstract_Buffer is a representation of a buffer in normal memory. It is 
// usually used as a temporary buffer for data before uploading it to the GPU.
Abstract_Buffer :: struct {
    data: []byte,
    allocator: mem.Allocator,
}

abstractbuffer_init_empty :: proc(buffer: ^Abstract_Buffer, allocator := context.allocator) {
    buffer.allocator = allocator

    buffer.data = make([]byte, 0, allocator)
}

abstractbuffer_init_with_data :: proc(buffer: ^Abstract_Buffer, data: []$T, allocator := context.allocator) {
    buffer.allocator = allocator
    
    buffer.data = make([]byte, len(data) * size_of(T), buffer.allocator)
    if len(data) != 0 do mem.copy_non_overlapping(&buffer.data[0], &data[0], len(data) * size_of(T))
}

abstractbuffer_init :: proc { abstractbuffer_init_empty, abstractbuffer_init_with_data }

// Copies the contents of data into the abstract buffer.
abstractbuffer_set_data :: proc(buffer: ^Abstract_Buffer, data: []$T) {
    delete(buffer.data, buffer.allocator)

    buffer.data = make([]byte, len(data) * size_of(T), buffer.allocator)
    if len(data) != 0 do mem.copy_non_overlapping(&buffer.data[0], &data[0], len(data) * size_of(T))
}

// Takes ownership of the data slice. The slice will be freed when 
// abstractbuffer_free is called.  
// The user should not use the data slice anymore.  
// Use this function if the data slice will not be needed and if a copy is not 
// necessary.
abstractbuffer_acquire_data :: proc(buffer: ^Abstract_Buffer, data: []$T, allocator := context.allocator) {
    delete(buffer.data, buffer.allocator)

    buffer.allocator = allocator
    buffer.data = transmute([]byte)(data)
}

abstractbuffer_clear :: proc(buffer: ^Abstract_Buffer) {
    abstractbuffer_set_data(buffer, []byte {})
}

abstractbuffer_get_data_as :: proc(buffer: ^Abstract_Buffer, $type: typeid) -> (data: []type) {
    raw_data: [^]type = ([^]type)(&buffer.data[0])
    return raw_data[: size_of(byte) * len(buffer.data) / size_of(type)]
}

abstractbuffer_free :: proc(buffer: Abstract_Buffer) {
    delete(buffer.data, buffer.allocator)
}

abstactbuffer_get_size :: proc(buffer: Abstract_Buffer) -> uint {
    return size_of(byte) * len(buffer.data)
}
