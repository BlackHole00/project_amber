package vx_lib_gfx

import "core:c"
import "core:log"
import "core:os"
import "core:mem"
import "vendor:stb/image"

Texture_Type :: enum {
    Texture_1D,
    Texture_2D,
    Texture_2D_Multisample,
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

Pixel_type :: enum {
    UByte,
    UInt24_8,
}

Cubemap_Face :: enum {
    PositiveX,
    NegativeX,
    PositiveY,
    NegativeY,
    PositiveZ,
    NegativeZ,
}

Texture_Descriptor :: struct {
    type: Texture_Type,
    internal_texture_format: Texture_Format,
    format: Texture_Format,
    pixel_type: Pixel_type,
    warp_s: Texture_Warp,
    warp_t: Texture_Warp,
    min_filter: Texture_Filter,
    mag_filter: Texture_Filter,
    gen_mipmaps: bool,
}

Texture :: distinct rawptr

texture_new_with_size_1d :: proc(desc: Texture_Descriptor, size: uint) -> Texture {
    when ODIN_DEBUG do if desc.type != .Texture_1D do panic("texture_new_with_size_1d works only with 1D textures")

    return GFXPROCS_INSTANCE.texture_new_with_size_1d(desc, size)
}

texture_new_with_size_2d :: proc(desc: Texture_Descriptor, dimension: [2]uint) -> Texture {
    when ODIN_DEBUG do if desc.type != .Texture_2D do panic("texture_new_with_size_2d works only with 2D textures")

    return GFXPROCS_INSTANCE.texture_new_with_size_2d(desc, dimension)
}

texture_new_with_size_3d :: proc(desc: Texture_Descriptor, dimension: [3]uint) -> Texture {
    when ODIN_DEBUG do if desc.type != .Texture_3D do panic("texture_new_with_size_3d works only with 3D textures")

    return GFXPROCS_INSTANCE.texture_new_with_size_3d(desc, dimension)
}

texture_new_with_data_1d :: proc(desc: Texture_Descriptor, data: []$T) -> Texture {
    when ODIN_DEBUG do if desc.type != .Texture_1D do panic("texture_new_with_data_1d works only with 1D textures")

    return GFXPROCS_INSTANCE.texture_new_with_data_1d(desc, raw_data(data), size_of(T) * len(data))
}

texture_new_with_data_2d :: proc(desc: Texture_Descriptor, data: []$T, dimension: [2]uint) -> Texture {
    when ODIN_DEBUG do if desc.type != .Texture_2D do panic("texture_new_with_data_2d works only with 2D textures")

    return GFXPROCS_INSTANCE.texture_new_with_data_2d(desc, raw_data(data), size_of(T) * len(data), dimension)
}

texture_new_with_data_3d :: proc(desc: Texture_Descriptor, data: []$T, dimension: [3]uint) -> Texture {
    when ODIN_DEBUG do if desc.type != .Texture_3D do panic("texture_new_with_data_3d works only with 3D textures")

    return GFXPROCS_INSTANCE.texture_new_with_data_3d(desc, raw_data(data), size_of(T) * len(data), dimension)
}

texture_new_from_file :: proc(desc: Texture_Descriptor, file_path: string) -> Texture {
    when ODIN_DEBUG do if desc.type != .Texture_2D do panic("texture_new_from_file works only with .Texture_2D textures!")

    data, x, y, ch_num, _ := get_texture_content_from_file(file_path)
    defer image.image_free(data)

    slice := mem.byte_slice(data, x * y * ch_num)
    texture := texture_new_with_data_2d(desc, slice, { (uint)(x), (uint)(y) })

    return texture
}

texture_new_cubemap_from_file :: proc(desc: Texture_Descriptor, right_path, left_path, top_path, bottom_path, front_path, back_path: string) -> Texture {
    when ODIN_DEBUG do if desc.type != .Texture_CubeMap do panic("texture_new_cubemap_from_file works only with .Texture_CubeMap textures!")

    texture := GFXPROCS_INSTANCE._internal_texture_new_no_size(desc)

    data, x, y, ch_num, _ := get_texture_content_from_file(right_path)
    slice := mem.byte_slice(data, x * y * ch_num)
    texture_set_data_cubemap_face(texture, slice, { (uint)(x), (uint)(y) }, .PositiveX)
    image.image_free(data)

    data, x, y, ch_num, _ = get_texture_content_from_file(left_path)
    slice = mem.byte_slice(data, x * y * ch_num)
    texture_set_data_cubemap_face(texture, slice, { (uint)(x), (uint)(y) }, .NegativeX)
    image.image_free(data)

    data, x, y, ch_num, _ = get_texture_content_from_file(top_path)
    slice = mem.byte_slice(data, x * y * ch_num)
    texture_set_data_cubemap_face(texture, slice, { (uint)(x), (uint)(y) }, .PositiveY)
    image.image_free(data)

    data, x, y, ch_num, _ = get_texture_content_from_file(bottom_path)
    slice = mem.byte_slice(data, x * y * ch_num)
    texture_set_data_cubemap_face(texture, slice, { (uint)(x), (uint)(y) }, .NegativeY)
    image.image_free(data)

    data, x, y, ch_num, _ = get_texture_content_from_file(back_path)
    slice = mem.byte_slice(data, x * y * ch_num)
    texture_set_data_cubemap_face(texture, slice, { (uint)(x), (uint)(y) }, .PositiveZ)
    image.image_free(data)

    data, x, y, ch_num, _ = get_texture_content_from_file(front_path)
    slice = mem.byte_slice(data, x * y * ch_num)
    texture_set_data_cubemap_face(texture, slice, { (uint)(x), (uint)(y) }, .NegativeZ)
    image.image_free(data)

    return texture
}

texture_new :: proc { texture_new_with_data_1d, texture_new_with_data_2d, texture_new_with_data_3d, texture_new_from_file, texture_new_cubemap_from_file, texture_new_with_size_1d, texture_new_with_size_2d, texture_new_with_size_3d }

texture_free :: proc(texture: Texture) {
    GFXPROCS_INSTANCE.texture_free(texture)
}

texture_set_data_1d :: proc(texture: Texture, data: []$T, offset := 0) {
    GFXPROCS_INSTANCE.texture_set_data_1d(texture, raw_data(data), size_of(T) * len(data), offset)
}

texture_set_data_2d :: proc(texture: Texture, data: []$T, dimension: [2]uint, offset := [2]uint{ 0, 0 }) {
    GFXPROCS_INSTANCE.texture_set_data_2d(texture, raw_data(data), size_of(T) * len(data), dimension, offset)
}

texture_set_data_3d :: proc(texture: Texture, data: []$T, dimension: [3]uint, offset := [3]uint{ 0, 0, 0 }) {
    GFXPROCS_INSTANCE.texture_set_data_2d(texture, raw_data(data), size_of(T) * len(data), dimension, offset)
}

texture_set_data_cubemap_face :: proc(texture: Texture, data: []$T, dimension: [2]uint, face: Cubemap_Face) {
    GFXPROCS_INSTANCE.texture_set_data_cubemap_face(texture, raw_data(data), size_of(T) * len(data), dimension, face)
}

texture_set_data :: proc { texture_set_data_1d, texture_set_data_2d, texture_set_data_3d }

texture_resize_1d :: proc(texture: Texture, new_len: uint, copy_content := true) {
    GFXPROCS_INSTANCE.texture_resize_1d(texture, new_len, copy_content)
}

texture_resize_2d :: proc(texture: Texture, new_size: [2]uint, copy_content := true) {
    GFXPROCS_INSTANCE.texture_resize_2d(texture, new_size, copy_content)
}

texture_resize_3d :: proc(texture: Texture, new_size: [3]uint, copy_content := true) {
    GFXPROCS_INSTANCE.texture_resize_3d(texture, new_size, copy_content)
}

texture_copy_1d :: proc(src: Texture, dest: Texture, src_offset: int = 0, dest_offset: int = 0) {
    GFXPROCS_INSTANCE.texture_copy_1d(src, dest, src_offset, dest_offset)
}

texture_copy_2d :: proc(src: Texture, dest: Texture, src_offset: [2]int = { 0, 0 }, dest_offset: [2]int = { 0, 0 }) {
    GFXPROCS_INSTANCE.texture_copy_2d(src, dest, src_offset, dest_offset)
}

texture_copy_3d :: proc(src: Texture, dest: Texture, src_offset: [3]int = { 0, 0, 0 }, dest_offset: [3]int = { 0, 0, 0 }) {
    GFXPROCS_INSTANCE.texture_copy_3d(src, dest, src_offset, dest_offset)
}

/**************************************************************************************************
***************************************************************************************************
**************************************************************************************************/

@(private)
get_texture_content_from_file :: proc(file_path: string) -> (
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

    switch ch_num {
        case 1: texture_format = .R8
        case 2: texture_format = .R8G8
        case 3: texture_format = .R8G8B8
        case 4: texture_format = .R8G8B8A8
        case: panic("Invalid ch_num")
    }

    return
}
