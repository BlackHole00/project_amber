package vx_lib_utils

import "../gfx"
import gl "vendor:OpenGL"

Batcher_Descriptor :: struct {
    primitive: u32,
}

Batcher :: struct {
    using mesh_builder: Mesh_Builder,

    vertex_buffer: gfx.Buffer,
    index_buffer: gfx.Buffer,
    primitive: u32,
}

batcher_init :: proc(batcher: ^Batcher, desc: Batcher_Descriptor) {
    meshbuilder_init(batcher)

    gfx.buffer_init(&batcher.vertex_buffer, gfx.Buffer_Descriptor {
        gl_type = gl.ARRAY_BUFFER,
        gl_usage = gl.DYNAMIC_DRAW,
    })
    gfx.buffer_init(&batcher.index_buffer, gfx.Buffer_Descriptor {
        gl_type = gl.ELEMENT_ARRAY_BUFFER,
        gl_usage = gl.DYNAMIC_DRAW,
    })

    batcher.primitive = desc.primitive
}

batcher_push_vertex :: proc(batcher: ^Batcher, vertex: $T) {
    meshbuilder_push_vertex(builder, vertex)
}

batcher_push_index :: proc(batcher: ^Batcher, index: u32) {
    meshbuilder_push_index(batcher, index)
}

batcher_push_triangle :: proc(batcher: ^Batcher, vertices: []$T, indices: []u32 = { 0, 1, 2 }) {
    meshbuilder_push_triangle(batcher, vertices, indices)
}

batcher_push_quad :: proc(batcher: ^Batcher, vertices: []$T, indices: []u32 = { 0, 1, 2, 2, 3, 0 }) {
    meshbuilder_push_quad(batcher, vertices, indices)
}

batcher_raw_push :: proc(batcher: ^Batcher, vertices: []$T, indices: []u32) {
    meshbuilder_raw_push(batcher, vertices, indices)
}

batcher_clear :: proc(batcher: ^Batcher) {
    meshbuilder_clear(batcher)
}

batcher_draw :: proc(batcher: ^Batcher, pipeline: ^gfx.Pipeline, texture_bindings: []gfx.Texture_Binding = {}) {
    bindings: gfx.Bindings = ---
    gfx.bindings_init(&bindings, 
        []gfx.Buffer{
            batcher.vertex_buffer,
        }, 
        batcher.index_buffer, 
        texture_bindings,
    )

    gfx.pipeline_draw_elements(pipeline, &bindings, batcher.primitive, gl.UNSIGNED_INT, (int)(batcher.index_count), nil)
}