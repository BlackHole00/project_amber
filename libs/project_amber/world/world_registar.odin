package project_amber_world

import "vx_lib:core"

@(private)
World_Record :: struct {
    accessor: World_Accessor,
    world: ^World,
}

World_Registar :: struct {
    worlds: map[string]World_Record,
}
WORLDREGISTAR_INSTANCE: core.Cell(World_Registar)

worldregistar_init :: proc() {
    core.cell_init(&WORLDREGISTAR_INSTANCE)

    WORLDREGISTAR_INSTANCE.worlds = make(map[string]World_Record)
}

worldregistar_deinit :: proc() {
    delete(WORLDREGISTAR_INSTANCE.worlds)

    core.cell_free(&WORLDREGISTAR_INSTANCE)
}

worldregistar_add_world :: proc(ident: string) {
    record: World_Record = ---
    record.world = new(World)
    world_init(record.world, World_Descriptor {
        world_name = ident,
    })
    worldaccessor_init(&record.accessor, record.world)

    map_insert(&WORLDREGISTAR_INSTANCE.worlds, ident, record)
}

worldregistar_get_world_accessor :: proc(ident: string) -> World_Accessor {
    if !(ident in WORLDREGISTAR_INSTANCE.worlds) do panic("World not found")

    return WORLDREGISTAR_INSTANCE.worlds[ident].accessor
}

worldregistar_remove_world :: proc(ident: string) {
    if !(ident in WORLDREGISTAR_INSTANCE.worlds) do panic("World not found")

    world_deinit(WORLDREGISTAR_INSTANCE.worlds[ident].world^)
    free(WORLDREGISTAR_INSTANCE.worlds[ident].world)

    delete_key(&WORLDREGISTAR_INSTANCE.worlds, ident)
}
