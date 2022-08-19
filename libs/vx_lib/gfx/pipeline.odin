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

    viewport_size: [2]uint,
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
    viewport_size: [2]uint,
}

Pipeline :: struct {
    using shader: Shader,
    using layout: Layout,

    states: Pipeline_States,
    render_target: Maybe(Framebuffer),
}

pipeline_init :: proc(pipeline: ^Pipeline, desc: Pipeline_Descriptor, render_target: Maybe(Framebuffer) = nil) {
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
    pipeline.states.viewport_size = desc.viewport_size

    pipeline.render_target = render_target
}

pipeline_free :: proc(pipeline: ^Pipeline) {
    shader_free(&pipeline.shader)
    layout_free(&pipeline.layout)
}

@(private)
pipeline_bind :: proc(pipeline: Pipeline) {
    shader_bind(pipeline.shader)
    layout_bind(pipeline.layout)

    pipeline_bind_rendertarget(pipeline)
}

@(private)
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

pipeline_resize :: proc(pipeline: ^Pipeline, new_size: [2]uint) {
    pipeline.states.viewport_size = new_size
}

pipeline_clear :: proc(pipeline: Pipeline) {
    pipeline_bind(pipeline)

    // VERY IMPORTANT NOTE: If DepthMask is set to false when clearing a screen, the depth buffer will not be properly cleared, causing a black screen.
    // Leave the depth mask to true!
    gl.DepthMask(true)

    pipeline_bind_rendertarget(pipeline)

    clear_bits: u32 = gl.COLOR_BUFFER_BIT

    if pipeline.states.depth_enabled do clear_bits |= gl.DEPTH_BUFFER_BIT

    // We could use glClearNamedFramebufferfv but I don't care about dsa in this case.
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

pipeline_draw_arrays :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: u32, first: int, count: int, draw_to_depth_buffer := true) {
    pipeline_bind(pipeline^)
    bindings_apply(pipeline, bindings)

    gl.DrawArrays(primitive, (i32)(first), (i32)(count))
}

pipeline_draw_elements :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: u32, type: u32, count: int, indices: rawptr, draw_to_depth_buffer := true) {
    pipeline_bind(pipeline^)
    bindings_apply(pipeline, bindings)

    gl.DrawElements(primitive, (i32)(count), type, indices)
}

pipeline_draw_arrays_instanced :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: u32, first: int, count: int, instance_count: int, draw_to_depth_buffer := true) {
    pipeline_bind(pipeline^)
    bindings_apply(pipeline, bindings)

    gl.DrawArraysInstanced(primitive, (i32)(first), (i32)(count), (i32)(instance_count))
}

pipeline_draw_elements_instanced :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: u32, type: u32, count: int, indices: rawptr, instance_count: int, draw_to_depth_buffer := true) {
    pipeline_bind(pipeline^)
    bindings_apply(pipeline, bindings)

    gl.DrawElementsInstanced(primitive, (i32)(count), type, indices, (i32)(instance_count))
}

@(private)
pipeline_bind_rendertarget :: proc(pipeline: Pipeline) {
    if pipeline.render_target != nil do framebuffer_bind(pipeline.render_target.(Framebuffer))
    else do bind_to_default_framebuffer()

    gl.Viewport(0, 0, (i32)(pipeline.states.viewport_size.x), (i32)(pipeline.states.viewport_size.y))
}
