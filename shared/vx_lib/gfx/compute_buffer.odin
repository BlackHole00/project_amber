package vx_lib_gfx

//import "core:log"
import cl "shared:OpenCL"

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

Compute_Buffer_Impl :: struct {
    cl_mem: cl.mem,
    flags: cl.mem_flags,
    size: uint,
    is_opengl: bool,
}
Compute_Buffer :: ^Compute_Buffer_Impl

computebuffer_new_empty :: proc(desc: Compute_Buffer_Descriptor) -> Compute_Buffer {
    buffer := new(Compute_Buffer_Impl, OPENCL_CONTEXT.cl_allocator)

    buffer.size = desc.size
    buffer.is_opengl = false
    switch desc.type {
        case .Read_Only:    buffer.flags |= cl.MEM_READ_ONLY
        case .Write_Only:   buffer.flags |= cl.MEM_WRITE_ONLY
        case .Read_Write:   buffer.flags |= cl.MEM_READ_WRITE
    }

    if buffer.cl_mem = cl.CreateBuffer(OPENCL_CONTEXT.cl_context, buffer.flags, desc.size, nil, nil); buffer.cl_mem == nil {
        panic("Could not create an opencl buffer")
    }

    return buffer
}

computebuffer_new_with_data :: proc(desc: Compute_Buffer_Descriptor, data: []$T, mode: Data_Handling_Mode) -> Compute_Buffer {
    if (uint)(size_of(T) * len(data)) < desc.size do panic("The size of data must be greater or equal than the size of the buffer.")

    buffer := new(Compute_Buffer_Impl, OPENCL_CONTEXT.cl_allocator)

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

    if buffer.cl_mem = cl.CreateBuffer(OPENCL_CONTEXT.cl_context, buffer.flags, desc.size, raw_data(data), nil); buffer.cl_mem == nil {
        panic("Could not create an opencl buffer")
    }

    return buffer
}

computebuffer_new_from_abstractbuffer :: proc(desc: Compute_Buffer_Descriptor, abstract_buffer: Abstract_Buffer, mode: Data_Handling_Mode) -> Compute_Buffer {
    return computebuffer_new_with_data(desc, abstract_buffer.data, mode)
}

computebuffer_new_from_buffer :: proc(desc: Compute_Buffer_Descriptor, gfx_buffer: Buffer) -> Compute_Buffer {
    buffer := new(Compute_Buffer_Impl, OPENCL_CONTEXT.cl_allocator)
    buffer.is_opengl = true

    switch desc.type {
        case .Read_Only:     buffer.flags |= cl.MEM_READ_ONLY
        case .Write_Only:    buffer.flags |= cl.MEM_WRITE_ONLY
        case .Read_Write:    buffer.flags |= cl.MEM_READ_WRITE
    }

    if buffer.cl_mem = cl.CreateFromGlBuffer(OPENCL_CONTEXT.cl_context, buffer.flags, gfx_buffer.buffer_handle, nil); buffer.cl_mem == nil {
        panic("Could not create an opencl buffer")
    }

    return buffer
}

computebuffer_new_from_texture :: proc(desc: Compute_Buffer_Descriptor, texture: Texture) -> Compute_Buffer {
    buffer := new(Compute_Buffer_Impl, OPENCL_CONTEXT.cl_allocator)
    buffer.is_opengl = true

    switch desc.type {
        case .Read_Only:     buffer.flags |= cl.MEM_READ_ONLY
        case .Write_Only:    buffer.flags |= cl.MEM_WRITE_ONLY
        case .Read_Write:    buffer.flags |= cl.MEM_READ_WRITE
    }

    if buffer.cl_mem = cl.CreateFromGLTexture(
        OPENCL_CONTEXT.cl_context, 
        buffer.flags, 
        texturetype_to_glenum(texture.type), 
        0, 
        texture.texture_handle, 
        nil,
    ); buffer.cl_mem == nil do panic("Could not create an opencl buffer")

    return buffer
}

computebuffer_new :: proc { computebuffer_new_empty, computebuffer_new_with_data, computebuffer_new_from_buffer, computebuffer_new_from_texture }

