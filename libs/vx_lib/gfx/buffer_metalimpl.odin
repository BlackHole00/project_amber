//+build darwin

package vx_lib_gfx

when ODIN_OS == .Darwin {

import NS "vendor:darwin/Foundation"
import MTL "vendor:darwin/Metal"
import "core:mem"

@(private)
_metalimpl_buffer_init_empty :: proc(buffer: ^Buffer, desc: Buffer_Descriptor) {
    buffer.type = desc.type
    buffer.usage = desc.usage
    buffer.size = 0

    buffer.buffer_handle = _metalimpl_metalbuffer_to_buffer_handle(METAL_CONTEXT.device->newBuffer(0, {.StorageModeManaged}))
}

@(private)
_metalimpl_buffer_init_with_data :: proc(buffer: ^Buffer, desc: Buffer_Descriptor, data: []byte) {
    buffer.type = desc.type
    buffer.usage = desc.usage
    buffer.size = len(data)

    buffer.buffer_handle = _metalimpl_metalbuffer_to_buffer_handle(METAL_CONTEXT.device->newBufferWithSlice(data[:], {.StorageModeManaged}))
}

@(private)
_metalimpl_buffer_set_data :: proc(buffer: ^Buffer, data: []byte) {
    mtl_buffer := _metalimpl_bufferhandle_to_metalbuffer(buffer.buffer_handle)

    if buffer.size >= len(data) {
        data_ptr := mtl_buffer->contents()
        mem.copy(&data_ptr[0], &data[0], len(data))

        mtl_buffer->didModifyRange(NS.Range_Make(0, (NS.UInteger)(len(data))))
    } else {
        new_buffer: Buffer = ---
        _metalimpl_buffer_init_with_data(&new_buffer, Buffer_Descriptor {
            type = buffer.type,
            usage = buffer.usage,
        }, data)

        _metalimpl_buffer_free(buffer)

        buffer^ = new_buffer
    }
}

@(private)
_metalimpl_buffer_free :: proc(buffer: ^Buffer) {
    _metalimpl_bufferhandle_to_metalbuffer(buffer.buffer_handle)->release()

    buffer.buffer_handle = INVALID_HANDLE
}

_metalimpl_bufferhandle_to_metalbuffer :: proc(handle: Gfx_Handle) -> ^MTL.Buffer {
    return transmute(^MTL.Buffer)(handle)
}

@(private)
_metalimpl_metalbuffer_to_buffer_handle :: proc(buffer: ^MTL.Buffer) -> Gfx_Handle {
    return transmute(Gfx_Handle)(buffer)
}

}
