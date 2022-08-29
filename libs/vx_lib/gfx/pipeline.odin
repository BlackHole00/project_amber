package vx_lib_gfx

import glsm "glstatemanager"
import gl "vendor:OpenGL"
import "core:log"
import "core:strings"
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
    cull_front_face: u32,
    cull_face: u32,

    depth_enabled: bool,
    depth_func: u32,

    blend_enabled: bool,
    blend_src_rgb_func: u32,
    blend_dst_rgb_func: u32,
    blend_src_alpha_func: u32,
    blend_dstdst_alphargb_func: u32,

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
    uniform_locations: map[string]i32,

    layout_handle: u32,
    layout_strides: []i32,
    layout_buffers: []u32,

    states: Pipeline_States,
    render_target: Maybe(Framebuffer),
}

pipeline_init :: proc(pipeline: ^Pipeline, desc: Pipeline_Descriptor, render_target: Maybe(Framebuffer) = nil) {
    gl.CreateVertexArrays(1, &pipeline.layout_handle)
    pipeline_layout_resolve(pipeline, desc.layout)

    if program, ok := gl.load_shaders_source(desc.vertex_source, desc.fragment_source); !ok {
		panic("Could not compile shaders")
	} else do pipeline.shader_handle = program

    pipeline.states.cull_enabled = desc.cull_enabled
    pipeline.states.cull_face = cullface_to_glenum(desc.cull_face)
    pipeline.states.cull_front_face = frontface_to_glenum(desc.cull_front_face)
    pipeline.states.depth_enabled = desc.depth_enabled
    pipeline.states.depth_func = depthfunc_to_glenum(desc.depth_func)
    pipeline.states.blend_enabled = desc.blend_enabled
    pipeline.states.blend_src_rgb_func = blendfunc_to_glenum(desc.blend_src_rgb_func)
    pipeline.states.blend_dst_rgb_func = blendfunc_to_glenum(desc.blend_dst_rgb_func)
    pipeline.states.blend_src_alpha_func = blendfunc_to_glenum(desc.blend_src_alpha_func)
    pipeline.states.blend_dstdst_alphargb_func = blendfunc_to_glenum(desc.blend_dstdst_alphargb_func)
    pipeline.states.clear_color = desc.clear_color
    pipeline.states.wireframe = desc.wireframe
    pipeline.states.viewport_size = desc.viewport_size
    pipeline.states.clearing_color = desc.clearing_color
    pipeline.states.clear_depth = desc.clear_depth

    pipeline.render_target = render_target
}

pipeline_free :: proc(pipeline: ^Pipeline) {
    gl.DeleteProgram(pipeline.shader_handle)
    pipeline.shader_handle = INVALID_HANDLE

    gl.DeleteVertexArrays(1, &pipeline.layout_handle)
    pipeline.layout_handle = INVALID_HANDLE

    delete(pipeline.layout_strides)
    delete(pipeline.layout_buffers)
}

pipeline_resize :: proc(pipeline: ^Pipeline, new_size: [2]uint) {
    pipeline.states.viewport_size = new_size
}

pipeline_clear :: proc(pipeline: Pipeline) {
    pipeline_bind(pipeline)

    // VERY IMPORTANT NOTE: If DepthMask is set to false when clearing a screen, the depth buffer will not be properly cleared, causing a black screen.
    // Leave the depth mask to true!
    glsm.DepthMask(true)

    clear_bits: u32 = 0

    if pipeline.states.clear_depth && pipeline.states.clear_depth do clear_bits |= gl.DEPTH_BUFFER_BIT
    if pipeline.states.clear_color {
        clear_bits |= gl.COLOR_BUFFER_BIT

        // We could use glClearNamedFramebufferfv but I don't care about dsa in this case.
        glsm.ClearColor(pipeline.states.clearing_color[0],
            pipeline.states.clearing_color[1],
            pipeline.states.clearing_color[2],
            pipeline.states.clearing_color[3],
        )
    }

    gl.Clear(clear_bits)
}

pipeline_set_wireframe :: proc(pipeline: ^Pipeline, wireframe: bool) {
    pipeline.states.wireframe = wireframe
}

