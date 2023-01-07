package vx_lib_gfx

import "core:log"
import "core:mem"
import cl "shared:OpenCL"
import core "shared:vx_core"

OpenCL_Context :: struct {
    cl_allocator: mem.Allocator,

    device: cl.device_id,
    cl_context: cl.cl_context,
    queue: cl.command_queue,
}
OPENCL_CONTEXT: core.Cell(OpenCL_Context)

when ODIN_OS == .Windows {
    import win "core:sys/windows"

    foreign import Gl_Ctx "system:Opengl32.lib"

    @(default_calling_convention="c", link_prefix="wgl")
    foreign Gl_Ctx {
        @(private)
        GetCurrentContext :: proc() -> win.HGLRC ---
        @(private)
        GetCurrentDC :: proc() -> win.HDC ---
    }
} else 
when ODIN_OS == .Darwin {
    CGLContextObj :: distinct rawptr
    CGLShareGroupObj :: distinct rawptr

    foreign import Gl_Ctx "system:OpenGL.framework"

    @(default_calling_convention="c", link_prefix="CGL")
    foreign Gl_Ctx {
        @(private)
        GetCurrentContext :: proc() -> CGLContextObj ---
        @(private)
        GetShareGroup :: proc(ctx: CGLContextObj) -> CGLShareGroupObj ---
    }
} else {
    foreign import Gl_Ctx "system:GL"

    GLXContext :: distinct rawptr
    GLXDisplay :: distinct rawptr

    @(default_calling_convention="c", link_prefix="glX")
    foreign Gl_Ctx {
        @(private)
        GetCurrentContext :: proc() -> GLXContext ---
        @(private)
        GetCurrentDisplay :: proc() -> GLXDisplay ---
    }
}

opencl_init :: proc(cl_allocator: mem.Allocator) -> bool {
    core.cell_init(&OPENCL_CONTEXT)

    err: i32

    platform: cl.platform_id
    if cl.GetPlatformIDs(1, &platform, nil) != cl.SUCCESS do panic("Could not get the platform ID.")

    device := select_opencldevice(platform)
    if device == nil do return false
    else do OPENCL_CONTEXT.device = device.?

    when ODIN_OS == .Windows {
        properties := []cl.context_properties {
            cl.GL_CONTEXT_KHR, transmute(cl.context_properties)(GetCurrentContext()),
            cl.WGL_HDC_KHR, transmute(cl.context_properties)(GetCurrentDC()),
            cl.CONTEXT_PLATFORM, transmute(cl.context_properties)(platform),
            0,
        }
    } else when ODIN_OS == .Darwin {
        properties := []cl.context_properties {
            cl.CONTEXT_PROPERTY_USE_CGL_SHAREGROUP_APPLE, transmute(cl.context_properties)(GetShareGroup(GetCurrentContext())), 
            0, 
        }
    } else {
        properties := []cl.context_properties {
            cl.GL_CONTEXT_KHR, auto_cast GetCurrentContext(),
            cl.GLX_DISPLAY_KHR, auto_cast GetCurrentDisplay(),
            cl.CONTEXT_PLATFORM, transmute(cl.context_properties)(plaform),
            0,
        }
    }

    if OPENCL_CONTEXT.cl_context = cl.CreateContext(raw_data(properties), 1, &OPENCL_CONTEXT.device, nil, nil, &err); err != cl.SUCCESS do return false
    if OPENCL_CONTEXT.queue = cl.CreateCommandQueue(OPENCL_CONTEXT.cl_context, OPENCL_CONTEXT.device, 0, &err); err != cl.SUCCESS do return false

    if !test_opencl() {
        log.error("test_opencl() failed.")
        return false
    } else {
        log.info("test_opencl() succeded.")
    }

    OPENCL_CONTEXT.cl_allocator = cl_allocator

    return true
}

opencl_deinit :: proc(free_all_mem := false) {
    cl.ReleaseCommandQueue(OPENCL_CONTEXT.queue)
    cl.ReleaseContext(OPENCL_CONTEXT.cl_context)

    if free_all_mem do mem.free_all(OPENCL_CONTEXT.cl_allocator)
    core.cell_free(&OPENCL_CONTEXT)
}

