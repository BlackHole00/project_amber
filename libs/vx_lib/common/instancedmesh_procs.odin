package vx_lib_common

import "../gfx"
import "../logic"
import "../logic/objects"
//import "core:log"
import "core:fmt"
import "core:math/linalg/glsl"

instancedmesh_apply_mat4_uniform :: proc(shader: ^gfx.Shader, uniform_name: string, index: uint, data: rawptr) {
    str := fmt.aprint(args = { uniform_name, "[", index, "]" }, sep = "")

    gfx.shader_uniform_mat4f(shader, str, (^glsl.mat4)(data))
}

instancedmesh_apply_transform_uniform :: proc(shader: ^gfx.Shader, uniform_name: string, index: uint, data: rawptr) {
    str := fmt.aprint(args = { uniform_name, "[", index, "]" }, sep = "")

    trs: ^objects.Full_Transform = (^objects.Full_Transform)(data)

    pos_mat := logic.to_matrix(trs.position)
    rot_mat := logic.to_matrix(trs.rotation)
    scale_mat := logic.to_matrix(trs.scale)

    mat := pos_mat * rot_mat * scale_mat

    //log.info(str)
    gfx.shader_uniform_mat4f(shader, str, &mat)
}