computebuffer_free :: proc(buffer: Compute_Buffer) {
    cl.ReleaseMemObject(buffer.cl_mem)

    free(buffer, OPENCL_CONTEXT.cl_allocator)
}

computebuffer_update_bound_texture :: proc(buffer: Compute_Buffer, texture: Texture) {
    when ODIN_DEBUG do if !buffer.is_opengl do panic("Only works with compute opengl buffers.")

    cl.ReleaseMemObject(buffer.cl_mem)

    if buffer.cl_mem = cl.CreateFromGLTexture(
        OPENCL_CONTEXT.cl_context, 
        buffer.flags, 
        texturetype_to_glenum(texture.type), 
        0, 
        texture.texture_handle, 
        nil,
    ); buffer.cl_mem == nil do panic("Could not create an opencl buffer")
}

computebuffer_update_bound_buffer :: proc(buffer: Compute_Buffer, gfx_buffer: Buffer) {
    when ODIN_DEBUG do if !buffer.is_opengl do panic("Only works with compute opengl buffers.")

    cl.ReleaseMemObject(buffer.cl_mem)

    if buffer.cl_mem = cl.CreateFromGlBuffer(OPENCL_CONTEXT.cl_context, buffer.flags, gfx_buffer.buffer_handle, nil); buffer.cl_mem == nil {
        panic("Could not create an opencl buffer")
    }
}

computebuffer_set_data :: proc(buffer: Compute_Buffer, input: []$T, blocking := false) -> Sync {
    if (uint)(size_of(T) * len(input)) > buffer.size do panic("The size of the input is greater than the size of the buffer.")

    computebuffer_glacquire(buffer)
    defer computebuffer_glrelease(buffer)

    event: cl.event
    cl.EnqueueWriteBuffer(OPENCL_CONTEXT.queue, buffer.cl_mem, blocking, 0, size_of(T) * len(input), raw_data(input), 0, nil, &event)

    if !blocking do return cleventsync_new(event, .Compute_Buffer_Upload)
    else do return nil
}

computebuffer_get_data :: proc(buffer: Compute_Buffer, output: []$T, blocking := false) -> Sync {
    if (uint)(size_of(T) * len(output)) > buffer.size do panic("The size of the input is lesser than the size of the buffer.")

    computebuffer_glacquire(buffer)
    defer computebuffer_glrelease(buffer)

    event: cl.event
    cl.EnqueueReadBuffer(OPENCL_CONTEXT.queue, buffer.cl_mem, blocking, 0, size_of(T) * len(output), raw_data(output), 0, nil, &event)

    if !blocking do return cleventsync_new(event, .Compute_Buffer_Upload)
    else do return nil
}

///////////////////////////////////////////////////////////////////////////////

@(private)
computebuffer_glacquire :: proc(buffer: Compute_Buffer) {
    if buffer.is_opengl {
        event: cl.event
        if cl.EnqueueAcquireGLObjects(OPENCL_CONTEXT.queue, 1, &buffer.cl_mem, 0, nil, &event) != cl.SUCCESS do panic("Could not acquire gl objects.")
        if cl.WaitForEvents(1, &event) != cl.SUCCESS do panic("Could not wait for events.")
    }
}

@(private)
computebuffer_glrelease :: proc(buffer: Compute_Buffer, events_to_wait: []cl.event = {}) {
    if buffer.is_opengl {
        event: cl.event
        if cl.EnqueueReleaseGLObjects(OPENCL_CONTEXT.queue, 1, &buffer.cl_mem, (u32)(len(events_to_wait)), raw_data(events_to_wait), &event) != cl.SUCCESS do panic("Could not release gl objects.")
        // if res := cl.EnqueueReleaseGLObjects(OPENCL_CONTEXT.queue, 1, &buffer.cl_mem, 0, nil, &event); res != cl.SUCCESS {
        //     log.fatal(res)
        //     panic("Could not release gl objects.")
        // }
        if cl.WaitForEvents(1, &event) != cl.SUCCESS do panic("Could not wait for events.")
    }
}