package vx_lib_logic_objects

import "../../logic"
import "core:math/linalg/glsl"

Instanced_Mesh :: struct {
    using mesh: logic.Instanced_Mesh_Component,
    transforms: logic.Dynamic_Storage(logic.Transform),
}

instancedmesh_transforms_as_matrices :: proc(transforms: ^logic.Dynamic_Storage(logic.Transform)) -> []glsl.mat4 {
    _, _, _, mat := soa_unzip(transforms.values)

    return mat
}

instancedmesh_sort_from_camera_pos :: proc(transforms: ^logic.Dynamic_Storage(logic.Transform), camera_pos: logic.Abstract_Transform) {
    // Do sorting for transparent textures.

    panic("TODO")
}
