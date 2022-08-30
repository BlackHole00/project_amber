package vx_lib_gfx

import glsm "../gfx/glstatemanager"
import gl "vendor:OpenGL"
import "core:math/linalg/glsl"

@(private)
_glimpl_pipeline_init :: proc(pipeline: ^Pipeline, desc: Pipeline_Descriptor, render_target: Maybe(Framebuffer)) {
    gl.CreateVertexArrays(1, &pipeline.layout_handle)
    _glimpl_pipeline_layout_resolve(pipeline, desc.layout)

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
    pipeline.states.clearing_color = desc.clearing_color
    pipeline.states.clear_depth = desc.clear_depth

    pipeline.render_target = render_target
}

@(private)
_glimpl_pipeline_free :: proc(pipeline: ^Pipeline) {
    gl.DeleteProgram(pipeline.shader_handle)
    pipeline.shader_handle = INVALID_HANDLE

    gl.DeleteVertexArrays(1, &pipeline.layout_handle)
    pipeline.layout_handle = INVALID_HANDLE

    delete(pipeline.layout_strides)
    delete(pipeline.layout_buffers)
}

@(private)
_glimpl_pipeline_resize :: proc(pipeline: ^Pipeline, new_size: [2]uint) {
    pipeline.states.viewport_size = new_size
}

@(private)
_glimpl_pipeline_clear :: proc(pipeline: Pipeline) {
    _glimpl_pipeline_bind(pipeline)

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

@(private)
_glimpl_pipeline_set_wireframe :: proc(pipeline: ^Pipeline, wireframe: bool) {
    pipeline.states.wireframe = wireframe
}

@(private)
_glimpl_pipeline_draw_arrays :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, first: int, count: int,) {
    _glimpl_pipeline_apply(pipeline^)
    _glimpl_pipeline_bind(pipeline^)
    bindings_apply(pipeline, bindings)

    gl.DrawArrays(_glimpl_primitive_to_glenum(primitive), (i32)(first), (i32)(count))
}

@(private)
_glimpl_pipeline_draw_elements :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, type: Index_Type, count: int) {
    _glimpl_pipeline_apply(pipeline^)
    _glimpl_pipeline_bind(pipeline^)
    bindings_apply(pipeline, bindings)

    gl.DrawElements(_glimpl_primitive_to_glenum(primitive), (i32)(count), _glimpl_indextype_to_glenum(type), nil)
}

@(private)
_glimpl_pipeline_draw_arrays_instanced :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, first: int, count: int, instance_count: int) {
    _glimpl_pipeline_apply(pipeline^)
    _glimpl_pipeline_bind(pipeline^)
    bindings_apply(pipeline, bindings)

    gl.DrawArraysInstanced(_glimpl_primitive_to_glenum(primitive), (i32)(first), (i32)(count), (i32)(instance_count))
}

@(private)
_glimpl_pipeline_draw_elements_instanced :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, type: Index_Type, count: int, instance_count: int) {
    _glimpl_pipeline_apply(pipeline^)
    _glimpl_pipeline_bind(pipeline^)
    bindings_apply(pipeline, bindings)

    gl.DrawElementsInstanced(_glimpl_primitive_to_glenum(primitive), (i32)(count), _glimpl_indextype_to_glenum(type), nil, (i32)(instance_count))
}

@(private)
_glimpl_pipeline_uniform_1f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: f32) {
    gl.ProgramUniform1f(pipeline.shader_handle, (i32)(uniform_location), value)
}

@(private)
_glimpl_pipeline_uniform_2f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: glsl.vec2) {
    gl.ProgramUniform2f(pipeline.shader_handle, (i32)(uniform_location), value.x, value.y)
}

@(private)
_glimpl_pipeline_uniform_3f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: glsl.vec3) {
    gl.ProgramUniform3f(pipeline.shader_handle, (i32)(uniform_location), value.x, value.y, value.z)
}

@(private)
_glimpl_pipeline_uniform_4f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: glsl.vec4) {
    gl.ProgramUniform4f(pipeline.shader_handle, (i32)(uniform_location), value.x, value.y, value.z, value.w)
}

@(private)
_glimpl_pipeline_uniform_mat4f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: glsl.mat4) {
    local := value
    gl.ProgramUniformMatrix4fv(pipeline.shader_handle, (i32)(uniform_location), 1, false, &local[0, 0])
}

@(private)
_glimpl_pipeline_uniform_1i :: proc(pipeline: ^Pipeline, uniform_location: uint, value: i32) {
    gl.ProgramUniform1i(pipeline.shader_handle, (i32)(uniform_location), value)
}

@(private)
_glimpl_pipeline_bind :: proc(pipeline: Pipeline) {
    _glimpl_pipeline_shader_bind(pipeline)
    _glimpl_pipeline_layout_bind(pipeline)

    _glimpl_pipeline_bind_rendertarget(pipeline)
}

