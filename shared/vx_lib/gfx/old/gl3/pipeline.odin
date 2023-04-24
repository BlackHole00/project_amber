package vx_lib_gfx_gl3

import glsm "shared:vx_lib/gfx/glstatemanager"
import gl "vendor:OpenGL"
import "shared:vx_lib/gfx"
import "core:log"
import "core:strings"

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

Pipeline_Impl :: struct {
    shader_handle: u32,
    uniform_locations: map[string]i32,

    layout_handle: u32,
    layout_strides: []i32,
    layout_offsets: []u32,
    layout_elements: []gfx.Layout_Element,

    is_draw_pipeline: bool,

    states: Pipeline_States,
    render_target: Maybe(Gl3Framebuffer),
}

Gl3Pipeline :: ^Pipeline_Impl

pipeline_new :: proc(desc: gfx.Pipeline_Descriptor, render_target: Maybe(Gl3Framebuffer) = nil) -> Gl3Pipeline {
    pipeline := new(Pipeline_Impl, CONTEXT.gl_allocator)

    if desc.vertex_source != nil && desc.fragment_source != nil {
        gl.GenVertexArrays(1, &pipeline.layout_handle)
        pipeline_layout_resolve(pipeline, desc.layout)

        vertex_source := strings.clone_to_cstring(desc.vertex_source.?, CONTEXT.gl_allocator)
        defer delete(vertex_source, CONTEXT.gl_allocator)
        fragment_source := strings.clone_to_cstring(desc.fragment_source.?, CONTEXT.gl_allocator)
        defer delete(fragment_source, CONTEXT.gl_allocator)

        vertex_shader := gl.CreateShader(gl.VERTEX_SHADER)
        defer gl.DeleteShader(vertex_shader)
        gl.ShaderSource(vertex_shader, 1, &vertex_source, nil)
        gl.CompileShader(vertex_shader)
        glshader_check_errors(vertex_shader)        

        fragment_shader := gl.CreateShader(gl.FRAGMENT_SHADER)
        defer gl.DeleteShader(fragment_shader)
        gl.ShaderSource(fragment_shader, 1, &fragment_source, nil)
        gl.CompileShader(fragment_shader)
        glshader_check_errors(fragment_shader)

        pipeline.shader_handle = gl.CreateProgram()
        gl.AttachShader(pipeline.shader_handle, vertex_shader)
        gl.AttachShader(pipeline.shader_handle, fragment_shader)
        gl.LinkProgram(pipeline.shader_handle)
        if glprogram_check_errors(pipeline.shader_handle) do panic("Could not compile shaders.")
        
        pipeline.uniform_locations = make(map[string]i32, 16, CONTEXT.gl_allocator)

        pipeline.is_draw_pipeline = true
    } else do pipeline.is_draw_pipeline = false

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

    return pipeline
}

pipeline_free :: proc(pipeline: Gl3Pipeline) {
    if pipeline.is_draw_pipeline {
        gl.DeleteProgram(pipeline.shader_handle)
        pipeline.shader_handle = INVALID_HANDLE

        gl.DeleteVertexArrays(1, &pipeline.layout_handle)
        pipeline.layout_handle = INVALID_HANDLE

        delete(pipeline.layout_strides)
        delete(pipeline.layout_offsets)
        delete(pipeline.layout_elements)
        delete(pipeline.uniform_locations)
    }

    free(pipeline, CONTEXT.gl_allocator)
}

pipeline_resize :: proc(pipeline: Gl3Pipeline, new_size: [2]uint) {
    pipeline.states.viewport_size = new_size
}

