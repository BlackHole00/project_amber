package project_amber_world

import "vx_lib:core"

Block_Registar :: struct {
    blocks: map[string]Block_Behaviour,
}
BLOCKREGISTAR_INSTANCE: core.Cell(Block_Registar)

blockregistar_init :: proc() {
    core.cell_init(&BLOCKREGISTAR_INSTANCE)

    BLOCKREGISTAR_INSTANCE.blocks = make(map[string]Block_Behaviour)

    blockregistar_register_block("air", Block_Behaviour {
        solid = false,
        mesh = nil,
    })
}

blockregistar_register_block :: proc(block: string, behaviour: Block_Behaviour) {
    map_insert(&BLOCKREGISTAR_INSTANCE.blocks, block, behaviour)
}

blockregistar_get_block :: proc(block: string) -> Block_Behaviour {
    if !(block in BLOCKREGISTAR_INSTANCE.blocks) do panic("Could not find block")

    return BLOCKREGISTAR_INSTANCE.blocks[block]
}
