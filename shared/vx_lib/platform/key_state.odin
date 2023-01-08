package vx_lib_platform

import "core:c"

Glfw_Key :: c.int

Key_State :: struct {
    pressed: bool,
    just_pressed: bool,
    just_released: bool,
}