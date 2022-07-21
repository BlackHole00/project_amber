#include "transform.h"

#include "../../../utils/math/vector_helpers.h"

namespace vx {

void position_move(PositionComponent* position, bx::Vec3 offset, f32 amount) {
    *position = bx::mul(offset, amount);
}

void position_move_cross(PositionComponent* position, const RotationComponent* rotation, bx::Vec3 cross_vector, f32 amount) {
    bx::Vec3 tmp = bx::normalize(bx::cross(*position, cross_vector));
    position_move(position, tmp, amount);
}

void position_move_forward(PositionComponent* position, const RotationComponent* rotation, f32 amount) {
    position_move(position, *rotation, amount);
}

void position_move_backward(PositionComponent* position, const RotationComponent* rotation, f32 amount) {
    position_move(position, *rotation, -amount);
}

void position_move_right(PositionComponent* position, const RotationComponent* rotation, f32 amount) {
    /**  @todo: Do not use HMM_Vec3(0.0f, 1.0f, 0.0f) as world top, calculate it using the rotation.    */
    position_move_cross(position, rotation, bx::Vec3 { 0.0f, 1.0f, 0.0f }, amount);
}

void position_move_left(PositionComponent* position, const RotationComponent* rotation, f32 amount) {
    position_move_right(position, rotation, -amount);
}

void rotation_rotate(RotationComponent* rotation, bx::Vec3 offset, f32 amount) {
    bx::Vec3 tmp = bx::mul(offset, amount);
    *rotation = bx::add(*rotation, tmp);

    if(rotation->y > 89.0f) {
        rotation->y = 89.0f;
    }
    else if(rotation->y < -89.0f) {
        rotation->y = -89.0f;
    }
}

bx::Vec3 rotation_direction(const RotationComponent* rotation) {
    return vx::direction(*rotation);
}

void position_rotation_get_view_matrix(const PositionComponent* position, const RotationComponent* rotation, f32* matrix) {
    bx::mtxLookAt(matrix, *position, bx::add(*rotation, rotation_direction(rotation)));
}

void to_matrix(const PositionComponent* position, const RotationComponent* rotation, const ScaleComponent* scale, f32* matrix) {
    f32 mtx_translation[16];
    f32 mtx_rotation[16];
    f32 mtx_scaling[16];

    to_matrix(position, mtx_translation);
    to_matrix(rotation, mtx_rotation);
    to_matrix(scale,    mtx_scaling);

    f32 mtx_rotation_x_scaling[16];
    bx::mtxMul(mtx_rotation_x_scaling, mtx_rotation, mtx_scaling);
    bx::mtxMul(matrix, mtx_rotation_x_scaling, mtx_translation);
}

void to_matrix(const PositionComponent* position, const RotationComponent* rotation, f32* matrix) {
    f32 mtx_translation[16];
    f32 mtx_rotation[16];

    to_matrix(position, mtx_translation);
    to_matrix(rotation, mtx_rotation);

    bx::mtxMul(matrix, mtx_rotation, mtx_translation);
}

};
