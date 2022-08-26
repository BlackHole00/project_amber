package project_amber_world

World_Descriptor :: struct {
    world_name: string,
}

World :: struct {
    world_name: string,

    chunks: map[Chunk_Identifier]^Chunk,
}

world_init :: proc(world: ^World, desc: World_Descriptor) {
    world.world_name = desc.world_name

    world.chunks = make(map[Chunk_Identifier]^Chunk)
}

world_deinit :: proc(world: World) {
    for _, chunk in world.chunks do free(chunk)

    delete(world.chunks)
}
