package vx_lib_gfx

Pipeline_Descriptor :: struct {
    shader: Shader,
    layout: Layout,
}

Pipeline :: struct {
    using shader: Shader,
    using layout: Layout,
}

pipeline_init :: proc(pipeline: ^Pipeline, desc: Pipeline_Descriptor) {
    pipeline.shader = desc.shader
    pipeline.layout = desc.layout
}

pipeline_free :: proc(pipeline: ^Pipeline) {
    shader_free(&pipeline.shader)
    layout_free(&pipeline.layout)
}

pipeline_bind :: proc(pipeline: Pipeline) {
    shader_bind(pipeline.shader)
    layout_bind(pipeline.layout)
}

pipeline_uniform_1f :: shader_uniform_1f
pipeline_uniform_2f :: shader_uniform_2f
pipeline_uniform_3f :: shader_uniform_3f
pipeline_uniform_4f :: shader_uniform_4f
pipeline_uniform_mat4f :: shader_uniform_mat4f
pipeline_uniform_1i :: shader_uniform_1i
