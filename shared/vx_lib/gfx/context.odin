package vx_lib_gfx

import core "shared:vx_core"

@(private)
Gfx_Procs :: struct {
    buffer_new_empty:               proc(desc: Buffer_Descriptor) -> Buffer,
    buffer_new_with_data:           proc(desc: Buffer_Descriptor, data: rawptr, data_size: uint) -> Buffer,
    buffer_free:                    proc(buffer: Buffer),
    buffer_set_data:                proc(buffer: Buffer, data: rawptr, data_size: uint),
    buffer_get_buffertype:          proc(buffer: Buffer) -> Buffer_Type,
    buffer_get_bufferusage:         proc(buffer: Buffer) -> Buffer_Usage,
    buffer_get_indextype:           proc(buffer: Buffer) -> Index_Type,

    bindings_new:                   proc(vertex_buffers: []Buffer, index_buffer: Maybe(Buffer), textures: []Texture_Binding, uniform_buffers: []Uniform_Buffer_Binding) -> Bindings,
    bindings_free:                  proc(bindings: Bindings),
    bindings_has_index_buffer:      proc(bindings: Bindings) -> bool,

    _internal_texture_new_no_size:  proc(desc: Texture_Descriptor) -> Texture,
    texture_new_with_size_1d:       proc(desc: Texture_Descriptor, size: uint) -> Texture,
    texture_new_with_size_2d:       proc(desc: Texture_Descriptor, dimension: [2]uint) -> Texture,
    texture_new_with_size_3d:       proc(desc: Texture_Descriptor, dimension: [3]uint) -> Texture,
    texture_new_with_data_1d:       proc(desc: Texture_Descriptor, data: rawptr, data_size: uint) -> Texture,
    texture_new_with_data_2d:       proc(desc: Texture_Descriptor, data: rawptr, data_size: uint, dimension: [2]uint) -> Texture,
    texture_new_with_data_3d:       proc(desc: Texture_Descriptor, data: rawptr, data_size: uint, dimension: [3]uint) -> Texture,
    texture_free:                   proc(texture: Texture),
    texture_set_data_1d:            proc(texture: Texture, data: rawptr, data_size: uint, offset: uint),
    texture_set_data_2d:            proc(texture: Texture, data: rawptr, data_size: uint, dimension: [2]uint, offset: [2]uint),
    texture_set_data_3d:            proc(texture: Texture, data: rawptr, data_size: uint, dimension: [3]uint, offset: [3]uint),
    texture_set_data_cubemap_face:  proc(texture: Texture, data: rawptr, data_size: uint, dimension: [2]uint, face: Cubemap_Face),
    texture_resize_1d:              proc(texture: Texture, new_len: uint, copy_content: bool),
    texture_resize_2d:              proc(texture: Texture, new_size: [2]uint, copy_content: bool),
    texture_resize_3d:              proc(texture: Texture, new_size: [3]uint, copy_content: bool),
    texture_copy_1d:                proc(src: Texture, dest: Texture, src_offset: int, dest_offset: int),
    texture_copy_2d:                proc(src: Texture, dest: Texture, src_offset: [2]int, dest_offset: [2]int),
    texture_copy_3d:                proc(src: Texture, dest: Texture, src_offset: [3]int, dest_offset: [3]int),
    texture_get_texturetype:        proc(texture: Texture) -> Texture_Type,
    texture_get_internalformat:     proc(texture: Texture) -> Texture_Format,
    texture_get_format:             proc(texture: Texture) -> Texture_Format,
    texture_get_warp:               proc(texture: Texture, warp_identifier: Warp_Identifier) -> Texture_Warp,
    texture_get_filter:             proc(texture: Texture, filter_identifier: Filter_Identifier) -> Texture_Filter,
    texture_does_gen_mipmaps:       proc(texture: Texture) -> bool,
    texture_get_size:               proc(texture: Texture) -> [3]uint,

    pipeline_new:                   proc(desc: Pipeline_Descriptor, render_target: Maybe(Framebuffer) = nil) -> Pipeline,
    pipeline_free:                  proc(pipeline: Pipeline),
    pipeline_resize:                proc(pipeline: Pipeline, new_size: [2]uint),
    pipeline_clear:                 proc(pipeline: Pipeline),
    pipeline_set_wireframe:         proc(pipeline: Pipeline, wireframe: bool),
    pipeline_draw_arrays:           proc(pipeline: Pipeline, bindings: Bindings, primitive: Primitive, first: int, count: int),
    pipeline_draw_elements:         proc(pipeline: Pipeline, bindings: Bindings, primitive: Primitive, count: int),
    pipeline_draw_arrays_instanced: proc(pipeline: Pipeline, bindings: Bindings, primitive: Primitive, first: int, count: int, instance_count: int),
    pipeline_draw_elements_instanced: proc(pipeline: Pipeline, bindings: Bindings, primitive: Primitive, count: int, instance_count: int),
    pipeline_uniform_1f:            proc(pipeline: Pipeline, uniform_name: string, value: f32),
    pipeline_uniform_2f:            proc(pipeline: Pipeline, uniform_name: string, value: [2]f32),
    pipeline_uniform_3f:            proc(pipeline: Pipeline, uniform_name: string, value: [3]f32),
    pipeline_uniform_4f:            proc(pipeline: Pipeline, uniform_name: string, value: [4]f32),
    pipeline_uniform_mat4f:         proc(pipeline: Pipeline, uniform_name: string, value: ^matrix[4, 4]f32),
    pipeline_uniform_1i:            proc(pipeline: Pipeline, uniform_name: string, value: i32),
    pipeline_get_size:              proc(pipeline: Pipeline) -> [2]uint,
    pipeline_is_draw_pipeline:      proc(pipeline: Pipeline) -> bool,
    pipeline_is_wireframe:          proc(pipeline: Pipeline) -> bool,
    pipeline_does_uniform_exist:    proc(pipeline: Pipeline, uniform_name: string) -> bool,

    framebuffer_new:                proc(desc: Framebuffer_Descriptor) -> Framebuffer,
    framebuffer_new_from_textures:  proc(framebuffer_size: [2]uint, color_attachment: Maybe(Texture), depth_attachment: Maybe(Texture)) -> Framebuffer,
    framebuffer_free:               proc(framebuffer: Framebuffer),
    framebuffer_resize:             proc(framebuffer: Framebuffer, size: [2]uint),
    framebuffer_get_color_texture_bindings: proc(framebuffer: Framebuffer, color_texture_uniform: string) -> Texture_Binding,
    framebuffer_get_depth_stencil_texture_bindings: proc(framebuffer: Framebuffer, depth_stencil_texture_uniform: string) -> Texture_Binding,
    framebuffer_has_color_attachment: proc(framebuffer: Framebuffer) -> bool,
    framebuffer_has_depthstencil_attachment: proc(framebuffer: Framebuffer) -> bool,
    framebuffer_uses_external_textures: proc(framebuffer: Framebuffer) -> bool,

    computebuffer_new_empty:        proc(desc: Compute_Buffer_Descriptor) -> Compute_Buffer,
    computebuffer_new_with_data:    proc(desc: Compute_Buffer_Descriptor, data: rawptr, data_size: uint, mode: Data_Handling_Mode) -> Compute_Buffer,
    computebuffer_new_from_buffer:  proc(desc: Compute_Buffer_Descriptor, gfx_buffer: Buffer) -> Compute_Buffer,
    computebuffer_new_from_texture: proc(desc: Compute_Buffer_Descriptor, texture: Texture) -> Compute_Buffer,
    computebuffer_free:             proc(buffer: Compute_Buffer),
    computebuffer_update_bound_texture: proc(buffer: Compute_Buffer, texture: Texture),
    computebuffer_update_bound_buffer: proc(buffer: Compute_Buffer, gfx_buffer: Buffer),
    computebuffer_set_data:         proc(buffer: Compute_Buffer, data: rawptr, data_size: uint, blocking: bool, sync: ^Sync),
    computebuffer_get_data:         proc(buffer: Compute_Buffer, data: rawptr, data_size: uint, blocking: bool, sync: ^Sync),
    computebuffer_get_buffertype:   proc(buffer: Compute_Buffer) -> Compute_Buffer_Type,
    computebuffer_is_gfx:           proc(buffer: Compute_Buffer) -> bool,
    computebuffer_get_size:         proc(buffer: Compute_Buffer) -> uint,

    computepipeline_new:            proc(desc: Compute_Pipeline_Descriptor) -> Compute_Pipeline,
    computepipeline_free:           proc(pipeline: Compute_Pipeline),
    computepipeline_set_local_work_size: proc(pipeline: Compute_Pipeline, size: []uint),
    computepipeline_set_global_work_size: proc(pipeline: Compute_Pipeline, size: []uint),
    computepipeline_compute:        proc(pipeline: Compute_Pipeline, bindings: Compute_Bindings, sync: ^Sync),
    computepipeline_get_dimensions: proc(pipeline: Compute_Pipeline) -> uint,
    computepipeline_get_global_work_sizes: proc(pipeline: Compute_Pipeline) -> []uint,
    computepipeline_get_local_work_sizes: proc(pipeline: Compute_Pipeline) -> []uint,

    computebindings_new:            proc(layout: []Compute_Bindings_Element) -> Compute_Bindings,
    computebindings_free:           proc(bindings: Compute_Bindings),
    computebindings_set_element:    proc(bindings: Compute_Bindings, index: uint, element: Compute_Bindings_Element),
}
GFXPROCS_INSTANCE: core.Cell(Gfx_Procs)

gfxprocs_init :: proc() {
    core.cell_init(&GFXPROCS_INSTANCE)
}

gfxprocs_deinit :: proc() {
    core.cell_free(&GFXPROCS_INSTANCE)
}