print_opencl_deviceinfo :: proc(device: cl.device_id) {
    device_name_size: uint = ---
    cl.GetDeviceInfo(device, cl.DEVICE_NAME, 0, nil, &device_name_size)
    name := make([]u8, device_name_size)
    defer delete(name)
    cl.GetDeviceInfo(device, cl.DEVICE_NAME, device_name_size, raw_data(name), nil)

    log.info("\tptr:", device, ", name:", cstring(raw_data(name)))
}

select_opencldevice :: proc(platform: cl.platform_id) -> Maybe(cl.device_id) {
    device_count: u32 = ---
    if err := cl.GetDeviceIDs(platform, cl.DEVICE_TYPE_ALL, 0, nil, &device_count); err != cl.SUCCESS {
        switch err {
            case cl.INVALID_PLATFORM: log.info("INVALID_PLATFORM")
            case cl.INVALID_DEVICE_TYPE: log.info("INVALID_DEVICE_TYPE")
            case cl.INVALID_VALUE: log.info("INVALID_VALUE")
            case cl.DEVICE_NOT_FOUND: log.info("DEVICE_NOT_FOUND")
        }

        panic("Could not get device ids.")
    }

    devices := make([]cl.device_id, device_count)
    defer delete(devices)
    cl.GetDeviceIDs(platform, cl.DEVICE_TYPE_ALL, device_count, raw_data(devices), nil)

    preferred_device: cl.device_id
    device_compute_cores: u32 = 0 

    log.info("OpenCL devices: ")
    for device in devices {
        print_opencl_deviceinfo(device)

        device_type: cl.device_type
        cl.GetDeviceInfo(device, cl.DEVICE_TYPE, size_of(cl.device_type), &device_type, nil)

        if device_type == cl.DEVICE_TYPE_GPU {
            compute_cores: u32 = ---
            cl.GetDeviceInfo(device, cl.DEVICE_MAX_COMPUTE_UNITS, size_of(u32), &compute_cores, nil)
    
            if compute_cores > device_compute_cores {
                preferred_device = device
                device_compute_cores = compute_cores
            }
        }
    }
        
    if preferred_device == nil {
        return nil
    }
    log.info("Selected device:")
    print_opencl_deviceinfo(preferred_device)

    return preferred_device
}

test_opencl :: proc() -> bool {
    COUNT: u32 = 1024
    test_program := `
        __kernel void square(__global float* input, __global float* output, const unsigned int count) {
            int i = get_global_id(0);
        
            if (i < count) {
                output[i] = input[i] * input[i];
            }
        }
    `

    input_values := make([]f32, COUNT)
    defer delete(input_values)
    for value, i in &input_values do value = (f32)(i)

    output_values := make([]f32, COUNT)
    defer delete(output_values)

    input: Compute_Buffer
    computebuffer_init_with_data(&input, Compute_Buffer_Descriptor {
        type = .Read_Only,
        size = (uint)(size_of(f32) * COUNT),
    }, input_values, .GPU_Memory)
    defer computebuffer_free(input)

    output: Compute_Buffer
    computebuffer_init_empty(&output, Compute_Buffer_Descriptor {
        type = .Write_Only,
        size = (uint)(size_of(f32) * COUNT), 
    })
    defer computebuffer_free(output)

    pipeline: Compute_Pipeline
    computepipeline_init(&pipeline, Compute_Pipeline_Descriptor {
        source = test_program,
        entry_point = "square",
        dimensions = 1,
        global_work_sizes = []uint{ 1024 },
        local_work_sizes = []uint{ 256 },
    })
    defer computepipeline_free(pipeline)

    bindings: Compute_Bindings
    computebindings_init(&bindings, []Compute_Bindings_Element {
        Compute_Bindings_Buffer_Element {
            buffer = input,
        },
        Compute_Bindings_Buffer_Element {
            buffer = output,
        },
        Compute_Bindings_U32_Element {
            value = COUNT,
        },
    })
    
    computepipeline_compute(&pipeline, &bindings)

    computebuffer_get_data(&output, output_values)

    for output, i in output_values do if output != (f32)(i * i) do return false

    return true
}
