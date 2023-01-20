package vx_lib_gfx

Cull_Face :: enum {
    Front,
    Back,
}

Front_Face :: enum {
    Clockwise,
    Counter_Clockwise,
}

Depth_Func :: enum {
    Never,
    Less,
    Equal,
    LEqual,
    Greater,
    Always,
}

Blend_Func :: enum {
    Zero,
    One,
    Src_Color,
    One_Minus_Src_Color,
    Dst_Color,
    One_Minus_Dst_Color,
    Src_Alpha,
    One_Minus_Src_Alpha,
    Dst_Alpha,
    One_Minus_Dst_Alpha,
    Constant_Color,
    One_Minus_Constant_Color,
    Constant_Alpha,
    One_Minus_Constant_Alpha,
    Src_Alpha_Saturate,
    Src1_Color,
    Src1_Alpha,
}

Pipeline_Descriptor :: struct {
    cull_enabled: bool,
    cull_front_face: Front_Face,
    cull_face: Cull_Face,
    depth_enabled: bool,
    depth_func: Depth_Func,
    blend_enabled: bool,
    blend_src_rgb_func: Blend_Func,
    blend_dst_rgb_func: Blend_Func,
    blend_src_alpha_func: Blend_Func,
    blend_dstdst_alphargb_func: Blend_Func,
    wireframe: bool,
    viewport_size: [2]uint,

    vertex_source: Maybe(string),
    fragment_source: Maybe(string),

    layout: Pipeline_Layout,

    clearing_color: [4]f32,
    clear_depth: bool,
    clear_color: bool,
}

Element_Type :: enum {
    F16,
    F32,
    F64,
    Byte,
    UByte,
    I8 = Byte,
    U8 = UByte,
    I16,
    U16,
    I32,
    U32,
}

Layout_Element :: struct {
    type: Element_Type,
    count: uint,
    normalized: bool,
    buffer_idx: uint,
    divisor: uint,
}

Primitive :: enum {
    Triangles,
}

Pipeline_Layout :: []Layout_Element

Pipeline :: distinct rawptr

pipeline_new :: proc(desc: Pipeline_Descriptor, render_target: Maybe(Framebuffer) = nil) -> Pipeline {
    return GFXPROCS_INSTANCE.pipeline_new(desc, render_target)
}

pipeline_free :: proc(pipeline: Pipeline) {
    GFXPROCS_INSTANCE.pipeline_free(pipeline)
}

pipeline_resize :: proc(pipeline: Pipeline, new_size: [2]uint) {
    GFXPROCS_INSTANCE.pipeline_resize(pipeline, new_size)
}

pipeline_clear :: proc(pipeline: Pipeline) {
    GFXPROCS_INSTANCE.pipeline_clear(pipeline)
}

pipeline_set_wireframe :: proc(pipeline: Pipeline, wireframe: bool) {
    when ODIN_DEBUG do if !pipeline_is_draw_pipeline(pipeline) do panic("Pipeline must be a draw pipeline.") 

    GFXPROCS_INSTANCE.pipeline_set_wireframe(pipeline, wireframe)
}

pipeline_draw_arrays :: proc(pipeline: Pipeline, bindings: Bindings, primitive: Primitive, first: int, count: int) {
    when ODIN_DEBUG do if !pipeline_is_draw_pipeline(pipeline) do panic("Pipeline must be a draw pipeline.") 

    GFXPROCS_INSTANCE.pipeline_draw_arrays(pipeline, bindings, primitive, first, count)
}

pipeline_draw_elements :: proc(pipeline: Pipeline, bindings: Bindings, primitive: Primitive, count: int) {
    when ODIN_DEBUG { 
        if !pipeline_is_draw_pipeline(pipeline) do panic("Pipeline must be a draw pipeline.")
        if !bindings_has_index_buffer(bindings) do panic("When drawing elements a valid index buffer must be provided.")
    }

    GFXPROCS_INSTANCE.pipeline_draw_elements(pipeline, bindings, primitive, count)
}

pipeline_draw_arrays_instanced :: proc(pipeline: Pipeline, bindings: Bindings, primitive: Primitive, first: int, count: int, instance_count: int) {
    when ODIN_DEBUG do if !pipeline_is_draw_pipeline(pipeline) do panic("Pipeline must be a draw pipeline.") 

    GFXPROCS_INSTANCE.pipeline_draw_arrays_instanced(pipeline, bindings, primitive, first, count, instance_count)
}

