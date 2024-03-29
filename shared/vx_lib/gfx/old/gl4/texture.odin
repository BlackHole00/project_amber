package vx_lib_gfx_GL4

import "core:c"
import "core:log"
import "core:os"
import gl "vendor:OpenGL"
import "vendor:stb/image"
import "shared:vx_lib/gfx"

Texture_Impl :: struct {
    texture_handle: u32,

    texture_size: [3]uint,

    using texture_desc: gfx.Texture_Descriptor,
}
GL4Texture :: ^Texture_Impl

texture_new_with_size_1d :: proc(desc: gfx.Texture_Descriptor, size: uint) -> GL4Texture {
    texture := _internal_texture_new_no_size(desc)
    texture_set_size_1d(texture, size)

    return texture
}

texture_new_with_size_2d :: proc(desc: gfx.Texture_Descriptor, dimension: [2]uint) -> GL4Texture {
    texture := _internal_texture_new_no_size(desc)
    texture_set_size_2d(texture, dimension)

    return texture
}

texture_new_with_size_3d :: proc(desc: gfx.Texture_Descriptor, dimension: [3]uint) -> GL4Texture {
    texture := _internal_texture_new_no_size(desc)
    texture_set_size_3d(texture, dimension)

    return texture
}

texture_new_with_data_1d :: proc(desc: gfx.Texture_Descriptor, data: rawptr, data_size: uint) -> GL4Texture {
    texture := _internal_texture_new_no_size(desc)
    texture_set_size_1d(texture, data_size)
    texture_set_data_1d(texture, data, data_size)

    return texture
}

texture_new_with_data_2d :: proc(desc: gfx.Texture_Descriptor, data: rawptr, data_size: uint, dimension: [2]uint) -> GL4Texture {
    texture := _internal_texture_new_no_size(desc)
    texture_set_size_2d(texture, dimension)
    texture_set_data_2d(texture, data, data_size, dimension)

    return texture
}

texture_new_with_data_3d :: proc(desc: gfx.Texture_Descriptor, data: rawptr, data_size: uint, dimension: [3]uint) -> GL4Texture {
    texture := _internal_texture_new_no_size(desc)
    texture_set_size_3d(texture, dimension)
    texture_set_data_3d(texture, data, data_size, dimension)

    return texture
}

texture_free :: proc(texture: GL4Texture) {
    gl.DeleteTextures(1, &texture.texture_handle)

    free(texture, CONTEXT.gl_allocator)
}

texture_set_data_1d :: proc(texture: GL4Texture, data: rawptr, data_size: uint, offset := 0) {
    gl.TextureSubImage1D(texture.texture_handle, 0, (i32)(offset), (i32)(data_size), (u32)(textureformat_to_glformat(texture.format)), (u32)(pixeltype_to_glenum(texture.pixel_type)), data)

    texture_gen_mipmaps(texture)
}

texture_set_data_2d :: proc(texture: GL4Texture, data: rawptr, data_size: uint, dimension: [2]uint, offset := [2]uint{ 0, 0 }) {
    gl.TextureSubImage2D(texture.texture_handle, 0, (i32)(offset.x), (i32)(offset.y), (i32)(dimension.x), (i32)(dimension.y), (u32)(textureformat_to_glformat(texture.format)), (u32)(pixeltype_to_glenum(texture.pixel_type)), data)

    texture_gen_mipmaps(texture)
}

texture_set_data_3d :: proc(texture: GL4Texture, data: rawptr, data_size: uint, dimension: [3]uint, offset := [3]uint{ 0, 0, 0 }) {
    gl.TextureSubImage3D(texture.texture_handle, 0, (i32)(offset.x), (i32)(offset.y), (i32)(offset.z), (i32)(dimension.x), (i32)(dimension.y), (i32)(dimension.z), (u32)(textureformat_to_glformat(texture.format)), (u32)(pixeltype_to_glenum(texture.pixel_type)), data)

    texture_gen_mipmaps(texture)
}

texture_set_data_cubemap_face :: proc(texture: GL4Texture, data: rawptr, data_size: uint, dimension: [2]uint, face: gfx.Cubemap_Face) {
    when true {
        texture_non_dsa_bind(texture)

        target: u32 = ---
        switch face {
            case .PositiveX: target = gl.TEXTURE_CUBE_MAP_POSITIVE_X
            case .NegativeX: target = gl.TEXTURE_CUBE_MAP_NEGATIVE_X
            case .PositiveY: target = gl.TEXTURE_CUBE_MAP_POSITIVE_Y
            case .NegativeY: target = gl.TEXTURE_CUBE_MAP_NEGATIVE_Y
            case .PositiveZ: target = gl.TEXTURE_CUBE_MAP_POSITIVE_Z
            case .NegativeZ: target = gl.TEXTURE_CUBE_MAP_NEGATIVE_Z
            case: panic("Unknown face")
        }

        gl.TexImage2D(target, 0, textureformat_to_glinternalformat(texture.internal_texture_format), (i32)(dimension.x), (i32)(dimension.y), 0, (u32)(textureformat_to_glformat(texture.format)), (u32)(pixeltype_to_glenum(texture.pixel_type)), data)

        texture_non_dsa_unbind(texturetype_to_glenum(texture.type))
    } else {
        texture_set_size_2d(texture, { (uint)(x), (uint)(y) })

        gl.TextureSubImage3D(texture.texture_handle, 0, 0, 0, (i32)(face), (i32)(dimension.x), (i32)(dimension.y), 1, texture_format, pixel_type, &data[0])
    }
    texture_gen_mipmaps(texture)
}

