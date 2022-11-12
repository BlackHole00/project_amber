package vx_lib_gfx

import "../core"
import "core:math/linalg/glsl"

Gfx_Procs :: struct {
    buffer_init_empty: proc(buffer: ^Buffer, desc: Buffer_Descriptor),
    buffer_init_with_data: proc(buffer: ^Buffer, desc: Buffer_Descriptor, data: []byte),
    buffer_set_data: proc(buffer: ^Buffer, data: []byte),
    buffer_free: proc(buffer: ^Buffer),

    texture_init_raw: proc(texture: ^Texture, desc: Texture_Descriptor),
    texture_init_with_size_1d: proc(texture: ^Texture, desc: Texture_Descriptor, size: uint),
    texture_init_with_size_2d: proc(texture: ^Texture, desc: Texture_Descriptor, dimension: [2]uint),
    texture_init_with_size_3d: proc(texture: ^Texture, desc: Texture_Descriptor, dimension: [3]uint),
    texture_free: proc(texture: ^Texture),
    texture_set_data_1d: proc(texture: Texture, data: []byte, texture_format: Texture_Format, offset: int),
    texture_set_data_2d: proc(texture: Texture, data: []byte, texture_format: Texture_Format, dimension: [2]uint, offset: [2]uint),
    texture_set_data_3d: proc(texture: Texture, data: []byte, texture_format: Texture_Format, dimension: [3]uint, offset: [3]uint),
    texture_set_data_cubemap_face: proc(texture: Texture, data: []byte, texture_format: Texture_Format, dimension: [2]uint, face: uint),
    texture_gen_mipmaps: proc(texture: Texture),
    texture_resize_1d: proc(texture: ^Texture, new_len: uint),
    texture_resize_2d: proc(texture: ^Texture, new_size: [2]uint),
    texture_resize_3d: proc(texture: ^Texture, new_size: [3]uint),
    texture_copy_1d: proc(src: Texture, dest: Texture, src_offset: [3]i32, dest_offset: [3]i32),
    texture_copy_2d: proc(src: Texture, dest: Texture, src_offset: [3]i32, dest_offset: [3]i32),
    texture_copy_3d: proc(src: Texture, dest: Texture, src_offset: [3]i32, dest_offset: [3]i32),

    framebuffer_init: proc(framebuffer: ^Framebuffer, desc: Framebuffer_Descriptor),
    framebuffer_free: proc(framebuffer: ^Framebuffer),
    framebuffer_get_color_texture_bindings: proc(framebuffer: Framebuffer, color_texture_location: uint) -> Texture_Binding,
    framebuffer_get_depth_stencil_texture_bindings: proc(framebuffer: Framebuffer, depth_stencil_texture_location: uint) -> Texture_Binding,

    pipeline_init: proc(pipeline: ^Pipeline, desc: Pipeline_Descriptor, pass: ^Pass),
    pipeline_free: proc(pipeline: ^Pipeline),
    pipeline_set_wireframe: proc(pipeline: ^Pipeline, wireframe: bool),
    pipeline_draw_arrays: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, first: int, count: int),
    pipeline_draw_elements: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, type: Index_Type, count: int),
    pipeline_draw_arrays_instanced: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, first: int, count: int, instance_count: int),
    pipeline_draw_elements_instanced: proc(pipeline: ^Pipeline, bindings: ^Bindings, primitive: Primitive, type: Index_Type, count: int, instance_count: int),
    pipeline_uniform_1f: proc(pipeline: ^Pipeline, uniform_location: uint, value: f32),
    pipeline_uniform_2f: proc(pipeline: ^Pipeline, uniform_location: uint, value: glsl.vec2),
    pipeline_uniform_3f: proc(pipeline: ^Pipeline, uniform_location: uint, value: glsl.vec3),
    pipeline_uniform_4f: proc(pipeline: ^Pipeline, uniform_location: uint, value: glsl.vec4),
    pipeline_uniform_mat4f: proc(pipeline: ^Pipeline, uniform_location: uint, value: glsl.mat4),
    pipeline_uniform_1i: proc(pipeline: ^Pipeline, uniform_location: uint, value: i32),

    pass_init: proc(pass: ^Pass, desc: Pass_Descriptor, target: Maybe(Framebuffer)),
    pass_begin: proc(pass: ^Pass),
    pass_end: proc(pass: ^Pass),
    pass_resize: proc(pass: ^Pass, size: [2]uint),
    pass_free: proc(pass: ^Pass),
}
GFX_PROCS: core.Cell(Gfx_Procs)

