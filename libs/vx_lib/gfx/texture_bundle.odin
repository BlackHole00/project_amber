package vx_lib_gfx

import "core:log"
import gl "vendor:OpenGL"

Texture_Bundle :: struct {
    textures: map[string]Texture,
    descriptor: Texture_Descriptor,
    current_texture: string,
}

texturebundle_init :: proc(bundle: ^Texture_Bundle, desc: Texture_Descriptor) {
    bundle.textures = make(map[string]Texture)
    bundle.descriptor = desc
}

texturebundle_free :: proc(bundle: ^Texture_Bundle) {
    for _, tex in &bundle.textures do texture_free(&tex)

    delete(bundle.textures)
}

texturebundle_insert_texture_1d :: proc(bundle: ^Texture_Bundle, texture_name: string, data: []$T, texture_format: u32) {
    if bundle.descriptor.gl_type != gl.TEXTURE_1D {
        log.error("This bundle is not compatible with gl.TEXTURE_1D textures (required type:", bundle.descriptor.gl_type, ")")
        return
    }

    texture: Texture = ---
    texture_init(&texture, bundle.descriptor, data, texture_format)
    bundle.textures[texture_name] = texture
}

texturebundle_insert_texture_2d :: proc(bundle: ^Texture_Bundle, texture_name: string, data: []$T, texture_format: u32, dimension: [2]uint) {
    if bundle.descriptor.gl_type != gl.TEXTURE_2D {
        log.error("This bundle is not compatible with gl.TEXTURE_2D textures (required type:", bundle.descriptor.gl_type, ")")
        return
    }

    texture: Texture = ---
    texture_init(&texture, bundle.descriptor, data, texture_format, dimension)
    bundle.textures[texture_name] = texture
}

texturebundle_insert_texture_3d :: proc(bundle: ^Texture_Bundle, texture_name: string, data: []$T, texture_format: u32, dimension: [3]uint) {
    if bundle.descriptor.gl_type != gl.TEXTURE_3D {
        log.error("This bundle is not compatible with gl.TEXTURE_3D textures (required type:", bundle.descriptor.gl_type, ")")
        return
    }

    texture: Texture = ---
    texture_init(&texture, bundle.descriptor, data, texture_format, dimension)
    bundle.textures[texture_name] = texture
}

texturebundle_insert_texture_from_file :: proc(bundle: ^Texture_Bundle, texture_name: string, file_path: string, texture_format := -1) {
    if bundle.descriptor.gl_type != gl.TEXTURE_2D {
        log.error("texturebundle_insert_texture_from_file works only with gl.TEXTURE_2D bundles.")
        return
    }

    texture: Texture = ---
    texture_init(&texture, bundle.descriptor, file_path, texture_format)
    bundle.textures[texture_name] = texture
}

texturebundle_insert_texture :: proc { texturebundle_insert_texture_1d, texturebundle_insert_texture_2d, texturebundle_insert_texture_3d, texturebundle_insert_texture_from_file }

texturebundle_get_texture :: proc(bundle: Texture_Bundle, texture_name: string) -> Texture {
    if texture_name not_in bundle.textures do panic("Texture not found in bundle")
    return bundle.textures[texture_name]
}

texturebundle_remove_texture :: proc(bundle: ^Texture_Bundle, texture_name: string) {
    if texture_name not_in bundle.textures {
        log.warn("Could not find texture", texture_name, "in bundle")
        return
    }

    texture_free(&bundle.textures[texture_name])
    delete_key(&bundle.textures, texture_name)

    if bundle.current_texture == texture_name do bundle.current_texture = ""
}

texturebundle_set_current_texture :: proc(bundle: ^Texture_Bundle, texture_name: string) {
    bundle.current_texture = texture_name
}

texturebundle_get_current_texture :: proc(bundle: Texture_Bundle) -> Texture {
    return texturebundle_get_texture(bundle, bundle.current_texture)
}

texturebundle_bind :: proc(bundle: Texture_Bundle) {
    if bundle.current_texture not_in bundle.textures {
        log.warn("Could not find texture", bundle.current_texture, "in bundle")
        return
    }

    texture_bind(bundle.textures[bundle.current_texture])
}

texturebundle_apply:: proc(bundle: Texture_Bundle, shader: ^Shader, uniform_name: string) {
    shader_uniform_1i(shader, uniform_name, bundle.descriptor.texture_unit)
}