texture_set_data :: proc { texture_set_data_1d, texture_set_data_2d, texture_set_data_3d }

texture_resize_1d :: proc(texture: GL4Texture, new_len: uint, copy_content := true) {
    old_texture := texture^

    texture_init_raw(texture, texture.texture_desc)
    texture_set_size_1d(texture, new_len)
    if copy_content do texture_copy_1d(&old_texture, texture)

    gl.DeleteTextures(1, &old_texture.texture_handle)
}

texture_resize_2d :: proc(texture: GL4Texture, new_size: [2]uint, copy_content := true) {
    old_texture := texture^

    texture_init_raw(texture, texture.texture_desc)
    texture_set_size_2d(texture, new_size)
    if copy_content do texture_copy_2d(&old_texture, texture)

    gl.DeleteTextures(1, &old_texture.texture_handle)
}

texture_resize_3d :: proc(texture: GL4Texture, new_size: [3]uint, copy_content := true) {
    old_texture := texture^

    texture_init_raw(texture, texture.texture_desc)
    texture_set_size_3d(texture, new_size)
    if copy_content do texture_copy_3d(&old_texture, texture)

    gl.DeleteTextures(1, &old_texture.texture_handle)
}

texture_copy_1d :: proc(src: GL4Texture, dest: GL4Texture, src_offset: int = 0, dest_offset: int = 0) {
    size := min(src.texture_size.x, dest.texture_size.y)
    _ = size

    gl.CopyImageSubData(src.texture_handle, texturetype_to_glenum(src.type), 0, (i32)(src_offset), 0, 0, dest.texture_handle, texturetype_to_glenum(dest.type), 0, (i32)(dest_offset), 0, 0, (i32)(size), 1, 1)
}

texture_copy_2d :: proc(src: GL4Texture, dest: GL4Texture, src_offset: [2]int = { 0, 0 }, dest_offset: [2]int = { 0, 0 }) {
    size: [2]uint = ---
    size.x = min(src.texture_size.x, dest.texture_size.y)
    size.y = min(src.texture_size.y, dest.texture_size.y)

    gl.CopyImageSubData(src.texture_handle, texturetype_to_glenum(src.type), 0, (i32)(src_offset.x), (i32)(src_offset.y), 0, dest.texture_handle, texturetype_to_glenum(dest.type), 0, (i32)(dest_offset.x), (i32)(dest_offset.y), 0, (i32)(size.x), (i32)(size.y), 1)
}

texture_copy_3d :: proc(src: GL4Texture, dest: GL4Texture, src_offset: [3]int = { 0, 0, 0 }, dest_offset: [3]int = { 0, 0, 0 }) {
    size: [3]uint = ---
    size.x = min(src.texture_size.x, dest.texture_size.y)
    size.y = min(src.texture_size.y, dest.texture_size.y)
    size.z = min(src.texture_size.z, dest.texture_size.z)

    gl.CopyImageSubData(src.texture_handle, texturetype_to_glenum(src.type), 0, (i32)(src_offset.x), (i32)(src_offset.y), (i32)(src_offset.z), dest.texture_handle, texturetype_to_glenum(dest.type), 0, (i32)(dest_offset.x), (i32)(dest_offset.y), (i32)(dest_offset.z), (i32)(size.x), (i32)(size.y), (i32)(size.z))
}

texture_get_texturetype :: proc(texture: GL4Texture) -> gfx.Texture_Type {
    return texture.type
}

texture_get_internalformat :: proc(texture: GL4Texture) -> gfx.Texture_Format {
    return texture.texture_desc.internal_texture_format
}

texture_get_format :: proc(texture: GL4Texture) -> gfx.Texture_Format {
    return texture.texture_desc.format
}

texture_get_warp :: proc(texture: GL4Texture, warp_identifier: gfx.Warp_Identifier) -> gfx.Texture_Warp {
    switch warp_identifier {
        case .S: return texture.texture_desc.warp_s
        case .T: return texture.texture_desc.warp_t
    }

    panic("Unreachable")
}

texture_get_filter :: proc(texture: GL4Texture, filter_identifier: gfx.Filter_Identifier) -> gfx.Texture_Filter {
    switch filter_identifier {
        case .Min: return texture.texture_desc.min_filter
        case .Mag: return texture.texture_desc.mag_filter
    }

    panic("Unreachable")
}

texture_does_gen_mipmaps :: proc(texture: GL4Texture) -> bool {
    return texture.gen_mipmaps
}

