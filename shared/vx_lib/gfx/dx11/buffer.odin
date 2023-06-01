package vx_lib_gfx_dx11

import "core:mem"
import win "core:sys/windows"
import "vendor:directx/d3d11"
import "shared:vx_lib/gfx"
import bku "shared:vx_lib/gfx/backendutils"

_ :: mem

Buffer :: struct {
    dx11_buffer: ^d3d11.IBuffer,
    info: gfx.Buffer_Info,
    is_mapped: bool,
}

buffer_new_empty :: proc(descriptor: gfx.Buffer_Descriptor) -> (gfx.Buffer, gfx.Buffer_Creation_Error) {
    context = d3d11_default_context()

    buffer := new(Buffer)
    buffer.info = bku.bufferdescriptor_to_bufferinfo(descriptor)

    buffer.dx11_buffer = gen_dx11buffer_with_data(descriptor, nil, buffer.info.size)

    if buffer.dx11_buffer == nil {
        return (gfx.Buffer)(buffer), .Backend_Generic_Error
    }
    return (gfx.Buffer)(buffer), .Ok
}

buffer_new_with_data :: proc(descriptor: gfx.Buffer_Descriptor, data: []byte) -> (gfx.Buffer, gfx.Buffer_Creation_Error) {
    context = d3d11_default_context()

    buffer := new(Buffer)
    buffer.info = bku.bufferdescriptor_to_bufferinfo(descriptor)

    size: uint = len(data)
    if (size < buffer.info.size) {
        size = buffer.info.size
    }

    buffer.dx11_buffer = gen_dx11buffer_with_data(descriptor, &data[0], len(data))

    if buffer.dx11_buffer == nil {
        return (gfx.Buffer)(buffer), .Backend_Generic_Error
    }
    return (gfx.Buffer)(buffer), .Ok
}

buffer_free :: proc(buffer: gfx.Buffer) {
    context = d3d11_default_context()
    buffer := (^Buffer)(buffer)

    buffer.dx11_buffer->Release()

    free(buffer)
}

buffer_set_data :: proc(buffer: gfx.Buffer, data: []byte) -> gfx.Buffer_Set_Data_Error {
    buffer := (^Buffer)(buffer)

    desc := bku.bufferinfo_to_bufferdescriptor(buffer.info)
    tmp_buffer := gen_dx11buffer_with_data(desc, &data[0], buffer.info.size)
    defer tmp_buffer->Release()
    if tmp_buffer == nil {
        return .Backend_Generic_Error
    }

    CONTEXT_INSTANCE.device_context->CopyResource(buffer.dx11_buffer, tmp_buffer)

    return .Ok
}

buffer_map :: proc(buffer: gfx.Buffer, mode: gfx.Buffer_Map_Mode) -> ([]byte, gfx.Buffer_Map_Error) {
    buffer := (^Buffer)(buffer)

    if buffer.is_mapped do return nil, .Alreay_Mapped
    buffer.is_mapped = true

    desc := bku.bufferinfo_to_bufferdescriptor(buffer.info)
    dx11_desc := get_cpuaccessible_dx11BUFFERDESC(desc, buffer.info.size)
    map_buffer: ^d3d11.IBuffer
    CONTEXT_INSTANCE.device->CreateBuffer(
        &dx11_desc, 
        nil,
        &map_buffer,
    )
    map_insert(&CONTEXT_INSTANCE.map_buffer_associations, buffer.dx11_buffer, Map_Data {
        buffer = map_buffer,
        map_mode = mode,
    })
    if map_buffer == nil {
        return nil, .Backend_Generic_Error
    }

    if mode == .Read || mode == .Read_Write {
        CONTEXT_INSTANCE.device_context->CopyResource(map_buffer, buffer.dx11_buffer)
    }

    map_type := d3d11.MAP.READ
    #partial switch mode {
        case .Write: map_type = .WRITE
        case .Read_Write: map_type = .READ_WRITE
    }

    mapped_resource: d3d11.MAPPED_SUBRESOURCE
    if CONTEXT_INSTANCE.device_context->Map(
        map_buffer, 
        0, 
        map_type, 
        d3d11.MAP_FLAGS {},
        &mapped_resource,
    ) != win.NO_ERROR {
        return nil, .Backend_Generic_Error
    }

    return mem.byte_slice(mapped_resource.pData, mapped_resource.DepthPitch), .Ok
}

