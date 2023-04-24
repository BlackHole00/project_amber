package vx_lib_logic

import "core:math"
import "core:math/linalg/glsl"
import "../gfx"
import vx_math "../math"

Position_Component :: distinct glsl.vec3
Rotation_Component :: distinct glsl.vec3
Scale_Component :: distinct glsl.vec3

Abstract_Transform :: struct {
    position: Position_Component,
    rotation: Rotation_Component,
}

Transform :: struct {
    position: Position_Component,
    rotation: Rotation_Component,
    scale: Scale_Component,

    mat: glsl.mat4,
}

position_to_matrix :: proc(position: Position_Component) -> glsl.mat4 {
    return glsl.mat4Translate((glsl.vec3)(position))
}

rotation_to_matrix :: proc(rotation: Rotation_Component) -> glsl.mat4 {
    return glsl.mat4Rotate({ 1.0, 0.0, 0.0 }, rotation.x) * glsl.mat4Rotate({ 0.0, 1.0, 0.0 }, rotation.y) * glsl.mat4Rotate({ 0.0, 0.0, 1.0 }, rotation.z)
}

scale_to_matrix :: proc(scale: Scale_Component) -> glsl.mat4 {
    return glsl.mat4Scale((glsl.vec3)(scale))
}

prs_to_matrix :: proc(position: Position_Component, rotation: Rotation_Component, scale: Scale_Component) -> glsl.mat4 {
    return position_to_matrix(position) * rotation_to_matrix(rotation) * scale_to_matrix(scale)
}

pr_to_matrix :: proc(position: Position_Component, rotation: Rotation_Component) -> glsl.mat4 {
    return position_to_matrix(position) * rotation_to_matrix(rotation)
}

to_matrix :: proc { position_to_matrix, rotation_to_matrix, scale_to_matrix, prs_to_matrix, pr_to_matrix, transform_to_matrix }

position_move :: proc(position: ^Position_Component, offset: glsl.vec3, amount: f32 = 1.0) {
    position^ += (Position_Component)(offset * amount)
}

position_move_cross :: proc(position: ^Position_Component, rotation: Rotation_Component, cross_vec: glsl.vec3, amount: f32 = 1.0) {
    arg: glsl.vec3 = glsl.normalize(glsl.cross(rotation_direction(rotation), cross_vec))

    position_move(position, arg, amount)
}

position_move_forward :: proc(position: ^Position_Component, rotation: Rotation_Component, amount: f32 = 1.0) {
    position_move(position, rotation_direction(rotation), amount)
}

position_move_backward :: proc(position: ^Position_Component, rotation: Rotation_Component, amount: f32 = 1.0) {
    position_move(position, rotation_direction(rotation), -amount)
}

position_move_right :: proc(position: ^Position_Component, rotation: Rotation_Component, amount: f32 = 1.0) {
    position_move_cross(position, rotation, { 0.0, 1.0, 0.0 }, amount)
}

position_move_left :: proc(position: ^Position_Component, rotation: Rotation_Component, amount: f32 = 1.0) {
    position_move_cross(position, rotation, { 0.0, 1.0, 0.0 }, -amount)
}

rotation_rotate :: proc(rotation: ^Rotation_Component, offset: glsl.vec3, amount: f32 = 1.0, resolve_wrapping := true) {
    rotation^ += (Rotation_Component)(offset * amount)

    if resolve_wrapping {
        if rotation.y >= math.PI / 2 do rotation.y = math.PI / 2 - 0.01
        else if rotation.y <= -math.PI / 2 do rotation.y = -math.PI/2 + 0.01
    }
}

rotation_direction :: proc(rotation: Rotation_Component) -> glsl.vec3 {
    return vx_math.vec3_direction((glsl.vec3)(rotation))
}

pr_get_view_matrix :: proc(position: Position_Component, rotation: Rotation_Component) -> glsl.mat4 {
    return glsl.mat4LookAt((glsl.vec3)(position), ((glsl.vec3)(position) + rotation_direction(rotation) * 0.01 ), { 0.0, 1.0, 0.0 })
}

pr_apply :: proc(position: Position_Component, rotation: Rotation_Component, pipeline: gfx.Pipeline, uniform_name := gfx.MODEL_UNIFORM_NAME) {
    mat := to_matrix(position) * to_matrix(rotation)
    gfx.pipeline_uniform_mat4f(pipeline, uniform_name, auto_cast &mat)
}

prs_apply :: proc(position: Position_Component, rotation: Rotation_Component, scale: Scale_Component, pipeline: gfx.Pipeline, uniform_name := gfx.MODEL_UNIFORM_NAME) {
    mat := to_matrix(position) * to_matrix(rotation) * to_matrix(scale)
    gfx.pipeline_uniform_mat4f(pipeline, uniform_name, auto_cast &mat)
}

transform_move :: proc(transform: ^Transform, offset: glsl.vec3, amount: f32 = 1.0) {
    position_move(&transform.position, offset, amount)

    transform_calc_matrix(transform)
}

transform_move_cross :: proc(transform: ^Transform, cross_vec: glsl.vec3, amount: f32 = 1.0) {
    position_move_cross(&transform.position, transform.rotation, cross_vec, amount)
    
    transform_calc_matrix(transform)
}

transform_move_forward :: proc(transform: ^Transform, amount: f32 = 1.0) {
    position_move_forward(&transform.position, transform.rotation, amount)

    transform_calc_matrix(transform)
}

transform_move_backward :: proc(transform: ^Transform, amount: f32 = 1.0) {
    position_move_backward(&transform.position, transform.rotation, amount)

    transform_calc_matrix(transform)
}

transform_move_right :: proc(transform: ^Transform, amount: f32 = 1.0) {
    position_move_right(&transform.position, transform.rotation, amount)

    transform_calc_matrix(transform)
}

transform_move_left :: proc(transform: ^Transform, amount: f32 = 1.0) {
    position_move_left(&transform.position, transform.rotation, amount)

    transform_calc_matrix(transform)
}

transform_rotate :: proc(transform: ^Transform, offset: glsl.vec3, amount: f32 = 1.0, resolve_wrapping := true) {
    rotation_rotate(&transform.rotation, offset, amount, resolve_wrapping)

    transform_calc_matrix(transform)
}

transform_direction :: proc(transform: Transform) -> glsl.vec3 {
    return rotation_direction(transform.rotation)
}

transform_calc_matrix :: proc(transform: ^Transform) {
    transform.mat = prs_to_matrix(transform.position, transform.rotation, transform.scale)
}

transform_to_matrix :: proc(transform: ^Transform) -> glsl.mat4 {
    transform_calc_matrix(transform)
    return transform.mat
}

transform_apply :: proc(transform: ^Transform, pipeline: gfx.Pipeline, uniform_name := gfx.MODEL_UNIFORM_NAME) {
    transform_calc_matrix(transform)
    gfx.pipeline_uniform_mat4f(pipeline, uniform_name, auto_cast &transform.mat)
}