pipeline_draw_elements_instanced :: proc(pipeline: Pipeline, bindings: Bindings, primitive: Primitive, count: int, instance_count: int) {
    when ODIN_DEBUG {
        if !pipeline_is_draw_pipeline(pipeline) do panic("Pipeline must be a draw pipeline.")
        if !bindings_has_index_buffer(bindings) do panic("When drawing elements a valid index buffer must be provided.")
    }

    GFXPROCS_INSTANCE.pipeline_draw_elements_instanced(pipeline, bindings, primitive, count, instance_count)
}

pipeline_uniform_1f :: proc(pipeline: Pipeline, uniform_name: string, value: f32) {
    when ODIN_DEBUG {
        if !pipeline_is_draw_pipeline(pipeline) do panic("Pipeline must be a draw pipeline.") 
        if !pipeline_does_uniform_exist(pipeline, uniform_name) do panic("Pipeline does not have the requested uniform.")
    }

    GFXPROCS_INSTANCE.pipeline_uniform_1f(pipeline, uniform_name, value)
}

pipeline_uniform_2f :: proc(pipeline: Pipeline, uniform_name: string, value: [2]f32) {
    when ODIN_DEBUG {
        if !pipeline_is_draw_pipeline(pipeline) do panic("Pipeline must be a draw pipeline.") 
        if !pipeline_does_uniform_exist(pipeline, uniform_name) do panic("Pipeline does not have the requested uniform.")
    }

    GFXPROCS_INSTANCE.pipeline_uniform_2f(pipeline, uniform_name, value)
}

pipeline_uniform_3f :: proc(pipeline: Pipeline, uniform_name: string, value: [3]f32) {
    when ODIN_DEBUG {
        if !pipeline_is_draw_pipeline(pipeline) do panic("Pipeline must be a draw pipeline.") 
        if !pipeline_does_uniform_exist(pipeline, uniform_name) do panic("Pipeline does not have the requested uniform.")
    }

    GFXPROCS_INSTANCE.pipeline_uniform_3f(pipeline, uniform_name, value)
}

pipeline_uniform_4f :: proc(pipeline: Pipeline, uniform_name: string, value: [4]f32) {
    when ODIN_DEBUG {
        if !pipeline_is_draw_pipeline(pipeline) do panic("Pipeline must be a draw pipeline.") 
        if !pipeline_does_uniform_exist(pipeline, uniform_name) do panic("Pipeline does not have the requested uniform.")
    }

    GFXPROCS_INSTANCE.pipeline_uniform_4f(pipeline, uniform_name, value)
}

pipeline_uniform_mat4f :: proc(pipeline: Pipeline, uniform_name: string, value: ^matrix[4, 4]f32) {
    when ODIN_DEBUG {
        if !pipeline_is_draw_pipeline(pipeline) do panic("Pipeline must be a draw pipeline.") 
        if !pipeline_does_uniform_exist(pipeline, uniform_name) do panic("Pipeline does not have the requested uniform.")
    }

    GFXPROCS_INSTANCE.pipeline_uniform_mat4f(pipeline, uniform_name, value)
}

pipeline_uniform_1i :: proc(pipeline: Pipeline, uniform_name: string, value: i32) {
    when ODIN_DEBUG {
        if !pipeline_is_draw_pipeline(pipeline) do panic("Pipeline must be a draw pipeline.") 
        if !pipeline_does_uniform_exist(pipeline, uniform_name) do panic("Pipeline does not have the requested uniform.")
    }
    
    GFXPROCS_INSTANCE.pipeline_uniform_1i(pipeline, uniform_name, value)
}

pipeline_get_size :: proc(pipeline: Pipeline) -> [2]uint {
    return GFXPROCS_INSTANCE.pipeline_get_size(pipeline)
}

pipeline_is_draw_pipeline :: proc(pipeline: Pipeline) -> bool {
    return GFXPROCS_INSTANCE.pipeline_is_draw_pipeline(pipeline)
}

pipeline_is_wireframe :: proc(pipeline: Pipeline) -> bool {
    when ODIN_DEBUG do if !pipeline_is_draw_pipeline(pipeline) do panic("Pipeline must be a draw pipeline.") 

    return GFXPROCS_INSTANCE.pipeline_is_wireframe(pipeline)
}

pipeline_does_uniform_exist :: proc(pipeline: Pipeline, uniform_name: string) -> bool {
    when ODIN_DEBUG do if !pipeline_is_draw_pipeline(pipeline) do panic("Pipeline must be a draw pipeline.") 

    return GFXPROCS_INSTANCE.pipeline_does_uniform_exist(pipeline, uniform_name)
}
