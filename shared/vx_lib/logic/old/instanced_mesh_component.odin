package vx_lib_logic

import "../gfx"

Instanced_Mesh_Descriptor :: struct {
    index_buffer_type: gfx.Index_Type,
    usage: gfx.Buffer_Usage,
    draw_type: gfx.Primitive,

    textures: []gfx.Texture_Binding,
}

Instanced_Mesh_Component :: struct {
    using _base: Mesh_Component,
    instance_buffer: gfx.Buffer,

    instance_count: int,
}

instancedmeshcomponent_init_empty :: proc(mesh: ^Instanced_Mesh_Component, desc: Instanced_Mesh_Descriptor) {
    meshcomponent_init_empty(mesh,
        Mesh_Descriptor {
            desc.index_buffer_type,
            desc.usage,
            desc.draw_type,

            desc.textures,
        },
    )

    mesh.instance_buffer = gfx.buffer_new(gfx.Buffer_Descriptor {
        type = .Vertex_Buffer,
        usage = .Dynamic_Draw,
    })
}

instancedmeshcomponent_init_with_data :: proc(mesh: ^Instanced_Mesh_Component, desc: Mesh_Descriptor, vertex_data: []$T, index_data: []$U, uniform_data: []$V, instance_count: int, index_count := -1) {
    meshcomponent_init_with_data(mesh, Mesh_Descriptor {
        desc.index_buffer_type, desc.gl_usage, desc.draw_type,
    }, vertex_data, index_data, index_count)

    instancedmeshcomponent_set_uniorm_data(mesh, uniform_data, instance_count)
}

instancedmeshcomponent_init :: proc { instancedmeshcomponent_init_empty, instancedmeshcomponent_init_with_data }

instancedmeshcomponent_free :: proc(mesh: ^Instanced_Mesh_Component) {
    gfx.buffer_free(mesh.instance_buffer)
    meshcomponent_free(mesh)
}

instancedmeshcomponent_set_data :: meshcomponent_set_data

instancedmeshcomponent_set_instanced_data :: proc(mesh: ^Instanced_Mesh_Component, instance_data: []$T, instance_count: int) {
    mesh.instance_count = instance_count

    gfx.buffer_set_data(mesh.instance_buffer, instance_data)
}

instancedmeshcomponent_get_bindings :: proc(mesh: Instanced_Mesh_Component) -> gfx.Bindings {
    return mesh._base.bindings
}

instancedmeshcomponent_draw :: proc(mesh: Instanced_Mesh_Component, pipeline: gfx.Pipeline) {
    bindings := instancedmeshcomponent_get_bindings(mesh)

    gfx.pipeline_draw_elements_instanced(
        pipeline,
        bindings,
        mesh.draw_type,
        mesh.index_count,
        mesh.instance_count,
    )
}
