#pragma once

#include <bx/math.h>

#include "position.h"
#include "rotation.h"
#include "scale.h"

#include "components.h"

namespace vx {

struct Transform {
    Position position;
    Rotation rotation;
    Scale scale = { 1.0f, 1.0f, 1.0f };

    VX_COMPONENT_EXPORT(Position, position);
    VX_COMPONENT_EXPORT(Rotation, rotation);
    VX_COMPONENT_EXPORT(Scale,    scale);
};

inline Transform transform_new(Position p, Rotation r, Scale s) {
    return Transform { p, r, s };
}

inline void to_matrix(const Transform* t, f32* matrix) {
    f32 translation[16];
    f32 rotation[16];
    f32 scaling[16];

    to_matrix(&t->position, translation);
    to_matrix(&t->rotation, rotation);
    to_matrix(&t->scale,    scaling);

    f32 rotation_x_scaling[16];
    bx::mtxMul(rotation_x_scaling, rotation, scaling);
    bx::mtxMul(matrix, rotation_x_scaling, translation);
}

};
