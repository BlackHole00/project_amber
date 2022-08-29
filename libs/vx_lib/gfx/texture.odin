package vx_lib_gfx

import "core:c"
import "core:log"
import "core:os"
import "core:mem"
import "vendor:stb/image"

Texture_Type :: enum {
    Texture_1D,
    Texture_2D,
    Texture_3D,
    Texture_CubeMap,
}

Texture_Format :: enum {
    R8,
    R8G8,
    R8G8B8,
    R8G8B8A8,
    D24S8,
}

Texture_Warp :: enum {
    Repeat,
    Mirrored_Repeat,
    Clamp_To_Edge,
    Clamp_To_Border,
}

Texture_Filter :: enum {
    Linear,
    Nearest,
    Nearest_MNearest,
    Linear_MNearest,
    Nearest_MLinear,
    Linear_MLinear,
}

Texture_Descriptor :: struct {
    type: Texture_Type,
    internal_texture_format: Texture_Format,
    warp_s: Texture_Warp,
    warp_t: Texture_Warp,
    min_filter: Texture_Filter,
    mag_filter: Texture_Filter,
    gen_mipmaps: bool,
}

Texture :: struct {
    texture_handle: u32,

    texture_size: [3]uint,

    using texture_desc: Texture_Descriptor,
}

texture_init_with_size_1d :: proc(texture: ^Texture, desc: Texture_Descriptor, size: uint) {
    GFX_PROCS.texture_init_with_size_1d(texture, desc, size)
}

texture_init_with_size_2d :: proc(texture: ^Texture, desc: Texture_Descriptor, dimension: [2]uint) {
    GFX_PROCS.texture_init_with_size_2d(texture, desc, dimension)
}

texture_init_with_size_3d :: proc(texture: ^Texture, desc: Texture_Descriptor, dimension: [3]uint) {
    GFX_PROCS.texture_init_with_size_3d(texture, desc, dimension)
}

texture_init_with_data_1d :: proc(texture: ^Texture, desc: Texture_Descriptor, data: []$T, texture_format: Texture_Format) {
    texture_init_with_size_1d(texture, desc, len(data))
    GFX_PROCS.texture_set_data_1d(texture^, mem.slice_to_bytes(data), texture_format, 0)
}

texture_init_with_data_2d :: proc(texture: ^Texture, desc: Texture_Descriptor, data: []$T, texture_format: Texture_Format, dimension: [2]uint) {
    texture_init_with_size_2d(texture, desc, dimension)
    GFX_PROCS.texture_set_data_2d(texture^, mem.slice_to_bytes(data), texture_format, dimension, 0)
}

texture_init_with_data_3d :: proc(texture: ^Texture, desc: Texture_Descriptor, data: []$T, texture_format: Texture_Format, dimension: [3]uint) {
    texture_init_with_size_3d(texture, desc, dimension)
    GFX_PROCS.texture_set_data_3d(texture^, mem.slice_to_bytes(data), texture_format, dimension, 0)
}

texture_init_from_file :: proc(texture: ^Texture, desc: Texture_Descriptor, file_path: string, texture_format: Maybe(Texture_Format) = nil) {
    if (desc.type != .Texture_2D) {
        log.error("texture_init_from_file works only with .Texture_2D textures!")
        return
    }

    data, x, y, ch_num, real_texture_format := get_texture_content_from_file(file_path, texture_format)
    defer image.image_free(data)

    slice := mem.byte_slice(data, x * y * ch_num)
    texture_init_with_data_2d(texture, desc, slice, real_texture_format, { (uint)(x), (uint)(y) })
}

texture_init_cubemap_from_file :: proc(texture: ^Texture, desc: Texture_Descriptor, right_path, left_path, top_path, bottom_path, front_path, back_path: string, texture_format: Maybe(Texture_Format) = nil) {
    if desc.type != .Texture_CubeMap {
        log.error("texture_init_cubemap_from_file works only with .Texture_CubeMap textures!")
        return
    }

    GFX_PROCS.texture_init_raw(texture, desc)

    data, x, y, ch_num, real_texture_format := get_texture_content_from_file(right_path, texture_format)
    slice := mem.byte_slice(data, x * y * ch_num)
    texture_set_data_cubemap_face(texture^, slice, real_texture_format, { (uint)(x), (uint)(y) }, 0)
    image.image_free(data)

    data, x, y, ch_num, real_texture_format = get_texture_content_from_file(left_path, texture_format)
    slice = mem.byte_slice(data, x * y * ch_num)
    texture_set_data_cubemap_face(texture^, slice, real_texture_format, { (uint)(x), (uint)(y) }, 1)
    image.image_free(data)

    data, x, y, ch_num, real_texture_format = get_texture_content_from_file(top_path, texture_format)
    slice = mem.byte_slice(data, x * y * ch_num)
    texture_set_data_cubemap_face(texture^, slice, real_texture_format, { (uint)(x), (uint)(y) }, 2)
    image.image_free(data)

    data, x, y, ch_num, real_texture_format = get_texture_content_from_file(bottom_path, texture_format)
    slice = mem.byte_slice(data, x * y * ch_num)
    texture_set_data_cubemap_face(texture^, slice, real_texture_format, { (uint)(x), (uint)(y) }, 3)
    image.image_free(data)

    data, x, y, ch_num, real_texture_format = get_texture_content_from_file(back_path, texture_format)
    slice = mem.byte_slice(data, x * y * ch_num)
    texture_set_data_cubemap_face(texture^, slice, real_texture_format, { (uint)(x), (uint)(y) }, 4)
    image.image_free(data)

    data, x, y, ch_num, real_texture_format = get_texture_content_from_file(front_path, texture_format)
    slice = mem.byte_slice(data, x * y * ch_num)
    texture_set_data_cubemap_face(texture^, slice, real_texture_format, { (uint)(x), (uint)(y) }, 5)
    image.image_free(data)
}

