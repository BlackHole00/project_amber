package vx_lib_logic_objects

import "../../logic"
import "../../gfx"

Skybox :: struct {
    using mesh: logic.Mesh_Component,
    using texture: gfx.Texture,
}
