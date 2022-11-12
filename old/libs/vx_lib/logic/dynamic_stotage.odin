package vx_lib_logic

Dynamic_Storage :: struct($T: typeid) {
    values: #soa[]T,
}

dynamicstorage_init :: proc(storage: ^Dynamic_Storage($T), cap: int) {
    storage.values = make_soa(#soa[]T, cap)
}

dynamicstorage_get :: proc(storage: ^Dynamic_Storage($T), idx: int) -> T {
    return storage.values[idx]
}

dynamicstorage_set :: proc(storage: ^Dynamic_Storage($T), value: T, idx: int) {
    storage.values[idx] = value
}

dynamicstorage_get_size :: proc(storage: Dynamic_Storage($T)) -> int {
    return len(storage.values)
}

dynamicstorage_resize :: proc(storage: ^Dynamic_Storage($T), new_size: int) {
    new_slice := make_soa(#soa[]T, new_size)

    for i := 0; i < len(new_slice) && i < len(storage.values); i += 1 do new_slice[i] = storage.values[i]

    delete_soa(storage.values)
    storage.values = new_slice
}

dynamicstorage_free :: proc(storage: Dynamic_Storage($T)) {
    delete_soa(storage.values)
}

dynamicstorage_as_slice :: proc(storage: Dynamic_Storage($T)) -> #soa[]T {
    return storage.values
}
