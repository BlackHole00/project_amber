package vx_lib_logic

import "../gfx"

Mesh_Descriptor :: struct {
    index_buffer_type: gfx.Index_Type,
    usage: gfx.Buffer_Usage,
    draw_type: gfx.Primitive,

    textures: []gfx.Texture_Binding,
}

Mesh_Component :: struct {
    usage: gfx.Buffer_Usage,
    draw_type: gfx.Primitive,

    vertex_buffer: gfx.Buffer,
    index_buffer: gfx.Buffer,
    bindings: gfx.Bindings,

    index_count: int,
}

meshcomponent_init_empty :: proc(mesh: ^Mesh_Component, desc: Mesh_Descriptor) {
    mesh.usage = desc.usage
    mesh.draw_type = desc.draw_type

    mesh.vertex_buffer = gfx.buffer_new(gfx.Buffer_Descriptor {
        type = .Vertex_Buffer,
        usage = desc.usage,
    })
    mesh.index_buffer = gfx.buffer_new(gfx.Buffer_Descriptor {
        type = .Index_Buffer,
        usage = desc.usage,
        index_type = desc.index_buffer_type,
    })

    gfx.bindings_new(
        []gfx.Buffer {
            mesh.vertex_buffer,
        }, 
        mesh.index_buffer,
        desc.textures,
        {},
    )
}

meshcomponent_init_with_data :: proc(mesh: ^Mesh_Component, desc: Mesh_Descriptor, vertex_data: []$T, index_data: []$U, index_count := -1) {
    mesh.usage = desc.usage
    mesh.draw_type = desc.draw_type

    mesh.vertex_buffer = gfx.buffer_new(gfx.Buffer_Descriptor {
        type = .Vertex_Buffer,
        usage = desc.usage,
    }, vertex_data)
    mesh.index_buffer = gfx.buffer_new(gfx.Buffer_Descriptor {
        type = .Index_Buffer,
        usage = desc.usage,
    }, index_data)

    mesh.index_count = index_count
    if index_count == -1 {
        mesh.index_count = len(index_data)
    }
}

meshcomponent_init :: proc { meshcomponent_init_empty, meshcomponent_init_with_data }

meshcomponent_free :: proc(mesh: ^Mesh_Component) {
    gfx.buffer_free(mesh.vertex_buffer)
    gfx.buffer_free(mesh.index_buffer)
}

meshcomponent_set_data :: proc(mesh: ^Mesh_Component, vertex_data: []$T, index_data: []$U, index_count := -1) {
    gfx.buffer_set_data(mesh.vertex_buffer, vertex_data)
    gfx.buffer_set_data(mesh.index_buffer, index_data)

    mesh.index_count = index_count
    if index_count == -1 {
        mesh.index_count = len(index_data)
    }
}

meshcomponent_get_bindings :: proc(mesh: Mesh_Component) -> gfx.Bindings {
    return mesh.bindings
}

meshcomponent_draw :: proc(mesh: Mesh_Component, pipeline: gfx.Pipeline) {
    bindings := meshcomponent_get_bindings(mesh)

    gfx.pipeline_draw_elements(
        pipeline,
        bindings,
        mesh.draw_type,
        mesh.index_count,
    )
}
