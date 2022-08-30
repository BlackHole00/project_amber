package vx_lib_gfx

import "core:log"
import gl "vendor:OpenGL"

@(private)
_glimpl_texture_init_raw :: proc(texture: ^Texture, desc: Texture_Descriptor) {
    texture.texture_desc = desc

    gl.CreateTextures(_glimpl_texturetype_to_glenum(texture.type), 1, ([^]u32)(&texture.texture_handle))

    gl.TextureParameteri((u32)(texture.texture_handle), gl.TEXTURE_WRAP_S,     _glimpl_texturewarp_to_glenum(desc.warp_s))
    gl.TextureParameteri((u32)(texture.texture_handle), gl.TEXTURE_WRAP_T,     _glimpl_texturewarp_to_glenum(desc.warp_t))
    gl.TextureParameteri((u32)(texture.texture_handle), gl.TEXTURE_MIN_FILTER, _glimpl_texturefilter_to_glenum(desc.min_filter))
    gl.TextureParameteri((u32)(texture.texture_handle), gl.TEXTURE_MAG_FILTER, _glimpl_texturefilter_to_glenum(desc.mag_filter))
}

@(private)
_glimpl_texture_init_with_size_1d :: proc(texture: ^Texture, desc: Texture_Descriptor, size: uint) {
    _glimpl_texture_init_raw(texture, desc)
    _glimpl_texture_set_size_1d(texture, size)
}

@(private)
_glimpl_texture_init_with_size_2d :: proc(texture: ^Texture, desc: Texture_Descriptor, dimension: [2]uint) {
    _glimpl_texture_init_raw(texture, desc)
    _glimpl_texture_set_size_2d(texture, dimension)
}

@(private)
_glimpl_texture_init_with_size_3d :: proc(texture: ^Texture, desc: Texture_Descriptor, dimension: [3]uint) {
    _glimpl_texture_init_raw(texture, desc)
    _glimpl_texture_set_size_3d(texture, dimension)
}

@(private)
_glimpl_texture_set_data_1d :: proc(texture: Texture, data: []$T, texture_format: Texture_Format, offset: int) {
    gl.TextureSubImage1D((u32)(texture.texture_handle), 0, (i32)(offset), (i32)(len(data)), (u32)(_glimpl_textureformat_to_glformat(texture_format)), gl.UNSIGNED_BYTE, &data[0])
}

@(private)
_glimpl_texture_set_data_2d :: proc(texture: Texture, data: []$T, texture_format: Texture_Format, dimension: [2]uint, offset: [2]uint) {
    gl.TextureSubImage2D((u32)(texture.texture_handle), 0, (i32)(offset.x), (i32)(offset.y), (i32)(dimension.x), (i32)(dimension.y), (u32)(_glimpl_textureformat_to_glformat(texture_format)), gl.UNSIGNED_BYTE, &data[0])
}

@(private)
_glimpl_texture_set_data_3d :: proc(texture: Texture, data: []$T, texture_format: Texture_Format, dimension: [3]uint, offset: [3]uint) {
    gl.TextureSubImage3D((u32)(texture.texture_handle), 0, (i32)(offset.x), (i32)(offset.y), (i32)(offset.z), (i32)(dimension.x), (i32)(dimension.y), (i32)(dimension.z), (u32)(_glimpl_textureformat_to_glformat(texture_format)), gl.UNSIGNED_BYTE, &data[0])
}

@(private)
_glimpl_texture_set_data_cubemap_face :: proc(texture: Texture, data: []$T, texture_format: Texture_Format, dimension: [2]uint, face: uint) {
    if texture.type != .Texture_CubeMap {
        log.error("texture_set_data_cubemap_face works only with .Texture_CubeMap textures!")
        return
    }

    when true {
        _glimpl_texture_non_dsa_bind(texture)

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

        gl.TexImage2D(target, 0, _glimpl_textureformat_to_glinternalformat(texture.internal_texture_format), (i32)(dimension.x), (i32)(dimension.y), 0, (u32)(_glimpl_textureformat_to_glformat(texture_format)), gl.UNSIGNED_BYTE, &data[0])

        _glimpl_texture_non_dsa_unbind(_glimpl_texturetype_to_glenum(texture.type))
    } else {
        texture_set_size_2d(texture, { (uint)(x), (uint)(y) })

        gl.TextureSubImage3D(texture.texture_handle, 0, 0, 0, (i32)(face), (i32)(dimension.x), (i32)(dimension.y), 1, texture_format, pixel_type, &data[0])
    }
    _glimpl_texture_gen_mipmaps(texture)
}

@(private)
_glimpl_texture_gen_mipmaps :: proc(texture: Texture) {
    if texture.gen_mipmaps do gl.GenerateTextureMipmap((u32)(texture.texture_handle))
}

@(private)
_glimpl_texture_resize_1d :: proc(texture: ^Texture, new_len: uint) {
    new_texture: Texture = ---

    texture_init(&new_texture, texture.texture_desc, new_len)

    _glimpl_texture_copy_1d(texture^, new_texture, { 0, 0, 0 }, { 0, 0, 0 })

    _glimpl_texture_free(texture)
    texture^ = new_texture
}

@(private)
_glimpl_texture_resize_2d :: proc(texture: ^Texture, new_size: [2]uint) {
    new_texture: Texture = ---

    texture_init(&new_texture, texture.texture_desc, new_size)

    _glimpl_texture_copy_2d(texture^, new_texture, { 0, 0, 0 }, { 0, 0, 0 })

    _glimpl_texture_free(texture)
    texture^ = new_texture
}

