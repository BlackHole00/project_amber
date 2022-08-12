package vx_lib_logic

import "../gfx"
import gl "vendor:OpenGL"

Mesh_Descriptor :: struct {
    index_buffer_type: u32,
    gl_usage: u32,
    gl_draw_mode: u32,
}

Mesh_Component :: struct {
    using desc: Mesh_Descriptor,

    vertex_buffer: gfx.Buffer,
    index_buffer: gfx.Buffer,
    index_count: int,
}

meshcomponent_init_empty :: proc(mesh: ^Mesh_Component, desc: Mesh_Descriptor) {
    mesh.index_buffer_type = desc.index_buffer_type
    mesh.gl_usage = desc.gl_usage
    mesh.gl_draw_mode = desc.gl_draw_mode

    gfx.buffer_init(&mesh.vertex_buffer, gfx.Buffer_Descriptor {
        gl_type = gl.ARRAY_BUFFER,
        gl_usage = desc.gl_usage,
    })
    gfx.buffer_init(&mesh.index_buffer, gfx.Buffer_Descriptor {
        gl_type = gl.ELEMENT_ARRAY_BUFFER,
        gl_usage = desc.gl_usage,
    })
}

meshcomponent_init_with_data :: proc(mesh: ^Mesh_Component, desc: Mesh_Descriptor, vertex_data: []$T, index_data: []$U, index_count := -1) {
    mesh.index_buffer_type = desc.index_buffer_type
    mesh.gl_usage = desc.gl_usage
    mesh.gl_draw_mode = desc.gl_draw_mode

    gfx.buffer_init(&mesh.vertex_buffer, gfx.Buffer_Descriptor {
        gl_type = gl.ARRAY_BUFFER,
        gl_usage = desc.gl_usage,
    }, vertex_data)
    gfx.buffer_init(&mesh.index_buffer, gfx.Buffer_Descriptor {
        gl_type = gl.ELEMENT_ARRAY_BUFFER,
        gl_usage = desc.gl_usage,
    }, index_data)

    mesh.index_count = index_count
    if index_count == -1 {
        mesh.index_count = len(index_data)
    }
}

meshcomponent_init :: proc { meshcomponent_init_empty, meshcomponent_init_with_data }

meshcomponent_free :: proc(mesh: ^Mesh_Component) {
    gfx.buffer_free(&mesh.vertex_buffer)
    gfx.buffer_free(&mesh.index_buffer)
}

meshcomponent_set_data :: proc(mesh: ^Mesh_Component, vertex_data: []$T, index_data: []$U, index_count := -1) {
    gfx.buffer_add_data(mesh.vertex_buffer, vertex_data)
    gfx.buffer_add_data(mesh.index_buffer, index_data)

    mesh.index_count = index_count
    if index_count == -1 {
        mesh.index_count = len(index_data)
    }
}

meshcomponent_bind :: proc(mesh: Mesh_Component) {
    gfx.buffer_bind(mesh.vertex_buffer)
    gfx.buffer_bind(mesh.index_buffer)
}

meshcomponent_draw :: proc(mesh: Mesh_Component) {
    meshcomponent_bind(mesh)

    gl.DrawElements(mesh.gl_draw_mode, (i32)(mesh.index_count), mesh.index_buffer_type, nil)
}
