package vx_core

import "core:intrinsics"

Owned :: struct($T: typeid) {
    using data: T,
    user_freedata: rawptr,
    user_freeproc: proc(T, rawptr),
}

nowned_init :: proc(owned: ^Owned($T), data: T, user_freedata: rawptr, user_freeproc: $U)
where intrinsics.type_is_proc(U) {
    owned.data = data
    owned.user_freedata = user_freedata
    owned.user_freeproc = auto_cast user_freeproc
}

nowned_free :: proc(owned: ^Owned($T)) {
    owned.user_freeproc(owned.data, owned.user_freedata)
}

POwned :: struct($T: typeid) {
    data: T,
    user_freedata: rawptr,
    user_freeproc: proc(T, rawptr),
}

powned_init :: proc(owned: ^POwned($T), data: T, user_freedata: rawptr, user_freeproc: $U)
where intrinsics.type_is_proc(U) {
    owned.data = data
    owned.user_freedata = user_freedata
    owned.user_freeproc = auto_cast user_freeproc
}

powned_free :: proc(owned: ^POwned($T)) {
    owned.user_freeproc(owned.data, owned.user_freedata)
}

owned_init :: proc { nowned_init, powned_init }
owned_free :: proc { nowned_free, powned_free }