//+build darwin
package vx_lib_gfx

when ODIN_OS == .Darwin {

import "core:math/linalg/glsl"
import "core:log"
import "core:os"
import NS "vendor:darwin/Foundation"
import MTL "vendor:darwin/Metal"

@(private)
Mtl_Extra_Data :: struct {
    uniform_buffers: []Buffer,
}

@(private)
_metalimpl_pipeline_init :: proc(pipeline: ^Pipeline, desc: Pipeline_Descriptor, pass: ^Pass) {
    if desc.layout == nil do log.warn("Creating a pipeline without a layout. This is fine in Metal, but will be a bug in other APIs")

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
    pipeline.states.wireframe = desc.wireframe

    pipeline.uniform_locations = desc.uniform_locations

    pipeline.extra_data = (rawptr)(new(Mtl_Extra_Data))
    (^Mtl_Extra_Data)(pipeline.extra_data).uniform_buffers = make([]Buffer, desc.uniform_locations)
    for buffer in &(^Mtl_Extra_Data)(pipeline.extra_data).uniform_buffers do buffer_init(&buffer, Buffer_Descriptor {
        type = .Uniform_Buffer,
        usage = .Dynamic_Draw,
    })

    files := get_shader_files_from_name(desc.source_path)
    defer {
        for file in files do delete(file)
        delete(files)
    }

    source, source_ok := os.read_entire_file(files[0])
	if !source_ok do panic("Could not open metal shader file")
    defer delete(source)

    source_str := NS.String.alloc()->initWithOdinString((string)(source))
	defer source_str->release()

	library, library_err := METAL_CONTEXT.device->newLibraryWithSource(source_str, nil)
    if library_err != nil {
        log.error(library_err->localizedDescription()->odinString())
        panic("Could not compile metal shader")
    }
    defer library->release()

	vertex_function := library->newFunctionWithName(NS.AT(SHADER_VERTEX_MAIN_FUNCTION))
	fragment_function := library->newFunctionWithName(NS.AT(SHADER_FRAGMENT_MAIN_FUNCTION))
	defer vertex_function->release()
	defer fragment_function->release()

	mtl_desc := MTL.RenderPipelineDescriptor.alloc()->init()
	defer mtl_desc->release()

	mtl_desc->setVertexFunction(vertex_function)
	mtl_desc->setFragmentFunction(fragment_function)

    // TODO: customization of pixel formats
    mtl_desc->colorAttachments()->object(0)->setPixelFormat(.BGRA8Unorm_sRGB)

    if pipeline.states.blend_enabled {
        color_attachment := mtl_desc->colorAttachments()->object(0)
        color_attachment->setBlendingEnabled(true)

        color_attachment->setDestinationRGBBlendFactor(_metalimpl_blendfunc_to_mtl(desc.blend_dst_rgb_func))
        color_attachment->setDestinationAlphaBlendFactor(_metalimpl_blendfunc_to_mtl(desc.blend_dstdst_alphargb_func))
        color_attachment->setSourceAlphaBlendFactor(_metalimpl_blendfunc_to_mtl(desc.blend_src_alpha_func))
        color_attachment->setSourceRGBBlendFactor(_metalimpl_blendfunc_to_mtl(desc.blend_src_rgb_func))
    }

    if pipeline.states.depth_enabled do panic("TODO!")

    mtl_pipeline, mtl_pipeline_err := METAL_CONTEXT.device->newRenderPipelineStateWithDescriptor(mtl_desc)
    if mtl_pipeline_err != nil {
        log.error(mtl_pipeline_err->localizedDescription()->odinString())
        panic("Could not compile metal shader")
    }

	pipeline.shader_handle = _metalimpl_metalpipeline_to_shader_handle(mtl_pipeline)

    pipeline.pass = pass
}

@(private)
_metalimpl_pipeline_free :: proc(pipeline: ^Pipeline) {
    for buffer in &(^Mtl_Extra_Data)(pipeline.extra_data).uniform_buffers do buffer_free(&buffer)

    delete((^Mtl_Extra_Data)(pipeline.extra_data).uniform_buffers)
    free(pipeline.extra_data)
}

@(private)
_metalimpl_pipeline_set_wireframe :: proc(pipeline: ^Pipeline, wireframe: bool) {
    pipeline.states.wireframe = wireframe
}

@(private)
_metalimpl_pipeline_draw_arrays :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, first: int, count: int) {
    render_encoder: ^MTL.RenderCommandEncoder = _metalimpl_pipeline_get_mtl_rendererencoder(pipeline^)
    defer render_encoder->release()

    _metalimpl_bindings_apply(bindings, render_encoder, (^Mtl_Extra_Data)(pipeline.extra_data).uniform_buffers)
	render_encoder->drawPrimitives(_metalimpl_primitive_to_mtl(primitive), (NS.UInteger)(first), (NS.UInteger)(count))

	render_encoder->endEncoding()
}

