package vx_lib_gfx

Compute_Buffer_Type :: enum {
    Read_Only,
    Write_Only,
    Read_Write,
}

Data_Handling_Mode :: enum {
    // OpenCL will use the pointer provided by the application to store data.
    Host_Memory,
    // OpenCL will create a new buffer in the gpu memory that is accessible also by the CPU (using PCIe).
    GPU_Memory,
}

Compute_Buffer_Descriptor :: struct {
    type: Compute_Buffer_Type,
    size: uint,
}

Compute_Buffer :: distinct rawptr

computebuffer_new_empty :: proc(desc: Compute_Buffer_Descriptor) -> Compute_Buffer {
    return GFXPROCS_INSTANCE.computebuffer_new_empty(desc)
}

computebuffer_new_with_data :: proc(desc: Compute_Buffer_Descriptor, data: []$T, mode: Data_Handling_Mode) -> Compute_Buffer {
    when ODIN_DEBUG do if (uint)(len(data) * size_of(T)) < desc.size do panic("The size of data must be greater or equal than the size of the buffer.")

    return GFXPROCS_INSTANCE.computebuffer_new_with_data(desc, raw_data(data), size_of(T) * len(data), mode)
}

computebuffer_new_from_abstractbuffer :: proc(desc: Compute_Buffer_Descriptor, abstract_buffer: Abstract_Buffer, mode: Data_Handling_Mode) -> Compute_Buffer {
    when ODIN_DEBUG do if abstactbuffer_get_size(abstract_buffer) < desc.size do panic("The size of data must be greater or equal than the size of the buffer.")

    return computebuffer_new_with_data(desc, abstract_buffer.data, mode)
}

computebuffer_new_from_buffer :: proc(desc: Compute_Buffer_Descriptor, gfx_buffer: Buffer) -> Compute_Buffer {
    return GFXPROCS_INSTANCE.computebuffer_new_from_buffer(desc, gfx_buffer)
}

computebuffer_new_from_texture :: proc(desc: Compute_Buffer_Descriptor, texture: Texture) -> Compute_Buffer {
    return GFXPROCS_INSTANCE.computebuffer_new_from_texture(desc, texture)
}

computebuffer_new :: proc { computebuffer_new_empty, computebuffer_new_with_data, computebuffer_new_from_buffer, computebuffer_new_from_texture }

computebuffer_free :: proc(buffer: Compute_Buffer) {
    GFXPROCS_INSTANCE.computebuffer_free(buffer)
}

computebuffer_update_bound_texture :: proc(buffer: Compute_Buffer, texture: Texture) {
    when ODIN_DEBUG do if !computebuffer_is_gfx(buffer) do panic("Only works with compute gfx buffers.")

    GFXPROCS_INSTANCE.computebuffer_update_bound_texture(buffer, texture)
}

computebuffer_update_bound_buffer :: proc(buffer: Compute_Buffer, gfx_buffer: Buffer) {
    when ODIN_DEBUG do if !computebuffer_is_gfx(buffer) do panic("Only works with compute gfx buffers.")

    GFXPROCS_INSTANCE.computebuffer_update_bound_buffer(buffer, gfx_buffer)
}

computebuffer_set_data :: proc(buffer: Compute_Buffer, input: []$T, blocking := false, sync: ^Sync = nil) {
    if (uint)(len(input) * size_of(T)) > computebuffer_get_size(buffer) do panic("The size of the input is greater than the size of the buffer.")

    GFXPROCS_INSTANCE.computebuffer_set_data(buffer, raw_data(input), size_of(T) * len(input), blocking, sync)
}

computebuffer_get_data :: proc(buffer: Compute_Buffer, output: []$T, blocking := false, sync: ^Sync = nil) {
    if (uint)(len(output) * size_of(T)) < computebuffer_get_size(buffer) do panic("The size of the output is lesser than the size of the buffer.")

    GFXPROCS_INSTANCE.computebuffer_get_data(buffer, raw_data(output), size_of(T) * len(output), blocking, sync)
}

computebuffer_get_buffertype :: proc(buffer: Compute_Buffer) -> Compute_Buffer_Type {
    return GFXPROCS_INSTANCE.computebuffer_get_buffertype(buffer)
}

computebuffer_is_gfx :: proc(buffer: Compute_Buffer) -> bool {
    return GFXPROCS_INSTANCE.computebuffer_is_gfx(buffer)
}

computebuffer_get_size :: proc(buffer: Compute_Buffer) -> uint {
    return GFXPROCS_INSTANCE.computebuffer_get_size(buffer)
}