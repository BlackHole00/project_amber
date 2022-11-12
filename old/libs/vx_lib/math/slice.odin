package vx_lib_math

import "core:intrinsics"

slice_rotate :: proc(slice: []$T) {
    tmp := slice[0]
    new_tmp: T = ---

    for i := len(slice) - 1; i >= 0; i -= 1 {
        new_tmp = slice[i]
        slice[i] = tmp
        tmp = new_tmp
    }
}

slice_abs :: proc(slice: []$T) where intrinsics.type_is_numeric(T) {
    for elem, i in slice do slice[i] = abs(elem)
}