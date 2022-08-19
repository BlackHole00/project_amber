package vx_lib_logic

import "../gfx"
import gl "vendor:OpenGL"

Instanced_Mesh_Descriptor :: struct {
    // using base: Mesh_Descriptor,
    index_buffer_type: u32,
    gl_usage: u32,
    gl_draw_mode: u32,
    draw_to_depth_buffer: bool,
}

Instanced_Mesh_Component :: struct {
    using _base: Mesh_Component,
    instance_buffer: gfx.Buffer,

    instance_count: int,
}

instancedmeshcomponent_init_empty :: proc(mesh: ^Instanced_Mesh_Component, desc: Instanced_Mesh_Descriptor) {
    meshcomponent_init_empty(mesh, Mesh_Descriptor {
        desc.index_buffer_type, desc.gl_usage, desc.gl_draw_mode, desc.draw_to_depth_buffer,
    })

    gfx.buffer_init(&mesh.instance_buffer, gfx.Buffer_Descriptor {
        gl_type = gl.ARRAY_BUFFER,
        gl_usage = gl.DYNAMIC_DRAW,
    })
}

instancedmeshcomponent_init_with_data :: proc(mesh: ^Instanced_Mesh_Component, desc: Mesh_Descriptor, vertex_data: []$T, index_data: []$U, uniform_data: []$V, instance_count: int, index_count := -1) {
    meshcomponent_init_with_data(mesh, Mesh_Descriptor {
        desc.index_buffer_type, desc.gl_usage, desc.gl_draw_mode,
    }, vertex_data, index_data, index_count)

    instancedmeshcomponent_set_uniorm_data(mesh, uniform_data, instance_count)
}

instancedmeshcomponent_init :: proc { instancedmeshcomponent_init_empty, instancedmeshcomponent_init_with_data }

instancedmeshcomponent_free :: proc(mesh: ^Instanced_Mesh_Component) {
    gfx.buffer_free(&mesh.instance_buffer)
    meshcomponent_free(mesh)
}

instancedmeshcomponent_set_data :: meshcomponent_set_data

instancedmeshcomponent_set_instanced_data :: proc(mesh: ^Instanced_Mesh_Component, instance_data: []$T, instance_count: int) {
    mesh.instance_count = instance_count

    gfx.buffer_add_data(mesh.instance_buffer, instance_data)
}

instancedmeshcomponent_get_bindings :: proc(mesh: Instanced_Mesh_Component, textures: Maybe([]gfx.Texture_Binding), bindings: ^gfx.Bindings) {
    real_textures := []gfx.Texture_Binding { }
    if textures != nil do real_textures = textures.([]gfx.Texture_Binding)

    gfx.bindings_init(bindings, 
        []gfx.Buffer {
            mesh.vertex_buffer,
            mesh.instance_buffer,
        }, mesh.index_buffer,
        real_textures,
    )
}

instancedmeshcomponent_draw :: proc(mesh: Instanced_Mesh_Component, pipeline: ^gfx.Pipeline, textures: Maybe([]gfx.Texture_Binding)) {
    bindings: gfx.Bindings = ---
    instancedmeshcomponent_get_bindings(mesh, textures, &bindings)

    gfx.pipeline_draw_elements_instanced(
        pipeline,
        &bindings,
        mesh.gl_draw_mode,
        mesh.index_buffer_type,
        mesh.index_count,
        nil,
        mesh.instance_count,
        mesh.draw_to_depth_buffer,
    )
}
