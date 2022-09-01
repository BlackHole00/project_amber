package project_amber_world

import "../renderer"
import "vx_lib:gfx"
import "vx_lib:logic/objects"
import "vx_lib:logic"
import "vx_lib:utils"

CHUNK_SIZE :: 16

Chunk_Identifier :: [3]int

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
        index_buffer_type = .U32,
        usage = .Static_Draw,
        draw_type = .Triangles,
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

chunk_remesh :: proc(chunk: ^Chunk, world_accessor: World_Accessor) {
    mesh_builder: utils.Mesh_Builder = ---
    utils.meshbuilder_init(&mesh_builder)
    defer utils.meshbuilder_free(mesh_builder)

    mesh: logic.Abstract_Mesh = ---
    logic.abstractmesh_init(&mesh)
    defer logic.abstractmesh_free(mesh)

    for x in 0..<CHUNK_SIZE do for y in 0..<CHUNK_SIZE do for z in 0..<CHUNK_SIZE {
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
                        top, bottom, left, right := utils.textureatlas_get_uv(&renderer.RENDERER_INSTANCE.block_texture_atlas, texturing.texture)

                        if .Natural_Flip_X in texturing.modifiers {
                            if (chunk.blocks[x][y][z].position.x * chunk.blocks[x][y][z].position.y + chunk.blocks[x][y][z].position.z) % 2 == 0 {
                                left, right = right, left
                            }
                        }
                        if .Natural_Flip_Y in texturing.modifiers {
                            if (chunk.blocks[x][y][z].position.x + chunk.blocks[x][y][z].position.y * chunk.blocks[x][y][z].position.z) % 2 == 1 {
                                top, bottom = bottom, top
                            }
                        }

                        block_pos := chunk.blocks[x][y][z].position

                        if block_behaviour, ok := worldaccessor_get_block_behaviour(world_accessor, { block_pos.x, block_pos.y, block_pos.z + 1 }); !ok || !block_behaviour.solid do utils.meshbuilder_push_quad(&mesh_builder, []renderer.World_Vertex {
                            { pos = { -0.5 + (f32)(x), -0.5 + (f32)(y), 0.5 + (f32)(z) }, uv = { left, bottom } },
                            { pos = {  0.5 + (f32)(x), -0.5 + (f32)(y), 0.5 + (f32)(z) }, uv = { right, bottom } },
                            { pos = {  0.5 + (f32)(x),  0.5 + (f32)(y), 0.5 + (f32)(z) }, uv = { right, top } },
                            { pos = { -0.5 + (f32)(x),  0.5 + (f32)(y), 0.5 + (f32)(z) }, uv = { left, top } },
                        })

                        if block_behaviour, ok := worldaccessor_get_block_behaviour(world_accessor, { block_pos.x, block_pos.y, block_pos.z - 1}); !ok || !block_behaviour.solid do utils.meshbuilder_push_quad(&mesh_builder, []renderer.World_Vertex {
                            { pos = { -0.5 + (f32)(x), -0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { left, bottom } },
                            { pos = { -0.5 + (f32)(x),  0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { right, bottom } },
                            { pos = {  0.5 + (f32)(x),  0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { right, top } },
                            { pos = {  0.5 + (f32)(x), -0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { left, top } },
                        })

                        if block_behaviour, ok := worldaccessor_get_block_behaviour(world_accessor, { block_pos.x - 1, block_pos.y, block_pos.z }); !ok || !block_behaviour.solid do utils.meshbuilder_push_quad(&mesh_builder, []renderer.World_Vertex {
                            { pos = { -0.5 + (f32)(x), -0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { left, bottom } },
                            { pos = { -0.5 + (f32)(x), -0.5 + (f32)(y),  0.5 + (f32)(z) }, uv = { right, bottom } },
                            { pos = { -0.5 + (f32)(x),  0.5 + (f32)(y),  0.5 + (f32)(z) }, uv = { right, top } },
                            { pos = { -0.5 + (f32)(x),  0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { left, top } },
                        })

                        if block_behaviour, ok := worldaccessor_get_block_behaviour(world_accessor, { block_pos.x + 1, block_pos.y, block_pos.z }); !ok || !block_behaviour.solid do utils.meshbuilder_push_quad(&mesh_builder, []renderer.World_Vertex {
                            { pos = {  0.5 + (f32)(x), -0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { left, bottom } },
                            { pos = {  0.5 + (f32)(x),  0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { right, bottom } },
                            { pos = {  0.5 + (f32)(x),  0.5 + (f32)(y),  0.5 + (f32)(z) }, uv = { right, top } },
                            { pos = {  0.5 + (f32)(x), -0.5 + (f32)(y),  0.5 + (f32)(z) }, uv = { left, top } },
                        })

                        if block_behaviour, ok := worldaccessor_get_block_behaviour(world_accessor, { block_pos.x, block_pos.y + 1, block_pos.z }); !ok || !block_behaviour.solid do utils.meshbuilder_push_quad(&mesh_builder, []renderer.World_Vertex {
                            { pos = { -0.5 + (f32)(x),  0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { left, bottom } },
                            { pos = { -0.5 + (f32)(x),  0.5 + (f32)(y),  0.5 + (f32)(z) }, uv = { right, bottom } },
                            { pos = {  0.5 + (f32)(x),  0.5 + (f32)(y),  0.5 + (f32)(z) }, uv = { right, top } },
                            { pos = {  0.5 + (f32)(x),  0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { left, top } },
                        })

                        if block_behaviour, ok := worldaccessor_get_block_behaviour(world_accessor, { block_pos.x, block_pos.y - 1, block_pos.z }); !ok || !block_behaviour.solid do utils.meshbuilder_push_quad(&mesh_builder, []renderer.World_Vertex {
                            { pos = { -0.5 + (f32)(x), -0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { left, bottom } },
                            { pos = {  0.5 + (f32)(x), -0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { right, bottom } },
                            { pos = {  0.5 + (f32)(x), -0.5 + (f32)(y),  0.5 + (f32)(z) }, uv = { right, top } },
                            { pos = { -0.5 + (f32)(x), -0.5 + (f32)(y),  0.5 + (f32)(z) }, uv = { left, top } },
                        })
                    }
                    case Full_Block_Mesh_Multi_Texture: {
                        tops, bottoms, lefts, rights: [6]f32 = ---, ---, ---, ---

                        for texture, i in texturing {
                            tops[i], bottoms[i], lefts[i], rights[i] = utils.textureatlas_get_uv(&renderer.RENDERER_INSTANCE.block_texture_atlas, texture.texture)

                            if .Natural_Flip_X in texture.modifiers {
                                if ((7 - chunk.blocks[x][y][z].position.x * 673) * (3 - chunk.blocks[x][y][z].position.y * 37) / (10 - chunk.blocks[x][y][z].position.z * 74)) % (chunk.blocks[x][y][z].position.x + 1) == 0 {
                                    lefts[i], rights[i] = rights[i], lefts[i]
                                }
                            }
                            if .Natural_Flip_Y in texture.modifiers {
                                if ((10 - chunk.blocks[x][y][z].position.x * 453) / (7 - chunk.blocks[x][y][z].position.y * 13) * (3 - chunk.blocks[x][y][z].position.z * 4)) % (chunk.blocks[x][y][z].position.z + 1) == 1 {
                                    tops[i], bottoms[i] = bottoms[i], tops[i]
                                }
                            }
                        }

                        block_pos := chunk.blocks[x][y][z].position

                        if block_behaviour, ok := worldaccessor_get_block_behaviour(world_accessor, { block_pos.x, block_pos.y, block_pos.z + 1 }); !ok || !block_behaviour.solid do utils.meshbuilder_push_quad(&mesh_builder, []renderer.World_Vertex {
                            { pos = { -0.5 + (f32)(x), -0.5 + (f32)(y), 0.5 + (f32)(z) }, uv = { lefts[5], bottoms[5] } },
                            { pos = {  0.5 + (f32)(x), -0.5 + (f32)(y), 0.5 + (f32)(z) }, uv = { rights[5], bottoms[5] } },
                            { pos = {  0.5 + (f32)(x),  0.5 + (f32)(y), 0.5 + (f32)(z) }, uv = { rights[5], tops[5] } },
                            { pos = { -0.5 + (f32)(x),  0.5 + (f32)(y), 0.5 + (f32)(z) }, uv = { lefts[5], tops[5] } },
                        })

                        if block_behaviour, ok := worldaccessor_get_block_behaviour(world_accessor, { block_pos.x, block_pos.y, block_pos.z - 1}); !ok || !block_behaviour.solid do utils.meshbuilder_push_quad(&mesh_builder, []renderer.World_Vertex {
                            { pos = { -0.5 + (f32)(x), -0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { lefts[4], bottoms[4] } },
                            { pos = { -0.5 + (f32)(x),  0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { lefts[4], tops[4] } },
                            { pos = {  0.5 + (f32)(x),  0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { rights[4], tops[4] } },
                            { pos = {  0.5 + (f32)(x), -0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { rights[4], bottoms[4] } },
                        })

                        if block_behaviour, ok := worldaccessor_get_block_behaviour(world_accessor, { block_pos.x - 1, block_pos.y, block_pos.z }); !ok || !block_behaviour.solid do utils.meshbuilder_push_quad(&mesh_builder, []renderer.World_Vertex {
                            { pos = { -0.5 + (f32)(x), -0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { lefts[2], bottoms[2] } },
                            { pos = { -0.5 + (f32)(x), -0.5 + (f32)(y),  0.5 + (f32)(z) }, uv = { rights[2], bottoms[2] } },
                            { pos = { -0.5 + (f32)(x),  0.5 + (f32)(y),  0.5 + (f32)(z) }, uv = { rights[2], tops[2] } },
                            { pos = { -0.5 + (f32)(x),  0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { lefts[2], tops[2] } },
                        })

                        if block_behaviour, ok := worldaccessor_get_block_behaviour(world_accessor, { block_pos.x + 1, block_pos.y, block_pos.z }); !ok || !block_behaviour.solid do utils.meshbuilder_push_quad(&mesh_builder, []renderer.World_Vertex {
                            { pos = {  0.5 + (f32)(x), -0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { lefts[3], bottoms[3] } },
                            { pos = {  0.5 + (f32)(x),  0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { lefts[3], tops[3] } },
                            { pos = {  0.5 + (f32)(x),  0.5 + (f32)(y),  0.5 + (f32)(z) }, uv = { rights[3], tops[3] } },
                            { pos = {  0.5 + (f32)(x), -0.5 + (f32)(y),  0.5 + (f32)(z) }, uv = { rights[3], bottoms[3] } },
                        })

                        if block_behaviour, ok := worldaccessor_get_block_behaviour(world_accessor, { block_pos.x, block_pos.y + 1, block_pos.z }); !ok || !block_behaviour.solid do utils.meshbuilder_push_quad(&mesh_builder, []renderer.World_Vertex {
                            { pos = { -0.5 + (f32)(x),  0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { lefts[0], bottoms[0] } },
                            { pos = { -0.5 + (f32)(x),  0.5 + (f32)(y),  0.5 + (f32)(z) }, uv = { rights[0], bottoms[0] } },
                            { pos = {  0.5 + (f32)(x),  0.5 + (f32)(y),  0.5 + (f32)(z) }, uv = { rights[0], tops[0] } },
                            { pos = {  0.5 + (f32)(x),  0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { lefts[0], tops[0] } },
                        })

                        if block_behaviour, ok := worldaccessor_get_block_behaviour(world_accessor, { block_pos.x, block_pos.y - 1, block_pos.z }); !ok || !block_behaviour.solid do utils.meshbuilder_push_quad(&mesh_builder, []renderer.World_Vertex {
                            { pos = { -0.5 + (f32)(x), -0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { lefts[1], bottoms[1] } },
                            { pos = {  0.5 + (f32)(x), -0.5 + (f32)(y), -0.5 + (f32)(z) }, uv = { rights[1], bottoms[1] } },
                            { pos = {  0.5 + (f32)(x), -0.5 + (f32)(y),  0.5 + (f32)(z) }, uv = { rights[1], tops[1] } },
                            { pos = { -0.5 + (f32)(x), -0.5 + (f32)(y),  0.5 + (f32)(z) }, uv = { lefts[1], tops[1] } },
                        })
                    }
                }
            }
        }
    }

    utils.meshbuilder_build(mesh_builder, &chunk.mesh)

    chunk.needs_remesh = false
}

draw_chunk :: proc(chunk: ^Chunk) {
    logic.transform_apply(&chunk.mesh.transform, &renderer.RENDERER_INSTANCE.full_block_solid_pipeline)

    logic.meshcomponent_draw(chunk.mesh, &renderer.RENDERER_INSTANCE.full_block_solid_pipeline, renderer.renderer_get_pass(), []gfx.Texture_Binding {
        utils.textureatlas_get_texture_bindings(renderer.RENDERER_INSTANCE.block_texture_atlas, renderer.BLOCK_TEXTURE_ATLAS_LOCATION),
    })
}
