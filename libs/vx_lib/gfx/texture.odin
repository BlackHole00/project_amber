package vx_lib_gfx

import "core:c"
import "core:log"
import "core:os"
import "core:mem"
import gl "vendor:OpenGL"
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
    texture_init_raw(texture, desc)
    texture_set_size_1d(texture, size)
}

texture_init_with_size_2d :: proc(texture: ^Texture, desc: Texture_Descriptor, dimension: [2]uint) {
    texture_init_raw(texture, desc)
    texture_set_size_2d(texture, dimension)
}

texture_init_with_size_3d :: proc(texture: ^Texture, desc: Texture_Descriptor, dimension: [3]uint) {
    texture_init_raw(texture, desc)
    texture_set_size_3d(texture, dimension)
}

texture_init_with_data_1d :: proc(texture: ^Texture, desc: Texture_Descriptor, data: []$T, texture_format: Texture_Format) {
    texture_init_raw(texture, desc)
    texture_set_size_1d(texture, len(data))
    texture_set_data_1d(texture^, data, texture_format)
}

texture_init_with_data_2d :: proc(texture: ^Texture, desc: Texture_Descriptor, data: []$T, texture_format: Texture_Format, dimension: [2]uint) {
    texture_init_raw(texture, desc)
    texture_set_size_2d(texture, dimension)
    texture_set_data_2d(texture^, data, texture_format, dimension)
}

