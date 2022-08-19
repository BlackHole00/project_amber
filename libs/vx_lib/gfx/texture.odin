package vx_lib_gfx

import "core:c"
import "core:log"
import "core:os"
import "core:mem"
import gl "vendor:OpenGL"
import "vendor:stb/image"

Texture_Descriptor :: struct {
    gl_type: u32,
    internal_texture_format: i32,
    texture_unit: i32,
    warp_s: i32,
    warp_t: i32,
    min_filter: i32,
    mag_filter: i32,
    gen_mipmaps: bool,
}

Texture :: struct {
    texture_handle: u32,

    gl_type: u32,
    texture_format: i32, // internal_texture_format
    texture_unit: i32,
    gen_mipmaps: bool,
}

texture_init_raw :: proc(texture: ^Texture, desc: Texture_Descriptor) {
    texture.gl_type         = desc.gl_type
    texture.texture_format  = desc.internal_texture_format
    texture.texture_unit    = desc.texture_unit
    texture.gen_mipmaps     = desc.gen_mipmaps

    gl.CreateTextures(texture.gl_type, 1, &texture.texture_handle)

    gl.TextureParameteri(texture.texture_handle, gl.TEXTURE_WRAP_S, desc.warp_s)
    gl.TextureParameteri(texture.texture_handle, gl.TEXTURE_WRAP_T, desc.warp_t)
    gl.TextureParameteri(texture.texture_handle, gl.TEXTURE_MIN_FILTER, desc.min_filter)
    gl.TextureParameteri(texture.texture_handle, gl.TEXTURE_MAG_FILTER, desc.mag_filter)
}

texture_init_with_data_1d :: proc(texture: ^Texture, desc: Texture_Descriptor, data: []$T, texture_format: u32) {
    texture_init_raw(texture, desc)
    texture_set_size_1d(texture^, dimension)
    texture_set_data_1d(texture^, data, texture_format)
}

texture_init_with_data_2d :: proc(texture: ^Texture, desc: Texture_Descriptor, data: []$T, texture_format: u32, dimension: [2]uint) {
    texture_init_raw(texture, desc)
    texture_set_size_2d(texture^, dimension)
    texture_set_data_2d(texture^, data, texture_format, dimension)
}

texture_init_with_data_3d :: proc(texture: ^Texture, desc: Texture_Descriptor, data: []$T, texture_format: u32, dimension: [3]uint) {
    texture_init_raw(texture, desc)
    texture_set_size_3d(texture^, dimension)
    texture_set_data_3d(texture^, data, texture_format, dimension)
}

texture_init_from_file :: proc(texture: ^Texture, desc: Texture_Descriptor, file_path: string, texture_format := -1) {
    if (desc.gl_type != gl.TEXTURE_2D) {
        log.error("texture_init_from_file works only with gl.TEXTURE_2D textures!")
        return
    }

    data, x, y, ch_num, real_texture_format := get_texture_content_from_file(file_path, texture_format)
    defer image.image_free(data)

    slice := mem.byte_slice(data, x * y * ch_num)
    texture_init_with_data_2d(texture, desc, slice, real_texture_format, { (uint)(x), (uint)(y) })
}