pipeline_draw_arrays :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, first: int, count: int,) {
    pipeline_apply(pipeline^)
    pipeline_bind(pipeline^)
    bindings_apply(pipeline, bindings)

    gl.DrawArrays(primitive_to_glenum(primitive), (i32)(first), (i32)(count))
}

pipeline_draw_elements :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, type: Index_Type, count: int, indices: rawptr) {
    pipeline_apply(pipeline^)
    pipeline_bind(pipeline^)
    bindings_apply(pipeline, bindings)

    gl.DrawElements(primitive_to_glenum(primitive), (i32)(count), indextype_to_glenum(type), indices)
}

pipeline_draw_arrays_instanced :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, first: int, count: int, instance_count: int) {
    pipeline_apply(pipeline^)
    pipeline_bind(pipeline^)
    bindings_apply(pipeline, bindings)

    gl.DrawArraysInstanced(primitive_to_glenum(primitive), (i32)(first), (i32)(count), (i32)(instance_count))
}

pipeline_draw_elements_instanced :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, type: Index_Type, count: int, indices: rawptr, instance_count: int) {
    pipeline_apply(pipeline^)
    pipeline_bind(pipeline^)
    bindings_apply(pipeline, bindings)

    gl.DrawElementsInstanced(primitive_to_glenum(primitive), (i32)(count), indextype_to_glenum(type), indices, (i32)(instance_count))
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
        glsm.Enable(gl.CULL_FACE)
        glsm.FrontFace(pipeline.states.cull_front_face)
        glsm.CullFace(pipeline.states.cull_face)
    } else do glsm.Disable(gl.CULL_FACE)

    if pipeline.states.depth_enabled {
        glsm.Enable(gl.DEPTH_TEST)
        glsm.DepthFunc(pipeline.states.depth_func)
    } else do glsm.Disable(gl.DEPTH_TEST)

    if pipeline.states.blend_enabled {
        glsm.Enable(gl.BLEND)
        glsm.BlendFuncSeparate(pipeline.states.blend_src_rgb_func,
            pipeline.states.blend_dst_rgb_func,
            pipeline.states.blend_src_alpha_func,
            pipeline.states.blend_dstdst_alphargb_func,
        )
    } else do glsm.Disable(gl.BLEND)

    if pipeline.states.wireframe do glsm.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
    else do glsm.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
}

@(private)
pipeline_bind_rendertarget :: proc(pipeline: Pipeline) {
    if pipeline.render_target != nil do framebuffer_bind(pipeline.render_target.(Framebuffer))
    else do bind_to_default_framebuffer()

    glsm.Viewport(0, 0, (i32)(pipeline.states.viewport_size.x), (i32)(pipeline.states.viewport_size.y))
}

