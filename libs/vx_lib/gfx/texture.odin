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

    gl.GenTextures(1, &texture.texture_handle)
    texture_bind(texture^)
    //gl.BindTexture(texture.gl_type, texture.handle)

    gl.TexParameteri(texture.gl_type, gl.TEXTURE_WRAP_S, desc.warp_s)
    gl.TexParameteri(texture.gl_type, gl.TEXTURE_WRAP_T, desc.warp_t)
    gl.TexParameteri(texture.gl_type, gl.TEXTURE_MIN_FILTER, desc.min_filter)
    gl.TexParameteri(texture.gl_type, gl.TEXTURE_MAG_FILTER, desc.mag_filter)
}

texture_init_with_data_1d :: proc(texture: ^Texture, desc: Texture_Descriptor, data: []$T, texture_format: u32) {
    texture_init_raw(texture, desc)
    texture_set_data_1d(texture^, data, texture_format)
}

texture_init_with_data_2d :: proc(texture: ^Texture, desc: Texture_Descriptor, data: []$T, texture_format: u32, dimension: [2]uint) {
    texture_init_raw(texture, desc)
    texture_set_data_2d(texture^, data, texture_format, dimension)
}

texture_init_with_data_3d :: proc(texture: ^Texture, desc: Texture_Descriptor, data: []$T, texture_format: u32, dimension: [3]uint) {
    texture_init_raw(texture, desc)
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

texture_init_cubemap_from_file :: proc(texture: ^Texture, desc: Texture_Descriptor, right_path, left_path, top_path, bottom_path, back_path, front_path: string, texture_format := -1) {
    if desc.gl_type != gl.TEXTURE_CUBE_MAP {
        log.error("texture_init_cubemap_from_file works only with gl.TEXTURE_CUBE_MAP textures!")
        return
    }

    texture_init_raw(texture, desc)

    data, x, y, ch_num, real_texture_format := get_texture_content_from_file(right_path, texture_format)
    slice := mem.byte_slice(data, x * y * ch_num)
    texture_set_data_2d(texture^, slice, real_texture_format, { (uint)(x), (uint)(y) }, gl.UNSIGNED_BYTE, gl.TEXTURE_CUBE_MAP_POSITIVE_X)
    image.image_free(data)

    data, x, y, ch_num, real_texture_format = get_texture_content_from_file(left_path, texture_format)
    slice = mem.byte_slice(data, x * y * ch_num)
    texture_set_data_2d(texture^, slice, real_texture_format, { (uint)(x), (uint)(y) }, gl.UNSIGNED_BYTE, gl.TEXTURE_CUBE_MAP_NEGATIVE_X)
    image.image_free(data)

    data, x, y, ch_num, real_texture_format = get_texture_content_from_file(top_path, texture_format)
    slice = mem.byte_slice(data, x * y * ch_num)
    texture_set_data_2d(texture^, slice, real_texture_format, { (uint)(x), (uint)(y) }, gl.UNSIGNED_BYTE, gl.TEXTURE_CUBE_MAP_POSITIVE_Y)
    image.image_free(data)

    data, x, y, ch_num, real_texture_format = get_texture_content_from_file(bottom_path, texture_format)
    slice = mem.byte_slice(data, x * y * ch_num)
    texture_set_data_2d(texture^, slice, real_texture_format, { (uint)(x), (uint)(y) }, gl.UNSIGNED_BYTE, gl.TEXTURE_CUBE_MAP_NEGATIVE_Y)
    image.image_free(data)

    data, x, y, ch_num, real_texture_format = get_texture_content_from_file(back_path, texture_format)
    slice = mem.byte_slice(data, x * y * ch_num)
    texture_set_data_2d(texture^, slice, real_texture_format, { (uint)(x), (uint)(y) }, gl.UNSIGNED_BYTE, gl.TEXTURE_CUBE_MAP_NEGATIVE_Z)
    image.image_free(data)

    data, x, y, ch_num, real_texture_format = get_texture_content_from_file(front_path, texture_format)
    slice = mem.byte_slice(data, x * y * ch_num)
    texture_set_data_2d(texture^, slice, real_texture_format, { (uint)(x), (uint)(y) }, gl.UNSIGNED_BYTE, gl.TEXTURE_CUBE_MAP_POSITIVE_Z)
    image.image_free(data)
}

texture_init :: proc { texture_init_raw, texture_init_with_data_1d, texture_init_with_data_2d, texture_init_with_data_3d, texture_init_from_file, texture_init_cubemap_from_file }

texture_free :: proc(texture: ^Texture) {
    gl.DeleteTextures(1, &texture.texture_handle)

    texture.texture_handle = INVALID_HANDLE
}

texture_set_data_1d :: proc(texture: Texture, data: []$T, texture_format: u32, pixel_type: u32 = gl.UNSIGNED_BYTE, bind_target := -1) {
    texture_bind(texture)

    real_bind_target: u32 = (u32)(bind_target)
    if bind_target == -1 do real_bind_target = texture.gl_type

    gl.TexImage1D(texture.gl_type, 0, texture.texture_format, len(data) * size_of(T), 0, texture_format, pixel_type, (rawptr)(&data[0]))
    texture_gen_mipmaps(texture)
}

texture_set_data_2d :: proc(texture: Texture, data: []$T, texture_format: u32, dimension: [2]uint, pixel_type: u32 = gl.UNSIGNED_BYTE, bind_target := -1) {
    texture_bind(texture)

    real_bind_target: u32 = (u32)(bind_target)
    if bind_target == -1 do real_bind_target = texture.gl_type

    gl.TexImage2D(real_bind_target, 0, texture.texture_format, (i32)(dimension.x), (i32)(dimension.y), 0, texture_format, pixel_type, (rawptr)(&data[0]))
    texture_gen_mipmaps(texture)
}

texture_set_data_3d :: proc(texture: Texture, data: []$T, texture_format: u32, dimension: [3]uint, pixel_type: u32 = gl.UNSIGNED_BYTE, bind_target := -1) {
    texture_bind(texture)

    real_bind_target: u32 = (u32)(bind_target)
    if bind_target == -1 do real_bind_target = texture.gl_type

    gl.TexImage3D(texture.gl_type, 0, texture.texture_format, (i32)(dimension.x), (i32)(dimension.y), (i32)(dimension.z), 0, texture_format, pixel_type, (rawptr)(&data[0]))
    texture_gen_mipmaps(texture)
}

texture_set_data :: proc { texture_set_data_1d, texture_set_data_2d, texture_set_data_3d }

texture_set_size_1d :: proc(texture: Texture, size: uint, texture_format: u32, pixel_type: u32 = gl.UNSIGNED_BYTE, bind_target := -1) {
    texture_bind(texture)

    real_bind_target: u32 = (u32)(bind_target)
    if bind_target == -1 do real_bind_target = texture.gl_type

    gl.TexImage1D(texture.gl_type, 0, texture.texture_format, (i32)(size), 0, texture_format, pixel_type, nil)
    texture_gen_mipmaps(texture)
}

texture_set_size_2d :: proc(texture: Texture, dimension: [2]uint, texture_format: u32, pixel_type: u32 = gl.UNSIGNED_BYTE, bind_target := -1) {
    texture_bind(texture)

    real_bind_target: u32 = (u32)(bind_target)
    if bind_target == -1 do real_bind_target = texture.gl_type

    gl.TexImage2D(texture.gl_type, 0, texture.texture_format, (i32)(dimension.x), (i32)(dimension.y), 0, texture_format, pixel_type, nil)
    texture_gen_mipmaps(texture)
}

texture_set_size_3d :: proc(texture: Texture, dimension: [3]uint, texture_format: u32, pixel_type: u32 = gl.UNSIGNED_BYTE, bind_target := -1) {
    texture_bind(texture)

    real_bind_target: u32 = (u32)(bind_target)
    if bind_target == -1 do real_bind_target = texture.gl_type

    gl.TexImage3D(texture.gl_type, 0, texture.texture_format, (i32)(dimension.x), (i32)(dimension.y), (i32)(dimension.z), 0, texture_format, pixel_type, nil)
    texture_gen_mipmaps(texture)
}

@(private)
texture_bind :: proc(texture: Texture) {
    gl.ActiveTexture(gl.TEXTURE0 + (u32)(texture.texture_unit))
    gl.BindTexture(texture.gl_type, texture.texture_handle)
}

texture_gen_mipmaps :: proc(texture: Texture) {
    texture_bind(texture)

    if texture.gen_mipmaps do gl.GenerateMipmap(texture.gl_type)
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

