package vx_lib_gfx

import "core:strings"
import "core:slice"
import cl "shared:OpenCL"

Compute_Pipeline_Descriptor :: struct {
    source: string,
    entry_point: string,

    dimensions: uint,
    global_work_sizes: []uint,
    local_work_sizes: []uint,
}

Compute_Pipeline_Impl :: struct {
    kernel: cl.kernel,

    dimensions: uint,
    global_work_sizes: []uint,
    local_work_sizes: []uint,
}
Compute_Pipeline :: ^Compute_Pipeline_Impl

computepipeline_new :: proc(desc: Compute_Pipeline_Descriptor) -> Compute_Pipeline {
    pipeline := new(Compute_Pipeline_Impl, OPENCL_CONTEXT.cl_allocator)

    if len(desc.global_work_sizes) != (int)(desc.dimensions) do panic("The length of work sizes must be the same as the dimensions.")
    if len(desc.local_work_sizes)  != (int)(desc.dimensions) do panic("The length of work sizes must be the same as the dimensions.")

    csource := strings.clone_to_cstring(desc.source, context.allocator)
    defer delete(csource)
    ckernel := strings.clone_to_cstring(desc.entry_point, context.allocator)
    defer delete(ckernel)

    program: cl.program
    if program = cl.CreateProgramWithSource(OPENCL_CONTEXT.cl_context, 1, &csource, nil, nil); program == nil do panic("Could not create a compute program.")
    if cl.BuildProgram(program, 1, &OPENCL_CONTEXT.device, nil, nil, nil) != cl.SUCCESS do panic("Could not build a compute program.")
    if pipeline.kernel = cl.CreateKernel(program, ckernel, nil); pipeline.kernel == nil do panic("Could not create a kernel.")

    cl.ReleaseProgram(program)

    pipeline.global_work_sizes = slice.clone(desc.global_work_sizes)
    pipeline.local_work_sizes = slice.clone(desc.local_work_sizes)
    pipeline.dimensions = desc.dimensions

    return pipeline
}

computepipeline_free :: proc(pipeline: Compute_Pipeline) {
    cl.ReleaseKernel(pipeline.kernel)

    delete(pipeline.global_work_sizes)
    delete(pipeline.local_work_sizes)

    free(pipeline, OPENCL_CONTEXT.cl_allocator)
}

computepipeline_compute :: proc(pipeline: Compute_Pipeline, bindings: Compute_Bindings) {
    for element, i in &bindings.elements {
        switch v in &element {
            case Compute_Bindings_Raw_Element: cl.SetKernelArg(pipeline.kernel, (u32)(i), v.size, v.data)
            case Compute_Bindings_Buffer_Element: {
                computebuffer_glacquire(v.buffer)
                if cl.SetKernelArg(pipeline.kernel, (u32)(i), size_of(cl.mem), &v.buffer.cl_mem) != cl.SUCCESS do panic("Could not set kernel argument.")
            }
            case Compute_Bindings_U32_Element: cl.SetKernelArg(pipeline.kernel, (u32)(i), size_of(u32), &v.value)
            case Compute_Bindings_I32_Element: cl.SetKernelArg(pipeline.kernel, (u32)(i), size_of(i32), &v.value)
        }
    }

    local_size: uint
    cl.GetKernelWorkGroupInfo(pipeline.kernel, OPENCL_CONTEXT.device, cl.KERNEL_WORK_GROUP_SIZE, size_of(uint), &local_size, nil)
    for size in &pipeline.local_work_sizes do if local_size < size do size = local_size

    if err := cl.EnqueueNDRangeKernel(OPENCL_CONTEXT.queue, pipeline.kernel, (u32)(pipeline.dimensions), nil, raw_data(pipeline.global_work_sizes), raw_data(pipeline.local_work_sizes), 0, nil, nil); err != cl.SUCCESS {
        panic("Could not enqueue a compute operation.")
    }

    // Blocking, for now...
    cl.Flush(OPENCL_CONTEXT.queue)

    for element in &bindings.elements {
        #partial switch v in &element {
            case Compute_Bindings_Buffer_Element: computebuffer_glrelease(v.buffer)
        }
    }
}