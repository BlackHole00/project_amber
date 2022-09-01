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
_metalimpl_pipeline_init :: proc(pipeline: ^Pipeline, desc: Pipeline_Descriptor) {
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
    if library_err != nil do panic("Could not compile metal shader")
    defer library->release()

	vertex_function := library->newFunctionWithName(NS.AT(SHADER_VERTEX_MAIN_FUNCTION))
	fragment_function := library->newFunctionWithName(NS.AT(SHADER_FRAGMENT_MAIN_FUNCTION))
	defer vertex_function->release()
	defer fragment_function->release()

	desc := MTL.RenderPipelineDescriptor.alloc()->init()
	defer desc->release()

	desc->setVertexFunction(vertex_function)
	desc->setFragmentFunction(fragment_function)

    desc->colorAttachments()->object(0)->setPixelFormat(.BGRA8Unorm_sRGB)

    mtl_pipeline, mtl_pipeline_err := METAL_CONTEXT.device->newRenderPipelineStateWithDescriptor(desc)
    if mtl_pipeline_err != nil do panic("Could not create a metal pipeline")
	pipeline.shader_handle = _metalimpl_metalpipeline_to_shader_handle(mtl_pipeline)
}

@(private)
_metalimpl_pipeline_free :: proc(pipeline: ^Pipeline) {
    for buffer in &(^Mtl_Extra_Data)(pipeline.extra_data).uniform_buffers do buffer_free(&buffer)

    delete((^Mtl_Extra_Data)(pipeline.extra_data).uniform_buffers)
    free(pipeline.extra_data)
}

@(private)
_metalimpl_pipeline_set_wireframe :: proc(pipeline: ^Pipeline, wireframe: bool) {
}

@(private)
_metalimpl_pipeline_draw_arrays :: proc(pipeline: ^Pipeline, pass: ^Pass, bindings: ^Bindings, primitive: Primitive, first: int, count: int) {
    render_encoder: ^MTL.RenderCommandEncoder
    defer render_encoder->release()

    if pass.render_target == nil do render_encoder = _metalimpl_pass_get_commandbuffer(pass^)->renderCommandEncoderWithDescriptor(_metalimpl_pass_get_mtl_pass(pass^))
    else do panic("TODO!")

	render_encoder->setRenderPipelineState(_metalimpl_pipeline_get_mtl_pipeline(pipeline^))
    _metalimpl_bindings_apply(bindings, render_encoder)
	render_encoder->drawPrimitives(_metalimpl_primitive_to_glenum(primitive), (NS.UInteger)(first), (NS.UInteger)(count))

	render_encoder->endEncoding()
}

@(private)
_metalimpl_pipeline_draw_elements :: proc(pipeline: ^Pipeline, pass: ^Pass, bindings: ^Bindings, primitive: Primitive, type: Index_Type, count: int) {
    render_encoder: ^MTL.RenderCommandEncoder
    defer render_encoder->release()

    if pass.render_target == nil do render_encoder = _metalimpl_pass_get_commandbuffer(pass^)->renderCommandEncoderWithDescriptor(_metalimpl_pass_get_mtl_pass(pass^))
    else do panic("TODO!")

    if bindings.index_buffer == nil do panic("Requesting pipeline_draw_elements without an index buffer in the bindings")

	render_encoder->setRenderPipelineState(_metalimpl_pipeline_get_mtl_pipeline(pipeline^))
    _metalimpl_bindings_apply(bindings, render_encoder)
    render_encoder->drawIndexedPrimitives(
        _metalimpl_primitive_to_glenum(primitive), 
        (NS.UInteger)(count), 
        _metalimpl_indextype_to_glenum(type), 
        _metalimpl_buffer_get_mtl_buffer(bindings.index_buffer.(Buffer)),
        0,
    )

	render_encoder->endEncoding()
}

@(private)
_metalimpl_pipeline_draw_arrays_instanced :: proc(pipeline: ^Pipeline, pass: ^Pass, bindings: ^Bindings, primitive: Primitive, first: int, count: int, instance_count: int) {
    render_encoder: ^MTL.RenderCommandEncoder
    defer render_encoder->release()

    if pass.render_target == nil do render_encoder = _metalimpl_pass_get_commandbuffer(pass^)->renderCommandEncoderWithDescriptor(_metalimpl_pass_get_mtl_pass(pass^))
    else do panic("TODO!")

	render_encoder->setRenderPipelineState(_metalimpl_pipeline_get_mtl_pipeline(pipeline^))
    _metalimpl_bindings_apply(bindings, render_encoder)
	render_encoder->drawPrimitivesWithInstanceCount(_metalimpl_primitive_to_glenum(primitive), (NS.UInteger)(first), (NS.UInteger)(count), (NS.UInteger)(instance_count))

	render_encoder->endEncoding()
}

@(private)
_metalimpl_pipeline_draw_elements_instanced :: proc(pipeline: ^Pipeline, pass: ^Pass, bindings: ^Bindings, primitive: Primitive, type: Index_Type, count: int, instance_count: int) {
    render_encoder: ^MTL.RenderCommandEncoder
    defer render_encoder->release()

    if pass.render_target == nil do render_encoder = _metalimpl_pass_get_commandbuffer(pass^)->renderCommandEncoderWithDescriptor(_metalimpl_pass_get_mtl_pass(pass^))
    else do panic("TODO!")

    if bindings.index_buffer == nil do panic("Requesting pipeline_draw_elements without an index buffer in the bindings")

	render_encoder->setRenderPipelineState(_metalimpl_pipeline_get_mtl_pipeline(pipeline^))
    _metalimpl_bindings_apply(bindings, render_encoder)
    render_encoder->drawIndexedPrimitivesWithInstanceCount(
        _metalimpl_primitive_to_glenum(primitive), 
        (NS.UInteger)(count), 
        _metalimpl_indextype_to_glenum(type), 
        _metalimpl_buffer_get_mtl_buffer(bindings.index_buffer.(Buffer)),
        0,
        (NS.UInteger)(instance_count),
    )

	render_encoder->endEncoding()
}

@(private)
_metalimpl_pipeline_uniform_1f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: f32) {
}

@(private)
_metalimpl_pipeline_uniform_2f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: glsl.vec2) {
}

@(private)
_metalimpl_pipeline_uniform_3f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: glsl.vec3) {
}

@(private)
_metalimpl_pipeline_uniform_4f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: glsl.vec4) {
}

@(private)
_metalimpl_pipeline_uniform_mat4f :: proc(pipeline: ^Pipeline, uniform_location: uint, value: glsl.mat4) {
}

@(private)
_metalimpl_pipeline_uniform_1i :: proc(pipeline: ^Pipeline, uniform_location: uint, value: i32) {
}

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
_metalimpl_primitive_to_glenum :: proc(primitive: Primitive) -> MTL.PrimitiveType {
    switch primitive {
        case .Triangles: return .Triangle
    }

    return .Triangle
}

@(private)
_metalimpl_indextype_to_glenum :: proc(type: Index_Type) -> MTL.IndexType {
    switch type {
        case .U16: return .UInt16
        case .U32: return .UInt32
    }

    return .UInt32
}

}