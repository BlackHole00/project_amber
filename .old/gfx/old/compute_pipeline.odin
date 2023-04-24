package vx_lib_gfx

Compute_Pipeline_Descriptor :: struct {
    source: string,
    entry_point: string,

    dimensions: uint,
    global_work_sizes: []uint,
    local_work_sizes: []uint,
}

Compute_Pipeline :: distinct rawptr

computepipeline_new :: proc(desc: Compute_Pipeline_Descriptor) -> Compute_Pipeline {
    if len(desc.global_work_sizes) != (int)(desc.dimensions) do panic("The length of work sizes must be the same as the dimensions.")
    if len(desc.local_work_sizes)  != (int)(desc.dimensions) do panic("The length of work sizes must be the same as the dimensions.")

    return GFXPROCS_INSTANCE.computepipeline_new(desc)
}

computepipeline_free :: proc(pipeline: Compute_Pipeline) {
    GFXPROCS_INSTANCE.computepipeline_free(pipeline)
}

computepipeline_compute :: proc(pipeline: Compute_Pipeline, bindings: Compute_Bindings, sync: ^Sync = nil) {
    GFXPROCS_INSTANCE.computepipeline_compute(pipeline, bindings, sync)
}

computepipeline_set_local_work_size :: proc(pipeline: Compute_Pipeline, size: []uint) {
    GFXPROCS_INSTANCE.computepipeline_set_local_work_size(pipeline, size)
}

computepipeline_set_global_work_size :: proc(pipeline: Compute_Pipeline, size: []uint) {
    GFXPROCS_INSTANCE.computepipeline_set_global_work_size(pipeline, size)
}

computepipeline_get_dimensions :: proc(pipeline: Compute_Pipeline) -> uint {
    return GFXPROCS_INSTANCE.computepipeline_get_dimensions(pipeline)
}

computepipeline_get_global_work_sizes :: proc(pipeline: Compute_Pipeline) -> []uint {
    return GFXPROCS_INSTANCE.computepipeline_get_global_work_sizes(pipeline)
}

computepipeline_get_local_work_sizes :: proc(pipeline: Compute_Pipeline) -> []uint {
    return GFXPROCS_INSTANCE.computepipeline_get_local_work_sizes(pipeline)
}