@(private)
_glimpl_texture_resize_3d :: proc(texture: ^Texture, new_size: [3]uint) {
    new_texture: Texture = ---

    texture_init(&new_texture, texture.texture_desc, new_size)

    _glimpl_texture_copy_3d(texture^, new_texture, { 0, 0, 0 }, { 0, 0, 0 })

    _glimpl_texture_free(texture)
    texture^ = new_texture
}

@(private)
_glimpl_texture_copy_1d :: proc(src: Texture, dest: Texture, src_offset: [3]i32, dest_offset: [3]i32) {
    size := min(src.texture_size.x, dest.texture_size.y)

    gl.CopyImageSubData((u32)(src.texture_handle), _glimpl_texturetype_to_glenum(src.type), 0, src_offset.x, src_offset.y, src_offset.z, (u32)(dest.texture_handle), _glimpl_texturetype_to_glenum(dest.type), 0, dest_offset.x, dest_offset.y, dest_offset.z, (i32)(size), 1, 1)
}

@(private)
_glimpl_texture_copy_2d :: proc(src: Texture, dest: Texture, src_offset: [3]i32, dest_offset: [3]i32) {
    size: [2]uint = ---
    size.x = min(src.texture_size.x, dest.texture_size.y)
    size.y = min(src.texture_size.y, dest.texture_size.y)

    gl.CopyImageSubData((u32)(src.texture_handle), _glimpl_texturetype_to_glenum(src.type), 0, src_offset.x, src_offset.y, src_offset.z, (u32)(dest.texture_handle), _glimpl_texturetype_to_glenum(dest.type), 0, dest_offset.x, dest_offset.y, dest_offset.z, (i32)(size.x), (i32)(size.y), 1)
}

@(private)
_glimpl_texture_copy_3d :: proc(src: Texture, dest: Texture, src_offset: [3]i32, dest_offset: [3]i32) {
    size: [3]uint = ---
    size.x = min(src.texture_size.x, dest.texture_size.y)
    size.y = min(src.texture_size.y, dest.texture_size.y)
    size.z = min(src.texture_size.z, dest.texture_size.z)

    gl.CopyImageSubData((u32)(src.texture_handle), _glimpl_texturetype_to_glenum(src.type), 0, src_offset.x, src_offset.y, src_offset.z, (u32)(dest.texture_handle), _glimpl_texturetype_to_glenum(dest.type), 0, dest_offset.x, dest_offset.y, dest_offset.z, (i32)(size.x), (i32)(size.y), (i32)(size.z))
}

@(private)
_glimpl_texture_free :: proc(texture: ^Texture) {
    gl.DeleteTextures(1, ([^]u32)(&texture.texture_handle))

    texture.texture_handle = INVALID_HANDLE
}


@(private)
_glimpl_texturetype_to_glenum :: proc(type: Texture_Type) -> u32 {
    switch type {
        case .Texture_1D: return gl.TEXTURE_1D
        case .Texture_2D: return gl.TEXTURE_2D
        case .Texture_3D: return gl.TEXTURE_3D
        case .Texture_CubeMap: return gl.TEXTURE_CUBE_MAP
    }

    return 0
}

@(private)
_glimpl_textureformat_to_glinternalformat :: proc(format: Texture_Format) -> i32 {
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
_glimpl_textureformat_to_glformat :: proc(format: Texture_Format) -> i32 {
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
_glimpl_texturewarp_to_glenum :: proc(warp: Texture_Warp) -> i32 {
    switch warp {
        case .Clamp_To_Border: return gl.CLAMP_TO_BORDER
        case .Clamp_To_Edge: return gl.CLAMP_TO_EDGE
        case .Mirrored_Repeat: return gl.MIRRORED_REPEAT
        case .Repeat: return gl.REPEAT
    }

    return 0
}

@(private)
_glimpl_texturefilter_to_glenum :: proc(filter: Texture_Filter) -> i32 {
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

@(private)
_glimpl_texture_non_dsa_bind :: proc(texture: Texture) {
    gl.BindTexture(_glimpl_texturetype_to_glenum(texture.type), (u32)(texture.texture_handle))
}

@(private)
_glimpl_texture_non_dsa_unbind :: proc(target: u32) {
    gl.BindTexture(target, 0)
}

@(private)
_glimpl_texture_full_bind :: proc(texture: Texture, texture_unit: u32) {
    gl.BindTextureUnit(texture_unit, (u32)(texture.texture_handle))
}

@(private)
_glimpl_texture_apply:: proc(texture: Texture, texture_unit: u32, shader: ^Pipeline, uniform_location: uint) {
    pipeline_uniform_1i(shader, uniform_location, (i32)(texture_unit))
}

@(private)
_glimpl_texture_set_size_1d :: proc(texture: ^Texture, size: uint) {
    gl.TextureStorage1D((u32)(texture.texture_handle), 1, (u32)(_glimpl_textureformat_to_glinternalformat(texture.internal_texture_format)), (i32)(size))
    texture_gen_mipmaps(texture^)

    texture.texture_size = { size, 0, 0 }
}

@(private)
_glimpl_texture_set_size_2d :: proc(texture: ^Texture, dimension: [2]uint) {
    gl.TextureStorage2D((u32)(texture.texture_handle), 1, (u32)(_glimpl_textureformat_to_glinternalformat(texture.internal_texture_format)), (i32)(dimension.x), (i32)(dimension.y))
    texture_gen_mipmaps(texture^)

    texture.texture_size = { dimension.x, dimension.y, 0 }
}

@(private)
_glimpl_texture_set_size_3d :: proc(texture: ^Texture, dimension: [3]uint) {
    gl.TextureStorage3D((u32)(texture.texture_handle), 1, (u32)(_glimpl_textureformat_to_glinternalformat(texture.internal_texture_format)), (i32)(dimension.x), (i32)(dimension.y), (i32)(dimension.z))
    texture_gen_mipmaps(texture^)

    texture.texture_size = dimension
}

