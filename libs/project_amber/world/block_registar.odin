package project_amber_world

import "vx_lib:core"

Block_Registar :: struct {
    blocks: map[string]Block_Behaviour,
}
BLOCK_REGISTAR_INSTANCE: core.Cell(Block_Registar)

blockregistar_init :: proc() {
    core.cell_init(&BLOCK_REGISTAR_INSTANCE)

    BLOCK_REGISTAR_INSTANCE.blocks = make(map[string]Block_Behaviour)
}

blockregistar_register_block :: proc(block: string, behaviour: Block_Behaviour) {
    map_insert(&BLOCK_REGISTAR_INSTANCE.blocks, block, behaviour)
}

blockregistar_get_block :: proc(block: string) -> ^Block_Behaviour {
    if !(block in BLOCK_REGISTAR_INSTANCE.blocks) do panic("Could not find block")

    return &BLOCK_REGISTAR_INSTANCE.blocks[block]
}


