package vx_lib_gfx

import "core:mem"

Sync_Info_Type :: enum {
    Compute_Dispatch,
    Compute_Buffer_Upload,
    Compute_Buffer_Download,
    Other,
}

Sync_Impl :: struct {
    info: Sync_Info_Type,

    data: rawptr,
    wait_proc: proc(sync: Sync),
    is_done_proc: proc(sync: Sync) -> bool,
    // Frees the used memory. Frees also the sync pointer.
    free_proc: proc(sync: Sync),
}

// A sync object similar to glFence. Once it is done the data will be freed 
// automatically by the implementation.
// Calling sync_is_done will not free memory, only calling sync_await will
// free memory.
// Memory can be freed manually by calling sync_discart.
Sync :: ^Sync_Impl

sync_get_type :: proc(sync: Sync) -> Sync_Info_Type {
    return sync.info
}

// Waits for all the syncs and frees all their memory.
sync_await :: proc(syncs: ..Sync) {
    for sync in syncs {
        sync.wait_proc(sync)
        sync.free_proc(sync)
    }
}

sync_is_done :: proc(syncs: ..Sync) -> bool {
    for sync in syncs do if !sync.is_done_proc(sync) do return false

    return true
}

sync_discart :: proc(sync: ..Sync) {
    for sync in sync do sync.free_proc(sync)
} 

///////////////////////////////////////////////////////////////////////////////

@(private)
Sync_Descriptor :: Sync_Impl

@(private)
sync_new :: proc(desc: Sync_Descriptor, allocator: mem.Allocator) -> Sync {
    sync := new(Sync_Impl, allocator)
    sync^ = desc

    return sync
}
