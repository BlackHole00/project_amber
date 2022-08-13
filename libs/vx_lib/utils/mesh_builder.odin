package vx_lib_utils

import "../logic"
import "core:log"
import gl "vendor:OpenGL"

MeshBuilder_Descriptor :: struct {
    gl_usage: u32,
    gl_draw_mode: u32,
}

Mesh_Builder :: struct {
    vertices: [dynamic]byte,
    indices: [dynamic]u32,

    desc: MeshBuilder_Descriptor,
}

meshbuilder_init :: proc(builder: ^Mesh_Builder, desc: MeshBuilder_Descriptor) {
    builder.vertices = make([dynamic]byte)
    builder.indices = make([dynamic]u32)

    builder.desc = desc
}

meshbuilder_push_vertex :: proc(builder: ^Mesh_Builder, vertex: $T) {
    v := vertex

    data := ([^]byte)(&v)
    length := size_of(T)

    for i in 0..<length {
        append(&builder.vertices, data[i])
    }
}

meshbuilder_push_index :: proc(builder: ^Mesh_Builder, index: u32) {
    append(&builder.indices, index)
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

meshbuilder_build :: proc(builder: Mesh_Builder, mesh: ^logic.Mesh_Component) {
    logic.meshcomponent_init(mesh, logic.Mesh_Descriptor {
        index_buffer_type = gl.UNSIGNED_INT,
        gl_usage = builder.desc.gl_usage,
        gl_draw_mode = builder.desc.gl_draw_mode,
    })

    log.info("Vertex data:", builder.vertices)
    log.info("Index data:", builder.indices)

    logic.meshcomponent_set_data(mesh, builder.vertices[:], builder.indices[:], len(builder.indices))
}

meshbuilder_free :: proc(builder: Mesh_Builder) {
    delete(builder.vertices)
    delete(builder.indices)
}