@(private)
pipeline_layout_resolve :: proc(pipeline: ^Pipeline, elements: []Layout_Element) {
    buffer_count := pipeline_layout_find_buffer_count(elements)

    pipeline.layout_buffers = make([]u32, len(elements))
    pipeline.layout_strides = make([]i32, len(elements))

    strides := make([]uint, buffer_count)
    defer delete(strides)

    offsets := make([]uint, buffer_count)
    defer delete(offsets)

    for elem in elements do strides[elem.buffer_idx] += size_of_gl_type(elem.gl_type) * elem.count
    for stride, i in strides do offsets[i] = stride

    for i := len(elements) - 1; i >= 0; i -= 1 {
        offsets[elements[i].buffer_idx] -= size_of_gl_type(elements[i].gl_type) * elements[i].count

        gl.EnableVertexArrayAttrib(pipeline.layout_handle, (u32)(i))
        gl.VertexArrayAttribFormat(pipeline.layout_handle, (u32)(i), (i32)(elements[i].count), elements[i].gl_type, elements[i].normalized, (u32)(offsets[elements[i].buffer_idx]))
        gl.VertexArrayBindingDivisor(pipeline.layout_handle, (u32)(i), (u32)(elements[i].divisor))

        pipeline.layout_buffers[i] = (u32)(elements[i].buffer_idx)
        pipeline.layout_strides[i] = (i32)(strides[elements[i].buffer_idx])
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
    for buffer, i in vertex_buffers do gl.VertexArrayVertexBuffer((u32)(pipeline.layout_handle), (u32)(i), (u32)(buffer.buffer_handle), 0, pipeline.layout_strides[i])

    for buffer, i in pipeline.layout_buffers {
        gl.VertexArrayAttribBinding(pipeline.layout_handle, (u32)(i), buffer)
    }
}

@(private)
pipeline_layout_apply_with_index_buffer :: proc(pipeline: Pipeline, vertex_buffers: []Buffer, index_buffer: Buffer) {
    pipeline_layout_apply_without_index_buffer(pipeline, vertex_buffers)
    gl.VertexArrayElementBuffer(pipeline.layout_handle, (u32)(index_buffer.buffer_handle))
}

@(private)
pipeline_layout_apply :: proc { pipeline_layout_apply_without_index_buffer, pipeline_layout_apply_with_index_buffer }

@(private)
pipeline_layout_bind :: proc(pipeline: Pipeline) {
    glsm.BindVertexArray(pipeline.layout_handle)
}

@(private)
pipeline_shader_bind :: proc(pipeline: Pipeline) {
    glsm.UseProgram(pipeline.shader_handle)
}

@(private)
pipeline_find_uniform_location :: proc(pipeline: ^Pipeline, uniform_name: string) -> (i32, bool) {
    if uniform_name in pipeline.uniform_locations do return pipeline.uniform_locations[uniform_name], true

    loc := gl.GetUniformLocation(pipeline.shader_handle, strings.clone_to_cstring(uniform_name, context.temp_allocator))
    pipeline.uniform_locations[uniform_name] = loc

    return loc, loc != -1
}

@(private)
cullface_to_glenum :: proc(face: Cull_Face) -> u32 {
    switch face {
        case .Front: return gl.FRONT
        case .Back: return gl.BACK
    }

    return 0
}

@(private)
frontface_to_glenum :: proc(front: Front_Face) -> u32 {
    switch front {
        case .Clockwise: return gl.CW
        case .Counter_Clockwise: return gl.CCW
    }

    return 0
}

@(private)
depthfunc_to_glenum :: proc(func: Depth_Func) -> u32 {
    switch func {
        case .Always: return gl.ALWAYS
        case .Equal: return gl.EQUAL
        case .Greater: return gl.GREATER
        case .LEqual: return gl.LEQUAL
        case .Less: return gl.LESS
        case .Never: return gl.NEVER
    }

    return 0
}

@(private)
blendfunc_to_glenum :: proc(blend: Blend_Func) -> u32 {
    switch blend {
        case .Zero: return gl.ZERO
        case .One: return gl.ONE
        case .Src_Color: return gl.SRC_COLOR
        case .One_Minus_Src_Color: return gl.ONE_MINUS_SRC_COLOR
        case .Dst_Color: return gl.DST_COLOR
        case .One_Minus_Dst_Color: return gl.ONE_MINUS_DST_COLOR
        case .Src_Alpha: return gl.SRC_ALPHA
        case .One_Minus_Src_Alpha: return gl.ONE_MINUS_SRC_ALPHA
        case .Dst_Alpha: return gl.ONE_MINUS_DST_ALPHA
        case .One_Minus_Dst_Alpha: return gl.ONE_MINUS_DST_ALPHA
        case .Constant_Color: return gl.CONSTANT_COLOR
        case .One_Minus_Constant_Color: return gl.ONE_MINUS_CONSTANT_ALPHA
        case .Constant_Alpha: return gl.CONSTANT_ALPHA
        case .One_Minus_Constant_Alpha: return gl.ONE_MINUS_CONSTANT_ALPHA
        case .Src_Alpha_Saturate: return gl.SRC_ALPHA_SATURATE
        case .Src1_Alpha: return gl.SRC1_ALPHA
        case .Src1_Color: return gl.SRC1_COLOR
    }

    return 0
}

@(private)
primitive_to_glenum :: proc(primitive: Primitive) -> u32 {
    switch primitive {
        case .Triangles: return gl.TRIANGLES
    }

    return 0
}

@(private)
indextype_to_glenum :: proc(type: Index_Type) -> u32 {
    switch type {
        case .U8: return gl.UNSIGNED_BYTE
        case .U16: return gl.UNSIGNED_SHORT
        case .U32: return gl.UNSIGNED_INT
    }

    return 0
}
