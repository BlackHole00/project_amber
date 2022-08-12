package vx_lib_core

import "core:intrinsics"

@(private="file")
dummy_func :: proc() {}

safetize_function :: proc(procedure: $T) {
    if procedure^ == nil do (^proc())(procedure)^ = dummy_func
}