package vx_lib_gfx_GL4

import cl "shared:OpenCL"
import "shared:vx_lib/gfx"

Compute_Buffer_Impl :: struct {
    type: gfx.Compute_Buffer_Type,
    cl_mem: cl.mem,
    flags: cl.mem_flags,
    size: uint,
    is_opengl: bool,
}
GL4Compute_Buffer :: ^Compute_Buffer_Impl

computebuffer_new_empty :: proc(desc: gfx.Compute_Buffer_Descriptor) -> GL4Compute_Buffer {
    buffer := new(Compute_Buffer_Impl, CONTEXT.gl_allocator)

    buffer.type = desc.type
    buffer.size = desc.size
    buffer.is_opengl = false
    switch desc.type {
        case .Read_Only:    buffer.flags |= cl.MEM_READ_ONLY
        case .Write_Only:   buffer.flags |= cl.MEM_WRITE_ONLY
        case .Read_Write:   buffer.flags |= cl.MEM_READ_WRITE
    }

    if buffer.cl_mem = cl.CreateBuffer(CONTEXT.cl_context, buffer.flags, desc.size, nil, nil); buffer.cl_mem == nil {
        panic("Could not create an opencl buffer")
    }

    return buffer
}

computebuffer_new_with_data :: proc(desc: gfx.Compute_Buffer_Descriptor, data: rawptr, data_size: uint, mode: gfx.Data_Handling_Mode) -> GL4Compute_Buffer {
    buffer := new(Compute_Buffer_Impl, CONTEXT.gl_allocator)

    buffer.type = desc.type
    buffer.size = desc.size
    buffer.is_opengl = false

    switch desc.type {
        case .Read_Only:     buffer.flags |= cl.MEM_READ_ONLY
        case .Write_Only:    buffer.flags |= cl.MEM_WRITE_ONLY
        case .Read_Write:    buffer.flags |= cl.MEM_READ_WRITE
    }
    switch mode {
        case .Host_Memory:   buffer.flags |= cl.MEM_COPY_HOST_PTR
        case .GPU_Memory: {
            buffer.flags |= cl.MEM_ALLOC_HOST_PTR
            buffer.flags |= cl.MEM_COPY_HOST_PTR
        }
    }

    if buffer.cl_mem = cl.CreateBuffer(CONTEXT.cl_context, buffer.flags, desc.size, data, nil); buffer.cl_mem == nil {
        panic("Could not create an opencl buffer")
    }

    return buffer
}

computebuffer_new_from_buffer :: proc(desc: gfx.Compute_Buffer_Descriptor, gfx_buffer: GL4Buffer) -> GL4Compute_Buffer {
    buffer := new(Compute_Buffer_Impl, CONTEXT.gl_allocator)
    buffer.is_opengl = true

    buffer.type = desc.type

    switch desc.type {
        case .Read_Only:     buffer.flags |= cl.MEM_READ_ONLY
        case .Write_Only:    buffer.flags |= cl.MEM_WRITE_ONLY
        case .Read_Write:    buffer.flags |= cl.MEM_READ_WRITE
    }

    if buffer.cl_mem = cl.CreateFromGLBuffer(CONTEXT.cl_context, buffer.flags, gfx_buffer.buffer_handle, nil); buffer.cl_mem == nil {
        panic("Could not create an opencl buffer")
    }

    return buffer
}

computebuffer_new_from_texture :: proc(desc: gfx.Compute_Buffer_Descriptor, texture: GL4Texture) -> GL4Compute_Buffer {
    buffer := new(Compute_Buffer_Impl, CONTEXT.gl_allocator)
    buffer.is_opengl = true

    buffer.type = desc.type

    switch desc.type {
        case .Read_Only:     buffer.flags |= cl.MEM_READ_ONLY
        case .Write_Only:    buffer.flags |= cl.MEM_WRITE_ONLY
        case .Read_Write:    buffer.flags |= cl.MEM_READ_WRITE
    }

    if buffer.cl_mem = cl.CreateFromGLTexture(
        CONTEXT.cl_context, 
        buffer.flags, 
        texturetype_to_glenum(texture.type), 
        0, 
        texture.texture_handle, 
        nil,
    ); buffer.cl_mem == nil do panic("Could not create an opencl buffer")

    return buffer
}

