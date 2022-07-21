#pragma once

#include <vx_utils/types.h>
#include <bx/math.h>

#include "position.h"
#include "rotation.h"

namespace vx {
    void position_move(Position* position, bx::Vec3 offset, f32 amount = 1.0f);
    void position_move_cross(Position* position, const Rotation* rotation, bx::Vec3 cross_vector, f32 amount = 1.0f);
    void position_move_forward(Position* position, const Rotation* rotation, f32 amount = 1.0f);
    void position_move_backward(Position* position, const Rotation* rotation, f32 amount = 1.0f);
    void position_move_right(Position* position, const Rotation* rotation, f32 amount = 1.0f);
    void position_move_left(Position* position, const Rotation* rotation, f32 amount = 1.0f);

    void rotation_rotate(Rotation* rotation, bx::Vec3 offset, f32 amount = 1.0f);
    bx::Vec3 rotation_direction(const Rotation* rotation);
};