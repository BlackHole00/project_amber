package vx_lib_gfx

when ODIN_OS == .Darwin {

import "core:math/linalg/glsl"
import "core:log"
import "core:os"
import NS "vendor:darwin/foundation"
import MTL "vendor:darwin/Metal"

@(private)
Mtl_Extra_Data :: struct {
    uniform_buffers: []Buffer,
    pass: ^MTL.RenderPassDescriptor,
}

@(private)
_metalimpl_pipeline_init :: proc(pipeline: ^Pipeline, desc: Pipeline_Descriptor, render_target: Maybe(Framebuffer) = nil) {
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
    pipeline.states.clear_color = desc.clear_color
    pipeline.states.wireframe = desc.wireframe
    pipeline.states.viewport_size = desc.viewport_size
    pipeline.states.clearing_color = desc.clearing_color
    pipeline.states.clear_depth = desc.clear_depth
    
    pipeline.uniform_locations = desc.uniform_locations

    pipeline.render_target = render_target

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

    if render_target == nil do desc->colorAttachments()->object(0)->setPixelFormat(.BGRA8Unorm_sRGB)
    else do panic("TODO!") // desc->colorAttachments()->object(0)->setPixelFormat(framebuffer_get_texture_format(render_target.(Framebuffer)))

    mtl_pipeline, mtl_pipeline_err := METAL_CONTEXT.device->newRenderPipelineStateWithDescriptor(desc)
    if mtl_pipeline_err != nil do panic("Could not create a metal pipeline")
	pipeline.shader_handle = _metalimpl_metalpipeline_to_shader_handle(mtl_pipeline)

    (^Mtl_Extra_Data)(pipeline.extra_data).pass = MTL.RenderPassDescriptor.renderPassDescriptor()
}

@(private)
_metalimpl_pipeline_free :: proc(pipeline: ^Pipeline) {
    for buffer in &(^Mtl_Extra_Data)(pipeline.extra_data).uniform_buffers do buffer_free(&buffer)

    delete((^Mtl_Extra_Data)(pipeline.extra_data).uniform_buffers)
    free(pipeline.extra_data)
}

@(private)
_metalimpl_pipeline_resize :: proc(pipeline: ^Pipeline, new_size: [2]uint) {
}

@(private)
_metalimpl_pipeline_clear :: proc(pipeline: Pipeline) {
    if pipeline.states.clear_color {
        // Listen to this: Odin is actually bugged, I believe. The value passed to clear color is not
        // the one actually received by the function. :-P

        color_attachment := _metalimpl_pipeline_get_pass(pipeline)->colorAttachments()->object(0)
        assert(color_attachment != nil)
        color_attachment->setClearColor(MTL.ClearColor { 
            (f64)(pipeline.states.clearing_color[0]),
            (f64)(pipeline.states.clearing_color[1]),
            (f64)(pipeline.states.clearing_color[2]),
            (f64)(pipeline.states.clearing_color[3]),
        })
        color_attachment->setLoadAction(.Clear)
        color_attachment->setStoreAction(.Store)
        color_attachment->setTexture(METAL_CONTEXT.drawable->texture())
    }
}

@(private)
_metalimpl_pipeline_set_wireframe :: proc(pipeline: ^Pipeline, wireframe: bool) {
}

@(private)
_metalimpl_pipeline_draw_arrays :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, first: int, count: int) {
}

@(private)
_metalimpl_pipeline_draw_elements :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, type: Index_Type, count: int) {
}

@(private)
_metalimpl_pipeline_draw_arrays_instanced :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, first: int, count: int, instance_count: int) {
}

@(private)
_metalimpl_pipeline_draw_elements_instanced :: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, type: Index_Type, count: int, instance_count: int) {
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

_metalimpl_pipeline_get_pass :: proc(pipeline: Pipeline) -> ^MTL.RenderPassDescriptor {
    return (^Mtl_Extra_Data)(pipeline.extra_data).pass
}

}