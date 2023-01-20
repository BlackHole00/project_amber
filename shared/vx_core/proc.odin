package vx_core

import "core:intrinsics"

dummy_func :: proc() {}

safetize_function :: proc(procedure: ^$T) {
    if procedure^ == nil do (^proc())(procedure)^ = dummy_func
}

assign_proc :: proc(procedure: ^$T, new_procedure: $U) {
    (^proc())(procedure)^ = (proc())(new_procedure)
}