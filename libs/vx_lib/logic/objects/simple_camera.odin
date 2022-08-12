package vx_lib_logic_objects

import "../../logic"

Simple_Camera :: struct {
    using transform: Transform,
    using camera: logic.Camera_Component,
}
