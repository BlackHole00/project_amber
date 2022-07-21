#include "transform.h"

#include "../../../utils/math/vector_helpers.h"

namespace vx {

void position_move(Position* position, bx::Vec3 offset, f32 amount) {
    *position = bx::mul(offset, amount);
}

void position_move_cross(Position* position, const Rotation* rotation, bx::Vec3 cross_vector, f32 amount) {
    bx::Vec3 tmp = bx::normalize(bx::cross(*position, cross_vector));
    position_move(position, tmp, amount);
}

void position_move_forward(Position* position, const Rotation* rotation, f32 amount = 1.0f) {
    position_move(position, *rotation, amount);
}

void position_move_backward(Position* position, const Rotation* rotation, f32 amount = 1.0f) {
    position_move(position, *rotation, -amount);
}

void position_move_right(Position* position, const Rotation* rotation, f32 amount = 1.0f) {
    /**  @todo: Do not use HMM_Vec3(0.0f, 1.0f, 0.0f) as world top, calculate it using the rotation.    */
    position_move_cross(position, rotation, bx::Vec3 { 0.0f, 1.0f, 0.0f }, amount);
}

void position_move_left(Position* position, const Rotation* rotation, f32 amount = 1.0f) {
    position_move_right(position, rotation, -amount);
}

void rotation_rotate(Rotation* rotation, bx::Vec3 offset, f32 amount = 1.0f) {
    bx::Vec3 tmp = bx::mul(offset, amount);
    *rotation = bx::add(*rotation, tmp);

    if(rotation->y > 89.0f) {
        rotation->y = 89.0f;
    }
    else if(rotation->y < -89.0f) {
        rotation->y = -89.0f;
    }
}

bx::Vec3 rotation_direction(const Rotation* rotation) {
    return vx::direction(*rotation);
}

};
