package vx_core

import "core:sync"

RWSync_Lock_Mode :: enum {
    Read,
    Write,
}

////////////////////////////////////////////////////////////////////////////////

Sync :: struct($T: typeid) {
    using value: T,
    mutex: sync.Mutex,
}

PSync :: struct($T: typeid) {
    value: T,
    mutex: sync.Mutex,
}

nsync_lock :: proc(s: ^Sync($T)) {
    sync.lock(&s.mutex)
}

psync_lock :: proc(s: ^PSync($T)) {
    sync.lock(&s.mutex)
}

nsync_unlock :: proc(s: ^Sync($T)) {
    sync.unlock(&s.mutex)
}

psync_unlock :: proc(s: ^PSync($T)) {
    sync.unlock(&s.mutex)
}

nsync_try_lock :: proc(s: ^Sync($T)) -> bool {
    return sync.mutex_try_lock(&s.mutex)
}

psync_try_lock :: proc(s: ^PSync($T)) -> bool {
    return sync.mutex_try_lock(&s.mutex)
}

nsync_get_value :: proc(s: ^Sync($T)) -> (ret: T) {
    sync_lock(s)
    ret = s
    sync_unlock(s)

    return
}

psync_get_value :: proc(s: ^PSync($T)) -> (ret: T) {
    sync_lock(s)
    ret = s.value
    sync_unlock(s)

    return
}

nsync_set_value :: proc(s: ^Sync($T), value: T) {
    sync_lock(s)
    s = value
    sync_unlock(s)
}

psync_set_value :: proc(s: ^PSync($T), value: T) {
    sync_lock(s)
    s.value = value
    sync_unlock(s)
}

sync_lock :: proc { nsync_lock, psync_lock }
sync_unlock :: proc { nsync_unlock, psync_unlock }
sync_try_lock :: proc { nsync_try_lock, psync_try_lock }
sync_get_value :: proc { nsync_get_value, psync_get_value }
sync_set_value :: proc { nsync_set_value, psync_set_value }

////////////////////////////////////////////////////////////////////////////////

RWSync :: struct($T: typeid) {
    using value: T,
    mutex: sync.RW_Mutex,
}

PRWSync :: struct($T: typeid) {
    value: T,
    mutex: sync.RW_Mutex,
}

rwnsync_lock :: proc(s: ^RWSync($T), mode: RWSync_Lock_Mode) {
    switch mode {
        case .Read: sync.rw_mutex_shared_lock(&s.mutex)
        case .Write: sync.rw_mutex_lock(&s.mutex)
    }
}

rwpsync_lock :: proc(s: ^PRWSync($T), mode: RWSync_Lock_Mode) {
    switch mode {
        case .Read: sync.rw_mutex_shared_lock(&s.mutex)
        case .Write: sync.rw_mutex_lock(&s.mutex)
    }
}

rwnsync_unlock :: proc(s: ^RWSync($T), mode: RWSync_Lock_Mode) {
    switch mode {
        case .Read: sync.rw_mutex_shared_unlock(&s.mutex)
        case .Write: sync.rw_mutex_unlock(&s.mutex)
    }
}

rwpsync_unlock :: proc(s: ^PRWSync($T), mode: RWSync_Lock_Mode) {
    switch mode {
        case .Read: sync.rw_mutex_shared_unlock(&s.mutex)
        case .Write: sync.rw_mutex_unlock(&s.mutex)
    }
}

rwnsync_try_lock :: proc(s: ^RWSync($T), mode: RWSync_Lock_Mode) -> bool {
    switch mode {
        case .Read: return sync.rw_mutex_try_shared_lock(&s.mutex)
        case .Write: return sync.rw_mutex_try_lock(&s.mutex)
    }
}

rwpsync_try_lock :: proc(s: ^PRWSync($T), mode: RWSync_Lock_Mode) -> bool {
    switch mode {
        case .Read: return sync.rw_mutex_try_shared_lock(&s.mutex)
        case .Write: return sync.rw_mutex_try_lock(&s.mutex)
    }
}

rwnsync_get_value :: proc(s: ^RWSync($T)) -> (ret: T) {
    rwsync_lock(s, .Read)
    ret = s
    rwsync_unlock(s, .Read)
}

rwpsync_get_value :: proc(s: ^PRWSync($T)) -> (ret: T) {
    rwsync_lock(s, .Read)
    ret = s.value
    rwsync_unlock(s, .Read)
}

rwnsync_set_value :: proc(s: ^RWSync($T), value: T) {
    rwsync_lock(s, .Write)
    s = value
    rwsync_unlock(s, .Write)
}

rwpsync_set_value :: proc(s: ^PRWSync($T), value: T) {
    rwsync_lock(s, .Write)
    s.value = value
    rwsync_unlock(s, .Write)
}


rwsync_lock :: proc { rwnsync_lock, rwpsync_lock }
rwsync_unlock :: proc { rwnsync_unlock, rwpsync_unlock }
rwsync_try_lock :: proc { rwnsync_try_lock, rwpsync_unlock }
rwsync_get_value :: proc { rwnsync_get_value, rwpsync_get_value }
rwsync_set_value :: proc { rwnsync_get_value, rwpsync_get_value }

_ :: sync