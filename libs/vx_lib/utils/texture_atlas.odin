package vx_lib_utils

import "../gfx"
import "core:os"
import "core:encoding/csv"
import "core:strconv"
import "core:log"
import "core:strings"
import gl "vendor:OpenGL"

Texture_Atlas_Descriptor :: struct {
    initial_size: [2]uint,
    internal_texture_format: i32,
    texture_unit: i32,
    warp_s: i32,
    warp_t: i32,
    min_filter: i32,
    mag_filter: i32,
    gen_mipmaps: bool,
}

Texture_Atlas_Elem :: struct {
    start_pos: [2]uint,
    size: [2]uint,
}

Texture_Atlas :: struct {
    textures: map[string]Texture_Atlas_Elem,

    texture: gfx.Texture,
}

textureatlas_init :: proc(atlas: ^Texture_Atlas, desc: Texture_Atlas_Descriptor) {
    atlas.textures = make(map[string]Texture_Atlas_Elem)

    gfx.texture_init(&atlas.texture, gfx.Texture_Descriptor {
        gl_type = gl.TEXTURE_2D,
        internal_texture_format = desc.internal_texture_format,
        texture_unit = desc.texture_unit,
        warp_s = desc.warp_s,
        warp_t = desc.warp_t,
        min_filter = desc.min_filter,
        mag_filter = desc.mag_filter,
        gen_mipmaps = desc.gen_mipmaps,
    }, desc.initial_size)
}

textureatlas_init_from_file :: proc(atlas: ^Texture_Atlas, desc: Texture_Atlas_Descriptor, image_name: string, config_file_name: string) {
    gfx.texture_init(&atlas.texture, gfx.Texture_Descriptor {
        gl_type = gl.TEXTURE_2D,
        internal_texture_format = desc.internal_texture_format,
        texture_unit = desc.texture_unit,
        warp_s = desc.warp_s,
        warp_t = desc.warp_t,
        min_filter = desc.min_filter,
        mag_filter = desc.mag_filter,
        gen_mipmaps = desc.gen_mipmaps,
    }, image_name)

    atlas.textures = make(map[string]Texture_Atlas_Elem)

    config_file_contents, ok := os.read_entire_file(config_file_name)
    defer delete(config_file_contents)
    if !ok do panic("could not open configuration file")

    log.info((string)(config_file_contents))

    elems, _ := csv.read_all_from_string((string)(config_file_contents))
    defer for elem in elems do delete(elem)
    defer delete(elems)

    for line in elems {
        if len(line) != 5 do panic("invalid configuration file format")

        log.info(line)

        elem := Texture_Atlas_Elem {
            start_pos = {
                (uint)(strconv.atoi(strings.trim_space(line[1]))),
                (uint)(strconv.atoi(strings.trim_space(line[2]))),
            },
            size = {
                (uint)(strconv.atoi(strings.trim_space(line[3]))),
                (uint)(strconv.atoi(strings.trim_space(line[4]))),
            },
        }

        map_insert(&atlas.textures, line[0], elem)
    }
}

textureatlas_get_texture_bindings :: proc(atlas: Texture_Atlas, uniform_name: string) -> gfx.Texture_Binding {
    return gfx.Texture_Binding {
        texture = atlas.texture,
        uniform_name = uniform_name,
    }
}

textureatlas_resize :: proc(atlas: ^Texture_Atlas, new_size: [2]uint) {
    gfx.texture_resize_2d(&atlas.texture, new_size)
}

textureatlas_get_uv :: proc(atlas: ^Texture_Atlas, texture: string) -> (
    top, bottom, left, right: f32,
) {
    log.info(atlas)

    elem := atlas.textures[texture]
    atlas_size := atlas.texture.texture_size

    left = (f32)(elem.start_pos.x) / (f32)(atlas_size.x)
    bottom = (f32)(elem.start_pos.y + elem.size.y) / (f32)(atlas_size.y)
    right = (f32)(elem.start_pos.x + elem.size.x) / (f32)(atlas_size.x)
    top = (f32)(elem.start_pos.y) / (f32)(atlas_size.y)

    return
}
