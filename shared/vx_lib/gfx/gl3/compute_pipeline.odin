package vx_lib_gfx_gl3

import "core:strings"
import "core:slice"
import "core:log"
import cl "shared:OpenCL"
import "shared:vx_lib/gfx"

Compute_Pipeline_Impl :: struct {
    kernel: cl.kernel,

    dimensions: uint,
    global_work_sizes: []uint,
    local_work_sizes: []uint,
}
Gl3Compute_Pipeline :: ^Compute_Pipeline_Impl

computepipeline_new :: proc(desc: gfx.Compute_Pipeline_Descriptor) -> Gl3Compute_Pipeline {
    pipeline := new(Compute_Pipeline_Impl, CONTEXT.gl_allocator)

    if len(desc.global_work_sizes) != (int)(desc.dimensions) do panic("The length of work sizes must be the same as the dimensions.")
    if len(desc.local_work_sizes)  != (int)(desc.dimensions) do panic("The length of work sizes must be the same as the dimensions.")

    csource := strings.clone_to_cstring(desc.source, context.allocator)
    defer delete(csource)
    ckernel := strings.clone_to_cstring(desc.entry_point, context.allocator)
    defer delete(ckernel)

    program: cl.program
    if program = cl.CreateProgramWithSource(CONTEXT.cl_context, 1, &csource, nil, nil); program == nil do panic("Could not create a compute program.")
    if cl.BuildProgram(program, 1, &CONTEXT.device, nil, nil, nil) != cl.SUCCESS {
        build_status: cl.build_status = ---
        cl.GetProgramBuildInfo(program, CONTEXT.device, cl.PROGRAM_BUILD_STATUS, size_of(cl.build_status), &build_status, nil)

        log_len: uint = ---
        cl.GetProgramBuildInfo(program, CONTEXT.device, cl.PROGRAM_BUILD_LOG, 0, nil, &log_len)
        info_log := make([]u8, log_len + 1, CONTEXT.gl_allocator)
        cl.GetProgramBuildInfo(program, CONTEXT.device, cl.PROGRAM_BUILD_LOG, log_len, raw_data(info_log), nil)

        log.error("Compute Shader Compilation Failed:")
        log.error("\t", string(info_log))

        delete(info_log, CONTEXT.gl_allocator)

        panic("Could not compile shaders.")
    }
    if pipeline.kernel = cl.CreateKernel(program, ckernel, nil); pipeline.kernel == nil do panic("Could not create a kernel.")

    cl.ReleaseProgram(program)

    pipeline.global_work_sizes = slice.clone(desc.global_work_sizes)
    pipeline.local_work_sizes = slice.clone(desc.local_work_sizes)
    pipeline.dimensions = desc.dimensions

    return pipeline
}

computepipeline_free :: proc(pipeline: Gl3Compute_Pipeline) {
    cl.ReleaseKernel(pipeline.kernel)

    delete(pipeline.global_work_sizes)
    delete(pipeline.local_work_sizes)

    free(pipeline, CONTEXT.gl_allocator)
}

computepipeline_compute :: proc(pipeline: Gl3Compute_Pipeline, bindings: Gl3Compute_Bindings, sync: ^gfx.Sync = nil) {
    for element, i in &bindings.elements {
        switch v in &element {
            case gfx.Compute_Bindings_Raw_Element: cl.SetKernelArg(pipeline.kernel, (u32)(i), v.size, v.data)
            case gfx.Compute_Bindings_Buffer_Element: {
                computebuffer_glacquire((Gl3Compute_Buffer)(v.buffer))
                if cl.SetKernelArg(pipeline.kernel, (u32)(i), size_of(cl.mem), &(Gl3Compute_Buffer)(v.buffer).cl_mem) != cl.SUCCESS do panic("Could not set kernel argument.")
            }
            case gfx.Compute_Bindings_U32_Element: cl.SetKernelArg(pipeline.kernel, (u32)(i), size_of(u32), &v.value)
            case gfx.Compute_Bindings_I32_Element: cl.SetKernelArg(pipeline.kernel, (u32)(i), size_of(i32), &v.value)
            case gfx.Compute_Bindings_F32_Element: cl.SetKernelArg(pipeline.kernel, (u32)(i), size_of(f32), &v.value)
            case gfx.Compute_Bindings_2F32_Element: cl.SetKernelArg(pipeline.kernel, (u32)(i), size_of([2]f32), &v.value[0])
        }
    }

    local_size: uint
    cl.GetKernelWorkGroupInfo(pipeline.kernel, CONTEXT.device, cl.KERNEL_WORK_GROUP_SIZE, size_of(uint), &local_size, nil)
    for size in &pipeline.local_work_sizes do if local_size < size do size = local_size

    event: cl.event = ---
    if err := cl.EnqueueNDRangeKernel(CONTEXT.queue, pipeline.kernel, (u32)(pipeline.dimensions), nil, raw_data(pipeline.global_work_sizes), raw_data(pipeline.local_work_sizes), 0, nil, &event); err != cl.SUCCESS {
        panic("Could not enqueue a compute operation.")
    }

    // In Sync: Using the buffers used for computation before the end of the computing is an error.
    // cl.WaitForEvents(1, &event)
    // cl.Flush(CONTEXT.queue)
    // for element in &bindings.elements {
    //     #partial switch v in &element {
    //         case Compute_Bindings_Buffer_Element: computebuffer_glrelease(v.buffer)
    //     }
    // }
    tmp := cldispatchsync_new(event, bindings)
    if sync == nil do gfx.sync_await(tmp)
    else do sync^ = tmp
}

computepipeline_set_local_work_size :: proc(pipeline: Gl3Compute_Pipeline, size: []uint) {
    for s, i in size {
        pipeline.local_work_sizes[i] = s
        pipeline.global_work_sizes[i] = get_optimal_global_size(pipeline.global_work_sizes[i], s)
    }
}

computepipeline_set_global_work_size :: proc(pipeline: Gl3Compute_Pipeline, size: []uint) {
    for s, i in size do pipeline.global_work_sizes[i] = get_optimal_global_size(s, pipeline.local_work_sizes[i])
}

@(private)
get_optimal_global_size :: proc(desired_size: uint, logical_size: uint) -> (size: uint) {
    for size < desired_size do size += logical_size
    return
}