package vx_lib_logic_objects

import "../../logic"

Transform :: struct {
    position: logic.Position_Component,
    rotation: logic.Rotation_Component,
}

Full_Transform :: struct {
    using base: Transform,
    scale: logic.Scale_Component,
}
