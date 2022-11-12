package vx_lib_core

//import "core:sync"

RWSync_Cell_Lock_Mode :: enum {
    Read,
    Write,
}

Sync_Cell :: struct($T: typeid) {
    using cell: Cell(T),
    mutex: sync.Mutex,
}

RWSync_Cell :: struct($T: typeid) {
    using cell: Cell(T),
    mutex: sync.RW_Mutex,
}

synccell_init_raw :: cell_init_raw
synccell_init_with_data :: cell_init_with_data

synccell_init :: proc { synccell_init_raw, synccell_init_with_data }

synccell_free :: cell_free
synccell_is_valid :: cell_is_valid

synccell_lock :: proc(cell: ^Sync_Cell($T)) {
    sync.mutex_lock(&cell.mutex)
}

synccell_unlock :: proc(cell: ^Sync_Cell($T)) {
    sync.mutex_unlock(&cell.mutex)
}

synccell_try_lock :: proc(cell: ^Sync_Cell($T)) -> bool {
    return sync.mutex_try_lock(&cell.mutex)
}


rwsynccell_init_raw :: cell_init_raw
rwsynccell_init_with_data :: cell_init_with_data

rwsynccell_init :: proc { rwsynccell_init_raw, rwsynccell_init_with_data }

rwsynccell_free :: cell_free
rwsynccell_is_valid :: cell_is_valid

rwsynccell_lock :: proc(cell: ^RWSync_Cell($T), mode: RWSync_Cell_Lock_Mode) {
    switch mode {
        case .Read: sync.rw_mutex_shared_lock(&cell.mutex)
        case .Write: sync.rw_mutex_lock(&cell.mutex)
    }
}

rwsynccell_unlock :: proc(cell: ^RWSync_Cell($T), mode: RWSync_Cell_Lock_Mode) {
    switch mode {
        case .Read: sync.rw_mutex_shared_unlock(&cell.mutex)
        case .Write: sync.rw_mutex_unlock(&cell.mutex)
    }
}

rwsynccell_try_lock :: proc(cell: ^RWSync_Cell($T), mode: RWSync_Cell_Lock_Mode) -> bool {
    switch mode {
        case .Read: return sync.rw_mutex_try_shared_lock(&cell.mutex)
        case .Write: sync.rw_mutex_try_lock(&cell.mutex)
    }
}