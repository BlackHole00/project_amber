package vx_lib_utils

import "../gfx"
import "../logic"
import gl "vendor:OpenGL"

Batcher_Descriptor :: struct {
    primitive: u32,
}

Batcher :: struct {
    using mesh_builder: Mesh_Builder,

    mesh: logic.Mesh_Component,
}

batcher_init :: proc(batcher: ^Batcher, desc: Batcher_Descriptor) {
    meshbuilder_init(batcher)

    logic.meshcomponent_init(&batcher.mesh, logic.Mesh_Descriptor {
        index_buffer_type = gl.UNSIGNED_INT,
        gl_usage = gl.DYNAMIC_DRAW,
        gl_draw_mode = desc.primitive,
    })
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
    logic.meshcomponent_set_data(&batcher.mesh, batcher.vertices[:], batcher.indices[:])
    logic.meshcomponent_draw(batcher.mesh, pipeline, texture_bindings)
}

batcher_free :: proc(batcher: ^Batcher) {
    logic.meshcomponent_free(&batcher.mesh)
    meshbuilder_free(batcher)
}