@(private)
_glimpl_pipeline_apply :: proc(pipeline: Pipeline) {
    _glimpl_pipeline_bind(pipeline)

    if pipeline.states.cull_enabled {
        glsm.Enable(gl.CULL_FACE)
        glsm.FrontFace(_glimpl_frontface_to_glenum(pipeline.states.cull_front_face))
        glsm.CullFace(_glimpl_cullface_to_glenum(pipeline.states.cull_face))
    } else do glsm.Disable(gl.CULL_FACE)

    if pipeline.states.depth_enabled {
        glsm.Enable(gl.DEPTH_TEST)
        glsm.DepthFunc(_glimpl_depthfunc_to_glenum(pipeline.states.depth_func))
    } else do glsm.Disable(gl.DEPTH_TEST)

    if pipeline.states.blend_enabled {
        glsm.Enable(gl.BLEND)
        glsm.BlendFuncSeparate(_glimpl_blendfunc_to_glenum(pipeline.states.blend_src_rgb_func),
            _glimpl_blendfunc_to_glenum(pipeline.states.blend_dst_rgb_func),
            _glimpl_blendfunc_to_glenum(pipeline.states.blend_src_alpha_func),
            _glimpl_blendfunc_to_glenum(pipeline.states.blend_dstdst_alphargb_func),
        )
    } else do glsm.Disable(gl.BLEND)

    if pipeline.states.wireframe do glsm.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
    else do glsm.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
}

@(private)
_glimpl_pipeline_bind_rendertarget :: proc(pipeline: Pipeline) {
    if pipeline.render_target != nil do _glimpl_framebuffer_bind(pipeline.render_target.(Framebuffer))
    else do _glimpl_bind_to_default_framebuffer()

    glsm.Viewport(0, 0, (i32)(pipeline.states.viewport_size.x), (i32)(pipeline.states.viewport_size.y))
}

@(private)
_glimpl_pipeline_layout_resolve :: proc(pipeline: ^Pipeline, elements: []Layout_Element) {
    buffer_count := _glimpl_pipeline_layout_find_buffer_count(elements)

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
_glimpl_pipeline_layout_find_buffer_count :: proc(elements: []Layout_Element) -> (count: uint = 0) {
    for elem in elements {
        if elem.buffer_idx > count do count = elem.buffer_idx
    }
    count += 1

    return
}

@(private)
_glimpl_pipeline_layout_apply_without_index_buffer :: proc(pipeline: Pipeline, vertex_buffers: []Buffer) {
    for buffer, i in vertex_buffers do gl.VertexArrayVertexBuffer((u32)(pipeline.layout_handle), (u32)(i), (u32)(buffer.buffer_handle), 0, pipeline.layout_strides[i])

    for buffer, i in pipeline.layout_buffers {
        gl.VertexArrayAttribBinding(pipeline.layout_handle, (u32)(i), buffer)
    }
}

@(private)
_glimpl_pipeline_layout_apply_with_index_buffer :: proc(pipeline: Pipeline, vertex_buffers: []Buffer, index_buffer: Buffer) {
    _glimpl_pipeline_layout_apply_without_index_buffer(pipeline, vertex_buffers)
    gl.VertexArrayElementBuffer(pipeline.layout_handle, (u32)(index_buffer.buffer_handle))
}

@(private)
_glimpl_pipeline_layout_bind :: proc(pipeline: Pipeline) {
    glsm.BindVertexArray(pipeline.layout_handle)
}

@(private)
_glimpl_pipeline_shader_bind :: proc(pipeline: Pipeline) {
    glsm.UseProgram(pipeline.shader_handle)
}

@(private)
_glimpl_cullface_to_glenum :: proc(face: Cull_Face) -> u32 {
    switch face {
        case .Front: return gl.FRONT
        case .Back: return gl.BACK
    }

    return 0
}

@(private)
_glimpl_frontface_to_glenum :: proc(front: Front_Face) -> u32 {
    switch front {
        case .Clockwise: return gl.CW
        case .Counter_Clockwise: return gl.CCW
    }

    return 0
}

@(private)
_glimpl_depthfunc_to_glenum :: proc(func: Depth_Func) -> u32 {
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
_glimpl_blendfunc_to_glenum :: proc(blend: Blend_Func) -> u32 {
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
_glimpl_primitive_to_glenum :: proc(primitive: Primitive) -> u32 {
    switch primitive {
        case .Triangles: return gl.TRIANGLES
    }

    return 0
}

@(private)
_glimpl_indextype_to_glenum :: proc(type: Index_Type) -> u32 {
    switch type {
        case .U8: return gl.UNSIGNED_BYTE
        case .U16: return gl.UNSIGNED_SHORT
        case .U32: return gl.UNSIGNED_INT
    }

    return 0
}
