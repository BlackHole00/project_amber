package vx_lib_gfx

import gl "vendor:OpenGL"
import "core:log"
import "core:strings"
import "core:math/linalg/glsl"

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

    vertex_source: string,
    fragment_source: string,

    layout_elements: []Layout_Element,
}

Layout_Resolution_Element :: struct {
    index: u32,
    size:  i32,
    gl_type: u32,
    normalized: bool,
    offset: u32,
    buffer_idx: u32,
    divisor: u32,
}

Layout_Resolution :: struct {
    strides: []i32,
    resolutions: []Layout_Resolution_Element,
}

Layout_Element :: struct {
    gl_type: u32,
    count: uint,
    normalized: bool,
    buffer_idx: uint,
    divisor: uint,
}

Pipeline :: struct {
    //using shader: Shader,
    //using layout: Layout,
    shader_handle: u32,
    uniform_locations: map[string]i32,

    layout_handle: u32,
    layout_resolution: Layout_Resolution,

    states: Pipeline_States,
    render_target: Maybe(Framebuffer),
}

pipeline_init :: proc(pipeline: ^Pipeline, desc: Pipeline_Descriptor, render_target: Maybe(Framebuffer) = nil) {
    gl.CreateVertexArrays(1, &pipeline.layout_handle)
    pipeline_layout_resolve(pipeline, desc.layout_elements)

    if program, ok := gl.load_shaders_source(desc.vertex_source, desc.fragment_source); !ok {
		panic("Could not compile shaders")
	} else do pipeline.shader_handle = program

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
    gl.DeleteProgram(pipeline.shader_handle)

    gl.DeleteVertexArrays(1, &pipeline.layout_handle)
    delete(pipeline.layout_resolution.resolutions)
    delete(pipeline.layout_resolution.strides)
    pipeline.layout_handle = INVALID_HANDLE
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

pipeline_uniform_1f :: proc(pipeline: ^Pipeline, uniform_name: string, value: f32) {
    if loc, ok := pipeline_find_uniform_location(pipeline, uniform_name); !ok {
        log.warn("Could not find the uniform", uniform_name, "in pipeline", pipeline.shader_handle)
    } else {
        gl.ProgramUniform1f(pipeline.shader_handle, loc, value)
    }
}

pipeline_uniform_2f :: proc(pipeline: ^Pipeline, uniform_name: string, value: glsl.vec2) {
    if loc, ok := pipeline_find_uniform_location(pipeline, uniform_name); !ok {
        log.warn("Could not find the uniform", uniform_name, "in pipeline", pipeline.shader_handle)
    } else {
        gl.ProgramUniform2f(pipeline.shader_handle, loc, value.x, value.y)
    }
}

pipeline_uniform_3f :: proc(pipeline: ^Pipeline, uniform_name: string, value: glsl.vec3) {
    if loc, ok := pipeline_find_uniform_location(pipeline, uniform_name); !ok {
        log.warn("Could not find the uniform", uniform_name, "in pipeline", pipeline.shader_handle)
    } else {
        gl.ProgramUniform3f(pipeline.shader_handle, loc, value.x, value.y, value.z)
    }
}

pipeline_uniform_4f :: proc(pipeline: ^Pipeline, uniform_name: string, value: glsl.vec4) {
    if loc, ok := pipeline_find_uniform_location(pipeline, uniform_name); !ok {
        log.warn("Could not find the uniform", uniform_name, "in pipeline", pipeline.shader_handle)
    } else {
        gl.ProgramUniform4f(pipeline.shader_handle, loc, value.x, value.y, value.z, value.w)
    }
}

pipeline_uniform_mat4f :: proc(pipeline: ^Pipeline, uniform_name: string, value: ^glsl.mat4) {
    if loc, ok := pipeline_find_uniform_location(pipeline, uniform_name); !ok {
        log.warn("Could not find the uniform", uniform_name, "in pipeline", pipeline.shader_handle)
    } else {
        gl.ProgramUniformMatrix4fv(pipeline.shader_handle, loc, 1, false, &value[0, 0])
    }
}

pipeline_uniform_1i :: proc(pipeline: ^Pipeline, uniform_name: string, value: i32) {
    if loc, ok := pipeline_find_uniform_location(pipeline, uniform_name); !ok {
        log.warn("Could not find the uniform", uniform_name, "in pipeline", pipeline.shader_handle)
    } else {
        gl.ProgramUniform1i(pipeline.shader_handle, loc, value)
    }
}

/**************************************************************************************************
***************************************************************************************************
**************************************************************************************************/

@(private)
pipeline_bind :: proc(pipeline: Pipeline) {
    pipeline_shader_bind(pipeline)
    pipeline_layout_bind(pipeline)

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

@(private)
pipeline_bind_rendertarget :: proc(pipeline: Pipeline) {
    if pipeline.render_target != nil do framebuffer_bind(pipeline.render_target.(Framebuffer))
    else do bind_to_default_framebuffer()

    gl.Viewport(0, 0, (i32)(pipeline.states.viewport_size.x), (i32)(pipeline.states.viewport_size.y))
}

@(private)
pipeline_layout_resolve :: proc(pipeline: ^Pipeline, elements: []Layout_Element) {
    pipeline.layout_resolution.resolutions = make([]Layout_Resolution_Element, len(elements))
    pipeline.layout_resolution.strides = make([]i32, len(elements))

    buffer_count := pipeline_layout_find_buffer_count(elements)
    
    strides := make([]uint, buffer_count)
    defer delete(strides)

    offsets := make([]uint, buffer_count)
    defer delete(offsets)

    for elem in elements do strides[elem.buffer_idx] += size_of_gl_type(elem.gl_type) * elem.count
    for stride, i in strides do offsets[i] = stride

    for i := len(elements) - 1; i >= 0; i -= 1 {
        layout_index := i

        offsets[elements[i].buffer_idx] -= size_of_gl_type(elements[i].gl_type) * elements[i].count

        //log.info((u32)(layout_index), (i32)(elements[i].count), elements[i].gl_type, elements[i].normalized, (i32)(strides[elements[i].buffer_idx]), (uintptr)(offsets[elements[i].buffer_idx]))
        pipeline.layout_resolution.resolutions[i] = Layout_Resolution_Element {
            index = (u32)(layout_index),
            size = (i32)(elements[i].count),
            gl_type = elements[i].gl_type,
            normalized = elements[i].normalized,
            offset = (u32)(offsets[elements[i].buffer_idx]),
            buffer_idx = (u32)(elements[i].buffer_idx),
            divisor = (u32)(elements[i].divisor),
        }
        pipeline.layout_resolution.strides[i] = (i32)(strides[elements[i].buffer_idx])
    }
}

@(private)
pipeline_layout_find_buffer_count :: proc(elements: []Layout_Element) -> (count: uint = 0) {
    for elem in elements {
        if elem.buffer_idx > count do count = elem.buffer_idx
    }
    count += 1

    return
}

@(private)
pipeline_layout_apply_without_index_buffer :: proc(pipeline: Pipeline, vertex_buffers: []Buffer) {
    for buffer, i in vertex_buffers do gl.VertexArrayVertexBuffer(pipeline.layout_handle, (u32)(i), buffer.buffer_handle, 0, pipeline.layout_resolution.strides[i])

    for resolution, i in pipeline.layout_resolution.resolutions {
        gl.EnableVertexArrayAttrib(pipeline.layout_handle, (u32)(i))
        gl.VertexArrayAttribFormat(pipeline.layout_handle, (u32)(i), resolution.size, resolution.gl_type, resolution.normalized, resolution.offset)
        gl.VertexArrayAttribBinding(pipeline.layout_handle, (u32)(i), resolution.buffer_idx)
    }
}

@(private)
pipeline_layout_apply_with_index_buffer :: proc(pipeline: Pipeline, vertex_buffers: []Buffer, index_buffer: Buffer) {
    pipeline_layout_apply_without_index_buffer(pipeline, vertex_buffers)
    gl.VertexArrayElementBuffer(pipeline.layout_handle, index_buffer.buffer_handle)
}

@(private)
pipeline_layout_apply :: proc { pipeline_layout_apply_without_index_buffer, pipeline_layout_apply_with_index_buffer }

@(private)
pipeline_layout_bind :: proc(pipeline: Pipeline) {
    gl.BindVertexArray(pipeline.layout_handle)
}

@(private)
pipeline_shader_bind :: proc(pipeline: Pipeline) {
    gl.UseProgram(pipeline.shader_handle)
}

@(private)
pipeline_find_uniform_location :: proc(pipeline: ^Pipeline, uniform_name: string) -> (i32, bool) {
    if uniform_name in pipeline.uniform_locations do return pipeline.uniform_locations[uniform_name], true

    loc := gl.GetUniformLocation(pipeline.shader_handle, strings.clone_to_cstring(uniform_name, context.temp_allocator))
    pipeline.uniform_locations[uniform_name] = loc

    return loc, loc != -1
}
