package vx_lib_gfx

import "core:math/linalg/glsl"

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

Pipeline_States :: struct {
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

    clearing_color: [4]f32,
    clear_depth: bool,
    clear_color: bool,
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

    vertex_source: string,
    fragment_source: string,

    layout: Pipeline_Layout,

    clearing_color: [4]f32,
    clear_depth: bool,
    clear_color: bool,
}

Layout_Element :: struct {
    gl_type: u32,
    count: uint,
    normalized: bool,
    buffer_idx: uint,
    divisor: uint,
}

Primitive :: enum {
    Triangles,
}

Index_Type :: enum {
    U8,
    U16,
    U32,
}

Pipeline_Layout :: []Layout_Element

Pipeline :: struct {
    shader_handle: u32,
    //uniform_locations: map[string]i32,

    layout_handle: u32,
    layout_strides: []i32,
    layout_buffers: []u32,

    states: Pipeline_States,
    render_target: Maybe(Framebuffer),
}

pipeline_init :: proc(pipeline: ^Pipeline, desc: Pipeline_Descriptor, render_target: Maybe(Framebuffer) = nil) {
    GFX_PROCS.pipeline_init(pipeline, desc, render_target)
}

pipeline_free :: proc(pipeline: ^Pipeline) {
    GFX_PROCS.pipeline_free(pipeline)
}

pipeline_resize :: proc(pipeline: ^Pipeline, new_size: [2]uint) {
    GFX_PROCS.pipeline_resize(pipeline, new_size)
}

pipeline_clear :: proc(pipeline: Pipeline) {
    GFX_PROCS.pipeline_clear(pipeline)
}

pipeline_set_wireframe :: proc(pipeline: ^Pipeline, wireframe: bool) {
    GFX_PROCS.pipeline_set_wireframe(pipeline, wireframe)
}

pipeline_draw_arrays :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, first: int, count: int) {
    GFX_PROCS.pipeline_draw_arrays(pipeline, bindings, primitive, first, count)
}

pipeline_draw_elements :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, type: Index_Type, count: int) {
    GFX_PROCS.pipeline_draw_elements(pipeline, bindings, primitive, type, count)
}

pipeline_draw_arrays_instanced :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, first: int, count: int, instance_count: int) {
    GFX_PROCS.pipeline_draw_arrays_instanced(pipeline, bindings, primitive, first, count, instance_count)
}

pipeline_draw_elements_instanced :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, type: Index_Type, count: int, instance_count: int) {
    GFX_PROCS.pipeline_draw_elements_instanced(pipeline, bindings, primitive, type, count, instance_count)
}

pipeline_uniform_1f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: f32) {
    GFX_PROCS.pipeline_uniform_1f(pipeline, uniform_location, value)
}

pipeline_uniform_2f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: glsl.vec2) {
    GFX_PROCS.pipeline_uniform_2f(pipeline, uniform_location, value)
}

pipeline_uniform_3f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: glsl.vec3) {
    GFX_PROCS.pipeline_uniform_3f(pipeline, uniform_location, value)
}

pipeline_uniform_4f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: glsl.vec4) {
    GFX_PROCS.pipeline_uniform_4f(pipeline, uniform_location, value)
}

pipeline_uniform_mat4f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: ^glsl.mat4) {
    GFX_PROCS.pipeline_uniform_mat4f(pipeline, uniform_location, value)
}

pipeline_uniform_1i :: proc(pipeline: ^Pipeline, uniform_location: uint, value: i32) {
    GFX_PROCS.pipeline_uniform_1i(pipeline, uniform_location, value)
}