@(private)
_metalimpl_pipeline_draw_elements :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, type: Index_Type, count: int) {
    render_encoder: ^MTL.RenderCommandEncoder = _metalimpl_pipeline_get_mtl_rendererencoder(pipeline^)
    defer render_encoder->release()

    _metalimpl_bindings_apply(bindings, render_encoder, (^Mtl_Extra_Data)(pipeline.extra_data).uniform_buffers)
    render_encoder->drawIndexedPrimitives(
        _metalimpl_primitive_to_mtl(primitive), 
        (NS.UInteger)(count), 
        _metalimpl_indextype_to_mtl(type), 
        _metalimpl_buffer_get_mtl_buffer(bindings.index_buffer.(Buffer)),
        0,
    )

	render_encoder->endEncoding()
}

@(private)
_metalimpl_pipeline_draw_arrays_instanced :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, first: int, count: int, instance_count: int) {
    render_encoder: ^MTL.RenderCommandEncoder = _metalimpl_pipeline_get_mtl_rendererencoder(pipeline^)
    defer render_encoder->release()

    _metalimpl_bindings_apply(bindings, render_encoder, (^Mtl_Extra_Data)(pipeline.extra_data).uniform_buffers)
	render_encoder->drawPrimitivesWithInstanceCount(_metalimpl_primitive_to_mtl(primitive), (NS.UInteger)(first), (NS.UInteger)(count), (NS.UInteger)(instance_count))

	render_encoder->endEncoding()
}

@(private)
_metalimpl_pipeline_draw_elements_instanced :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, type: Index_Type, count: int, instance_count: int) {
    render_encoder: ^MTL.RenderCommandEncoder = _metalimpl_pipeline_get_mtl_rendererencoder(pipeline^)
    defer render_encoder->release()

    _metalimpl_bindings_apply(bindings, render_encoder, (^Mtl_Extra_Data)(pipeline.extra_data).uniform_buffers)
    render_encoder->drawIndexedPrimitivesWithInstanceCount(
        _metalimpl_primitive_to_mtl(primitive), 
        (NS.UInteger)(count), 
        _metalimpl_indextype_to_mtl(type), 
        _metalimpl_buffer_get_mtl_buffer(bindings.index_buffer.(Buffer)),
        0,
        (NS.UInteger)(instance_count),
    )

	render_encoder->endEncoding()
}

@(private)
_metalimpl_pipeline_uniform_1f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: f32) {
    value_cpy := value
    buffer_set_data_raw(&(^Mtl_Extra_Data)(pipeline.extra_data).uniform_buffers[uniform_location], &value_cpy, size_of(f32))
}

@(private)
_metalimpl_pipeline_uniform_2f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: glsl.vec2) {
    value_cpy := value
    buffer_set_data_raw(&(^Mtl_Extra_Data)(pipeline.extra_data).uniform_buffers[uniform_location], &value_cpy, size_of(glsl.vec2))
}

@(private)
_metalimpl_pipeline_uniform_3f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: glsl.vec3) {
    value_cpy := value
    buffer_set_data_raw(&(^Mtl_Extra_Data)(pipeline.extra_data).uniform_buffers[uniform_location], &value_cpy, size_of(glsl.vec3))
}

@(private)
_metalimpl_pipeline_uniform_4f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: glsl.vec4) {
    value_cpy := value
    buffer_set_data_raw(&(^Mtl_Extra_Data)(pipeline.extra_data).uniform_buffers[uniform_location], &value_cpy, size_of(glsl.vec4))
}

@(private)
_metalimpl_pipeline_uniform_mat4f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: glsl.mat4) {
    value_cpy := value
    buffer_set_data_raw(&(^Mtl_Extra_Data)(pipeline.extra_data).uniform_buffers[uniform_location], &value_cpy, size_of(glsl.mat4))
}

@(private)
_metalimpl_pipeline_uniform_1i :: proc(pipeline: ^Pipeline, uniform_location: uint, value: i32) {
    value_cpy := value
    buffer_set_data_raw(&(^Mtl_Extra_Data)(pipeline.extra_data).uniform_buffers[uniform_location], &value_cpy, size_of(i32))
}

