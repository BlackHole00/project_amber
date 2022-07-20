#pragma once

#include <vx_utils/types.h>
#include "helpers/vector_builder.h"

namespace vx {

VX_BUILD_VEC3(f32, Rotation)

inline Rotation rotation_new(f32 x, f32 y, f32 z) {
    return Rotation { x, y, z };
}

inline void to_matrix(const Rotation* r, f32* matrix) {
    bx::mtxFromQuaternion(matrix, bx::fromEuler(bx::Vec3(r->x, r->y, r->z)));
}

};

#include "helpers/vector_builder_undef.h"