texture_init :: proc { texture_init_with_data_1d, texture_init_with_data_2d, texture_init_with_data_3d, texture_init_from_file, texture_init_cubemap_from_file, texture_init_with_size_1d, texture_init_with_size_2d, texture_init_with_size_3d }

texture_free :: proc(texture: ^Texture) {
    GFX_PROCS.texture_free(texture)
}

texture_set_data_1d :: proc(texture: Texture, data: []$T, texture_format: Texture_Format, offset := 0) {
    GFX_PROCS.texture_set_data_1d(texture, mem.slice_to_bytes(data), texture_format, offset)
    texture_gen_mipmaps(texture)
}

texture_set_data_2d :: proc(texture: Texture, data: []$T, texture_format: Texture_Format, dimension: [2]uint, offset := [2]uint{ 0, 0 }) {
    GFX_PROCS.texture_set_data_2d(texture, mem.slice_to_bytes(data), texture_format, dimension, offset)
    texture_gen_mipmaps(texture)
}

texture_set_data_3d :: proc(texture: Texture, data: []$T, texture_format: Texture_Format, dimension: [3]uint, offset := [3]uint{ 0, 0, 0 }) {
    GFX_PROCS.texture_set_data_3d(texture, mem.slice_to_bytes(data), texture_format, dimension, offset)
    texture_gen_mipmaps(texture)
}

texture_set_data_cubemap_face :: proc(texture: Texture, data: []$T, texture_format: Texture_Format, dimension: [2]uint, face: uint) {
    GFX_PROCS.texture_set_data_cubemap_face(texture, mem.slice_to_bytes(data), texture_format, dimension, face)
    texture_gen_mipmaps(texture)
}

texture_set_data :: proc { texture_set_data_1d, texture_set_data_2d, texture_set_data_3d }

texture_gen_mipmaps :: proc(texture: Texture) {
    GFX_PROCS.texture_gen_mipmaps(texture)
}

texture_resize_1d :: proc(texture: ^Texture, new_len: uint) {
    GFX_PROCS.texture_resize_1d(texture, new_len)
}

texture_resize_2d :: proc(texture: ^Texture, new_size: [2]uint) {
    GFX_PROCS.texture_resize_2d(texture, new_size)
}

texture_resize_3d :: proc(texture: ^Texture, new_size: [3]uint) {
    GFX_PROCS.texture_resize_3d(texture, new_size)
}

texture_copy_1d :: proc(src: Texture, dest: Texture, src_offset: [3]i32 = { 0, 0, 0 }, dest_offset: [3]i32 = { 0, 0, 0 }) {
    GFX_PROCS.texture_copy_1d(src, dest, src_offset, dest_offset)
}

texture_copy_2d :: proc(src: Texture, dest: Texture, src_offset: [3]i32 = { 0, 0, 0 }, dest_offset: [3]i32 = { 0, 0, 0 }) {
    GFX_PROCS.texture_copy_2d(src, dest, src_offset, dest_offset)
}

texture_copy_3d :: proc(src: Texture, dest: Texture, src_offset: [3]i32 = { 0, 0, 0 }, dest_offset: [3]i32 = { 0, 0, 0 }) {
    GFX_PROCS.texture_copy_3d(src, dest, src_offset, dest_offset)
}

/**************************************************************************************************
***************************************************************************************************
**************************************************************************************************/

@(private)
get_texture_content_from_file :: proc(file_path: string, desired_texture_format: Maybe(Texture_Format) = nil) -> (
    data: [^]byte,
    x, y, ch_num: c.int,
    texture_format: Texture_Format,
) {
    file, ok := os.read_entire_file(file_path)
    if !ok {
        log.error("Could not open file", file_path)
        return
    }
    defer delete(file)

    data = image.load_from_memory(([^]byte)(&file[0]), (i32)(len(file)), &x, &y, &ch_num, 0)

    if desired_texture_format == nil do switch ch_num {
        case 1: texture_format = .R8
        case 2: texture_format = .R8G8
        case 3: texture_format = .R8G8B8
        case 4: texture_format = .R8G8B8A8
        case: panic("Invalid ch_num")
    } else do texture_format = desired_texture_format.(Texture_Format)

    return
}
