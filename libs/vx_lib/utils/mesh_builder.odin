package vx_lib_utils

import "../logic"

Mesh_Builder :: struct {
    vertices: [dynamic]byte,
    indices: [dynamic]u32,

    vertex_count: uint,
    index_count: uint,
}

meshbuilder_init :: proc(builder: ^Mesh_Builder) {
    builder.vertices = make([dynamic]byte)
    builder.indices = make([dynamic]u32)
}

meshbuilder_push_vertex :: proc(builder: ^Mesh_Builder, vertex: $T) {
    v := vertex

    data := ([^]byte)(&v)
    length := size_of(T)

    for i in 0..<length {
        append(&builder.vertices, data[i])
    }

    builder.vertex_count += 1
}

meshbuilder_push_index :: proc(builder: ^Mesh_Builder, index: u32) {
    append(&builder.indices, index)

    builder.index_count += 1
}

meshbuilder_push_triangle :: proc(builder: ^Mesh_Builder, vertices: []$T, indices: []u32 = { 0, 1, 2 }) {
    if len(indices) != 3 do panic("Invalid mesh indices")

    meshbuilder_raw_push(builder, vertices, indices)
}

meshbuilder_push_quad :: proc(builder: ^Mesh_Builder, vertices: []$T, indices: []u32 = { 0, 1, 2, 2, 3, 0 }) {
    if len(indices) != 6 do panic("Invalid mesh indices")

    meshbuilder_raw_push(builder, vertices, indices)
}

meshbuilder_raw_push :: proc(builder: ^Mesh_Builder, vertices: []$T, indices: []u32) {
    starting_idx := len(builder.indices)

    for vertex in vertices do meshbuilder_push_vertex(builder, vertex)
    for index in indices do meshbuilder_push_index(builder, (u32)(starting_idx) + index)
}

meshbuilder_clear :: proc(builder: ^Mesh_Builder) {
    clear(&builder.vertices)
    clear(&builder.indices)

    builder.vertex_count = 0
    builder.index_count = 0
}

meshbuilder_build :: proc(builder: Mesh_Builder, mesh: ^logic.Mesh_Component) {
    logic.meshcomponent_set_data(mesh, builder.vertices[:], builder.indices[:], len(builder.indices))
}

meshbuilder_free :: proc(builder: Mesh_Builder) {
    delete(builder.vertices)
    delete(builder.indices)
}
