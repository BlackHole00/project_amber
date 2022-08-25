package project_amber_world

import "../renderer"
import "vx_lib:gfx"
import "vx_lib:logic/objects"
import "vx_lib:logic"
import "vx_lib:utils"
import "vx_lib:math"
import gl "vendor:OpenGL"

CHUNK_SIZE :: 16

Chunk_Descriptor :: struct {
    chunk_pos: [3]int,
}

Chunk :: struct {
    blocks: [CHUNK_SIZE][CHUNK_SIZE][CHUNK_SIZE]Block_Instance,
    chunk_pos: [3]int,

    needs_remesh: bool,
    mesh: objects.Simple_Mesh,
}

chunk_init :: proc(chunk: ^Chunk, desc: Chunk_Descriptor) {
    logic.meshcomponent_init(&chunk.mesh, logic.Mesh_Descriptor {
        index_buffer_type = gl.UNSIGNED_INT,
        gl_usage = gl.STATIC_DRAW,
        gl_draw_mode = gl.TRIANGLES,
    })

    chunk.chunk_pos = desc.chunk_pos

    chunk.mesh.transform.scale = { 1.0, 1.0, 1.0 }
    chunk.mesh.transform.position = { (f32)(desc.chunk_pos[0] * CHUNK_SIZE), (f32)(desc.chunk_pos[1] * CHUNK_SIZE), (f32)(desc.chunk_pos[2] * CHUNK_SIZE) }
}

chunk_get_block :: proc(chunk: ^Chunk, x, y, z: uint) -> ^Block_Instance {
    return &chunk.blocks[x][y][z]
}

chunk_set_block :: proc(chunk: ^Chunk, x, y, z: uint, block: Block_Instance_Descriptor) {
    chunk.blocks[x][y][z].block = block.block
    chunk.blocks[x][y][z].position = chunk.chunk_pos * CHUNK_SIZE + { (int)(x), (int)(y), (int)(z) }
}

chunk_remesh :: proc(chunk: ^Chunk) {
    mesh_builder: utils.Mesh_Builder = ---
    utils.meshbuilder_init(&mesh_builder)
    defer utils.meshbuilder_free(mesh_builder)

    mesh: logic.Abstract_Mesh = ---
    logic.abstractmesh_init(&mesh)
    defer logic.abstractmesh_free(mesh)

    for x in 0..<16 do for y in 0..<16 do for z in 0..<16 {
        block := blockregistar_get_block(chunk.blocks[x][y][z].block)

        switch block_mesh in block.mesh {
            case Scripted_Block_Mesh: {
                block_mesh.get_mesh_proc(chunk.blocks[x][y][z], &mesh)
                vertices, indices := logic.abstractmesh_get_data_as(&mesh, byte, u32)
                utils.meshbuilder_raw_push(&mesh_builder, vertices, indices)

                logic.abstractmesh_clear(&mesh)
            }
            case Full_Block_Mesh: {
                switch texturing in block_mesh.texturing {
                    case Full_Block_Mesh_Single_Texture: {
                        top, bottom, left, right := utils.textureatlas_get_uv(&renderer.RENDERER_INSTANCE.block_texture_atlas, texturing)

                        // TODO: rotate a random number of times.
                        if block_mesh.natural_texture {
                            uvs := []f32{ top, bottom, left, right }

                            num := (chunk.blocks[x][y][z].position.x + chunk.blocks[x][y][z].position.y + chunk.blocks[x][y][z].position.z) % 3 + 1

                            for _ in 0..<num do math.slice_rotate(uvs)

                            top = uvs[0]
                            bottom = uvs[1]
                            left = uvs[2]
                            right = uvs[3]
                        }

                        utils.meshbuilder_push_quad(&mesh_builder, []renderer.World_Vertex {
                            {
                                pos = { -0.5 + (f32)(x), -0.5 + (f32)(y), 0.0 + (f32)(z) }, uv = { left, bottom },
                            },
                            {
                                pos = {  0.5 + (f32)(x), -0.5 + (f32)(y), 0.0 + (f32)(z) }, uv = { right, bottom },
                            },
                            {
                                pos = {  0.5 + (f32)(x),  0.5 + (f32)(y), 0.0 + (f32)(z) }, uv = { right, top },
                            },
                            {
                                pos = { -0.5 + (f32)(x),  0.5 + (f32)(y), 0.0 + (f32)(z) }, uv = { left, top },
                            },
                        })
                    }
                    case Full_Block_Mesh_Multi_Texture: panic("ahhhh")
                }
            }
        }
    }

    utils.meshbuilder_build(mesh_builder, &chunk.mesh)

    chunk.needs_remesh = false
}

draw_chunk :: proc(chunk: ^Chunk) {
    if chunk.needs_remesh do chunk_remesh(chunk) // TODO: do elsewhere

    logic.transform_apply(&chunk.mesh.transform, &renderer.RENDERER_INSTANCE.full_block_solid_pipeline)

    logic.meshcomponent_draw(chunk.mesh, &renderer.RENDERER_INSTANCE.full_block_solid_pipeline, []gfx.Texture_Binding {
        utils.textureatlas_get_texture_bindings(renderer.RENDERER_INSTANCE.block_texture_atlas, renderer.BLOCK_TEXTURE_ATLAS_UNIFORM),
    })
}
