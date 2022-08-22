package vx_lib_logic

import "../gfx"

Abstract_Mesh :: struct {
    vertices: gfx.Abstract_Buffer,
    indices: gfx.Abstract_Buffer,
}

abstractmesh_init_empty :: proc(mesh: ^Abstract_Mesh) {
    gfx.abstractbuffer_init_empty(&mesh.vertices)
    gfx.abstractbuffer_init_empty(&mesh.indices)
}

abstactmesh_init_with_data :: abstractmesh_set_data

abstractmesh_init :: proc { abstractmesh_init_empty, abstactmesh_init_with_data }

abstractmesh_free :: proc(mesh: Abstract_Mesh) {
    gfx.abstractbuffer_free(mesh.vertices)
    gfx.abstractbuffer_free(mesh.indices)
}

abstractmesh_set_data :: proc(mesh: ^Abstract_Mesh, vertex_data: []$T, index_data: []$U) {
    gfx.abstractbuffer_set_data(&mesh.vertices, vertex_data)
    gfx.abstractbuffer_set_data(&mesh.indices, index_data)
}