gfxprocs_init_with_opengl :: proc() {
    core.cell_init(&GFX_PROCS)

    GFX_PROCS.buffer_init_empty = _glimpl_buffer_init_empty
    GFX_PROCS.buffer_init_with_data = _glimpl_buffer_init_with_data
    GFX_PROCS.buffer_set_data = _glimpl_buffer_set_data
    GFX_PROCS.buffer_free = _glimpl_buffer_free

    GFX_PROCS.texture_init_raw = _glimpl_texture_init_raw
    GFX_PROCS.texture_init_with_size_1d = _glimpl_texture_init_with_size_1d
    GFX_PROCS.texture_init_with_size_2d = _glimpl_texture_init_with_size_2d
    GFX_PROCS.texture_init_with_size_3d = _glimpl_texture_init_with_size_3d
    GFX_PROCS.texture_free = _glimpl_texture_free
    GFX_PROCS.texture_set_data_1d = _glimpl_texture_set_data_1d
    GFX_PROCS.texture_set_data_2d = _glimpl_texture_set_data_2d
    GFX_PROCS.texture_set_data_3d = _glimpl_texture_set_data_3d
    GFX_PROCS.texture_set_data_cubemap_face = _glimpl_texture_set_data_cubemap_face
    GFX_PROCS.texture_gen_mipmaps = _glimpl_texture_gen_mipmaps
    GFX_PROCS.texture_resize_1d = _glimpl_texture_resize_1d
    GFX_PROCS.texture_resize_2d = _glimpl_texture_resize_2d
    GFX_PROCS.texture_resize_3d = _glimpl_texture_resize_3d
    GFX_PROCS.texture_copy_1d = _glimpl_texture_copy_1d
    GFX_PROCS.texture_copy_2d = _glimpl_texture_copy_2d
    GFX_PROCS.texture_copy_3d = _glimpl_texture_copy_3d

    GFX_PROCS.framebuffer_init = _glimpl_framebuffer_init
    GFX_PROCS.framebuffer_free = _glimpl_framebuffer_free
    GFX_PROCS.framebuffer_get_color_texture_bindings = _glimpl_framebuffer_get_color_texture_bindings
    GFX_PROCS.framebuffer_get_depth_stencil_texture_bindings = _glimpl_framebuffer_get_depth_stencil_texture_bindings

    GFX_PROCS.pipeline_init = _glimpl_pipeline_init
    GFX_PROCS.pipeline_free = _glimpl_pipeline_free
    GFX_PROCS.pipeline_set_wireframe = _glimpl_pipeline_set_wireframe
    GFX_PROCS.pipeline_draw_arrays = _glimpl_pipeline_draw_arrays
    GFX_PROCS.pipeline_draw_elements = _glimpl_pipeline_draw_elements
    GFX_PROCS.pipeline_draw_arrays_instanced = _glimpl_pipeline_draw_arrays_instanced
    GFX_PROCS.pipeline_draw_elements_instanced = _glimpl_pipeline_draw_elements_instanced
    GFX_PROCS.pipeline_uniform_1f = _glimpl_pipeline_uniform_1f
    GFX_PROCS.pipeline_uniform_2f = _glimpl_pipeline_uniform_2f
    GFX_PROCS.pipeline_uniform_3f = _glimpl_pipeline_uniform_3f
    GFX_PROCS.pipeline_uniform_4f = _glimpl_pipeline_uniform_4f
    GFX_PROCS.pipeline_uniform_mat4f = _glimpl_pipeline_uniform_mat4f
    GFX_PROCS.pipeline_uniform_1i = _glimpl_pipeline_uniform_1i

    GFX_PROCS.pass_init = _glimpl_pass_init
    GFX_PROCS.pass_begin = _glimpl_pass_begin
    GFX_PROCS.pass_end = _glimpl_pass_end
    GFX_PROCS.pass_resize = _glimpl_pass_resize
    GFX_PROCS.pass_free = _glimpl_pass_free
}

