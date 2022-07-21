#pragma once

#include <vx_utils/types.h>
#include <bgfx/bgfx.h>

#include "transform/transform.h"

namespace vx {

enum class CameraMode {
    Orthographic,
    Perspective
};

struct CameraComponent {
    CameraMode mode;

    union {
        struct {
            f32 fov;
        };
        struct {
            f32 right;
            f32 left;
            f32 top;
            f32 bottom;
        };
    };

    Vec2<i32> viewport_size;
    f32 near;
    f32 far;

    CameraComponent() {}
};

CameraComponent camera_perspective_new(f32 fov, Vec2<i32> viewport_size, f32 near, f32 far);
CameraComponent camera_orthographic_new(f32 right, f32 left, f32 top, f32 bottom, Vec2<i32> viewport_size, f32 near, f32 far);
void camera_get_proj_matrix(const CameraComponent* camera, f32* matrix);
void camera_apply(const CameraComponent* camera, const PositionComponent* position, const RotationComponent* rotation, bgfx::ViewId id);

};
