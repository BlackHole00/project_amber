package vx_lib_gfx

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

Buffer_Info :: Buffer_Descriptor

Buffer :: distinct rawptr

buffer_new_empty :: proc(descriptor: Buffer_Descriptor) -> (Buffer, Buffer_Creation_Error) {
    if descriptor.size == nil do return nil, .Invalid_Size

    unimplemented()
}

buffer_new_with_data :: proc(descriptor: Buffer_Descriptor, data: $T/[]$U) -> (Buffer, Buffer_Creation_Error) {
    if descriptor.size != nil && descriptor.size.? != len(data) * size_of(U) {
        log.warn("Descriptor size and data size do not match. Using the bigger one.")
    }

    unimplemented()
}

buffer_new :: proc { buffer_new_empty, buffer_new_with_data }

buffer_free :: proc(buffer: Buffer) {
    unimplemented()
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

    unimplemented()
}

buffer_map :: proc(buffer: Buffer, mode: Buffer_Map_Mode) -> ([]byte, Buffer_Map_Error) {
    if buffer_get_usage(buffer) == .Static {
        return nil, .Static_Buffer
    }
    if mode == .Read_Write && buffer_get_usage(buffer) == .Dynamic {
        return nil, .Illegal_Map_Mode
    }

    unimplemented()
}

buffer_unmap :: proc(buffer: Buffer) -> Buffer_Unmap_Error {
    unimplemented()
}

buffer_resize :: proc(buffer: Buffer, size: uint) -> Buffer_Resize_Error {
    if buffer_get_usage(buffer) == .Static {
        return .Static_Buffer
    }

    unimplemented()
}

buffer_get_type :: proc(buffer: Buffer) -> Buffer_Type {
    unimplemented()
}

buffer_get_usage :: proc(buffer: Buffer) -> Buffer_Usage {
    unimplemented()
}

buffer_get_allocation_mode :: proc(buffer: Buffer) -> Buffer_Allocation_Mode {
    unimplemented()
}

buffer_get_size :: proc(buffer: Buffer) -> uint {
    unimplemented()
}

buffer_is_compute :: proc(buffer: Buffer) -> bool {
    unimplemented()
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
