#pragma once

#include <vx_utils/types.h>
#include <bx/math.h>

#include "position.h"
#include "rotation.h"
#include "scale.h"

namespace vx {
    void position_move(PositionComponent* position, bx::Vec3 offset, f32 amount = 1.0f);
    void position_move_cross(PositionComponent* position, const RotationComponent* rotation, bx::Vec3 cross_vector, f32 amount = 1.0f);
    void position_move_forward(PositionComponent* position, const RotationComponent* rotation, f32 amount = 1.0f);
    void position_move_backward(PositionComponent* position, const RotationComponent* rotation, f32 amount = 1.0f);
    void position_move_right(PositionComponent* position, const RotationComponent* rotation, f32 amount = 1.0f);
    void position_move_left(PositionComponent* position, const RotationComponent* rotation, f32 amount = 1.0f);

    void rotation_rotate(RotationComponent* rotation, bx::Vec3 offset, f32 amount = 1.0f);
    bx::Vec3 rotation_direction(const RotationComponent* rotation);

    void position_rotation_get_view_matrix(const PositionComponent* position, const RotationComponent* rotation, f32* matrix);

    void to_matrix(const PositionComponent* position, const RotationComponent* rotation, const ScaleComponent* scale, f32* matrix);
    void to_matrix(const PositionComponent* position, const RotationComponent* rotation, f32* matrix);
};