package vx_lib_gfx

import gl "vendor:OpenGL"

Pipeline_States :: struct {
    cull_enabled: bool,
    cull_front_face: u32,
    cull_face: u32,

    depth_enabled: bool,
    depth_func: u32,

    blend_enabled: bool,
    blend_src_rgb_func: u32,
    blend_dst_rgb_func: u32,
    blend_src_alpha_func: u32,
    blend_dstdst_alphargb_func: u32,

    clear_color: [4]f32,

    wireframe: bool,
}

Pipeline_Descriptor :: struct {
    shader: Shader,
    layout: Layout,

    cull_enabled: bool,
    cull_front_face: u32,
    cull_face: u32,
    depth_enabled: bool,
    depth_func: u32,
    blend_enabled: bool,
    blend_src_rgb_func: u32,
    blend_dst_rgb_func: u32,
    blend_src_alpha_func: u32,
    blend_dstdst_alphargb_func: u32,
    clear_color: [4]f32,
    wireframe: bool,
}

Pipeline :: struct {
    using shader: Shader,
    using layout: Layout,

    states: Pipeline_States,
}

pipeline_init :: proc(pipeline: ^Pipeline, desc: Pipeline_Descriptor) {
    pipeline.shader = desc.shader
    pipeline.layout = desc.layout

    pipeline.states.cull_enabled = desc.cull_enabled
    pipeline.states.cull_face = desc.cull_face
    pipeline.states.cull_front_face = desc.cull_front_face
    pipeline.states.depth_enabled = desc.depth_enabled
    pipeline.states.depth_func = desc.depth_func
    pipeline.states.blend_enabled = desc.blend_enabled
    pipeline.states.blend_src_rgb_func = desc.blend_src_rgb_func
    pipeline.states.blend_dst_rgb_func = desc.blend_dst_rgb_func
    pipeline.states.blend_src_alpha_func = desc.blend_src_alpha_func
    pipeline.states.blend_dstdst_alphargb_func = desc.blend_dstdst_alphargb_func
    pipeline.states.clear_color = desc.clear_color
    pipeline.states.wireframe = desc.wireframe
}

pipeline_free :: proc(pipeline: ^Pipeline) {
    shader_free(&pipeline.shader)
    layout_free(&pipeline.layout)
}

pipeline_bind :: proc(pipeline: Pipeline) {
    shader_bind(pipeline.shader)
    layout_bind(pipeline.layout)
}

pipeline_apply :: proc(pipeline: Pipeline) {
    pipeline_bind(pipeline)

    if pipeline.states.cull_enabled {
        gl.Enable(gl.CULL_FACE)
        gl.FrontFace(pipeline.states.cull_front_face)
        gl.CullFace(pipeline.states.cull_face)
    } else do gl.Disable(gl.CULL_FACE)

    if pipeline.states.depth_enabled {
        gl.Enable(gl.DEPTH_TEST)
        gl.DepthFunc(pipeline.states.depth_func)
    } else do gl.Disable(gl.DEPTH_TEST)

    if pipeline.states.blend_enabled {
        gl.Enable(gl.BLEND)
        gl.BlendFuncSeparate(pipeline.states.blend_src_rgb_func,
            pipeline.states.blend_dst_rgb_func,
            pipeline.states.blend_src_alpha_func,
            pipeline.states.blend_dstdst_alphargb_func,
        )
    } else do gl.Disable(gl.BLEND)

    if pipeline.states.wireframe do gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
    else do gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
}

pipeline_clear :: proc(pipeline: Pipeline) {
    clear_bits: u32 = gl.COLOR_BUFFER_BIT

    if pipeline.states.depth_enabled do clear_bits |= gl.DEPTH_BUFFER_BIT

    gl.ClearColor(pipeline.states.clear_color[0],
        pipeline.states.clear_color[1],
        pipeline.states.clear_color[2],
        pipeline.states.clear_color[3],
    )
    gl.Clear(clear_bits)
}

pipeline_uniform_1f :: shader_uniform_1f
pipeline_uniform_2f :: shader_uniform_2f
pipeline_uniform_3f :: shader_uniform_3f
pipeline_uniform_4f :: shader_uniform_4f
pipeline_uniform_mat4f :: shader_uniform_mat4f
pipeline_uniform_1i :: shader_uniform_1i

pipeline_set_wireframe :: proc(pipeline: ^Pipeline, wireframe: bool) {
    pipeline.states.wireframe = wireframe
}
