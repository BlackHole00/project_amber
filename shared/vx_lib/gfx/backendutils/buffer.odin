package vx_lib_gfx_backendutils

import "shared:vx_lib/gfx"

bufferdescriptor_to_bufferinfo :: proc(descriptor: gfx.Buffer_Descriptor) -> (info: gfx.Buffer_Info) {
    info.usage = descriptor.usage
    info.type = descriptor.type
    info.allocation_mode = descriptor.allocation_mode
    info.cpu_access = descriptor.cpu_access
    info.is_compute = descriptor.is_compute
    if descriptor.size == nil do info.size = 0
    else do info.size = descriptor.size.?

    return
}

bufferinfo_to_bufferdescriptor :: proc(info: gfx.Buffer_Info) -> (descriptor: gfx.Buffer_Descriptor) {
    descriptor.usage = info.usage
    descriptor.type = info.type
    descriptor.allocation_mode = info.allocation_mode
    descriptor.cpu_access = info.cpu_access
    descriptor.is_compute = info.is_compute
    descriptor.size = info.size

    return
}