texture_init_cubemap_from_file :: proc(texture: ^Texture, desc: Texture_Descriptor, right_path, left_path, top_path, bottom_path, front_path, back_path: string, texture_format := -1) {
    if desc.gl_type != gl.TEXTURE_CUBE_MAP {
        log.error("texture_init_cubemap_from_file works only with gl.TEXTURE_CUBE_MAP textures!")
        return
    }

    texture_init_raw(texture, desc)

    data, x, y, ch_num, real_texture_format := get_texture_content_from_file(right_path, texture_format)
    texture_set_size_2d(texture^, { (uint)(x), (uint)(y) })

    slice := mem.byte_slice(data, x * y * ch_num)
    //texture_set_data_3d(texture^, slice, real_texture_format, { 0, (uint)(x), (uint)(y) })
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

texture_init :: proc { texture_init_raw, texture_init_with_data_1d, texture_init_with_data_2d, texture_init_with_data_3d, texture_init_from_file, texture_init_cubemap_from_file }

texture_free :: proc(texture: ^Texture) {
    gl.DeleteTextures(1, &texture.texture_handle)

    texture.texture_handle = INVALID_HANDLE
}

texture_set_data_1d :: proc(texture: Texture, data: []$T, texture_format: u32, pixel_type: u32 = gl.UNSIGNED_BYTE, offset := 0) {
    gl.TextureSubImage1D(texture.texture_handle, 0, (i32)(offset), len(data), 0, texture_format, pixel_type, &data[0])
    texture_gen_mipmaps(texture)
}

texture_set_data_2d :: proc(texture: Texture, data: []$T, texture_format: u32, dimension: [2]uint, pixel_type: u32 = gl.UNSIGNED_BYTE, offset := [2]uint{ 0, 0 }) {
    gl.TextureSubImage2D(texture.texture_handle, 0, (i32)(offset.x), (i32)(offset.y), (i32)(dimension.x), (i32)(dimension.y), texture_format, pixel_type, &data[0])
    texture_gen_mipmaps(texture)
}

texture_set_data_3d :: proc(texture: Texture, data: []$T, texture_format: u32, dimension: [3]uint, pixel_type: u32 = gl.UNSIGNED_BYTE, offset := [3]uint{ 0, 0, 0 }) {
    gl.TextureSubImage3D(texture.texture_handle, 0, (i32)(offset.x), (i32)(offset.y), (i32)(offset.z), (i32)(dimension.x), (i32)(dimension.y), (i32)(dimension.z), texture_format, pixel_type, &data[0])
    texture_gen_mipmaps(texture)
}

texture_set_data_cubemap_face :: proc(texture: Texture, data: []$T, texture_format: u32, dimension: [2]uint, face: uint, pixel_type: u32 = gl.UNSIGNED_BYTE) {
    if texture.gl_type != gl.TEXTURE_CUBE_MAP {
        log.error("texture_set_data_cubemap_face works only with gl.TEXTURE_CUBE_MAP textures!")
        return
    }

    gl.TextureSubImage3D(texture.texture_handle, 0, 0, 0, (i32)(face), (i32)(dimension.x), (i32)(dimension.y), 1, texture_format, pixel_type, &data[0])
    texture_gen_mipmaps(texture)
}

texture_set_data :: proc { texture_set_data_1d, texture_set_data_2d, texture_set_data_3d }

texture_set_size_1d :: proc(texture: Texture, size: uint) {
    gl.TextureStorage1D(texture.texture_handle, 1, (u32)(texture.texture_format), (i32)(size))
    texture_gen_mipmaps(texture)
}

texture_set_size_2d :: proc(texture: Texture, dimension: [2]uint) {
    gl.TextureStorage2D(texture.texture_handle, 1, (u32)(texture.texture_format), (i32)(dimension.x), (i32)(dimension.y))
    texture_gen_mipmaps(texture)
}

texture_set_size_3d :: proc(texture: Texture, dimension: [3]uint) {
    gl.TextureStorage3D(texture.texture_handle, 1, (u32)(texture.texture_format), (i32)(dimension.x), (i32)(dimension.y), (i32)(dimension.z))
    texture_gen_mipmaps(texture)
}

@(private)
texture_bind :: proc(texture: Texture) {
    //gl.ActiveTexture(gl.TEXTURE0 + (u32)(texture.texture_unit))
    //gl.BindTexture(texture.gl_type, texture.texture_handle)
    gl.BindTextureUnit((u32)(texture.texture_unit), texture.texture_handle)
}

texture_gen_mipmaps :: proc(texture: Texture) {
    if texture.gen_mipmaps do gl.GenerateTextureMipmap(texture.texture_handle)
}

@(private)
texture_apply:: proc(texture: Texture, shader: ^Shader, uniform_name: string) {
    shader_uniform_1i(shader, uniform_name, texture.texture_unit)
}

@(private)
get_texture_content_from_file :: proc(file_path: string, desired_texture_format := -1) -> (
    data: [^]byte,
    x, y, ch_num: c.int,
    texture_format: u32,
) {
    file, ok := os.read_entire_file(file_path)
    if !ok {
        log.error("Could not open file", file_path)
        return
    }
    defer delete(file)

    data = image.load_from_memory(([^]byte)(&file[0]), (i32)(len(file)), &x, &y, &ch_num, 0)

    texture_format = (u32)(desired_texture_format)
    if desired_texture_format == -1 do switch ch_num {
        case 1: texture_format = gl.RED
        case 2: texture_format = gl.RG
        case 3: texture_format = gl.RGB
        case 4: texture_format = gl.RGBA
        case: panic("Invalid ch_num")
    }

    return
}