gfxprocs_init_empty :: proc() {
    core.cell_init(&GFX_PROCS)

    core.safetize_function(&GFX_PROCS.buffer_init_empty)
    core.safetize_function(&GFX_PROCS.buffer_init_with_data)
    core.safetize_function(&GFX_PROCS.buffer_set_data)
    core.safetize_function(&GFX_PROCS.buffer_free)
    core.safetize_function(&GFX_PROCS.texture_init_raw)
    core.safetize_function(&GFX_PROCS.texture_init_with_size_1d)
    core.safetize_function(&GFX_PROCS.texture_init_with_size_2d)
    core.safetize_function(&GFX_PROCS.texture_init_with_size_3d)
    core.safetize_function(&GFX_PROCS.texture_free)
    core.safetize_function(&GFX_PROCS.texture_set_data_1d)
    core.safetize_function(&GFX_PROCS.texture_set_data_2d)
    core.safetize_function(&GFX_PROCS.texture_set_data_3d)
    core.safetize_function(&GFX_PROCS.texture_set_data_cubemap_face)
    core.safetize_function(&GFX_PROCS.texture_gen_mipmaps )
    core.safetize_function(&GFX_PROCS.texture_resize_1d)
    core.safetize_function(&GFX_PROCS.texture_resize_2d)
    core.safetize_function(&GFX_PROCS.texture_resize_3d)
    core.safetize_function(&GFX_PROCS.texture_copy_1d)
    core.safetize_function(&GFX_PROCS.texture_copy_2d)
    core.safetize_function(&GFX_PROCS.texture_copy_3d)
    core.safetize_function(&GFX_PROCS.framebuffer_init )
    core.safetize_function(&GFX_PROCS.framebuffer_free )
    core.safetize_function(&GFX_PROCS.framebuffer_get_color_texture_bindings)
    core.safetize_function(&GFX_PROCS.framebuffer_get_depth_stencil_texture_bindings)
    core.safetize_function(&GFX_PROCS.pipeline_init)
    core.safetize_function(&GFX_PROCS.pipeline_free)
    core.safetize_function(&GFX_PROCS.pipeline_set_wireframe)
    core.safetize_function(&GFX_PROCS.pipeline_draw_arrays)
    core.safetize_function(&GFX_PROCS.pipeline_draw_elements)
    core.safetize_function(&GFX_PROCS.pipeline_draw_arrays_instanced)
    core.safetize_function(&GFX_PROCS.pipeline_draw_elements_instanced)
    core.safetize_function(&GFX_PROCS.pipeline_uniform_1f)
    core.safetize_function(&GFX_PROCS.pipeline_uniform_2f)
    core.safetize_function(&GFX_PROCS.pipeline_uniform_3f)
    core.safetize_function(&GFX_PROCS.pipeline_uniform_4f)
    core.safetize_function(&GFX_PROCS.pipeline_uniform_mat4f)
    core.safetize_function(&GFX_PROCS.pipeline_uniform_1i)
    core.safetize_function(&GFX_PROCS.pass_init)
    core.safetize_function(&GFX_PROCS.pass_begin)
    core.safetize_function(&GFX_PROCS.pass_end)
    core.safetize_function(&GFX_PROCS.pass_resize)
    core.safetize_function(&GFX_PROCS.pass_free)
}

