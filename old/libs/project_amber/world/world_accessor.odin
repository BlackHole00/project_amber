package project_amber_world

World_Accessor :: struct {
    world: ^World,
}

worldaccessor_init :: proc(accessor: ^World_Accessor, world: ^World) {
    accessor.world = world
}

worldaccessor_register_chunk :: proc(accessor: World_Accessor, chunk: Chunk_Identifier) {
    if !(chunk in accessor.world.chunks) {
        new_chunk := map_insert(&accessor.world.chunks, chunk, new(Chunk))
        chunk_init(new_chunk^, Chunk_Descriptor {
            chunk_pos = chunk,
        })
    }
    worldaccessor_clear_chunk(accessor, chunk)
}

worldaccessor_get_chunk_blocks :: proc(accessor: World_Accessor, chunk: Chunk_Identifier) -> ([][CHUNK_SIZE][CHUNK_SIZE]Block_Instance, bool) {
    if !(chunk in accessor.world.chunks) do return nil, false

    return accessor.world.chunks[chunk].blocks[:], true
}

worldaccessor_get_chunk :: proc(accessor: World_Accessor, chunk: Chunk_Identifier) -> ^Chunk {
    return accessor.world.chunks[chunk]
}

worldaccessor_clear_chunk :: proc(accessor: World_Accessor, chunk: Chunk_Identifier) -> bool {
    blocks, ok := worldaccessor_get_chunk_blocks(accessor, chunk)
    if !ok do return false

    for x in 0..<CHUNK_SIZE do for y in 0..<CHUNK_SIZE do for z in 0..<CHUNK_SIZE do blocks[x][y][z].block = "air"

    return true
}

worldaccessor_set_block :: proc(accessor: World_Accessor, block_pos: [3]int, block: string) -> bool{
    chunk_pos := block_pos / CHUNK_SIZE
    if block_pos.x < 0 do chunk_pos.x -= 1
    if block_pos.y < 0 do chunk_pos.x -= 1
    if block_pos.z < 0 do chunk_pos.x -= 1

    block_pos_in_chunk := block_pos % CHUNK_SIZE
    abs_pos(block_pos_in_chunk[:])

    blocks, ok := worldaccessor_get_chunk_blocks(accessor, chunk_pos)
    if !ok do return false

    blocks[block_pos_in_chunk.x][block_pos_in_chunk.y][block_pos_in_chunk.z].block = block

    return true
}

worldaccessor_get_block :: proc(accessor: World_Accessor, block_pos: [3]int) -> (^Block_Instance, bool) {
    chunk_pos := block_pos / CHUNK_SIZE
    if block_pos.x < 0 do chunk_pos.x -= 1
    if block_pos.y < 0 do chunk_pos.x -= 1
    if block_pos.z < 0 do chunk_pos.x -= 1

    block_pos_in_chunk := block_pos % CHUNK_SIZE
    abs_pos(block_pos_in_chunk[:])

    blocks, ok := worldaccessor_get_chunk_blocks(accessor, chunk_pos)
    if !ok do return nil, false

    return &blocks[block_pos_in_chunk.x][block_pos_in_chunk.y][block_pos_in_chunk.z], true
}

worldaccessor_get_block_behaviour :: proc(accessor: World_Accessor, block_pos: [3]int) -> (Block_Behaviour, bool) {
    block, ok := worldaccessor_get_block(accessor, block_pos)
    if !ok do return {}, false

    return blockregistar_get_block(block.block), true
}

@(private)
abs_pos :: proc(block_pos: []int) {
    for _, i in block_pos {
        if block_pos[i] < 0 {
            block_pos[i] = 16 - (-block_pos[i])
        }
    }
}