package vx_lib_logic_objects

import "../../logic"

Simple_Camera :: struct {
    using transform: logic.Abstract_Transform,
    using camera: logic.Camera_Component,
}
