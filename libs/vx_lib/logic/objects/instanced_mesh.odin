package vx_lib_logic_objects

import "../../logic"
import "core:math/linalg/glsl"

Instanced_Mesh :: struct {
    using mesh: logic.Instanced_Mesh_Component,
    transforms: logic.Dynamic_Storage(Full_Transform),
}

instancedmesh_transforms_as_matrices :: proc(transforms: ^logic.Dynamic_Storage(Full_Transform), allocator := context.allocator) -> []glsl.mat4 {
    slice := make([]glsl.mat4, logic.dynamicstorage_get_size(transforms^))

    for mat, i in &slice {
        transf := logic.dynamicstorage_get(transforms, i)
        mat = logic.prs_to_matrix(transf.position, transf.rotation, transf.scale)
    }

    return slice
}