computebuffer_free :: proc(buffer: GL4Compute_Buffer) {
    cl.ReleaseMemObject(buffer.cl_mem)

    free(buffer, CONTEXT.gl_allocator)
}

computebuffer_update_bound_texture :: proc(buffer: GL4Compute_Buffer, texture: GL4Texture) {
    cl.ReleaseMemObject(buffer.cl_mem)

    if buffer.cl_mem = cl.CreateFromGLTexture(
        CONTEXT.cl_context, 
        buffer.flags, 
        texturetype_to_glenum(texture.type), 
        0, 
        texture.texture_handle, 
        nil,
    ); buffer.cl_mem == nil do panic("Could not create an opencl buffer")
}

computebuffer_update_bound_buffer :: proc(buffer: GL4Compute_Buffer, gfx_buffer: GL4Buffer) {
    cl.ReleaseMemObject(buffer.cl_mem)

    if buffer.cl_mem = cl.CreateFromGLBuffer(CONTEXT.cl_context, buffer.flags, gfx_buffer.buffer_handle, nil); buffer.cl_mem == nil {
        panic("Could not create an opencl buffer")
    }
}

computebuffer_set_data :: proc(buffer: GL4Compute_Buffer, input: rawptr, input_size: uint, blocking := false, sync: ^gfx.Sync = nil) {
    computebuffer_glacquire(buffer)
    defer computebuffer_glrelease(buffer)

    event: cl.event
    cl.EnqueueWriteBuffer(CONTEXT.queue, buffer.cl_mem, blocking, 0, input_size, input, 0, nil, &event)

    if !blocking && sync != nil do sync^ = cleventsync_new(event, .Compute_Buffer_Upload)
}

computebuffer_get_data :: proc(buffer: GL4Compute_Buffer, output: rawptr, output_size: uint, blocking := false, sync: ^gfx.Sync = nil) {
    computebuffer_glacquire(buffer)
    defer computebuffer_glrelease(buffer)

    event: cl.event
    cl.EnqueueReadBuffer(CONTEXT.queue, buffer.cl_mem, blocking, 0, output_size, output, 0, nil, &event)

    if !blocking && sync != nil do sync^ = cleventsync_new(event, .Compute_Buffer_Download)
}

computebuffer_get_buffertype :: proc(buffer: GL4Compute_Buffer) -> gfx.Compute_Buffer_Type {
    return buffer.type
}

computebuffer_is_gfx :: proc(buffer: GL4Compute_Buffer) -> bool {
    return buffer.is_opengl
}

computebuffer_get_size :: proc(buffer: GL4Compute_Buffer) -> uint {
    return buffer.size
}

///////////////////////////////////////////////////////////////////////////////

@(private)
computebuffer_glacquire :: proc(buffer: GL4Compute_Buffer) {
    if buffer.is_opengl {
        event: cl.event
        if cl.EnqueueAcquireGLObjects(CONTEXT.queue, 1, &buffer.cl_mem, 0, nil, &event) != cl.SUCCESS do panic("Could not acquire gl objects.")
        if cl.WaitForEvents(1, &event) != cl.SUCCESS do panic("Could not wait for events.")
    }
}

@(private)
computebuffer_glrelease :: proc(buffer: GL4Compute_Buffer, events_to_wait: []cl.event = {}) {
    if buffer.is_opengl {
        event: cl.event
        if cl.EnqueueReleaseGLObjects(CONTEXT.queue, 1, &buffer.cl_mem, (u32)(len(events_to_wait)), raw_data(events_to_wait), &event) != cl.SUCCESS do panic("Could not release gl objects.")
        // if res := cl.EnqueueReleaseGLObjects(CONTEXT.queue, 1, &buffer.cl_mem, 0, nil, &event); res != cl.SUCCESS {
        //     log.fatal(res)
        //     panic("Could not release gl objects.")
        // }
        if cl.WaitForEvents(1, &event) != cl.SUCCESS do panic("Could not wait for events.")
    }
}