@(private)
_metalimpl_shaderhandle_to_metalpipeline :: proc(handle: Gfx_Handle) -> ^MTL.RenderPipelineState {
    return transmute(^MTL.RenderPipelineState)(handle)
}

@(private)
_metalimpl_metalpipeline_to_shader_handle :: proc(buffer: ^MTL.RenderPipelineState) -> Gfx_Handle {
    return transmute(Gfx_Handle)(buffer)
}

@(private)
_metalimpl_pipeline_get_mtl_pipeline :: proc(pipeline: Pipeline) -> ^MTL.RenderPipelineState {
    return _metalimpl_shaderhandle_to_metalpipeline(pipeline.shader_handle)
}

@(private)
_metalimpl_primitive_to_mtl :: proc(primitive: Primitive) -> MTL.PrimitiveType {
    switch primitive {
        case .Triangles: return .Triangle
    }

    return .Triangle
}

@(private)
_metalimpl_indextype_to_mtl :: proc(type: Index_Type) -> MTL.IndexType {
    switch type {
        case .U16: return .UInt16
        case .U32: return .UInt32
    }

    return .UInt32
}

@(private)
_metalimpl_cullface_to_mtl :: proc(face: Cull_Face) -> MTL.CullMode {
    switch face {
        case .Front: return .Front
        case .Back: return .Back
    }

    return .None
}

@(private)
_metalimpl_frontface_to_mtl :: proc(front: Front_Face) -> MTL.Winding {
    switch front {
        case .Clockwise: return .Clockwise
        case .Counter_Clockwise: return .CounterClockwise
    }

    return .Clockwise
}


@(private)
_metalimpl_blendfunc_to_mtl :: proc(func: Blend_Func) -> MTL.BlendFactor {
    switch func {
        case .Constant_Color: return .BlendColor
        case .Constant_Alpha: return .BlendAlpha
        case .One: return .One
        case .Zero: return .Zero
        case .Dst_Alpha: return .DestinationAlpha
        case .Dst_Color: return .DestinationColor
        case .One_Minus_Constant_Alpha: return .OneMinusBlendAlpha
        case .One_Minus_Constant_Color: return .OneMinusBlendColor
        case .One_Minus_Dst_Alpha: return .OneMinusDestinationAlpha
        case .One_Minus_Dst_Color: return .OneMinusDestinationColor
        case .One_Minus_Src_Alpha: return .OneMinusSourceAlpha
        case .One_Minus_Src_Color: return .OneMinusSourceColor
        case .Src_Alpha: return .SourceAlpha
        case .Src_Color: return .Source1Color
        case .Src_Alpha_Saturate: return .SourceAlphaSaturated
        case .Src1_Alpha: return .Source1Alpha
        case .Src1_Color: return .Source1Color
    }

    return .One
}

@(private)
_metalimpl_pipeline_get_mtl_rendererencoder :: proc(pipeline: Pipeline) -> (encoder: ^MTL.RenderCommandEncoder) {
    // If we do not have a render texture target, we request the command buffer from the default pass
    encoder = _metalimpl_pass_get_commandbuffer(pipeline.pass^)->renderCommandEncoderWithDescriptor(_metalimpl_pass_get_mtl_pass(pipeline.pass^))

    if pipeline.states.cull_enabled {
        encoder->setCullMode(_metalimpl_cullface_to_mtl(pipeline.states.cull_face))
        encoder->setFrontFacingWinding(_metalimpl_frontface_to_mtl(pipeline.states.cull_front_face))
    } else do encoder->setCullMode(.None)

    if pipeline.states.blend_enabled do encoder->setBlendColorRed( // ???
        pipeline.states.blend_color[0],
        pipeline.states.blend_color[1],
        pipeline.states.blend_color[2],
        pipeline.states.blend_color[3],
    )

    if pipeline.states.wireframe do encoder->setTriangleFillMode(.Lines)

    //if pipeline.states.depth_enabled {
    //    glsm.Enable(gl.DEPTH_TEST)
    //    glsm.DepthFunc(_glimpl_depthfunc_to_glenum(pipeline.states.depth_func))
    //} else do glsm.Disable(gl.DEPTH_TEST)

    //if pipeline.states.wireframe do glsm.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
    //else do glsm.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)

    encoder->setRenderPipelineState(_metalimpl_pipeline_get_mtl_pipeline(pipeline))

    return
}

}