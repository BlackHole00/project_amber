#include "camera.h"

#include <bx/math.h>

namespace vx {

CameraComponent camera_perspective_new(f32 fov, Vec2<i32> viewport_size, f32 near, f32 far) {
    CameraComponent c;

    c.mode = CameraMode::Perspective;
    c.fov = fov;
    c.viewport_size = viewport_size;
    c.near = near;
    c.far = far;

    return c;
}

CameraComponent camera_orthographic_new(f32 right, f32 left, f32 top, f32 bottom, Vec2<i32> viewport_size, f32 near, f32 far) {
    CameraComponent c;

    c.mode = CameraMode::Orthographic;
    c.right = right;
    c.left = left;
    c.top = top;
    c.bottom = bottom;
    c.viewport_size = viewport_size;
    c.near = near;
    c.far = far;

    return c;
}

void camera_get_proj_matrix(const CameraComponent* camera, f32* matrix) {
    if (camera->mode == CameraMode::Orthographic) {
        bx::mtxProj(matrix, camera->top, camera->bottom, camera->left, camera->right, camera->near, camera->far, bgfx::getCaps()->homogeneousDepth);
    } else {
        bx::mtxProj(matrix, camera->fov, (f32)(camera->viewport_size.width) / (f32)(camera->viewport_size.height), camera->near, camera->far, bgfx::getCaps()->homogeneousDepth);
    }
}

void camera_apply(const CameraComponent* camera, const PositionComponent* position, const RotationComponent* rotation, bgfx::ViewId id) {
    float mtx_proj[16];
    float mtx_view[16];

    position_rotation_get_view_matrix(position, rotation, mtx_view);
    camera_get_proj_matrix(camera, mtx_proj);

    bgfx::setViewTransform(id, mtx_view, mtx_proj);
}

};
