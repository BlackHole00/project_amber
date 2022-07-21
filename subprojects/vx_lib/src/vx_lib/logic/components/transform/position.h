#pragma once

#include <vx_utils/types.h>
#include <bx/math.h>
#include "rotation.h"
#include "../helpers/vector_builder.h"

namespace vx {

VX_BUILD_VEC3(Position)

inline Position position_new(f32 x, f32 y, f32 z) {
    return Position { x, y, z };
}

inline void to_matrix(const Position* t, f32* matrix) {
    bx::mtxTranslate(matrix, t->x, t->y, t->z);
}

};

#include "../helpers/vector_builder_undef.h"
