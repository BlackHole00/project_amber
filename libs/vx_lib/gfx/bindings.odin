package vx_lib_gfx

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
    if bindings.vertex_count != 0 do mem.copy(&bindings.vertex_buffers[0], &vertex_buffers[0], len(vertex_buffers) * size_of(Buffer))

    bindings.index_buffer = index_buffer

    bindings.texture_count = len(textures)
    if bindings.texture_count != 0 do mem.copy(&bindings.textures[0], &textures[0], len(vertex_buffers) * size_of(Texture_Binding))
}

/**************************************************************************************************
***************************************************************************************************
**************************************************************************************************/

@(private)
bindings_apply :: proc(pipeline: ^Pipeline, bindings: ^Bindings) {
    GFX_PROCS.bindings_apply(pipeline, bindings)
}