buffer_unmap :: proc(buffer: gfx.Buffer) -> gfx.Buffer_Unmap_Error {
    buffer := (^Buffer)(buffer)

    if !buffer.is_mapped do return .Not_Mapped

    _, map_data := delete_key(&CONTEXT_INSTANCE.map_buffer_associations, buffer.dx11_buffer)
    defer map_data.buffer->Release()

    CONTEXT_INSTANCE.device_context->Unmap(map_data.buffer, 0)

    if map_data.map_mode == .Write || map_data.map_mode == .Read_Write {
        CONTEXT_INSTANCE.device_context->CopyResource(buffer.dx11_buffer, map_data.buffer)
    }

    buffer.is_mapped = false

    return .Ok
}

buffer_resize :: proc(buffer: gfx.Buffer, size: uint) -> gfx.Buffer_Resize_Error {
    buffer := (^Buffer)(buffer)

    old_buffer := buffer.dx11_buffer
    new_buffer: ^d3d11.IBuffer = nil

    if buf := bku.gfxbufferallocator_get_buffer(size, buffer.info.usage); buf != nil {
        new_buffer = (^d3d11.IBuffer)(buf.?.raw_buffer)
    } else {
        desc := bku.bufferinfo_to_bufferdescriptor(buffer.info)
        new_buffer = gen_dx11buffer_with_data(desc, nil, size)

        if new_buffer == nil {
            return .Backend_Generic_Error
        }
    }

    CONTEXT_INSTANCE.device_context->CopySubresourceRegion(
        (^d3d11.IResource)(new_buffer), 
        0, 
        0, 
        0, 
        0, 
        old_buffer, 
        0, 
        nil,
    )
    buffer.dx11_buffer = new_buffer

    bku.gfxbufferallocator_register_buffer(bku.GfxBufferAllocator_Entry {
        raw_buffer = old_buffer,
        size = buffer.info.size,
        usage = buffer.info.usage,
    })

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
gen_dx11buffer_with_data :: proc(descriptor: gfx.Buffer_Descriptor, ptr: rawptr, size: uint) -> (buffer: ^d3d11.IBuffer) {
    dx11_desc := get_default_dx11BUFFERDESC(descriptor, size)

    subresource_data: ^d3d11.SUBRESOURCE_DATA = nil
    if ptr != nil {
        subresource_data = &d3d11.SUBRESOURCE_DATA {
            pSysMem = ptr,
            SysMemPitch = (u32)(size),
        }
    }

    CONTEXT_INSTANCE.device->CreateBuffer(
        &dx11_desc, 
        subresource_data,
        &buffer,
    )

    return
}

@(private)
get_default_dx11BUFFERDESC :: proc(descriptor: gfx.Buffer_Descriptor, size: uint) -> d3d11.BUFFER_DESC {
    usage := d3d11.USAGE.IMMUTABLE
    #partial switch descriptor.usage {
        case .Default: usage = d3d11.USAGE.DEFAULT
        case .Dynamic: usage = d3d11.USAGE.DYNAMIC
    }

    bind_flags: d3d11.BIND_FLAGS = {}
    #partial switch descriptor.type {
        case .Index_Buffer: incl(&bind_flags, d3d11.BIND_FLAG.INDEX_BUFFER)
        case .Vertex_Buffer: incl(&bind_flags, d3d11.BIND_FLAG.VERTEX_BUFFER)
        case .Uniform_Buffer: incl(&bind_flags, d3d11.BIND_FLAG.CONSTANT_BUFFER)
    }

    return d3d11.BUFFER_DESC {
        ByteWidth = (u32)(size),
        Usage = usage,
        BindFlags = bind_flags,
        CPUAccessFlags = d3d11.CPU_ACCESS_FLAGS {},
        MiscFlags = d3d11.RESOURCE_MISC_FLAGS {},
        StructureByteStride = 0,
    }
}

@(private)
get_cpuaccessible_dx11BUFFERDESC :: proc(descriptor: gfx.Buffer_Descriptor, size: uint) -> d3d11.BUFFER_DESC {
    usage := d3d11.USAGE.DEFAULT

    cpu_access_flags: d3d11.CPU_ACCESS_FLAGS = {}
    #partial switch descriptor.cpu_access {
        case .Read: incl(&cpu_access_flags, d3d11.CPU_ACCESS_FLAG.READ)
        case .Write: incl(&cpu_access_flags, d3d11.CPU_ACCESS_FLAG.WRITE)
        case .Read_Write: {
            incl(&cpu_access_flags, d3d11.CPU_ACCESS_FLAG.READ)
            incl(&cpu_access_flags, d3d11.CPU_ACCESS_FLAG.WRITE)
        }
    }

    return d3d11.BUFFER_DESC {
        ByteWidth = (u32)(size),
        Usage = usage,
        BindFlags = d3d11.BIND_FLAGS { d3d11.BIND_FLAG.UNORDERED_ACCESS },
        CPUAccessFlags = cpu_access_flags,
        MiscFlags = d3d11.RESOURCE_MISC_FLAGS {},
        StructureByteStride = 0,
    }
}