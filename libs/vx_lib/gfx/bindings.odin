package vx_lib_gfx

import "core:log"
import "core:mem"

Texture_Binding :: struct {
    texture: Texture,
    uniform_name: string,
}

Bindings :: struct {
    vertex_count: uint,
    vertex_buffers: [16]Buffer,
    index_buffer: Maybe(Buffer),

    texture_count: uint,
    textures: [16]Texture_Binding,
}

bindings_init :: proc(bindings: ^Bindings, vertex_buffers: []Buffer, index_buffer: Maybe(Buffer), textures: []Texture_Binding) {
    bindings.vertex_count = len(vertex_buffers)
    mem.copy(&bindings.vertex_buffers[0], &vertex_buffers[0], len(vertex_buffers) * size_of(Buffer))

    bindings.index_buffer = index_buffer

    bindings.texture_count = len(textures)
    mem.copy(&bindings.textures[0], &textures[0], len(vertex_buffers) * size_of(Texture_Binding))
}

/**************************************************************************************************
***************************************************************************************************
**************************************************************************************************/

@(private)
bindings_apply :: proc(pipeline: ^Pipeline, bindings: ^Bindings) {
    if bindings.index_buffer == nil do pipeline_layout_apply(pipeline^, bindings.vertex_buffers[:bindings.vertex_count])
    else do pipeline_layout_apply(pipeline^, bindings.vertex_buffers[:bindings.vertex_count], bindings.index_buffer.(Buffer))

    used_units: [32]bool

    for i in 0..<bindings.texture_count {
        texture_apply(bindings.textures[i].texture, pipeline, bindings.textures[i].uniform_name)
        texture_full_bind(bindings.textures[i].texture)

        if used_units[bindings.textures[i].texture.texture_unit] do log.warn("Texture unit", bindings.textures[i].texture.texture_unit, "is already used")
        else do used_units[bindings.textures[i].texture.texture_unit] = true
    }
}
