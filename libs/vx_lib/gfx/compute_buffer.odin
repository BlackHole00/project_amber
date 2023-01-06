package vx_lib_gfx

import "core:log"
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

Compute_Buffer :: struct {
    cl_mem: cl.mem,
    size: uint,
    is_opengl: bool,
}

computebuffer_init_empty :: proc(buffer: ^Compute_Buffer, desc: Compute_Buffer_Descriptor) {
    buffer.size = desc.size
    buffer.is_opengl = false

    flags: cl.mem_flags
    switch desc.type {
        case .Read_Only:    flags |= cl.MEM_READ_ONLY
        case .Write_Only:   flags |= cl.MEM_WRITE_ONLY
        case .Read_Write:   flags |= cl.MEM_READ_WRITE
    }

    if buffer.cl_mem = cl.CreateBuffer(OPENCL_CONTEXT.cl_context, flags, desc.size, nil, nil); buffer.cl_mem == nil {
        panic("Could not create an opencl buffer")
    }
}

computebuffer_init_with_data :: proc(buffer: ^Compute_Buffer, desc: Compute_Buffer_Descriptor, data: []$T, mode: Data_Handling_Mode) {
    if (uint)(size_of(T) * len(data)) < desc.size do panic("The size of data must be greater or equal than the size of the buffer.")

    buffer.size = desc.size
    buffer.is_opengl = false

    flags: cl.mem_flags
    switch desc.type {
        case .Read_Only:     flags |= cl.MEM_READ_ONLY
        case .Write_Only:    flags |= cl.MEM_WRITE_ONLY
        case .Read_Write:    flags |= cl.MEM_READ_WRITE
    }
    switch mode {
        case .Host_Memory:   flags |= cl.MEM_COPY_HOST_PTR
        case .GPU_Memory: {
            flags |= cl.MEM_ALLOC_HOST_PTR
            flags |= cl.MEM_COPY_HOST_PTR
        }
    }

    if buffer.cl_mem = cl.CreateBuffer(OPENCL_CONTEXT.cl_context, flags, desc.size, raw_data(data), nil); buffer.cl_mem == nil {
        panic("Could not create an opencl buffer")
    }
}

computebuffer_init_from_abstractbuffer :: proc(buffer: ^Compute_Buffer, desc: Compute_Buffer_Descriptor, abstract_buffer: Abstract_Buffer, mode: Data_Handling_Mode) {
    computebuffer_init_with_data(buffer, desc, abstract_buffer.data, mode)
}

computebuffer_init_from_buffer :: proc(buffer: ^Compute_Buffer, desc: Compute_Buffer_Descriptor, gfx_buffer: Buffer) {
    buffer.size = desc.size
    buffer.is_opengl = true

    flags: cl.mem_flags
    switch desc.type {
        case .Read_Only:     flags |= cl.MEM_READ_ONLY
        case .Write_Only:    flags |= cl.MEM_WRITE_ONLY
        case .Read_Write:    flags |= cl.MEM_READ_WRITE
    }

    if buffer.cl_mem = cl.CreateFromGlBuffer(OPENCL_CONTEXT.cl_context, flags, gfx_buffer.buffer_handle, nil); buffer.cl_mem == nil {
        panic("Could not create an opencl buffer")
    }
}

computebuffer_init_from_texture :: proc(buffer: ^Compute_Buffer, desc: Compute_Buffer_Descriptor, texture: Texture) {
    buffer.size = desc.size
    buffer.is_opengl = true

    flags: cl.mem_flags
    switch desc.type {
        case .Read_Only:     flags |= cl.MEM_READ_ONLY
        case .Write_Only:    flags |= cl.MEM_WRITE_ONLY
        case .Read_Write:    flags |= cl.MEM_READ_WRITE
    }

    err: i32
    if buffer.cl_mem = cl.CreateFromGLTexture(
        OPENCL_CONTEXT.cl_context, 
        flags, 
        texturetype_to_glenum(texture.type), 
        0, 
        texture.texture_handle, 
        &err,
    ); buffer.cl_mem == nil {
        switch err {
            case cl.INVALID_VALUE: log.error("INVALID_VALUE")
            case cl.INVALID_MIP_LEVEL: log.error("INVALID_MIP_LEVEL")
            case cl.INVALID_GL_OBJECT: log.error("INVALID_GL_OBJECT")
            case cl.INVALID_IMAGE_FORMAT_DESCRIPTOR: log.error("INVALID_IMAGE_FORMAT_DESCRIPTOR")
            case cl.INVALID_OPERATION: log.error("INVALID_OPERATION")
            case cl.OUT_OF_RESOURCES: log.error("OUT_OF_RESOURCES")
        }

        panic("Could not create an opencl buffer")
    }
}

computebuffer_init :: proc { computebuffer_init_empty, computebuffer_init_with_data, computebuffer_init_from_buffer, computebuffer_init_from_texture }

computebuffer_free :: proc(buffer: Compute_Buffer) {
    cl.ReleaseMemObject(buffer.cl_mem)
}

computebuffer_set_data :: proc(buffer: ^Compute_Buffer, input: []$T) {
    if (uint)(size_of(T) * len(input)) > buffer.size do panic("The size of the input is greater than the size of the buffer.")

    computebuffer_glacquire(buffer)
    defer computebuffer_glrelease(buffer)

    // Blocking, for now...
    cl.EnqueueWriteBuffer(OPENCL_CONTEXT.queue, buffer.cl_mem, true, 0, size_of(T) * len(input), raw_data(input), 0, nil, nil)
}

computebuffer_get_data :: proc(buffer: ^Compute_Buffer, output: []$T) {
    if (uint)(size_of(T) * len(output)) > buffer.size do panic("The size of the input is lesser than the size of the buffer.")

    computebuffer_glacquire(buffer)
    defer computebuffer_glrelease(buffer)

    // Blocking, for now...
    cl.EnqueueReadBuffer(OPENCL_CONTEXT.queue, buffer.cl_mem, true, 0, size_of(T) * len(output), raw_data(output), 0, nil, nil)
}

///////////////////////////////////////////////////////////////////////////////

@(private)
computebuffer_glacquire :: proc(buffer: ^Compute_Buffer) {
    if buffer.is_opengl {
        event: cl.event
        if cl.EnqueueAcquireGLObjects(OPENCL_CONTEXT.queue, 1, &buffer.cl_mem, 0, nil, &event) != cl.SUCCESS do panic("Could not acquire gl objects.")
        if cl.WaitForEvents(1, &event) != cl.SUCCESS do panic("Could not wait for events.")
    }
}

@(private)
computebuffer_glrelease :: proc(buffer: ^Compute_Buffer) {
    if buffer.is_opengl {
        event: cl.event
        if cl.EnqueueReleaseGLObjects(OPENCL_CONTEXT.queue, 1, &buffer.cl_mem, 0, nil, &event) != cl.SUCCESS do panic("Could not release gl objects.")
        if cl.WaitForEvents(1, &event) != cl.SUCCESS do panic("Could not wait for events.")
    }
}