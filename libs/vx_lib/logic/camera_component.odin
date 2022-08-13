package vx_lib_logic

import "core:math/linalg/glsl"
import "../gfx"

Camera_Mode :: enum {
    Orthographic,
    Perspective,
}

Orthographic_Data :: struct {
    right   : f32,
    left    : f32,
    top     : f32,
    bottom  : f32,
}

Perspective_Data :: struct {
    fov: f32,
    viewport_size: [2]uint,
}

Orthographic_Camera_Descriptor :: struct {
    //using base: Orthographic_Data,
    right   : f32,
    left    : f32,
    top     : f32,
    bottom  : f32,
    near: f32,
    far: f32,
}

Perspective_Camera_Descriptor :: struct {
    //using base: Perspective_Data,
    fov: f32,
    viewport_size: [2]uint,
    near: f32,
    far: f32,
}

@(private="file")
Mode_Data :: struct #raw_union {
    orthographic_data: Orthographic_Data,
    perspective_data: Perspective_Data,
}

Camera_Component :: struct {
    using mode_data: Mode_Data,

    mode: Camera_Mode,
    near: f32,
    far: f32,
}

camera_init_perspective :: proc(camera: ^Camera_Component, desc: Perspective_Camera_Descriptor) {
    camera.perspective_data.fov = desc.fov
    camera.perspective_data.viewport_size = desc.viewport_size
    camera.mode = .Perspective
    camera.near = desc.near
    camera.far = desc.far
}

camera_init_orthographic :: proc(camera: ^Camera_Component, desc: Orthographic_Camera_Descriptor) {
    camera.orthographic_data.right  = desc.right
    camera.orthographic_data.left   = desc.left
    camera.orthographic_data.top    = desc.top
    camera.orthographic_data.bottom = desc.bottom
    camera.mode = .Orthographic
    camera.near = desc.near
    camera.far = desc.far
}

camera_init :: proc { camera_init_perspective, camera_init_orthographic }

camera_get_proj_matrix :: proc(camera: Camera_Component) -> glsl.mat4 {
    if camera.mode == .Orthographic do return glsl.mat4Ortho3d(
        camera.orthographic_data.left,
        camera.orthographic_data.right,
        camera.orthographic_data.bottom,
        camera.orthographic_data.top,
        camera.near,
        camera.far,
    )
    else do return glsl.mat4Perspective(
        camera.perspective_data.fov,
        (f32)(camera.perspective_data.viewport_size.x) / (f32)(camera.perspective_data.viewport_size.y),
        camera.near,
        camera.far,
    )
}

camera_get_view_matrix :: pr_get_view_matrix

camera_apply_full :: proc(camera: Camera_Component, position: Position_Component, rotation: Rotation_Component, shader: ^gfx.Shader) {
    view := camera_get_view_matrix(position, rotation)

    gfx.shader_uniform_mat4f(shader, gfx.VIEW_UNIFORM_NAME, &view)

    camera_apply_proj(camera, shader)
}

camera_apply_proj :: proc(camera: Camera_Component, shader: ^gfx.Shader) {
    proj := camera_get_proj_matrix(camera)

    gfx.shader_uniform_mat4f(shader, gfx.PROJ_UNIFORM_NAME, &proj)
}

camera_apply :: proc { camera_apply_full, camera_apply_proj }

camera_get_fov :: proc(camera: Camera_Component) -> f32 {
    return camera.perspective_data.fov
}

camera_resize_view_port :: proc(camera: ^Camera_Component, viewport_size: [2]uint) {
    camera.perspective_data.viewport_size = viewport_size
}

camera_set_fov :: proc(camera: ^Camera_Component, fov: f32) {
    camera.perspective_data.fov = fov
}