texture_init_with_data_3d :: proc(texture: ^Texture, desc: Texture_Descriptor, data: []$T, texture_format: Texture_Format, dimension: [3]uint) {
    texture_init_raw(texture, desc)
    texture_set_size_3d(texture, dimension)
    texture_set_data_3d(texture^, data, texture_format, dimension)
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

    texture_init_raw(texture, desc)

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

texture_init :: proc { texture_init_raw, texture_init_with_data_1d, texture_init_with_data_2d, texture_init_with_data_3d, texture_init_from_file, texture_init_cubemap_from_file, texture_init_with_size_1d, texture_init_with_size_2d, texture_init_with_size_3d }

texture_free :: proc(texture: ^Texture) {
    gl.DeleteTextures(1, &texture.texture_handle)

    texture.texture_handle = INVALID_HANDLE
}

texture_set_data_1d :: proc(texture: Texture, data: []$T, texture_format: Texture_Format, pixel_type: u32 = gl.UNSIGNED_BYTE, offset := 0) {
    gl.TextureSubImage1D(texture.texture_handle, 0, (i32)(offset), (i32)(len(data)), (u32)(textureformat_to_glformat(texture_format)), pixel_type, &data[0])
    texture_gen_mipmaps(texture)
}

texture_set_data_2d :: proc(texture: Texture, data: []$T, texture_format: Texture_Format, dimension: [2]uint, pixel_type: u32 = gl.UNSIGNED_BYTE, offset := [2]uint{ 0, 0 }) {
    gl.TextureSubImage2D(texture.texture_handle, 0, (i32)(offset.x), (i32)(offset.y), (i32)(dimension.x), (i32)(dimension.y), (u32)(textureformat_to_glformat(texture_format)), pixel_type, &data[0])
    texture_gen_mipmaps(texture)
}

texture_set_data_3d :: proc(texture: Texture, data: []$T, texture_format: Texture_Format, dimension: [3]uint, pixel_type: u32 = gl.UNSIGNED_BYTE, offset := [3]uint{ 0, 0, 0 }) {
    gl.TextureSubImage3D(texture.texture_handle, 0, (i32)(offset.x), (i32)(offset.y), (i32)(offset.z), (i32)(dimension.x), (i32)(dimension.y), (i32)(dimension.z), (u32)(textureformat_to_glformat(texture_format)), pixel_type, &data[0])
    texture_gen_mipmaps(texture)
}

texture_set_data_cubemap_face :: proc(texture: Texture, data: []$T, texture_format: Texture_Format, dimension: [2]uint, face: uint, pixel_type: u32 = gl.UNSIGNED_BYTE) {
    if texture.type != .Texture_CubeMap {
        log.error("texture_set_data_cubemap_face works only with .Texture_CubeMap textures!")
        return
    }

    when true {
        texture_non_dsa_bind(texture)

        target: u32 = ---
        switch face {
            case 0: target = gl.TEXTURE_CUBE_MAP_POSITIVE_X
            case 1: target = gl.TEXTURE_CUBE_MAP_NEGATIVE_X
            case 2: target = gl.TEXTURE_CUBE_MAP_POSITIVE_Y
            case 3: target = gl.TEXTURE_CUBE_MAP_NEGATIVE_Y
            case 4: target = gl.TEXTURE_CUBE_MAP_POSITIVE_Z
            case 5: target = gl.TEXTURE_CUBE_MAP_NEGATIVE_Z
            case: panic("Unknown face")
        }

        gl.TexImage2D(target, 0, textureformat_to_glinternalformat(texture.internal_texture_format), (i32)(dimension.x), (i32)(dimension.y), 0, (u32)(textureformat_to_glformat(texture_format)), pixel_type, &data[0])

        texture_non_dsa_unbind(texturetype_to_glenum(texture.type))
    } else {
        texture_set_size_2d(texture, { (uint)(x), (uint)(y) })

        gl.TextureSubImage3D(texture.texture_handle, 0, 0, 0, (i32)(face), (i32)(dimension.x), (i32)(dimension.y), 1, texture_format, pixel_type, &data[0])
    }
    texture_gen_mipmaps(texture)
}

texture_set_data :: proc { texture_set_data_1d, texture_set_data_2d, texture_set_data_3d }

texture_gen_mipmaps :: proc(texture: Texture) {
    if texture.gen_mipmaps do gl.GenerateTextureMipmap(texture.texture_handle)
}

texture_resize_1d :: proc(texture: ^Texture, new_len: uint) {
    new_texture: Texture = ---

    texture_init(&new_texture, texture.texture_desc, new_len)

    texture_copy_1d(texture^, new_texture)

    texture_free(texture)
    texture^ = new_texture
}

texture_resize_2d :: proc(texture: ^Texture, new_size: [2]uint) {
    new_texture: Texture = ---

    texture_init(&new_texture, texture.texture_desc, new_size)

    texture_copy_2d(texture^, new_texture)

    texture_free(texture)
    texture^ = new_texture
}

texture_resize_3d :: proc(texture: ^Texture, new_size: [3]uint) {
    new_texture: Texture = ---

    texture_init(&new_texture, texture.texture_desc, new_size)

    texture_copy_3d(texture^, new_texture)

    texture_free(texture)
    texture^ = new_texture
}

texture_copy_1d :: proc(src: Texture, dest: Texture, src_offset: [3]i32 = { 0, 0, 0 }, dest_offset: [3]i32 = { 0, 0, 0 }) {
    size := min(src.texture_size.x, dest.texture_size.y)

    gl.CopyImageSubData(src.texture_handle, texturetype_to_glenum(src.type), 0, src_offset.x, src_offset.y, src_offset.z, dest.texture_handle, texturetype_to_glenum(dest.type), 0, dest_offset.x, dest_offset.y, dest_offset.z, (i32)(size), 1, 1)
}

texture_copy_2d :: proc(src: Texture, dest: Texture, src_offset: [3]i32 = { 0, 0, 0 }, dest_offset: [3]i32 = { 0, 0, 0 }) {
    size: [2]uint = ---
    size.x = min(src.texture_size.x, dest.texture_size.y)
    size.y = min(src.texture_size.y, dest.texture_size.y)

    gl.CopyImageSubData(src.texture_handle, texturetype_to_glenum(src.type), 0, src_offset.x, src_offset.y, src_offset.z, dest.texture_handle, texturetype_to_glenum(dest.type), 0, dest_offset.x, dest_offset.y, dest_offset.z, (i32)(size.x), (i32)(size.y), 1)
}

texture_copy_3d :: proc(src: Texture, dest: Texture, src_offset: [3]i32 = { 0, 0, 0 }, dest_offset: [3]i32 = { 0, 0, 0 }) {
    size: [3]uint = ---
    size.x = min(src.texture_size.x, dest.texture_size.y)
    size.y = min(src.texture_size.y, dest.texture_size.y)
    size.z = min(src.texture_size.z, dest.texture_size.z)

    gl.CopyImageSubData(src.texture_handle, texturetype_to_glenum(src.type), 0, src_offset.x, src_offset.y, src_offset.z, dest.texture_handle, texturetype_to_glenum(dest.type), 0, dest_offset.x, dest_offset.y, dest_offset.z, (i32)(size.x), (i32)(size.y), (i32)(size.z))
}

/**************************************************************************************************
***************************************************************************************************
**************************************************************************************************/

@(private)
texture_non_dsa_bind :: proc(texture: Texture) {
    gl.BindTexture(texturetype_to_glenum(texture.type), texture.texture_handle)
}

@(private)
texture_non_dsa_unbind :: proc(target: u32) {
    gl.BindTexture(target, 0)
}

@(private)
texture_full_bind :: proc(texture: Texture, texture_unit: u32) {
    gl.BindTextureUnit(texture_unit, texture.texture_handle)
}

@(private)
texture_apply:: proc(texture: Texture, texture_unit: u32, shader: ^Pipeline, uniform_name: string) {
    pipeline_uniform_1i(shader, uniform_name, (i32)(texture_unit))
}

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

@(private)
texture_set_size_1d :: proc(texture: ^Texture, size: uint) {
    gl.TextureStorage1D(texture.texture_handle, 1, (u32)(textureformat_to_glinternalformat(texture.internal_texture_format)), (i32)(size))
    texture_gen_mipmaps(texture^)

    texture.texture_size = { size, 0, 0 }
}

@(private)
texture_set_size_2d :: proc(texture: ^Texture, dimension: [2]uint) {
    gl.TextureStorage2D(texture.texture_handle, 1, (u32)(textureformat_to_glinternalformat(texture.internal_texture_format)), (i32)(dimension.x), (i32)(dimension.y))
    texture_gen_mipmaps(texture^)

    texture.texture_size = { dimension.x, dimension.y, 0 }
}

@(private)
texture_set_size_3d :: proc(texture: ^Texture, dimension: [3]uint) {
    gl.TextureStorage3D(texture.texture_handle, 1, (u32)(textureformat_to_glinternalformat(texture.internal_texture_format)), (i32)(dimension.x), (i32)(dimension.y), (i32)(dimension.z))
    texture_gen_mipmaps(texture^)

    texture.texture_size = dimension
}

@(private)
texture_init_raw :: proc(texture: ^Texture, desc: Texture_Descriptor) {
    texture.texture_desc = desc

    gl.CreateTextures(texturetype_to_glenum(texture.type), 1, &texture.texture_handle)

    gl.TextureParameteri(texture.texture_handle, gl.TEXTURE_WRAP_S,     texturewarp_to_glenum(desc.warp_s))
    gl.TextureParameteri(texture.texture_handle, gl.TEXTURE_WRAP_T,     texturewarp_to_glenum(desc.warp_t))
    gl.TextureParameteri(texture.texture_handle, gl.TEXTURE_MIN_FILTER, texturefilter_to_glenum(desc.min_filter))
    gl.TextureParameteri(texture.texture_handle, gl.TEXTURE_MAG_FILTER, texturefilter_to_glenum(desc.mag_filter))
}

@(private)
texturetype_to_glenum :: proc(type: Texture_Type) -> u32 {
    switch type {
        case .Texture_1D: return gl.TEXTURE_1D
        case .Texture_2D: return gl.TEXTURE_2D
        case .Texture_3D: return gl.TEXTURE_3D
        case .Texture_CubeMap: return gl.TEXTURE_CUBE_MAP
    }

    return 0
}

@(private)
textureformat_to_glinternalformat :: proc(format: Texture_Format) -> i32 {
    switch format {
        case .R8: return gl.R8
        case .R8G8: return gl.RG8
        case .R8G8B8: return gl.RGB8
        case .R8G8B8A8: return gl.RGBA8
        case .D24S8: return gl.DEPTH24_STENCIL8
    }

    return 0
}

@(private)
textureformat_to_glformat :: proc(format: Texture_Format) -> i32 {
    switch format {
        case .R8: return gl.RED
        case .R8G8: return gl.RG
        case .R8G8B8: return gl.RGB
        case .R8G8B8A8: return gl.RGBA
        case .D24S8: return gl.DEPTH_STENCIL
    }

    return 0
}

@(private)
texturewarp_to_glenum :: proc(warp: Texture_Warp) -> i32 {
    switch warp {
        case .Clamp_To_Border: return gl.CLAMP_TO_BORDER
        case .Clamp_To_Edge: return gl.CLAMP_TO_EDGE
        case .Mirrored_Repeat: return gl.MIRRORED_REPEAT
        case .Repeat: return gl.REPEAT
    }

    return 0
}

@(private)
texturefilter_to_glenum :: proc(filter: Texture_Filter) -> i32 {
    switch filter {
        case .Linear: return gl.LINEAR
        case .Linear_MLinear: return gl.LINEAR_MIPMAP_LINEAR
        case .Linear_MNearest: return gl.LINEAR_MIPMAP_NEAREST
        case .Nearest: return gl.NEAREST
        case .Nearest_MLinear: return gl.NEAREST_MIPMAP_LINEAR
        case .Nearest_MNearest: return gl.NEAREST_MIPMAP_NEAREST
    }

    return 0
}
