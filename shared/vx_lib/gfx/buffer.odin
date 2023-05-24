package vx_lib_gfx

import "core:mem"

_ :: mem

Buffer_Creation_Error :: enum {
    Ok,
    Invalid_Size,
    Out_Of_Memory,
    Backend_Generic_Error,
}

Buffer_Set_Data_Error :: enum {
    Ok,
    Allocation_Failed,
    Buffer_Too_Small,
    Static_Buffer,
    Backend_Generic_Error,
}

Buffer_Resize_Error :: enum {
    Ok,
    Invalid_Size,
    Static_Buffer,
    Out_Of_Memory,
    Backend_Generic_Error,
}

Buffer_Map_Error :: enum {
    Ok,
    Static_Buffer,
    Illegal_Map_Mode,
    Alreay_Mapped,
    Backend_Generic_Error,
}

Buffer_Unmap_Error :: enum {
    Ok,
    Not_Mapped,
    Backend_Generic_Error,
}

Buffer_Map_Mode :: enum {
    Read,
    Write,
    Read_Write,
}

Buffer_Type :: enum {
    Vertex_Buffer,
    Index_Buffer,
    Uniform_Buffer,
}

Buffer_Usage :: enum {
    Default,
    Static,
    Dynamic,
}

Buffer_Allocation_Mode :: enum {
    Static,
    Dynamic,
}

Buffer_Descriptor :: struct {
    type: Buffer_Type,
    usage: Buffer_Usage,
    allocation_mode: Buffer_Allocation_Mode,
    size: Maybe(uint),
    is_compute: bool,
}

Buffer_Info :: struct {
    type: Buffer_Type,
    usage: Buffer_Usage,
    allocation_mode: Buffer_Allocation_Mode,
    size: uint,
    is_compute: bool,
}

Buffer :: distinct rawptr

INVALID_BUFFER: Buffer = nil

buffer_new_empty :: proc(descriptor: Buffer_Descriptor) -> (Buffer, Buffer_Creation_Error) {
    if descriptor.size == nil do return nil, .Invalid_Size

    return CONTEXT_INSTANCE.buffer_new_empty(descriptor)
}

buffer_new_with_data :: proc(descriptor: Buffer_Descriptor, data: $T/[]$U) -> (Buffer, Buffer_Creation_Error) {
    context = gfx_default_context()
    
    if descriptor.size != nil && descriptor.size.? != len(data) * size_of(U) {
        log.warn("Descriptor size and data size do not match. Using the bigger one.")
    }

    return CONTEXT_INSTANCE.buffer_new_with_data(descriptor, mem.slice_data_cast([]byte, data))
}

buffer_new :: proc { buffer_new_empty, buffer_new_with_data }

buffer_free :: proc(buffer: Buffer) {
    CONTEXT_INSTANCE.buffer_free(buffer)
}

// TODO: make async
buffer_set_data :: proc(buffer: Buffer, data: $T/[]$U) -> Buffer_Set_Data_Error {
    if buffer_get_usage(buffer) == .Static {
        return .Static_Buffer
    }

    if buffer_get_size(buffer) < len(data) * size_of(U) {
        if buffer_get_allocation_mode(buffer) == .Static {
            return .Buffer_Too_Small
        }

        if buffer_resize(buffer, len(data) * size_of(U)) != .Ok {
            return .Allocation_Failed
        }
    }

    return CONTEXT_INSTANCE.buffer_set_data(buffer, mem.slice_data_cast([]byte, data))
}

buffer_map :: proc(buffer: Buffer, mode: Buffer_Map_Mode) -> ([]byte, Buffer_Map_Error) {
    if buffer_get_usage(buffer) == .Static {
        return nil, .Static_Buffer
    }
    if mode == .Read_Write && buffer_get_usage(buffer) == .Dynamic {
        return nil, .Illegal_Map_Mode
    }

    return CONTEXT_INSTANCE.buffer_map(buffer, mode)
}

buffer_unmap :: proc(buffer: Buffer) -> Buffer_Unmap_Error {
    return CONTEXT_INSTANCE.buffer_unmap(buffer)
}

// Does not keep stored data.
buffer_resize :: proc(buffer: Buffer, size: uint) -> Buffer_Resize_Error {
    if buffer_get_usage(buffer) == .Static || buffer_get_allocation_mode(buffer) == .Static {
        return .Static_Buffer
    }

    return CONTEXT_INSTANCE.buffer_resize(buffer, size)
}

buffer_get_type :: proc(buffer: Buffer) -> Buffer_Type {
    return CONTEXT_INSTANCE.buffer_get_type(buffer)
}

buffer_get_usage :: proc(buffer: Buffer) -> Buffer_Usage {
    return CONTEXT_INSTANCE.buffer_get_usage(buffer)
}

buffer_get_allocation_mode :: proc(buffer: Buffer) -> Buffer_Allocation_Mode {
    return CONTEXT_INSTANCE.buffer_get_allocation_mode(buffer)
}

buffer_get_size :: proc(buffer: Buffer) -> uint {
    return CONTEXT_INSTANCE.buffer_get_size(buffer)
}

buffer_is_compute :: proc(buffer: Buffer) -> bool {
    return CONTEXT_INSTANCE.buffer_is_compute(buffer)
}

buffer_get_info :: proc(buffer: Buffer) -> Buffer_Info {
    return Buffer_Info {
        type            = buffer_get_type(buffer),
        usage           = buffer_get_usage(buffer),
        allocation_mode = buffer_get_allocation_mode(buffer),
        size            = buffer_get_size(buffer),
        is_compute      = buffer_is_compute(buffer),
    }
}