texture_get_size :: proc(texture: GL4Texture) -> [3]uint {
    return texture.texture_size
}


/**************************************************************************************************
***************************************************************************************************
**************************************************************************************************/

@(private)
texture_non_dsa_bind :: proc(texture: GL4Texture) {
    gl.BindTexture(texturetype_to_glenum(texture.type), texture.texture_handle)
}

@(private)
texture_non_dsa_unbind :: proc(target: u32) {
    gl.BindTexture(target, 0)
}

@(private)
texture_full_bind :: proc(texture: GL4Texture, texture_unit: u32) {
    gl.BindTextureUnit(texture_unit, texture.texture_handle)
}

@(private)
get_texture_content_from_file :: proc(file_path: string) -> (
    data: [^]byte,
    x, y, ch_num: c.int,
    texture_format: gfx.Texture_Format,
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

@(private)
texture_set_size_1d :: proc(texture: GL4Texture, size: uint) {
    gl.TextureStorage1D(texture.texture_handle, 1, (u32)(textureformat_to_glinternalformat(texture.internal_texture_format)), (i32)(size))

    texture_gen_mipmaps(texture)


    texture.texture_size = { size, 0, 0 }
}

@(private)
texture_set_size_2d :: proc(texture: GL4Texture, dimension: [2]uint) {
    gl.TextureStorage2D(texture.texture_handle, 1, (u32)(textureformat_to_glinternalformat(texture.internal_texture_format)), (i32)(dimension.x), (i32)(dimension.y))
    
    texture_gen_mipmaps(texture)

    texture.texture_size = { dimension.x, dimension.y, 0 }
}

@(private)
texture_set_size_3d :: proc(texture: GL4Texture, dimension: [3]uint) {
    gl.TextureStorage3D(texture.texture_handle, 1, (u32)(textureformat_to_glinternalformat(texture.internal_texture_format)), (i32)(dimension.x), (i32)(dimension.y), (i32)(dimension.z))

    texture_gen_mipmaps(texture)

    texture.texture_size = dimension
}

@(private)
_internal_texture_new_no_size :: proc(desc: gfx.Texture_Descriptor) -> GL4Texture {
    texture := new(Texture_Impl, CONTEXT.gl_allocator)
    texture.texture_desc = desc

    texture_init_raw(texture, desc)

    return texture
}

@(private)
texture_init_raw :: proc(texture: GL4Texture, desc: gfx.Texture_Descriptor) {
    gl.CreateTextures(texturetype_to_glenum(texture.type), 1, &texture.texture_handle)

    gl.TextureParameteri(texture.texture_handle, gl.TEXTURE_WRAP_S,     texturewarp_to_glenum(desc.warp_s))
    gl.TextureParameteri(texture.texture_handle, gl.TEXTURE_WRAP_T,     texturewarp_to_glenum(desc.warp_t))
    gl.TextureParameteri(texture.texture_handle, gl.TEXTURE_MIN_FILTER, texturefilter_to_glenum(desc.min_filter))
}

@(private)
texture_gen_mipmaps :: proc(texture: GL4Texture) {
    if texture.gen_mipmaps do gl.GenerateTextureMipmap(texture.texture_handle)
}

@(private)
texturetype_to_glenum :: proc(type: gfx.Texture_Type) -> u32 {
    switch type {
        case .Texture_1D: return gl.TEXTURE_1D
        case .Texture_2D: return gl.TEXTURE_2D
        case .Texture_2D_Multisample: return gl.TEXTURE_2D_MULTISAMPLE
        case .Texture_3D: return gl.TEXTURE_3D
        case .Texture_CubeMap: return gl.TEXTURE_CUBE_MAP
    }

    return 0
}

@(private)
textureformat_to_glinternalformat :: proc(format: gfx.Texture_Format) -> i32 {
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
textureformat_to_glformat :: proc(format: gfx.Texture_Format) -> i32 {
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
texturewarp_to_glenum :: proc(warp: gfx.Texture_Warp) -> i32 {
    switch warp {
        case .Clamp_To_Border: return gl.CLAMP_TO_BORDER
        case .Clamp_To_Edge: return gl.CLAMP_TO_EDGE
        case .Mirrored_Repeat: return gl.MIRRORED_REPEAT
        case .Repeat: return gl.REPEAT
    }

    return 0
}

@(private)
texturefilter_to_glenum :: proc(filter: gfx.Texture_Filter) -> i32 {
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

textureformat_size_pixel :: proc(format: gfx.Texture_Format) -> uint {
    switch format {
        case .D24S8: return 4
        case .R8: return 1
        case .R8G8: return 2
        case .R8G8B8: return 3
        case .R8G8B8A8: return 4
    }

    return 0
}

@(private)
pixeltype_to_glenum :: proc(type: gfx.Pixel_type) -> i32 {
    switch type {
        case .UByte: return gl.UNSIGNED_BYTE
        case .UInt24_8: return gl.UNSIGNED_INT_24_8
    }

    return 0
}