when ODIN_OS == .Darwin {

gfxprocs_init_with_metal :: proc() {
    core.cell_init(&GFX_PROCS)

    GFX_PROCS.buffer_init_empty = _metalimpl_buffer_init_empty
    GFX_PROCS.buffer_init_with_data = _metalimpl_buffer_init_with_data
    GFX_PROCS.buffer_set_data = _metalimpl_buffer_set_data
    GFX_PROCS.buffer_free = _metalimpl_buffer_free
    core.safetize_function(&GFX_PROCS.texture_init_raw)
    core.safetize_function(&GFX_PROCS.texture_init_with_size_1d)
    core.safetize_function(&GFX_PROCS.texture_init_with_size_2d)
    core.safetize_function(&GFX_PROCS.texture_init_with_size_3d)
    core.safetize_function(&GFX_PROCS.texture_free)
    core.safetize_function(&GFX_PROCS.texture_set_data_1d)
    core.safetize_function(&GFX_PROCS.texture_set_data_2d)
    core.safetize_function(&GFX_PROCS.texture_set_data_3d)
    core.safetize_function(&GFX_PROCS.texture_set_data_cubemap_face)
    core.safetize_function(&GFX_PROCS.texture_gen_mipmaps )
    core.safetize_function(&GFX_PROCS.texture_resize_1d)
    core.safetize_function(&GFX_PROCS.texture_resize_2d)
    core.safetize_function(&GFX_PROCS.texture_resize_3d)
    core.safetize_function(&GFX_PROCS.texture_copy_1d)
    core.safetize_function(&GFX_PROCS.texture_copy_2d)
    core.safetize_function(&GFX_PROCS.texture_copy_3d)
    core.safetize_function(&GFX_PROCS.framebuffer_init )
    core.safetize_function(&GFX_PROCS.framebuffer_free )
    core.safetize_function(&GFX_PROCS.framebuffer_get_color_texture_bindings)
    core.safetize_function(&GFX_PROCS.framebuffer_get_depth_stencil_texture_bindings)
    GFX_PROCS.pipeline_init = _metalimpl_pipeline_init
    GFX_PROCS.pipeline_free = _metalimpl_pipeline_free
    core.safetize_function(&GFX_PROCS.pipeline_set_wireframe)
    GFX_PROCS.pipeline_draw_arrays = _metalimpl_pipeline_draw_arrays
    GFX_PROCS.pipeline_draw_elements = _metalimpl_pipeline_draw_elements
    GFX_PROCS.pipeline_draw_arrays_instanced = _metalimpl_pipeline_draw_arrays_instanced
    GFX_PROCS.pipeline_draw_elements_instanced = _metalimpl_pipeline_draw_elements_instanced
    GFX_PROCS.pipeline_uniform_1f = _metalimpl_pipeline_uniform_1f
    GFX_PROCS.pipeline_uniform_2f = _metalimpl_pipeline_uniform_2f
    GFX_PROCS.pipeline_uniform_3f = _metalimpl_pipeline_uniform_3f
    GFX_PROCS.pipeline_uniform_4f = _metalimpl_pipeline_uniform_4f
    GFX_PROCS.pipeline_uniform_mat4f = _metalimpl_pipeline_uniform_mat4f
    GFX_PROCS.pipeline_uniform_1i = _metalimpl_pipeline_uniform_1i
    GFX_PROCS.pass_init = _metalimpl_pass_init
    GFX_PROCS.pass_begin = _metalimpl_pass_begin
    GFX_PROCS.pass_end = _metalimpl_pass_end
    GFX_PROCS.pass_resize = _metalimpl_pass_resize
    GFX_PROCS.pass_free = _metalimpl_pass_free
}

}

gfxprocs_free :: proc() {
    core.cell_free(&GFX_PROCS)
}