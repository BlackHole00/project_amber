package vx_lib_gfx

import "../core"

Gfx_Procs :: struct {
    buffer_init_empty: proc(buffer: ^Buffer, desc: Buffer_Descriptor),
    buffer_init_with_data: proc(buffer: ^Buffer, desc: Buffer_Descriptor, data: []byte),
    buffer_set_data: proc(buffer: Buffer, data: []byte),
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
}

gfxprocs_free :: proc() {
    core.cell_free(&GFX_PROCS)
}