pipeline_clear :: proc(pipeline: Gl3Pipeline) {
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

pipeline_set_wireframe :: proc(pipeline: Gl3Pipeline, wireframe: bool) {
    pipeline.states.wireframe = wireframe
}

pipeline_draw_arrays :: proc(pipeline: Gl3Pipeline, bindings: Gl3Bindings, primitive: gfx.Primitive, first: int, count: int) {
    pipeline_apply(pipeline)
    pipeline_bind(pipeline)
    bindings_apply(pipeline, bindings)

    gl.DrawArrays(primitive_to_glenum(primitive), (i32)(first), (i32)(count))

    pipeline_layout_unbind()
}

pipeline_draw_elements :: proc(pipeline: Gl3Pipeline, bindings: Gl3Bindings, primitive: gfx.Primitive, count: int) {
    pipeline_apply(pipeline)
    pipeline_bind(pipeline)
    bindings_apply(pipeline, bindings)

    gl.DrawElements(primitive_to_glenum(primitive), (i32)(count), indextype_to_glenum(bindings.index_buffer.?.index_type), nil)

    pipeline_layout_unbind()
}

pipeline_draw_arrays_instanced :: proc(pipeline: Gl3Pipeline, bindings: Gl3Bindings, primitive: gfx.Primitive, first: int, count: int, instance_count: int) {
    pipeline_apply(pipeline)
    pipeline_bind(pipeline)
    bindings_apply(pipeline, bindings)

    gl.DrawArraysInstanced(primitive_to_glenum(primitive), (i32)(first), (i32)(count), (i32)(instance_count))

    pipeline_layout_unbind()
}

pipeline_draw_elements_instanced :: proc(pipeline: Gl3Pipeline, bindings: Gl3Bindings, primitive: gfx.Primitive, count: int, instance_count: int) {
    pipeline_apply(pipeline)
    pipeline_bind(pipeline)
    bindings_apply(pipeline, bindings)

    gl.DrawElementsInstanced(primitive_to_glenum(primitive), (i32)(count), indextype_to_glenum(bindings.index_buffer.?.index_type), nil, (i32)(instance_count))

    pipeline_layout_unbind()
}

pipeline_uniform_1f :: proc(pipeline: Gl3Pipeline, uniform_name: string, value: f32) {
    if loc, ok := pipeline_find_uniform_location(pipeline, uniform_name); !ok {
        log.warn("Could not find the uniform", uniform_name, "in pipeline", pipeline.shader_handle)
    } else {
        glsm.UseProgram(pipeline.shader_handle)
        gl.Uniform1f(loc, value)
    }
}

pipeline_uniform_2f :: proc(pipeline: Gl3Pipeline, uniform_name: string, value: [2]f32) {
    if loc, ok := pipeline_find_uniform_location(pipeline, uniform_name); !ok {
        log.warn("Could not find the uniform", uniform_name, "in pipeline", pipeline.shader_handle)
    } else {
        glsm.UseProgram(pipeline.shader_handle)
        gl.Uniform2f(loc, value.x, value.y)
    }
}

pipeline_uniform_3f :: proc(pipeline: Gl3Pipeline, uniform_name: string, value: [3]f32) {
    if loc, ok := pipeline_find_uniform_location(pipeline, uniform_name); !ok {
        log.warn("Could not find the uniform", uniform_name, "in pipeline", pipeline.shader_handle)
    } else {
        glsm.UseProgram(pipeline.shader_handle)
        gl.Uniform3f(loc, value.x, value.y, value.z)
    }
}

pipeline_uniform_4f :: proc(pipeline: Gl3Pipeline, uniform_name: string, value: [4]f32) {
    if loc, ok := pipeline_find_uniform_location(pipeline, uniform_name); !ok {
        log.warn("Could not find the uniform", uniform_name, "in pipeline", pipeline.shader_handle)
    } else {
        glsm.UseProgram(pipeline.shader_handle)
        gl.Uniform4f(loc, value.x, value.y, value.z, value.w)
    }
}

pipeline_uniform_mat4f :: proc(pipeline: Gl3Pipeline, uniform_name: string, value: ^matrix[4, 4]f32) {
    if loc, ok := pipeline_find_uniform_location(pipeline, uniform_name); !ok {
        log.warn("Could not find the uniform", uniform_name, "in pipeline", pipeline.shader_handle)
    } else {
        glsm.UseProgram(pipeline.shader_handle)
        gl.UniformMatrix4fv(loc, 1, false, &value[0, 0])
    }
}

pipeline_uniform_1i :: proc(pipeline: Gl3Pipeline, uniform_name: string, value: i32) {
    if loc, ok := pipeline_find_uniform_location(pipeline, uniform_name); !ok {
        log.warn("Could not find the uniform", uniform_name, "in pipeline", pipeline.shader_handle)
    } else {
        glsm.UseProgram(pipeline.shader_handle)
        gl.Uniform1i(loc, value)
    }
}

pipeline_get_size :: proc(pipeline: Gl3Pipeline) -> [2]uint {
    return pipeline.states.viewport_size
}

pipeline_is_draw_pipeline :: proc(pipeline: Gl3Pipeline) -> bool {
    return pipeline.is_draw_pipeline
}

pipeline_is_wireframe :: proc(pipeline: Gl3Pipeline) -> bool {
    return pipeline.states.wireframe
}

pipeline_does_uniform_exist :: proc(pipeline: Gl3Pipeline, uniform_name: string) -> bool {
    _, ok := pipeline_find_uniform_location(pipeline, uniform_name)
    return ok
}

/**************************************************************************************************
***************************************************************************************************
**************************************************************************************************/

@(private)
pipeline_bind :: proc(pipeline: Gl3Pipeline) {
    if pipeline.is_draw_pipeline {
        pipeline_shader_bind(pipeline)
        pipeline_layout_bind(pipeline)
    }

    pipeline_bind_rendertarget(pipeline)
}

@(private)
pipeline_apply :: proc(pipeline: Gl3Pipeline) {
    pipeline_bind(pipeline)

    if !pipeline.is_draw_pipeline do return

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
pipeline_bind_rendertarget :: proc(pipeline: Gl3Pipeline) {
    if pipeline.render_target != nil do framebuffer_bind(pipeline.render_target.(Gl3Framebuffer))
    else do bind_to_default_framebuffer()

    glsm.Viewport(0, 0, (i32)(pipeline.states.viewport_size.x), (i32)(pipeline.states.viewport_size.y))
}

@(private)
pipeline_layout_resolve :: proc(pipeline: Gl3Pipeline, elements: []gfx.Layout_Element) {
    buffer_count := pipeline_layout_find_buffer_count(elements)

    pipeline.layout_strides = make([]i32, len(elements), CONTEXT.gl_allocator)
    pipeline.layout_elements = make([]gfx.Layout_Element, len(elements), CONTEXT.gl_allocator)
    pipeline.layout_offsets = make([]u32, len(elements), CONTEXT.gl_allocator)

    strides := make([]uint, buffer_count, CONTEXT.gl_allocator)
    defer delete(strides)

    offsets := make([]uint, buffer_count, CONTEXT.gl_allocator)
    defer delete(offsets)

    for elem in elements do strides[elem.buffer_idx] += size_of_gl_type(elementtype_to_gltype(elem.type)) * elem.count
    for stride, i in strides do offsets[i] = stride

    for i := len(elements) - 1; i >= 0; i -= 1 {
        offsets[elements[i].buffer_idx] -= size_of_gl_type(elementtype_to_gltype(elements[i].type)) * elements[i].count

        pipeline.layout_elements[i] = elements[i]
        pipeline.layout_strides[i] = (i32)(strides[elements[i].buffer_idx])
        pipeline.layout_offsets[i] = (u32)(offsets[elements[i].buffer_idx])
    }
}

@(private)
pipeline_layout_find_buffer_count :: proc(elements: []gfx.Layout_Element) -> (count: uint = 0) {
    for elem in elements {
        if elem.buffer_idx > count do count = elem.buffer_idx
    }
    count += 1

    return
}

@(private)
pipeline_layout_apply_without_index_buffer :: proc(pipeline: Gl3Pipeline, vertex_buffers: []Gl3Buffer) {
    pipeline_layout_bind(pipeline)

    for elem, i in pipeline.layout_elements {
        buffer_non_dsa_bind(vertex_buffers[elem.buffer_idx])

        gl.VertexAttribPointer((u32)(i), (i32)(elem.count), elementtype_to_gltype(elem.type), elem.normalized, pipeline.layout_strides[i], (uintptr)(pipeline.layout_offsets[i]))
        gl.EnableVertexAttribArray((u32)(i))

        buffer_non_dsa_bind(vertex_buffers[elem.buffer_idx])

        gl.VertexAttribDivisor((u32)(i), (u32)(elem.divisor))
    }
}

@(private)
pipeline_layout_apply_with_index_buffer :: proc(pipeline: Gl3Pipeline, vertex_buffers: []Gl3Buffer, index_buffer: Gl3Buffer) {
    assert(index_buffer.type == .Index_Buffer)

    pipeline_layout_apply_without_index_buffer(pipeline, vertex_buffers)
    buffer_non_dsa_bind(index_buffer)
    pipeline_layout_bind(pipeline)
}

@(private)
pipeline_layout_unbind :: proc() {
    glsm.BindVertexArray(0)
}

@(private)
pipeline_layout_apply :: proc { pipeline_layout_apply_without_index_buffer, pipeline_layout_apply_with_index_buffer }

@(private)
pipeline_layout_bind :: proc(pipeline: Gl3Pipeline) {
    glsm.BindVertexArray(pipeline.layout_handle)
}

@(private)
pipeline_shader_bind :: proc(pipeline: Gl3Pipeline) {
    glsm.UseProgram(pipeline.shader_handle)
}

@(private)
pipeline_texture_apply :: proc(pipeline: Gl3Pipeline, texture: Gl3Texture, texture_unit: u32, uniform_name: string) {
    texture_full_bind(texture, (u32)(texture_unit))
    pipeline_uniform_1i(pipeline, uniform_name, (i32)(texture_unit))
}

@(private)
pipeline_uniformbuffer_apply :: proc(pipeline: Gl3Pipeline, location_idx: u32, uniform_name: string) {
    c_uniform_name := strings.clone_to_cstring(uniform_name, CONTEXT.gl_allocator)
    defer delete(c_uniform_name)
    loc := gl.GetUniformBlockIndex(pipeline.shader_handle, c_uniform_name)
    gl.UniformBlockBinding(pipeline.shader_handle, (u32)(loc), location_idx)
}

@(private)
pipeline_find_uniform_location :: proc(pipeline: Gl3Pipeline, uniform_name: string) -> (i32, bool) {
    if uniform_name in pipeline.uniform_locations do return pipeline.uniform_locations[uniform_name], true

    c_uniform_name := strings.clone_to_cstring(uniform_name)
    loc := gl.GetUniformLocation(pipeline.shader_handle, c_uniform_name)
    defer delete(c_uniform_name)

    pipeline.uniform_locations[uniform_name] = loc

    return loc, loc != -1
}

@(private)
glshader_check_errors :: proc(shader: u32) -> bool {
    success: i32 = ---
    if gl.GetShaderiv(shader, gl.COMPILE_STATUS, &success); success == 0 {
        log_size: i32 = ---
        gl.GetShaderiv(shader, gl.INFO_LOG_LENGTH, &log_size)

        message := make([]u8, log_size + 1, CONTEXT.gl_allocator)

        gl.GetShaderInfoLog(shader, log_size, nil, raw_data(message))
        log.error("Vertex Shader Compilation failed:")
        log.error("\t", string(message[:log_size]))

        delete(message, CONTEXT.gl_allocator)

        return true
    }

    return false
}

@(private)
glprogram_check_errors :: proc(program: u32) -> bool {
    success: i32 = ---
    if gl.GetProgramiv(program, gl.LINK_STATUS, &success); success == 0 {
        log_size: i32 = ---
        gl.GetProgramiv(program, gl.INFO_LOG_LENGTH, &log_size)

        message := make([]u8, log_size + 1, CONTEXT.gl_allocator)

        gl.GetProgramInfoLog(program, log_size, nil, raw_data(message))
        log.error("Shader Compilation failed:")
        log.error("\t", string(message[:log_size]))

        delete(message, CONTEXT.gl_allocator)

        return true
    }

    return false
}

@(private)
cullface_to_glenum :: proc(face: gfx.Cull_Face) -> u32 {
    switch face {
        case .Front: return gl.FRONT
        case .Back: return gl.BACK
    }

    return 0
}

@(private)
frontface_to_glenum :: proc(front: gfx.Front_Face) -> u32 {
    switch front {
        case .Clockwise: return gl.CW
        case .Counter_Clockwise: return gl.CCW
    }

    return 0
}

@(private)
depthfunc_to_glenum :: proc(func: gfx.Depth_Func) -> u32 {
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
blendfunc_to_glenum :: proc(blend: gfx.Blend_Func) -> u32 {
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
primitive_to_glenum :: proc(primitive: gfx.Primitive) -> u32 {
    switch primitive {
        case .Triangles: return gl.TRIANGLES
    }

    return 0
}

@(private)
elementtype_to_gltype :: proc(type: gfx.Element_Type) -> u32 {
    switch type {
        case .F16: return gl.HALF_FLOAT
        case .F32: return gl.FLOAT
        case .F64: return gl.DOUBLE
        case .U8: return gl.UNSIGNED_BYTE
        case .I8: return gl.BYTE
        case .U16: return gl.UNSIGNED_SHORT
        case .I16: return gl.SHORT
        case .U32: return gl.UNSIGNED_INT
        case .I32: return gl.INT
    }

    return 0
}
